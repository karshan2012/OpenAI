from __future__ import annotations

import json
from collections import defaultdict
from collections.abc import AsyncIterator, Callable
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from sse_starlette.sse import EventSourceResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..db.models import Chat, Message, ToolCall
from ..db.session import get_session
from ..schemas.chat import (
    ChatBase,
    ChatCreateRequest,
    ChatDetail,
    ChatListResponse,
    MessageBase,
    MessageCreateRequest,
)
from ..services.auth import AuthenticatedUser, get_current_user
from ..services.llm import stream_completion
from ..services.tools import registry

router = APIRouter(prefix="/v1/chats", tags=["chats"])


async def _get_chat(session: AsyncSession, chat_id: int, user_id: int) -> Chat:
    chat = await session.get(Chat, chat_id)
    if not chat or chat.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Chat not found")
    return chat


@router.get("", response_model=ChatListResponse)
async def list_chats(
    current_user: AuthenticatedUser = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> ChatListResponse:
    result = await session.execute(select(Chat).where(Chat.user_id == current_user.id).order_by(Chat.updated_at.desc()))
    chats = result.scalars().all()
    return ChatListResponse(chats=chats)


@router.post("", response_model=ChatBase, status_code=status.HTTP_201_CREATED)
async def create_chat(
    payload: ChatCreateRequest,
    current_user: AuthenticatedUser = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> Chat:
    chat = Chat(user_id=current_user.id, title=payload.title or "New chat")
    session.add(chat)
    await session.commit()
    await session.refresh(chat)
    return chat


@router.get("/{chat_id}", response_model=ChatDetail)
async def get_chat(
    chat_id: int,
    current_user: AuthenticatedUser = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> ChatDetail:
    chat = await _get_chat(session, chat_id, current_user.id)
    await session.refresh(chat)
    return chat


@router.delete("/{chat_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_chat(
    chat_id: int,
    current_user: AuthenticatedUser = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> None:
    chat = await _get_chat(session, chat_id, current_user.id)
    await session.delete(chat)
    await session.commit()


@router.get("/{chat_id}/messages", response_model=list[MessageBase])
async def list_messages(
    chat_id: int,
    current_user: AuthenticatedUser = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> list[Message]:
    chat = await _get_chat(session, chat_id, current_user.id)
    await session.refresh(chat)
    return chat.messages


@router.post("/{chat_id}/messages")
async def create_message(
    chat_id: int,
    payload: MessageCreateRequest,
    current_user: AuthenticatedUser = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    chat = await _get_chat(session, chat_id, current_user.id)
    user_message = Message(chat_id=chat.id, role="user", content=payload.message)
    session.add(user_message)
    await session.flush()

    async def event_iterator() -> AsyncIterator[dict[str, str]]:
        assistant_text_parts: list[str] = []
        tool_call_buffers: dict[int, dict[str, str]] = defaultdict(lambda: {"name": "", "arguments": ""})
        usage: dict | None = None
        history = await session.execute(select(Message).where(Message.chat_id == chat.id).order_by(Message.created_at))
        history_messages = [
            {"role": message.role, "content": message.content}
            for message in history.scalars().all()
        ]
        history_messages.append({"role": "user", "content": payload.message})

        async for chunk in stream_completion(
            messages=history_messages,
            model=payload.model,
            temperature=payload.temperature,
            tools_enabled=payload.tools_enabled,
        ):
            choice = chunk.get("choices", [{}])[0]
            delta = choice.get("delta") or {}
            if "content" in delta:
                assistant_text_parts.append(delta["content"])
                yield {"event": "token", "data": json.dumps({"delta": delta["content"]})}
            if tool_calls := delta.get("tool_calls"):
                for tool in tool_calls:
                    index = tool.get("index", 0)
                    name = tool.get("function", {}).get("name", "")
                    arguments_fragment = tool.get("function", {}).get("arguments", "")
                    buffer = tool_call_buffers[index]
                    buffer["name"] = name
                    buffer["arguments"] += arguments_fragment
            if usage is None and "usage" in chunk:
                usage = chunk["usage"]
            finish_reason = choice.get("finish_reason")
            if finish_reason == "tool_calls":
                for buffer in tool_call_buffers.values():
                    arguments_json = json.loads(buffer["arguments"] or "{}")
                    tool_call = ToolCall(
                        message_id=user_message.id,
                        tool_name=buffer["name"],
                        arguments=arguments_json,
                        status="pending",
                    )
                    session.add(tool_call)
                    await session.flush()
                    yield {
                        "event": "tool_call",
                        "data": json.dumps({"name": buffer["name"], "arguments": arguments_json}),
                    }
                    result = await registry.execute(buffer["name"], arguments_json, current_user.id)
                    tool_call.result = result
                    tool_call.status = "success"
                    tool_message = Message(
                        chat_id=chat.id,
                        role="tool",
                        content=json.dumps(result),
                    )
                    session.add(tool_message)
                    await session.flush()
                    yield {
                        "event": "tool_result",
                        "data": json.dumps({"name": buffer["name"], "result": result}),
                    }
            if finish_reason == "stop":
                break
        assistant_text = "".join(assistant_text_parts).strip()
        if assistant_text:
            assistant_message = Message(chat_id=chat.id, role="assistant", content=assistant_text)
            session.add(assistant_message)
        chat.updated_at = datetime.utcnow()
        await session.commit()
        yield {"event": "done", "data": json.dumps({"usage": usage or {}})}

    return EventSourceResponse(event_iterator(), media_type="text/event-stream")

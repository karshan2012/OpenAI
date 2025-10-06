from __future__ import annotations

import asyncio
import json
from collections.abc import AsyncIterator
from typing import Any

import httpx

from ..config import get_settings
from .tools import registry

settings = get_settings()

OPENAI_URL = "https://api.openai.com/v1/chat/completions"


async def _mock_stream(message: str) -> AsyncIterator[dict[str, Any]]:
    words = message.split()
    for word in words:
        await asyncio.sleep(0)
        yield {"choices": [{"delta": {"content": f"{word} "}}]}
    yield {"choices": [{"finish_reason": "stop"}], "usage": {"prompt_tokens": 10, "completion_tokens": len(words)}}


async def stream_completion(messages: list[dict[str, Any]], model: str, temperature: float, tools_enabled: bool) -> AsyncIterator[dict[str, Any]]:
    if settings.feature_use_mock_llm or not settings.openai_api_key:
        last_user = next((m["content"] for m in reversed(messages) if m["role"] == "user"), "")
        async for chunk in _mock_stream(f"Echo: {last_user}"):
            yield chunk
        return

    headers = {
        "Authorization": f"Bearer {settings.openai_api_key}",
        "Content-Type": "application/json",
    }
    payload: dict[str, Any] = {
        "model": model,
        "messages": messages,
        "temperature": temperature,
        "stream": True,
    }
    if tools_enabled:
        payload["tools"] = registry.list_openai_schemas()
    async with httpx.AsyncClient(timeout=None) as client:
        async with client.stream("POST", OPENAI_URL, json=payload, headers=headers) as response:
            response.raise_for_status()
            async for line in response.aiter_lines():
                if not line:
                    continue
                if line.startswith("data: "):
                    data = line.removeprefix("data: ")
                    if data == "[DONE]":
                        break
                    chunk = json.loads(data)
                    yield chunk

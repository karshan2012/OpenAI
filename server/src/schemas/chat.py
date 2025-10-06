from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, EmailStr


class UserBase(BaseModel):
    id: int
    email: EmailStr
    created_at: datetime

    class Config:
        from_attributes = True


class ChatBase(BaseModel):
    id: int
    title: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class MessageBase(BaseModel):
    id: int
    chat_id: int
    role: str
    content: str
    tokens_in: Optional[int]
    tokens_out: Optional[int]
    created_at: datetime

    class Config:
        from_attributes = True


class ToolCallBase(BaseModel):
    id: int
    tool_name: str
    arguments: dict
    result: Optional[dict]
    status: str

    class Config:
        from_attributes = True


class ChatDetail(ChatBase):
    messages: List[MessageBase]


class MessageCreateRequest(BaseModel):
    message: str
    model: str
    temperature: float = 0.7
    tools_enabled: bool = True


class ChatCreateRequest(BaseModel):
    title: Optional[str] = None


class ChatListResponse(BaseModel):
    chats: List[ChatBase]

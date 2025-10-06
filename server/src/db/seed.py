import asyncio

from sqlalchemy import select

from .models import Chat, Message, User
from .session import AsyncSessionLocal


async def seed() -> None:
    async with AsyncSessionLocal() as session:
        result = await session.execute(select(User).where(User.email == "demo@pocketgpt.app"))
        user = result.scalar_one_or_none()
        if not user:
            user = User(email="demo@pocketgpt.app")
            session.add(user)
            await session.flush()
        result = await session.execute(select(Chat).where(Chat.user_id == user.id))
        chat = result.scalar_one_or_none()
        if not chat:
            chat = Chat(user_id=user.id, title="Welcome to PocketGPT")
            session.add(chat)
            await session.flush()
            session.add_all(
                [
                    Message(chat_id=chat.id, role="system", content="You are PocketGPT, a helpful assistant."),
                    Message(chat_id=chat.id, role="assistant", content="Hi! Ask me anything about your day."),
                ]
            )
        await session.commit()


if __name__ == "__main__":
    asyncio.run(seed())

from datetime import datetime

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..db.models import User
from ..db.session import get_session
from ..schemas.auth import MagicLinkRequest, TokenResponse
from ..services.auth import create_access_token

router = APIRouter(prefix="/v1/auth", tags=["auth"])


@router.post("/magic-link")
async def send_magic_link(
    payload: MagicLinkRequest,
    session: AsyncSession = Depends(get_session),
) -> dict[str, str]:
    result = await session.execute(select(User).where(User.email == payload.email))
    user = result.scalar_one_or_none()
    if not user:
        user = User(email=payload.email)
        session.add(user)
        await session.commit()
        await session.refresh(user)
    token, expires_at = create_access_token(str(user.id))
    # In production, send email with tokenized link
    return {"message": "Magic link sent", "preview_token": token}


@router.get("/callback", response_model=TokenResponse)
async def auth_callback(code: str, session: AsyncSession = Depends(get_session)) -> TokenResponse:
    result = await session.execute(select(User).where(User.email == code))
    user = result.scalar_one_or_none()
    if not user:
        user = User(email=code)
        session.add(user)
        await session.commit()
        await session.refresh(user)
    token, expires_at = create_access_token(str(user.id))
    return TokenResponse(access_token=token, expires_at=expires_at)

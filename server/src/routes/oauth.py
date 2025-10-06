from urllib.parse import urlencode

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from ..config import get_settings
from ..db.models import ProviderAccount
from ..db.session import get_session
from ..services.auth import AuthenticatedUser, get_current_user

settings = get_settings()

router = APIRouter(prefix="/v1/oauth", tags=["oauth"])


def _build_redirect(base: str, params: dict[str, str]) -> str:
    return f"{base}?{urlencode(params)}"


@router.get("/google/start")
async def google_start() -> dict[str, str]:
    params = {
        "client_id": settings.google_client_id or "demo-client",
        "response_type": "code",
        "scope": "https://www.googleapis.com/auth/calendar.events",
        "redirect_uri": "pocketgpt://oauth/google",
        "access_type": "offline",
        "prompt": "consent",
    }
    return {"authorization_url": _build_redirect("https://accounts.google.com/o/oauth2/v2/auth", params)}


@router.get("/google/callback")
async def google_callback(
    code: str,
    current_user: AuthenticatedUser = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> dict[str, str]:
    account = ProviderAccount(
        user_id=current_user.id,
        provider="google",
        access_token=f"mock-token-{code}",
        refresh_token="mock-refresh",
        scopes="https://www.googleapis.com/auth/calendar.events",
    )
    session.add(account)
    await session.commit()
    return {"status": "connected"}


@router.get("/notion/start")
async def notion_start() -> dict[str, str]:
    params = {
        "client_id": settings.notion_client_id or "demo-client",
        "response_type": "code",
        "owner": "user",
        "redirect_uri": "pocketgpt://oauth/notion",
    }
    return {"authorization_url": _build_redirect("https://api.notion.com/v1/oauth/authorize", params)}


@router.get("/notion/callback")
async def notion_callback(
    code: str,
    current_user: AuthenticatedUser = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> dict[str, str]:
    account = ProviderAccount(
        user_id=current_user.id,
        provider="notion",
        access_token=f"mock-token-{code}",
        refresh_token="mock-refresh",
        scopes="databases:read,databases:write",
    )
    session.add(account)
    await session.commit()
    return {"status": "connected"}

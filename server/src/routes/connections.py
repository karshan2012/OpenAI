from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..db.models import ProviderAccount
from ..db.session import get_session
from ..services.auth import AuthenticatedUser, get_current_user

router = APIRouter(prefix="/v1/connections", tags=["connections"])


@router.get("")
async def list_connections(
    current_user: AuthenticatedUser = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> dict[str, bool]:
    result = await session.execute(
        select(ProviderAccount.provider).where(ProviderAccount.user_id == current_user.id)
    )
    providers = {row[0] for row in result.all()}
    return {
        "google_calendar": "google" in providers,
        "notion": "notion" in providers,
    }

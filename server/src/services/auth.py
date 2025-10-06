from datetime import datetime, timedelta, timezone
from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

from ..config import get_settings

security = HTTPBearer()
settings = get_settings()


class AuthenticatedUser(dict):
    @property
    def id(self) -> int:
        return int(self.get("sub"))


async def get_current_user(credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)]) -> AuthenticatedUser:
    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        if "sub" not in payload:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    except JWTError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token") from exc
    return AuthenticatedUser(payload)


def create_access_token(subject: str, expires_minutes: int | None = None) -> tuple[str, datetime]:
    expire = datetime.now(timezone.utc) + timedelta(minutes=expires_minutes or settings.access_token_exp_minutes)
    payload = {"sub": subject, "exp": expire}
    encoded_jwt = jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)
    return encoded_jwt, expire

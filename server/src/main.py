from __future__ import annotations

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import structlog

from .config import get_settings
from .routes import auth, chats, connections, oauth

settings = get_settings()
logger = structlog.get_logger(__name__)

app = FastAPI(title="PocketGPT API", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"]
    ,
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(chats.router)
app.include_router(connections.router)
app.include_router(oauth.router)


@app.get("/health", tags=["health"])
async def health() -> dict[str, str]:
    logger.info("healthcheck")
    return {"status": "ok"}

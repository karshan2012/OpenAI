"""Agent wrappers that interface with application connectors."""
from __future__ import annotations

from typing import Dict, Protocol

from .base import Agent, AgentResponse


class AppConnector(Protocol):
    """Protocol that application connectors must implement."""

    name: str

    def invoke(self, message: str) -> str:
        ...


class ApplicationAgent(Agent):
    """Generic agent that delegates to an application connector."""

    def __init__(self, connector: AppConnector) -> None:
        super().__init__(name=f"{connector.name}_agent")
        self._connector = connector

    def handle(self, message: str, context: Dict[str, str] | None = None) -> AgentResponse:
        reasoning = [f"Forwarding request to {self._connector.name} application."]
        content = self._connector.invoke(message)
        reasoning.append("Received response from external application.")
        metadata = {"application": self._connector.name}
        return AgentResponse(content=content, reasoning=reasoning, metadata=metadata)


"""Routing agent that decides which specialist should handle the request."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Dict

from .base import Agent, AgentResponse


@dataclass(frozen=True)
class RoutingDecision:
    """Outcome of routing a message to a specialist agent."""

    target: str
    confidence: float
    rationale: str


class RouterAgent(Agent):
    """Light-weight heuristic router that selects the next agent."""

    def __init__(self) -> None:
        super().__init__(name="router")

    def handle(self, message: str, context: Dict[str, str] | None = None) -> AgentResponse:
        lowered = message.lower()
        reasoning = ["Analyzing message to determine best agent."]

        if any(keyword in lowered for keyword in {"weather", "temperature", "forecast"}):
            decision = RoutingDecision(
                target="weather_app",
                confidence=0.85,
                rationale="Weather-related keywords detected."
            )
        elif any(keyword in lowered for keyword in {"calculate", "sum", "difference", "multiply", "divide", "plus", "minus", "*", "/"}):
            decision = RoutingDecision(
                target="calculator_app",
                confidence=0.8,
                rationale="Mathematical intent inferred from message."
            )
        else:
            decision = RoutingDecision(
                target="qa_agent",
                confidence=0.6,
                rationale="Defaulting to knowledge-base question answering."
            )

        reasoning.append(decision.rationale)
        content = f"Route to {decision.target} (confidence={decision.confidence:.0%})."
        metadata = {"decision": decision}
        return AgentResponse(content=content, reasoning=reasoning, metadata=metadata)


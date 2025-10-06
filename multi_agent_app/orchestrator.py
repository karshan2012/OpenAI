"""High level orchestrator that mimics ChatGPT-style Q&A via multiple agents."""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Dict, List

from .agents.app_agent import ApplicationAgent
from .agents.base import AgentResponse
from .agents.qa_agent import QAAgent
from .agents.router_agent import RouterAgent
from .apps.calculator import CalculatorApp
from .apps.weather import WeatherApp
from .knowledge_base import KnowledgeBase


@dataclass
class ConversationTurn:
    """Records a turn in the conversation."""

    role: str
    content: str


@dataclass
class MultiAgentChatGPT:
    """ChatGPT-like orchestrator coordinating specialized agents."""

    knowledge_base: KnowledgeBase
    router: RouterAgent = field(default_factory=RouterAgent)
    calculator_agent: ApplicationAgent = field(default_factory=lambda: ApplicationAgent(CalculatorApp()))
    weather_agent: ApplicationAgent = field(default_factory=lambda: ApplicationAgent(WeatherApp()))
    qa_agent: QAAgent | None = None
    history: List[ConversationTurn] = field(default_factory=list)

    def __post_init__(self) -> None:
        if self.qa_agent is None:
            self.qa_agent = QAAgent(self.knowledge_base)

    def ask(self, message: str) -> Dict[str, object]:
        """Process a user question and generate a response."""

        self.history.append(ConversationTurn(role="user", content=message))

        router_response = self.router.handle(message)
        reasoning_steps = [
            {"agent": self.router.name, "reasoning": router_response.reasoning},
        ]

        decision = router_response.metadata["decision"]
        agent_response: AgentResponse
        if decision.target == "calculator_app":
            agent_response = self.calculator_agent.handle(message)
        elif decision.target == "weather_app":
            agent_response = self.weather_agent.handle(message)
        else:
            assert self.qa_agent is not None
            agent_response = self.qa_agent.handle(message)

        reasoning_steps.append({"agent": agent_response.metadata.get("application", decision.target) if agent_response.metadata else decision.target,
                                 "reasoning": agent_response.reasoning})

        self.history.append(ConversationTurn(role="assistant", content=agent_response.content))
        return {
            "answer": agent_response.content,
            "reasoning": reasoning_steps,
            "history": [turn.__dict__ for turn in self.history],
        }

    def reset(self) -> None:
        """Clear the conversation history."""

        self.history.clear()


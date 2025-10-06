"""Knowledge base backed Q&A agent."""
from __future__ import annotations

from difflib import get_close_matches
from typing import Dict, List, Tuple

from ..knowledge_base import KnowledgeBase
from .base import Agent, AgentResponse


class QAAgent(Agent):
    """Answer questions using a lightweight knowledge base."""

    def __init__(self, knowledge_base: KnowledgeBase) -> None:
        super().__init__(name="qa_agent")
        self._knowledge_base = knowledge_base

    def handle(self, message: str, context: Dict[str, str] | None = None) -> AgentResponse:
        reasoning: List[str] = ["Consulting knowledge base for potential answers."]
        question, answer = self._match_question(message)

        if answer is None:
            reasoning.append("No confident match found. Providing fallback response.")
            content = (
                "I could not find an exact answer, but I recommend clarifying the question "
                "or providing more details."
            )
            return AgentResponse(content=content, reasoning=reasoning)

        reasoning.append(f"Matched stored question: '{question}'.")
        content = answer
        return AgentResponse(content=content, reasoning=reasoning)

    def _match_question(self, message: str) -> Tuple[str | None, str | None]:
        """Find the closest question in the knowledge base."""

        candidates = self._knowledge_base.questions
        matches = get_close_matches(message, candidates, n=1, cutoff=0.5)
        if not matches:
            return None, None
        question = matches[0]
        answer = self._knowledge_base.get_answer(question)
        return question, answer


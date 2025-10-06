"""Simple in-memory knowledge base for the Q&A agent."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List


@dataclass
class KnowledgeItem:
    question: str
    answer: str


class KnowledgeBase:
    """Collection of question and answer pairs."""

    def __init__(self, items: Iterable[KnowledgeItem] | None = None) -> None:
        self._items: Dict[str, str] = {}
        if items is not None:
            for item in items:
                self.add_item(item)

    def add_item(self, item: KnowledgeItem) -> None:
        self._items[item.question] = item.answer

    @property
    def questions(self) -> List[str]:
        return list(self._items.keys())

    def get_answer(self, question: str) -> str | None:
        return self._items.get(question)


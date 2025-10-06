"""Utility helpers for the multi-agent application."""
from __future__ import annotations

import json
from pathlib import Path
from typing import Iterable

from .knowledge_base import KnowledgeBase, KnowledgeItem


def load_knowledge_base(path: str | Path) -> KnowledgeBase:
    """Load the knowledge base from a JSON file."""

    file_path = Path(path)
    with file_path.open("r", encoding="utf-8") as file:
        raw_items: Iterable[dict[str, str]] = json.load(file)

    items = [KnowledgeItem(question=item["question"], answer=item["answer"]) for item in raw_items]
    return KnowledgeBase(items=items)


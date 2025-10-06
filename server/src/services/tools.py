from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Any, Awaitable, Callable

from fastapi import HTTPException
from pydantic import BaseModel, Field, ValidationError

from ..db.models import CalendarItem, NotionPage

ToolExecutor = Callable[[dict, int], Awaitable[dict]]


class CreateCalendarEventArgs(BaseModel):
    title: str
    description: str | None = None
    start_iso: datetime
    end_iso: datetime
    attendees_email: list[str] = Field(default_factory=list)


class ListCalendarEventsArgs(BaseModel):
    time_min_iso: datetime
    time_max_iso: datetime


class CreateNotionPageArgs(BaseModel):
    database_id: str
    title: str
    properties_json: dict


class SearchNotionArgs(BaseModel):
    query: str


@dataclass
class ToolDefinition:
    name: str
    description: str
    parameters_model: type[BaseModel]
    executor: ToolExecutor


class ToolRegistry:
    def __init__(self) -> None:
        self._tools: dict[str, ToolDefinition] = {}

    def register(self, tool: ToolDefinition) -> None:
        self._tools[tool.name] = tool

    def list_openai_schemas(self) -> list[dict[str, Any]]:
        schemas: list[dict[str, Any]] = []
        for tool in self._tools.values():
            schemas.append(
                {
                    "type": "function",
                    "function": {
                        "name": tool.name,
                        "description": tool.description,
                        "parameters": tool.parameters_model.model_json_schema(),
                    },
                }
            )
        return schemas

    async def execute(self, name: str, args: dict, user_id: int) -> dict[str, Any]:
        if name not in self._tools:
            raise HTTPException(status_code=400, detail=f"Unknown tool {name}")
        tool = self._tools[name]
        try:
            validated = tool.parameters_model(**args)
        except ValidationError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        return await tool.executor(validated.model_dump(mode="json"), user_id)


registry = ToolRegistry()


async def _mock_create_calendar_event(args: dict, user_id: int) -> dict[str, Any]:
    return {
        "eventId": f"mock-event-{user_id}",
        "title": args["title"],
        "start": args["start_iso"],
        "end": args["end_iso"],
        "attendees": args.get("attendees_email", []),
    }


async def _mock_list_calendar_events(args: dict, user_id: int) -> dict[str, Any]:
    return {
        "events": [
            {
                "title": "Design Sync",
                "start": args["time_min_iso"],
                "end": args["time_max_iso"],
            }
        ]
    }


async def _mock_create_notion_page(args: dict, user_id: int) -> dict[str, Any]:
    return {
        "pageId": f"mock-page-{user_id}",
        "title": args["title"],
        "url": "https://www.notion.so/mock",
    }


async def _mock_search_notion(args: dict, user_id: int) -> dict[str, Any]:
    return {
        "results": [
            {
                "title": "Demo Task",
                "url": "https://www.notion.so/mock-demo",
            }
        ]
    }


registry.register(
    ToolDefinition(
        name="create_calendar_event",
        description="Create a Google Calendar event",
        parameters_model=CreateCalendarEventArgs,
        executor=_mock_create_calendar_event,
    )
)
registry.register(
    ToolDefinition(
        name="list_calendar_events",
        description="List Google Calendar events",
        parameters_model=ListCalendarEventsArgs,
        executor=_mock_list_calendar_events,
    )
)
registry.register(
    ToolDefinition(
        name="create_notion_page",
        description="Create a Notion page",
        parameters_model=CreateNotionPageArgs,
        executor=_mock_create_notion_page,
    )
)
registry.register(
    ToolDefinition(
        name="search_notion",
        description="Search Notion",
        parameters_model=SearchNotionArgs,
        executor=_mock_search_notion,
    )
)

# PocketGPT Backend

PocketGPT is a FastAPI backend that powers the PocketGPT iOS client with streaming ChatGPT-style responses, persistent conversations, and integrations with Google Calendar and Notion.

## Features

- Magic link authentication with JWT issuance
- Chat and message APIs with Server-Sent Events (SSE) streaming
- Tool/function calling for Google Calendar and Notion
- PostgreSQL persistence with Alembic migrations
- Redis-ready configuration for rate limiting and background jobs
- Mock LLM mode for offline development
- Seed data with a demo user and conversation
- Docker Compose for local development
- GitHub Actions workflow for linting and tests

## Getting Started

### Prerequisites

- Python 3.11+
- Docker & Docker Compose
- Make

### Environment Variables

Copy the sample environment file and adjust values as needed:

```bash
cp .env.example .env
```

### Local Development

Install dependencies and run the API locally:

```bash
pip install -e .
uvicorn src.main:app --reload
```

### Database

Apply migrations and seed the database:

```bash
alembic upgrade head
python -m src.db.seed
```

### Docker Compose

To start Postgres, Redis, and the API:

```bash
docker compose up --build
```

### Running Tests

```bash
pytest
```

### Mock LLM Mode

Set `FEATURE_USE_MOCK_LLM=true` to use the built-in echo streaming provider.

### Postman Collection

Import `postman/pocketgpt.postman_collection.json` into Postman or Bruno to explore all endpoints.

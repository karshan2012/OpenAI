.PHONY: db dev test lint

DB_URL ?= $(shell grep -E '^DATABASE_URL' infra/.env.example | cut -d'=' -f2-)

psql_cmd = PGPASSWORD=$$(echo $(DB_URL) | cut -d':' -f3 | cut -d'@' -f1) psql $(DB_URL)

init_db:
psql $(DB_URL) -c "CREATE DATABASE chatgpt_analytics" || true

db:
psql $(DB_URL) -f db/migrations/001_schema.sql
psql $(DB_URL) -f db/migrations/002_rls.sql
psql $(DB_URL) -f db/views.sql
psql $(DB_URL) -f db/migrations/003_seed.sql
psql $(DB_URL) -f db/migrations/004_completeness.sql
psql $(DB_URL) -f db/views_completeness.sql

install:
npm install

web-dev:
cd app/web && npm run dev

api-dev:
cd app/api && npm run dev

dev:
npm run dev --workspaces

test:
npm run test --workspaces

lint:
npm run lint --workspaces

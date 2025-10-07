# ChatGPT Analytics & BI Platform

A full-stack analytics platform for a ChatGPT-style product. The monorepo contains a Next.js web experience, an Express-based API with Postgres access controls, SQL migrations, realistic seed data, and automated coverage checks.

## Monorepo Structure

```
/app
  /api          # Express API with JWT auth, RBAC, RLS scoping
  /web          # Next.js 14 App Router UI with Tailwind, shadcn/ui, Recharts
/db
  /migrations   # schema, RLS, seed, completeness SQL files
  views*.sql    # analytical views
/tests
  /api          # Vitest coverage + policy tests
  /coverage     # Coverage validation tests
/app/web/tests  # Playwright smoke scaffolding
/infra          # Environment templates
coverage.json   # Coverage matrix consumed by UI & tests
```

## Prerequisites

* Node.js 20+
* npm 9+
* PostgreSQL 15+

## Initial Setup

1. Install dependencies:

   ```bash
   npm install
   npm install --prefix app/api
   npm install --prefix app/web
   ```

2. Configure environment variables by copying `infra/.env.example` to `infra/.env` and adjusting values as needed. The same file can be symlinked into `app/api` for local development.

3. Provision the database and load demo data:

   ```bash
   make db
   ```

   This applies the schema, RLS policies, base/completeness views, and seeds 30 days of analytics metrics plus hourly usage.

## Running the Stack

* API: `npm run dev --prefix app/api` (listens on port `3001` by default)
* Web UI: `npm run dev --prefix app/web` (Next.js dev server on `3000`)
* Combined (two terminals): use the above commands. A Makefile helper (`make dev`) fans out to workspace scripts if desired.

Set `API_BASE_URL` in `app/web/.env.local` (or shell) so the web tier can reach the API (defaults to `http://localhost:3001/api`).

The API expects a JWT (`Authorization: Bearer ...`) signed with the configured public key. Claims must include:

```json
{
  "roles": ["analyst"],
  "account_ids": ["10000000-0000-0000-0000-000000000001"]
}
```

For quick prototyping you can store a mock JWT in `localStorage` under the `demo_jwt` key; the UI guard component consumes it client-side while the API continues to enforce RBAC/RLS.

### Access Control Overview

* **RBAC** – `bi.dashboard_role_access` maps roles to dashboards; `authz.assertDashboardAccess` checks the mapping per request.
* **RLS** – `authz.can_see_account` and `SET LOCAL app.account_ids` restrict analytics tables to the caller’s accounts. Every `fact_*` table has enforced policies in `002_rls.sql`.

### Timezone Handling

* All timestamps are stored in UTC.
* UI renders display values in **Asia/Kolkata (UTC+05:30)** via locale formatting helpers.

## Testing & Coverage

```bash
make test
```

* Root Vitest suite checks coverage metadata and validates SQL policy files.
* `app/api` exposes additional Vitest tests (placeholder) and lint targets.
* `app/web` ships with a Playwright smoke scaffold so you can extend UI automation. The default test asserts environment wiring and is safe to run headless.

`coverage.json` drives automated validation (Vitest), the API catalog (`/api/_catalog`), and the Coverage dashboard inside the UI. Update it whenever you add new metrics or mark scenarios as not applicable.

## Adding Metrics & Dashboards

1. **Schema** – extend `/db/migrations/001_schema.sql` (or `004_completeness.sql`) with new tables/dimensions.
2. **Policies** – append to `002_rls.sql` so RLS stays enforced.
3. **Seeds** – update `003_seed.sql`/`004_completeness.sql` to keep demo data fresh.
4. **Views** – add to `db/views*.sql` for reusable aggregations.
5. **API** – register a new handler in `app/api/src/routes/dashboards.ts`, wire RBAC slug, and expose it through `_catalog`.
6. **UI** – create a Next.js route, reuse shared components (`FilterBar`, `KPIStat`, `ChartCard`, `DataTable`, `Guard`) and hook up drill-through navigation.
7. **Coverage** – extend `coverage.json` + tests to keep end-to-end mapping complete.

## Extending RBAC

* Insert new roles into `authz.roles` and map them via `bi.dashboard_role_access`.
* Update `/app/web/components/navigation.tsx` and the `Guard` wrappers to surface the right dashboards client-side.
* Extend tests in `tests/api` to validate catalog/coverage changes as you evolve access control.

## Demo Data Highlights

* 30 days of daily aggregates across usage, latency, cost, safety, experiments, prompts, features, and more.
* Hourly usage fact for heatmaps/drill-downs.
* Experiments, prompt templates, releases, and platform version health seeded with realistic values.
* Multiple accounts and role mappings to exercise RBAC + RLS end-to-end.

Happy analyzing!

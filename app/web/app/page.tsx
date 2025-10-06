import { createParams } from '../lib/params';
import { getOverview, getLatency, getCosts, getSafety } from '../lib/api';
import { FilterBar } from '../components/filter-bar';
import { Guard } from '../components/guard';
import { KPIStat } from '../components/kpi-stat';
import { ChartCard } from '../components/chart-card';
import { formatCurrency, formatNumber } from '../lib/format';

export default async function Page({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const [overview, latency, costs, safety] = await Promise.all([
    getOverview(params),
    getLatency(params),
    getCosts(params),
    getSafety(params)
  ]);

  const latest = overview[0] ?? {};
  return (
    <Guard roles={['executive', 'ops', 'analyst', 'admin']}>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-semibold text-slate-900">Executive Overview</h1>
            <p className="text-sm text-slate-500">Key health metrics for your ChatGPT experience.</p>
          </div>
        </div>
        <FilterBar />
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <KPIStat label="DAU" value={formatNumber(latest.dau)} />
          <KPIStat label="Sessions" value={formatNumber(latest.sessions)} />
          <KPIStat label="Messages" value={formatNumber(latest.messages)} />
          <KPIStat label="Cost" value={formatCurrency(latest.cost_usd)} />
        </div>
        <div className="grid gap-6 lg:grid-cols-2">
          <ChartCard
            title="Usage trend"
            description="Daily active users over time"
            data={overview.map((row) => ({ ...row, date_key: row.date_key }))}
            dataKey="dau"
            categoryKey="date_key"
            type="area"
          />
          <ChartCard
            title="P90 latency"
            description="Latency per day"
            data={latency.map((row) => ({ ...row, date_key: row.date_key }))}
            dataKey="p90_ms"
            categoryKey="date_key"
            type="area"
          />
        </div>
        <div className="grid gap-6 lg:grid-cols-2">
          <ChartCard
            title="Cost by model"
            description="Total cost per day"
            data={costs}
            dataKey="cost_usd"
            categoryKey="model_name"
            type="bar"
          />
          <ChartCard
            title="Safety triggers"
            description="Triggered safety events"
            data={safety}
            dataKey="triggered"
            categoryKey="name"
            type="bar"
          />
        </div>
        <p className="text-xs text-slate-500">
          * Timestamps rendered in Asia/Kolkata. Source data stored in UTC.
        </p>
      </div>
    </Guard>
  );
}

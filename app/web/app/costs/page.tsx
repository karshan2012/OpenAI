import { createParams } from '../../lib/params';
import { getCosts, getCostPerSuccess } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { ChartCard } from '../../components/chart-card';
import { DataTable } from '../../components/data-table';
import { formatCurrency } from '../../lib/format';

export default async function CostsPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const [costs, costPerSuccess] = await Promise.all([getCosts(params), getCostPerSuccess(params)]);
  return (
    <Guard roles={['analyst', 'pm', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Cost & Tokens</h1>
        <FilterBar />
        <ChartCard
          title="Daily cost by model"
          data={costs}
          dataKey="cost_usd"
          categoryKey="model_name"
          type="bar"
        />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'model_name', header: 'Model' },
            { key: 'total_tokens', header: 'Tokens' },
            { key: 'cache_hits', header: 'Cache Hits' },
            { key: 'cost_usd', header: 'Cost', render: (value) => formatCurrency(value) }
          ]}
          rows={costs}
        />
        <ChartCard
          title="Cost per session"
          data={costPerSuccess}
          dataKey="cost_per_session"
          categoryKey="model_name"
          type="bar"
        />
      </div>
    </Guard>
  );
}

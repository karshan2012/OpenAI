import { createParams } from '../../lib/params';
import { getPrompts } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { ChartCard } from '../../components/chart-card';
import { DataTable } from '../../components/data-table';

export default async function PromptsPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const prompts = await getPrompts(params);
  return (
    <Guard roles={['pm', 'analyst', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Prompt Templates</h1>
        <FilterBar />
        <ChartCard
          title="Template usage"
          data={prompts}
          dataKey="uses"
          categoryKey="template_name"
          type="bar"
        />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'template_name', header: 'Template' },
            { key: 'uses', header: 'Uses' },
            { key: 'avg_quality', header: 'Avg Quality' },
            { key: 'avg_latency_ms', header: 'Avg Latency (ms)' },
            { key: 'avg_cost_usd', header: 'Avg Cost (USD)' }
          ]}
          rows={prompts}
        />
      </div>
    </Guard>
  );
}

import { createParams } from '../../lib/params';
import { getTools } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { ChartCard } from '../../components/chart-card';
import { DataTable } from '../../components/data-table';

export default async function ToolsPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const tools = await getTools(params);
  return (
    <Guard roles={['ops', 'analyst', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Tool Health</h1>
        <FilterBar />
        <ChartCard
          title="Tool success rate"
          data={tools.map((row) => ({ ...row, success_rate: Number(row.success ?? 0) / Math.max(Number(row.calls ?? 1), 1) }))}
          dataKey="success_rate"
          categoryKey="tool_name"
          type="bar"
        />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'tool_name', header: 'Tool' },
            { key: 'calls', header: 'Calls' },
            { key: 'success', header: 'Success' },
            { key: 'failed', header: 'Failed' },
            { key: 'avg_duration_ms', header: 'Avg Duration (ms)' }
          ]}
          rows={tools}
        />
      </div>
    </Guard>
  );
}

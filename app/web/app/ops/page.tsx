import { createParams } from '../../lib/params';
import { getLatency, getRegionsLatency, getErrors } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { ChartCard } from '../../components/chart-card';
import { DataTable } from '../../components/data-table';

export default async function OpsPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const [latency, regionalLatency, errors] = await Promise.all([
    getLatency(params),
    getRegionsLatency(params),
    getErrors(params)
  ]);
  return (
    <Guard roles={['ops', 'analyst', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Operations</h1>
        <FilterBar />
        <ChartCard
          title="Latency by platform"
          data={latency}
          dataKey="p90_ms"
          categoryKey="platform"
          type="bar"
        />
        <ChartCard
          title="Latency by region"
          data={regionalLatency}
          dataKey="p90_ms"
          categoryKey="region_name"
          type="bar"
        />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'class', header: 'Error Class' },
            { key: 'code', header: 'Code' },
            { key: 'source', header: 'Source' },
            { key: 'occurrences', header: 'Occurrences' }
          ]}
          rows={errors}
        />
      </div>
    </Guard>
  );
}

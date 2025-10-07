import { createParams } from '../../lib/params';
import { getExperiments } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { DataTable } from '../../components/data-table';

export default async function ExperimentsPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const experiments = await getExperiments(params);
  return (
    <Guard roles={['pm', 'analyst', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Experiments</h1>
        <FilterBar />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'experiment_name', header: 'Experiment' },
            { key: 'variant_name', header: 'Variant' },
            { key: 'exposures', header: 'Exposures' },
            { key: 'conversions', header: 'Conversions' },
            { key: 'conv_rate', header: 'Conversion Rate' },
            { key: 'avg_cost_usd', header: 'Avg Cost (USD)' },
            { key: 'avg_latency_ms', header: 'Avg Latency (ms)' }
          ]}
          rows={experiments}
        />
      </div>
    </Guard>
  );
}

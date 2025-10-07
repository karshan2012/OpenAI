import { createParams } from '../../lib/params';
import { getQuality } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { ChartCard } from '../../components/chart-card';
import { DataTable } from '../../components/data-table';

export default async function QualityPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const quality = await getQuality(params);
  return (
    <Guard roles={['analyst', 'pm', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Model Quality</h1>
        <FilterBar />
        <ChartCard
          title="Average quality score"
          description="Aggregated by model and eval"
          data={quality}
          dataKey="avg_score"
          categoryKey="model_name"
          type="bar"
        />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'model_name', header: 'Model' },
            { key: 'eval_name', header: 'Evaluation' },
            { key: 'n', header: 'Runs' },
            { key: 'avg_score', header: 'Avg Score' },
            { key: 'ftr_rate', header: 'FTR %' }
          ]}
          rows={quality}
        />
      </div>
    </Guard>
  );
}

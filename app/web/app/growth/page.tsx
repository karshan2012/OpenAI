import { createParams } from '../../lib/params';
import { getGrowth } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { DataTable } from '../../components/data-table';

export default async function GrowthPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const growth = await getGrowth(params);
  return (
    <Guard roles={['pm', 'analyst', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Growth & Retention</h1>
        <FilterBar />
        <DataTable
          columns={[
            { key: 'cohort_week', header: 'Cohort Week' },
            { key: 'week_n', header: 'Week' },
            { key: 'retained_users', header: 'Retained Users' },
            { key: 'retention_pct', header: 'Retention %' }
          ]}
          rows={growth}
        />
      </div>
    </Guard>
  );
}

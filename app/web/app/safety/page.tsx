import { createParams } from '../../lib/params';
import { getSafety } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { ChartCard } from '../../components/chart-card';
import { DataTable } from '../../components/data-table';

export default async function SafetyPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const safety = await getSafety(params);
  return (
    <Guard roles={['safety', 'analyst', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Safety & Compliance</h1>
        <FilterBar />
        <ChartCard
          title="Safety triggers by category"
          data={safety}
          dataKey="triggered"
          categoryKey="name"
          type="bar"
        />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'name', header: 'Category' },
            { key: 'triggered', header: 'Triggered' },
            { key: 'blocked', header: 'Blocked' },
            { key: 'transformed', header: 'Transformed' },
            { key: 'review_required', header: 'Review Required' }
          ]}
          rows={safety}
        />
      </div>
    </Guard>
  );
}

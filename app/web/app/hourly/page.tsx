import { createParams } from '../../lib/params';
import { getHourly } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { DataTable } from '../../components/data-table';

export default async function HourlyPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const hourly = await getHourly(params);
  return (
    <Guard roles={['analyst', 'ops', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Hourly Usage</h1>
        <FilterBar />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'hour', header: 'Hour' },
            { key: 'platform', header: 'Platform' },
            { key: 'dau_hourly', header: 'Hourly DAU' },
            { key: 'messages', header: 'Messages' }
          ]}
          rows={hourly}
        />
      </div>
    </Guard>
  );
}

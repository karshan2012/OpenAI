import { createParams } from '../../../lib/params';
import { getBiUsage } from '../../../lib/api';
import { FilterBar } from '../../../components/filter-bar';
import { Guard } from '../../../components/guard';
import { DataTable } from '../../../components/data-table';

export default async function BiUsagePage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const usage = await getBiUsage(params);
  return (
    <Guard roles={['admin', 'analyst']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Dashboard Usage</h1>
        <FilterBar />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'title', header: 'Dashboard' },
            { key: 'views', header: 'Views' },
            { key: 'unique_viewers', header: 'Unique Viewers' },
            { key: 'exports', header: 'Exports' }
          ]}
          rows={usage}
        />
      </div>
    </Guard>
  );
}

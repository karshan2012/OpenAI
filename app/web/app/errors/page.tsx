import { createParams } from '../../lib/params';
import { getErrors } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { DataTable } from '../../components/data-table';

export default async function ErrorsPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const errors = await getErrors(params);
  return (
    <Guard roles={['ops', 'support', 'analyst', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Error Taxonomy</h1>
        <FilterBar />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'class', header: 'Class' },
            { key: 'code', header: 'Code' },
            { key: 'source', header: 'Source' },
            { key: 'occurrences', header: 'Occurrences' },
            { key: 'sessions_impacted', header: 'Sessions Impacted' },
            { key: 'users_impacted', header: 'Users Impacted' }
          ]}
          rows={errors}
        />
      </div>
    </Guard>
  );
}

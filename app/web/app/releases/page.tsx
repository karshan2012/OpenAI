import { getReleases } from '../../lib/api';
import { Guard } from '../../components/guard';
import { DataTable } from '../../components/data-table';

export default async function ReleasesPage() {
  const releases = await getReleases();
  return (
    <Guard roles={['admin', 'pm', 'analyst']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Release Timeline</h1>
        <DataTable
          columns={[
            { key: 'version', header: 'Version' },
            { key: 'released_at', header: 'Released At' }
          ]}
          rows={releases}
        />
      </div>
    </Guard>
  );
}

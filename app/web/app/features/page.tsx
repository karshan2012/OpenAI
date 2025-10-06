import { createParams } from '../../lib/params';
import { getFeatures } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { DataTable } from '../../components/data-table';
import { ChartCard } from '../../components/chart-card';

export default async function FeaturesPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const features = await getFeatures(params);
  return (
    <Guard roles={['pm', 'analyst', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Feature Adoption</h1>
        <FilterBar />
        <ChartCard
          title="Feature adoption"
          data={features}
          dataKey="active_users_feature"
          categoryKey="feature_name"
          type="bar"
        />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'feature_name', header: 'Feature' },
            { key: 'users', header: 'Users' },
            { key: 'events', header: 'Events' },
            { key: 'active_users_feature', header: 'Active Users' }
          ]}
          rows={features}
        />
      </div>
    </Guard>
  );
}

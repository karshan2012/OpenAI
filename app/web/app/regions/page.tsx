import { createParams } from '../../lib/params';
import { getRegionCache, getRegionsLatency, getPlatformHealth } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { ChartCard } from '../../components/chart-card';
import { DataTable } from '../../components/data-table';

export default async function RegionsPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const [cache, latency, platformHealth] = await Promise.all([getRegionCache(params), getRegionsLatency(params), getPlatformHealth(params)]);
  return (
    <Guard roles={['ops', 'analyst', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Regional Performance</h1>
        <FilterBar />
        <ChartCard
          title="Latency by region"
          data={latency}
          dataKey="p90_ms"
          categoryKey="region_name"
          type="bar"
        />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'model_name', header: 'Model' },
            { key: 'region_name', header: 'Region' },
            { key: 'p90_ms', header: 'P90 (ms)' },
            { key: 'p99_ms', header: 'P99 (ms)' }
          ]}
          rows={latency}
        />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'model_id', header: 'Model' },
            { key: 'region_id', header: 'Region' },
            { key: 'requests', header: 'Requests' },
            { key: 'cache_hits', header: 'Cache Hits' },
            { key: 'hit_rate', header: 'Hit Rate' }
          ]}
          rows={cache}
        />
        <DataTable
          columns={[
            { key: 'date_key', header: 'Date' },
            { key: 'version_id', header: 'Version ID' },
            { key: 'crashes', header: 'Crashes' },
            { key: 'errors', header: 'Errors' },
            { key: 'sessions', header: 'Sessions' },
            { key: 'error_rate', header: 'Error Rate' }
          ]}
          rows={platformHealth}
        />
      </div>
    </Guard>
  );
}

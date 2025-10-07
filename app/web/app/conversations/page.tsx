import Link from 'next/link';
import { createParams } from '../../lib/params';
import { getSessions } from '../../lib/api';
import { FilterBar } from '../../components/filter-bar';
import { Guard } from '../../components/guard';
import { DataTable } from '../../components/data-table';
import { formatNumber } from '../../lib/format';

export default async function ConversationsPage({ searchParams }: { searchParams: Record<string, string | string[] | undefined> }) {
  const params = createParams(searchParams);
  const sessions = await getSessions(params);
  return (
    <Guard roles={['analyst', 'support', 'ops', 'admin']}>
      <div className="space-y-6">
        <h1 className="text-2xl font-semibold text-slate-900">Conversations</h1>
        <FilterBar />
        <DataTable
          columns={[
            { key: 'session_id', header: 'Session', render: (value) => <Link href={`/session/${value}`}>{value as string}</Link> },
            { key: 'started_at', header: 'Started' },
            { key: 'ended_at', header: 'Ended' },
            { key: 'turns', header: 'Turns', render: (value) => formatNumber(value) },
            { key: 'avg_latency_ms', header: 'Avg Latency (ms)', render: (value) => formatNumber(value) },
            { key: 'total_tokens', header: 'Tokens', render: (value) => formatNumber(value) },
            { key: 'success', header: 'Success' }
          ]}
          rows={sessions}
        />
      </div>
    </Guard>
  );
}

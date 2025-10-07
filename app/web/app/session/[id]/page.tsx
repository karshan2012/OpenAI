import { notFound } from 'next/navigation';
import { getSession } from '../../../lib/api';
import { Guard } from '../../../components/guard';
import { formatNumber } from '../../../lib/format';

export default async function SessionDetail({ params }: { params: { id: string } }) {
  const session = await getSession(params.id).catch(() => null);
  if (!session) {
    notFound();
  }
  const started = new Date(session.started_at).toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' });
  const ended = session.ended_at
    ? new Date(session.ended_at).toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' })
    : '—';
  const cost = Number(session.cost_usd ?? 0).toFixed(3);
  return (
    <Guard roles={['analyst', 'support', 'ops', 'admin']}>
      <div className="space-y-4">
        <h1 className="text-2xl font-semibold text-slate-900">Session {session.session_id}</h1>
        <div className="grid gap-4 sm:grid-cols-2">
          <div className="rounded-lg border border-border bg-white/80 p-4 shadow-sm">
            <h2 className="text-sm font-semibold text-slate-600">Timing</h2>
            <dl className="mt-2 space-y-1 text-sm text-slate-700">
              <div className="flex justify-between"><dt>Started</dt><dd>{started}</dd></div>
              <div className="flex justify-between"><dt>Ended</dt><dd>{ended}</dd></div>
              <div className="flex justify-between"><dt>Turns</dt><dd>{formatNumber(session.turns)}</dd></div>
            </dl>
          </div>
          <div className="rounded-lg border border-border bg-white/80 p-4 shadow-sm">
            <h2 className="text-sm font-semibold text-slate-600">Performance</h2>
            <dl className="mt-2 space-y-1 text-sm text-slate-700">
              <div className="flex justify-between"><dt>Avg latency</dt><dd>{formatNumber(session.avg_latency_ms)} ms</dd></div>
              <div className="flex justify-between"><dt>Total tokens</dt><dd>{formatNumber(session.total_tokens)}</dd></div>
              <div className="flex justify-between"><dt>Cost</dt><dd>${cost}</dd></div>
              <div className="flex justify-between"><dt>Tool calls</dt><dd>{formatNumber(session.tool_calls)}</dd></div>
              <div className="flex justify-between"><dt>Safety flags</dt><dd>{formatNumber(session.safety_flags)}</dd></div>
              <div className="flex justify-between"><dt>Success</dt><dd>{String(session.success)}</dd></div>
            </dl>
          </div>
        </div>
      </div>
    </Guard>
  );
}

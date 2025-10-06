'use client';

import { ReactNode, useId, useMemo } from 'react';
import {
  ResponsiveContainer,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  BarChart,
  Bar,
  ReferenceDot,
} from 'recharts';

export type ChartType = 'area' | 'bar';

interface ChartCardProps {
  title: string;
  description?: string;
  data: Record<string, unknown>[];
  dataKey: string;
  categoryKey: string;
  type?: ChartType;
  actions?: ReactNode;
  valueFormatter?: (value: unknown) => string;
}

interface ChartTooltipProps {
  active?: boolean;
  label?: string | number;
  payload?: { value: unknown; color: string; name?: string }[];
  valueFormatter?: ChartCardProps['valueFormatter'];
}

function ChartTooltip({ active, label, payload, valueFormatter }: ChartTooltipProps) {
  if (!active || !payload?.length) {
    return null;
  }

  const formatter = valueFormatter ?? ((value: unknown) => (value ?? '').toString());

  return (
    <div className="min-w-[160px] rounded-xl border border-slate-200 bg-white/95 p-3 text-xs shadow-lg">
      <div className="mb-1 font-semibold text-slate-700">{label}</div>
      {payload.map((entry, index) => (
        <div key={index} className="flex items-center justify-between gap-4 text-slate-600">
          <span className="flex items-center gap-2">
            <span className="inline-flex h-2.5 w-2.5 rounded-full" style={{ backgroundColor: entry.color }} />
            {entry.name ?? 'Value'}
          </span>
          <span className="font-medium text-slate-900">{formatter(entry.value)}</span>
        </div>
      ))}
    </div>
  );
}

export function ChartCard({
  title,
  description,
  data,
  dataKey,
  categoryKey,
  type = 'area',
  actions,
  valueFormatter,
}: ChartCardProps) {
  const gradientId = useId();
  const chartData = useMemo(() => data ?? [], [data]);

  return (
    <div className="flex w-full flex-col rounded-3xl border border-slate-200/70 bg-gradient-to-br from-white via-white to-slate-50/80 p-6 shadow-lg shadow-slate-200/60 transition-colors hover:border-slate-300">
      <div className="flex items-start justify-between gap-4">
        <div>
          <h3 className="text-base font-semibold text-slate-900">{title}</h3>
          {description && <p className="text-sm text-slate-500">{description}</p>}
        </div>
        {actions}
      </div>
      <div className="mt-6 h-72 w-full">
        <ResponsiveContainer width="100%" height="100%">
          {type === 'bar' ? (
            <BarChart data={chartData} barSize={28}>
              <defs>
                <linearGradient id={`${gradientId}-bar`} x1="0" x2="0" y1="0" y2="1">
                  <stop offset="0%" stopColor="#0ea5e9" stopOpacity={0.9} />
                  <stop offset="100%" stopColor="#2563eb" stopOpacity={0.7} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="2 6" stroke="#e2e8f0" vertical={false} />
              <XAxis
                dataKey={categoryKey}
                stroke="#94a3b8"
                tickLine={false}
                axisLine={false}
                fontSize={12}
                padding={{ left: 16, right: 16 }}
              />
              <YAxis stroke="#94a3b8" tickLine={false} axisLine={false} fontSize={12} width={60} />
              <Tooltip content={<ChartTooltip valueFormatter={valueFormatter} />} cursor={{ fill: '#0ea5e914' }} />
              <Bar dataKey={dataKey} fill={`url(#${gradientId}-bar)`} radius={[12, 12, 12, 12]} />
            </BarChart>
          ) : (
            <AreaChart data={chartData} margin={{ top: 10, right: 16, left: 0, bottom: 0 }}>
              <defs>
                <linearGradient id={`${gradientId}-area`} x1="0" x2="0" y1="0" y2="1">
                  <stop offset="0%" stopColor="#2563eb" stopOpacity={0.35} />
                  <stop offset="95%" stopColor="#0ea5e9" stopOpacity={0.05} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="2 6" stroke="#e2e8f0" vertical={false} />
              <XAxis
                dataKey={categoryKey}
                stroke="#94a3b8"
                tickLine={false}
                axisLine={false}
                fontSize={12}
                padding={{ left: 10, right: 10 }}
              />
              <YAxis stroke="#94a3b8" tickLine={false} axisLine={false} fontSize={12} width={60} />
              <Tooltip content={<ChartTooltip valueFormatter={valueFormatter} />} cursor={{ stroke: '#0ea5e9', strokeWidth: 1 }} />
              <Area
                type="monotone"
                dataKey={dataKey}
                stroke="#2563eb"
                strokeWidth={3}
                fill={`url(#${gradientId}-area)`}
                dot={{ r: 4, fill: '#fff', stroke: '#2563eb', strokeWidth: 2 }}
                activeDot={{ r: 6, fill: '#2563eb', stroke: '#fff', strokeWidth: 2 }}
              />
              <ReferenceDot
                ifOverflow="discard"
                x={chartData?.[chartData.length - 1]?.[categoryKey] as string | number | undefined}
                y={chartData?.[chartData.length - 1]?.[dataKey] as number | undefined}
                r={0}
              />
            </AreaChart>
          )}
        </ResponsiveContainer>
      </div>
    </div>
  );
}

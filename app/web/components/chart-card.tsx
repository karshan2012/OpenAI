'use client';

import { ReactNode } from 'react';
import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid, BarChart, Bar } from 'recharts';

export type ChartType = 'area' | 'bar';

interface ChartCardProps {
  title: string;
  description?: string;
  data: Record<string, unknown>[];
  dataKey: string;
  categoryKey: string;
  type?: ChartType;
  actions?: ReactNode;
}

export function ChartCard({ title, description, data, dataKey, categoryKey, type = 'area', actions }: ChartCardProps) {
  return (
    <div className="flex w-full flex-col rounded-xl border border-border bg-white/80 p-4 shadow-sm">
      <div className="flex items-start justify-between gap-4">
        <div>
          <h3 className="text-sm font-semibold text-slate-800">{title}</h3>
          {description && <p className="text-xs text-slate-500">{description}</p>}
        </div>
        {actions}
      </div>
      <div className="mt-4 h-64">
        <ResponsiveContainer width="100%" height="100%">
          {type === 'bar' ? (
            <BarChart data={data} barSize={24}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
              <XAxis dataKey={categoryKey} stroke="#64748b" fontSize={12} />
              <YAxis stroke="#64748b" fontSize={12} width={60} />
              <Tooltip formatter={(value: unknown) => value?.toString()} labelClassName="text-xs" />
              <Bar dataKey={dataKey} fill="#2563eb" radius={[4, 4, 0, 0]} />
            </BarChart>
          ) : (
            <AreaChart data={data}>
              <defs>
                <linearGradient id="area" x1="0" x2="0" y1="0" y2="1">
                  <stop offset="5%" stopColor="#2563eb" stopOpacity={0.6} />
                  <stop offset="95%" stopColor="#2563eb" stopOpacity={0.05} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
              <XAxis dataKey={categoryKey} stroke="#64748b" fontSize={12} />
              <YAxis stroke="#64748b" fontSize={12} width={60} />
              <Tooltip formatter={(value: unknown) => value?.toString()} labelClassName="text-xs" />
              <Area dataKey={dataKey} stroke="#2563eb" fill="url(#area)" strokeWidth={2} />
            </AreaChart>
          )}
        </ResponsiveContainer>
      </div>
    </div>
  );
}

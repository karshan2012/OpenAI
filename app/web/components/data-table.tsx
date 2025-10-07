'use client';

import { ReactNode } from 'react';

interface DataTableProps {
  columns: { key: string; header: string; render?: (value: unknown, row: Record<string, unknown>) => ReactNode }[];
  rows: Record<string, unknown>[];
}

export function DataTable({ columns, rows }: DataTableProps) {
  return (
    <div className="overflow-hidden rounded-xl border border-border bg-white/70 shadow-sm">
      <table className="min-w-full divide-y divide-border text-sm">
        <thead className="bg-slate-50 text-left text-xs uppercase tracking-wide text-slate-500">
          <tr>
            {columns.map((column) => (
              <th key={column.key} className="px-3 py-2 font-medium">
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-border">
          {rows.map((row, idx) => (
            <tr key={idx} className="hover:bg-slate-50">
              {columns.map((column) => (
                <td key={column.key} className="px-3 py-2 text-slate-700">
                  {column.render ? column.render(row[column.key], row) : (row[column.key] as ReactNode)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
      {rows.length === 0 && <div className="p-6 text-center text-sm text-slate-500">No records found.</div>}
    </div>
  );
}

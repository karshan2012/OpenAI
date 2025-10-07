'use client';

import type { Key, ReactNode } from 'react';

export type DataTableColumn<T extends Record<string, unknown>> = {
  key: Extract<keyof T, string>;
  header: string;
  render?: (value: T[Extract<keyof T, string>], row: T) => ReactNode;
};

interface DataTableProps<T extends Record<string, unknown>> {
  columns: DataTableColumn<T>[];
  rows: T[];
  emptyMessage?: string;
  getRowKey?: (row: T, index: number) => Key;
}

export function DataTable<T extends Record<string, unknown>>({
  columns,
  rows,
  emptyMessage = 'No records found.',
  getRowKey
}: DataTableProps<T>) {
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
          {rows.map((row, idx) => {
            const rowKey = getRowKey ? getRowKey(row, idx) : idx;
            return (
              <tr key={rowKey} className="hover:bg-slate-50">
                {columns.map((column) => {
                  const value = row[column.key];
                  return (
                    <td key={column.key} className="px-3 py-2 text-slate-700">
                      {column.render ? column.render(value, row) : (value as ReactNode)}
                    </td>
                  );
                })}
              </tr>
            );
          })}
        </tbody>
      </table>
      {rows.length === 0 && <div className="p-6 text-center text-sm text-slate-500">{emptyMessage}</div>}
    </div>
  );
}

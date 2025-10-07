'use client';

import { usePathname, useRouter, useSearchParams } from 'next/navigation';
import { useMemo } from 'react';
import type { FormEvent } from 'react';

const filters = [
  { key: 'from', label: 'From' },
  { key: 'to', label: 'To' },
  { key: 'model_id', label: 'Model ID' },
  { key: 'platform', label: 'Platform' },
  { key: 'region_id', label: 'Region ID' },
  { key: 'account_id', label: 'Account ID' }
];

export function FilterBar() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const defaultValues = useMemo(() => {
    const entries: Record<string, string> = {};
    filters.forEach(({ key }) => {
      const value = searchParams.get(key);
      if (value) entries[key] = value;
    });
    return entries;
  }, [searchParams]);

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    const params = new URLSearchParams(searchParams.toString());
    filters.forEach(({ key }) => {
      const value = formData.get(key)?.toString() ?? '';
      if (value) params.set(key, value);
      else params.delete(key);
    });
    router.push(`${pathname}?${params.toString()}`);
  }

  function onReset() {
    router.push(pathname);
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-wrap items-end gap-4 rounded-lg border border-border bg-white/80 p-4 shadow-sm">
      {filters.map(({ key, label }) => (
        <label key={key} className="flex flex-col text-xs font-medium text-slate-600">
          {label}
          <input
            name={key}
            defaultValue={defaultValues[key] ?? ''}
            className="mt-1 rounded-md border border-border px-2 py-1 text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </label>
      ))}
      <div className="flex items-center gap-2">
        <button type="submit" className="rounded-md bg-blue-600 px-3 py-1 text-sm text-white shadow hover:bg-blue-700">
          Apply
        </button>
        <button type="button" onClick={onReset} className="rounded-md border border-border px-3 py-1 text-sm text-slate-600">
          Reset
        </button>
      </div>
    </form>
  );
}

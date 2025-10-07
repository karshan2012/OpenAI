'use client';

import { ReactNode } from 'react';
import { useUser } from '../lib/use-user';

export function Guard({ roles, children }: { roles: string[]; children: ReactNode }) {
  const { user } = useUser();
  if (!user) {
    return <div className="rounded-lg border border-dashed border-border p-4 text-sm text-slate-500">Authenticate to view this page.</div>;
  }
  const allowed = user.roles.some((role) => roles.includes(role));
  if (!allowed) {
    return <div className="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-600">You do not have access to this dashboard.</div>;
  }
  return <>{children}</>;
}

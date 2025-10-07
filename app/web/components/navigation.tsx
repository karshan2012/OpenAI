'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import clsx from 'clsx';

const navItems = [
  { href: '/', label: 'Overview' },
  { href: '/quality', label: 'Quality' },
  { href: '/conversations', label: 'Conversations' },
  { href: '/ops', label: 'Operations' },
  { href: '/tools', label: 'Tools' },
  { href: '/safety', label: 'Safety' },
  { href: '/costs', label: 'Costs' },
  { href: '/growth', label: 'Growth' },
  { href: '/prompts', label: 'Prompts' },
  { href: '/experiments', label: 'Experiments' },
  { href: '/features', label: 'Features' },
  { href: '/errors', label: 'Errors' },
  { href: '/regions', label: 'Regions' },
  { href: '/hourly', label: 'Hourly' },
  { href: '/admin/bi-usage', label: 'BI Usage' },
  { href: '/releases', label: 'Releases' },
  { href: '/coverage', label: 'Coverage' }
];

export function Navigation() {
  const pathname = usePathname();
  return (
    <nav className="w-60 border-r border-border bg-white/60 backdrop-blur">
      <div className="p-4 text-xl font-semibold">ChatGPT BI</div>
      <ul className="space-y-1 px-2 pb-4">
        {navItems.map((item) => {
          const active = pathname === item.href || (item.href !== '/' && pathname.startsWith(item.href));
          return (
            <li key={item.href}>
              <Link
                className={clsx(
                  'flex items-center rounded-md px-3 py-2 text-sm transition-colors',
                  active ? 'bg-blue-50 text-blue-600' : 'text-slate-600 hover:bg-slate-100'
                )}
                href={item.href}
              >
                {item.label}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}

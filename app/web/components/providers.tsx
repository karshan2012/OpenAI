'use client';

import { ThemeProvider } from 'next-themes';
import { ReactNode } from 'react';
import { UserProvider } from '../lib/use-user';

export function Providers({ children }: { children: ReactNode }) {
  return (
    <ThemeProvider attribute="class" enableSystem>
      <UserProvider>{children}</UserProvider>
    </ThemeProvider>
  );
}

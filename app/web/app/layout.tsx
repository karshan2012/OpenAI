import './globals.css';
import type { Metadata } from 'next';
import { ReactNode } from 'react';
import { Providers } from '../components/providers';
import { Navigation } from '../components/navigation';

export const metadata: Metadata = {
  title: 'ChatGPT Analytics Platform',
  description: 'Analytics & BI for ChatGPT-style product'
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="min-h-screen bg-background text-foreground">
        <Providers>
          <div className="flex min-h-screen">
            <Navigation />
            <main className="flex-1 overflow-y-auto p-6 space-y-6">{children}</main>
          </div>
        </Providers>
      </body>
    </html>
  );
}

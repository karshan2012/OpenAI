import { describe, it, expect } from 'vitest';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

describe('RLS policy script', () => {
  const here = dirname(fileURLToPath(import.meta.url));
  const sql = readFileSync(resolve(here, '../../db/migrations/002_rls.sql'), 'utf8');
  it('defines can_see_account function', () => {
    expect(sql).toContain('authz.can_see_account');
    expect(sql).toContain('ROW LEVEL SECURITY');
  });
  it('enables policies for key tables', () => {
    ['fact_daily_usage', 'fact_daily_latency', 'fact_daily_cost'].forEach((table) => {
      expect(sql).toContain(`ALTER TABLE analytics.${table}`);
      expect(sql).toContain(`CREATE POLICY`);
    });
  });
});

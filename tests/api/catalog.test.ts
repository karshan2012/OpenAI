import { describe, it, expect } from 'vitest';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const coveragePath = resolve(dirname(fileURLToPath(import.meta.url)), '../../coverage.json');
const coverage = JSON.parse(readFileSync(coveragePath, 'utf8')) as Record<string, any>;

describe('coverage catalog', () => {
  it('has entries for each required area', () => {
    const required = [
      'usage.sessions',
      'quality.evals',
      'latency.reliability',
      'cost.tokens',
      'safety.compliance',
      'tools.integrations',
      'growth.retention',
      'prompts.templates',
      'experiments.flags',
      'errors.incidents',
      'geo.version',
      'bi.usage',
      'releases.annotations'
    ];
    required.forEach((key) => {
      expect(coverage).toHaveProperty(key);
      const entry = (coverage as Record<string, any>)[key];
      expect(entry.status).toBeTruthy();
      expect(entry.tables.length).toBeGreaterThan(0);
      expect(entry.endpoints.length).toBeGreaterThan(0);
      expect(entry.components.length).toBeGreaterThan(0);
      expect(entry.drill).toBeTruthy();
    });
  });
});

import { Pool, PoolClient } from 'pg';
import { DATABASE_URL } from './config.js';

type ScopedClient = PoolClient & { setAccountScope: (accountIds: string[]) => Promise<void> };

export const pool = new Pool({ connectionString: DATABASE_URL });

export async function withScopedClient<T>(accountIds: string[], callback: (client: ScopedClient) => Promise<T>): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query("SET LOCAL timezone TO 'UTC'");
    await client.query("SET LOCAL app.account_ids = $1::uuid[]", [accountIds]);
    const result = await callback(Object.assign(client, {
      setAccountScope: async (ids: string[]) => {
        await client.query("SET LOCAL app.account_ids = $1::uuid[]", [ids]);
      }
    }));
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

export async function query<T>(text: string, params: unknown[] = []): Promise<T[]> {
  const { rows } = await pool.query<T>(text, params);
  return rows;
}

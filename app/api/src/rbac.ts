import { PoolClient } from 'pg';

export async function assertDashboardAccess(client: PoolClient, dashboardSlug: string, roles: string[]) {
  if (!dashboardSlug) return;
  const { rows } = await client.query<{ allowed: boolean }>(
    `SELECT EXISTS (
        SELECT 1
        FROM bi.dashboards d
        JOIN bi.dashboard_role_access dra ON dra.dashboard_id = d.dashboard_id
        JOIN authz.roles r ON r.role_id = dra.role_id
        WHERE d.slug = $1 AND dra.can_view = true AND r.role_name = ANY($2::text[])
    ) AS allowed`,
    [dashboardSlug, roles]
  );
  if (!rows[0]?.allowed) {
    throw Object.assign(new Error('Forbidden'), { statusCode: 403 });
  }
}

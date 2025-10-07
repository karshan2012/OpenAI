import { Router, type Response } from 'express';
import { z } from 'zod';
import { withScopedClient } from '../db.js';
import { assertDashboardAccess } from '../rbac.js';
import { AuthenticatedRequest } from '../auth.js';

const dateRangeSchema = z.object({
  from: z.string().optional(),
  to: z.string().optional()
});

function buildDateFilter(column: string, parsed: z.infer<typeof dateRangeSchema>) {
  const conditions: string[] = [];
  const values: (string | Date)[] = [];
  if (parsed.from) {
    conditions.push(`${column} >= $${conditions.length + 1}`);
    values.push(parsed.from);
  }
  if (parsed.to) {
    conditions.push(`${column} <= $${conditions.length + 1}`);
    values.push(parsed.to);
  }
  const clause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const normalized = clause ? clause.replace(/^WHERE\s*/i, '').trim() : '';
  return { clause, normalized, values };
}

function combineWhere(base: string, extras: string[]): string {
  const parts = [base, ...extras].filter((part) => part && part.length > 0);
  return parts.length ? `WHERE ${parts.join(' AND ')}` : '';
}

export const dashboardsRouter = Router();

async function handleQuery(
  req: AuthenticatedRequest,
  res: Response,
  slug: string,
  sql: string,
  params: unknown[]
): Promise<Response> {
  const user = req.user;
  if (!user) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  try {
    const result = await withScopedClient(user.accountIds, async (client) => {
      await assertDashboardAccess(client, slug, user.roles);
      const { rows } = await client.query(sql, params);
      return rows;
    });
    return res.json({ data: result });
  } catch (error) {
    const statusCode = (error as any).statusCode ?? 500;
    return res.status(statusCode).json({ error: (error as Error).message });
  }
}

const overviewSchema = dateRangeSchema.extend({
  model_id: z.string().uuid().optional(),
  platform: z.string().optional()
});

dashboardsRouter.get('/overview', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = overviewSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const filters: string[] = [];
  const params = [...filter.values];
  if (parsed.model_id) {
    filters.push(`model_id = $${params.length + 1}`);
    params.push(parsed.model_id);
  }
  if (parsed.platform) {
    filters.push(`platform = $${params.length + 1}`);
    params.push(parsed.platform);
  }
  const whereClause = combineWhere(filter.normalized, filters);
  const sql = `SELECT * FROM analytics.v_exec_overview ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'overview', sql, params);
});

const modelQualitySchema = dateRangeSchema.extend({ model_id: z.string().uuid().optional() });
dashboardsRouter.get('/models/quality', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = modelQualitySchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extra: string[] = [];
  if (parsed.model_id) {
    extra.push(`model_name = (SELECT model_name FROM analytics.dim_model WHERE model_id = $${params.length + 1})`);
    params.push(parsed.model_id);
  }
  const whereClause = combineWhere(filter.normalized, extra);
  const sql = `SELECT * FROM analytics.v_model_quality ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'quality', sql, params);
});

const latencySchema = dateRangeSchema.extend({
  model_id: z.string().uuid().optional(),
  platform: z.string().optional()
});
dashboardsRouter.get('/latency', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = latencySchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extras: string[] = [];
  if (parsed.model_id) {
    extras.push(`model_name = (SELECT model_name FROM analytics.dim_model WHERE model_id = $${params.length + 1})`);
    params.push(parsed.model_id);
  }
  if (parsed.platform) {
    extras.push(`platform = $${params.length + 1}`);
    params.push(parsed.platform);
  }
  const whereClause = combineWhere(filter.normalized, extras);
  const sql = `SELECT * FROM analytics.v_latency_by_model_platform ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'ops', sql, params);
});

const toolSchema = dateRangeSchema.extend({ tool_id: z.string().uuid().optional() });
dashboardsRouter.get('/tools/health', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = toolSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extras: string[] = [];
  if (parsed.tool_id) {
    extras.push(`tool_name = (SELECT tool_name FROM analytics.dim_tool WHERE tool_id = $${params.length + 1})`);
    params.push(parsed.tool_id);
  }
  const whereClause = combineWhere(filter.normalized, extras);
  const sql = `SELECT * FROM analytics.v_tool_health ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'tools', sql, params);
});

const safetySchema = dateRangeSchema.extend({ category_id: z.coerce.number().optional() });
dashboardsRouter.get('/safety', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = safetySchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extras: string[] = [];
  if (parsed.category_id) {
    extras.push(`name = (SELECT name FROM analytics.dim_safety_category WHERE safety_id = $${params.length + 1})`);
    params.push(parsed.category_id.toString());
  }
  const whereClause = combineWhere(filter.normalized, extras);
  const sql = `SELECT * FROM analytics.v_safety_by_category ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'safety', sql, params);
});

const costSchema = dateRangeSchema.extend({ model_id: z.string().uuid().optional() });
dashboardsRouter.get('/costs', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = costSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extras: string[] = [];
  if (parsed.model_id) {
    extras.push(`model_name = (SELECT model_name FROM analytics.dim_model WHERE model_id = $${params.length + 1})`);
    params.push(parsed.model_id);
  }
  const whereClause = combineWhere(filter.normalized, extras);
  const sql = `SELECT * FROM analytics.v_cost_by_model ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'costs', sql, params);
});

const featureSchema = dateRangeSchema.extend({ feature_id: z.string().uuid().optional() });
dashboardsRouter.get('/features', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = featureSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extras: string[] = [];
  if (parsed.feature_id) {
    extras.push(`feature_name = (SELECT feature_name FROM analytics.dim_feature WHERE feature_id = $${params.length + 1})`);
    params.push(parsed.feature_id);
  }
  const whereClause = combineWhere(filter.normalized, extras);
  const sql = `SELECT * FROM analytics.v_feature_adoption ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'features', sql, params);
});

const promptsSchema = dateRangeSchema.extend({ template_id: z.string().uuid().optional() });
dashboardsRouter.get('/prompts', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = promptsSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extras: string[] = [];
  if (parsed.template_id) {
    extras.push(`template_name = (SELECT template_name FROM analytics.dim_prompt_template WHERE template_id = $${params.length + 1})`);
    params.push(parsed.template_id);
  }
  const whereClause = combineWhere(filter.normalized, extras);
  const sql = `SELECT * FROM analytics.v_prompt_template_perf ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'prompts', sql, params);
});

const experimentsSchema = dateRangeSchema.extend({ experiment_id: z.string().uuid().optional() });
dashboardsRouter.get('/experiments', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = experimentsSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extras: string[] = [];
  if (parsed.experiment_id) {
    extras.push(`experiment_name = (SELECT name FROM analytics.dim_experiment WHERE experiment_id = $${params.length + 1})`);
    params.push(parsed.experiment_id);
  }
  const whereClause = combineWhere(filter.normalized, extras);
  const sql = `SELECT * FROM analytics.v_experiment_results ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'experiments', sql, params);
});

const errorsSchema = dateRangeSchema.extend({ error_id: z.string().uuid().optional() });
dashboardsRouter.get('/errors', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = errorsSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extras: string[] = [];
  if (parsed.error_id) {
    extras.push(`code = (SELECT code FROM analytics.dim_error_class WHERE error_id = $${params.length + 1})`);
    params.push(parsed.error_id);
  }
  const whereClause = combineWhere(filter.normalized, extras);
  const sql = `SELECT * FROM analytics.v_error_taxonomy ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'errors', sql, params);
});

dashboardsRouter.get('/hourly', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = dateRangeSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const sql = `SELECT * FROM analytics.v_usage_hourly_heatmap ${filter.clause} ORDER BY date_key DESC, hour`;
  return handleQuery(req, res, 'hourly', sql, filter.values);
});

const retentionSchema = dateRangeSchema.extend({ cohort_start: z.string().optional() });
dashboardsRouter.get('/retention', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = retentionSchema.parse(req.query);
  const filters: string[] = [];
  const params: string[] = [];
  if (parsed.from) {
    filters.push(`cohort_week >= $${params.length + 1}`);
    params.push(parsed.from);
  }
  if (parsed.to) {
    filters.push(`cohort_week <= $${params.length + 1}`);
    params.push(parsed.to);
  }
  if (parsed.cohort_start) {
    filters.push(`cohort_week = $${params.length + 1}`);
    params.push(parsed.cohort_start);
  }
  const sql = `SELECT * FROM analytics.v_retention_cohorts ${filters.length ? `WHERE ${filters.join(' AND ')}` : ''} ORDER BY cohort_week DESC, week_n`;
  return handleQuery(req, res, 'growth', sql, params);
});

dashboardsRouter.get('/releases', async (req: AuthenticatedRequest, res: Response) => {
  const sql = 'SELECT * FROM analytics.v_release_annotations ORDER BY released_at DESC';
  return handleQuery(req, res, 'releases', sql, []);
});


dashboardsRouter.get('/bi-usage', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = dateRangeSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const sql = `SELECT * FROM analytics.v_bi_audit ${filter.clause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'admin-bi-usage', sql, filter.values);
});

const sessionsSchema = dateRangeSchema.extend({ q: z.string().optional() });
dashboardsRouter.get('/sessions', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = sessionsSchema.parse(req.query);
  const params: (string | number)[] = [];
  const filters: string[] = [];
  if (parsed.from) {
    filters.push(`started_at >= $${params.length + 1}`);
    params.push(parsed.from);
  }
  if (parsed.to) {
    filters.push(`started_at <= $${params.length + 1}`);
    params.push(parsed.to);
  }
  if (parsed.q) {
    filters.push(`session_id::text ILIKE $${params.length + 1}`);
    params.push(`%${parsed.q}%`);
  }
  const sql = `SELECT * FROM analytics.fact_session_summary ${filters.length ? `WHERE ${filters.join(' AND ')}` : ''} ORDER BY started_at DESC LIMIT 200`;
  return handleQuery(req, res, 'conversations', sql, params);
});

dashboardsRouter.get('/session/:id', async (req: AuthenticatedRequest, res: Response) => {
  const sessionId = req.params.id;
  const sql = 'SELECT * FROM analytics.fact_session_summary WHERE session_id = $1';
  return handleQuery(req, res, 'conversations', sql, [sessionId]);
});

dashboardsRouter.get('/costs/per-success', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = costSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extras: string[] = [];
  if (parsed.model_id) {
    extras.push(`model_name = (SELECT model_name FROM analytics.dim_model WHERE model_id = $${params.length + 1})`);
    params.push(parsed.model_id);
  }
  const whereClause = combineWhere(filter.normalized, extras);
  const sql = `SELECT * FROM analytics.v_cost_per_success ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'costs', sql, params);
});

const regionLatencySchema = dateRangeSchema.extend({ region_id: z.string().uuid().optional(), model_id: z.string().uuid().optional() });
dashboardsRouter.get('/regions', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = regionLatencySchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extras: string[] = [];
  if (parsed.region_id) {
    extras.push(`region_name = (SELECT region_name FROM analytics.dim_region WHERE region_id = $${params.length + 1})`);
    params.push(parsed.region_id);
  }
  if (parsed.model_id) {
    extras.push(`model_name = (SELECT model_name FROM analytics.dim_model WHERE model_id = $${params.length + 1})`);
    params.push(parsed.model_id);
  }
  const whereClause = combineWhere(filter.normalized, extras);
  const sql = `SELECT * FROM analytics.v_latency_by_region ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'regions', sql, params);
});

dashboardsRouter.get('/regions/latency', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = regionLatencySchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const params = [...filter.values];
  const extras: string[] = [];
  if (parsed.region_id) {
    extras.push(`region_name = (SELECT region_name FROM analytics.dim_region WHERE region_id = $${params.length + 1})`);
    params.push(parsed.region_id);
  }
  if (parsed.model_id) {
    extras.push(`model_name = (SELECT model_name FROM analytics.dim_model WHERE model_id = $${params.length + 1})`);
    params.push(parsed.model_id);
  }
  const whereClause = combineWhere(filter.normalized, extras);
  const sql = `SELECT * FROM analytics.v_latency_by_region ${whereClause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'regions', sql, params);
});

dashboardsRouter.get('/regions/cache', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = dateRangeSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const sql = `SELECT * FROM analytics.fact_daily_cache ${filter.clause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'regions', sql, filter.values);
});

dashboardsRouter.get('/regions/platform-health', async (req: AuthenticatedRequest, res: Response) => {
  const parsed = dateRangeSchema.parse(req.query);
  const filter = buildDateFilter('date_key', parsed);
  const sql = `SELECT * FROM analytics.fact_daily_platform_version_health ${filter.clause} ORDER BY date_key DESC`;
  return handleQuery(req, res, 'regions', sql, filter.values);
});

const catalog = {
  'usage.overview': { endpoint: '/overview', view: 'analytics.v_exec_overview', component: 'OverviewChart', drill: '/ops' },
  'usage.hourly': { endpoint: '/hourly', view: 'analytics.v_usage_hourly_heatmap', component: 'HourlyHeatmap', drill: '/ops' },
  'quality.models': { endpoint: '/models/quality', view: 'analytics.v_model_quality', component: 'QualityTrend', drill: '/quality' },
  'latency.models': { endpoint: '/latency', view: 'analytics.v_latency_by_model_platform', component: 'LatencyChart', drill: '/ops' },
  'latency.region': { endpoint: '/regions', view: 'analytics.v_latency_by_region', component: 'RegionLatency', drill: '/regions' },
  'regions.cache': { endpoint: '/regions/cache', view: 'analytics.fact_daily_cache', component: 'DataTable', drill: '/regions' },
  'costs.summary': { endpoint: '/costs', view: 'analytics.v_cost_by_model', component: 'CostChart', drill: '/costs' },
  'safety.categories': { endpoint: '/safety', view: 'analytics.v_safety_by_category', component: 'SafetyStacked', drill: '/safety' },
  'tools.health': { endpoint: '/tools/health', view: 'analytics.v_tool_health', component: 'ToolHealth', drill: '/tools' },
  'growth.retention': { endpoint: '/retention', view: 'analytics.v_retention_cohorts', component: 'RetentionCohort', drill: '/growth' },
  'prompts.templates': { endpoint: '/prompts', view: 'analytics.v_prompt_template_perf', component: 'PromptPerformance', drill: '/prompts' },
  'experiments.results': { endpoint: '/experiments', view: 'analytics.v_experiment_results', component: 'ExperimentResults', drill: '/experiments' },
  'errors.taxonomy': { endpoint: '/errors', view: 'analytics.v_error_taxonomy', component: 'ErrorTable', drill: '/errors' },
  'regions.performance': { endpoint: '/regions', view: 'analytics.v_latency_by_region', component: 'RegionLatency', drill: '/regions' },
  'regions.platformHealth': { endpoint: '/regions/platform-health', view: 'analytics.fact_daily_platform_version_health', component: 'DataTable', drill: '/regions' },
  'sessions.catalog': { endpoint: '/sessions', view: 'analytics.fact_session_summary', component: 'SessionTable', drill: '/session/[id]' },
  'bi.usage': { endpoint: '/bi-usage', view: 'analytics.v_bi_audit', component: 'BiUsage', drill: '/admin/bi-usage' },
  'releases.annotations': { endpoint: '/releases', view: 'analytics.v_release_annotations', component: 'ReleaseTimeline', drill: '/releases' }
};

dashboardsRouter.get('/_catalog', async (req: AuthenticatedRequest, res: Response) => {
  return res.json({ data: catalog });
});

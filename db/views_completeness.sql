CREATE OR REPLACE VIEW analytics.v_usage_overview_daily AS
SELECT
    date_key,
    account_id,
    SUM(dau) AS dau,
    SUM(sessions) AS sessions,
    SUM(messages) AS messages,
    AVG(conversation_depth_avg) AS avg_depth
FROM analytics.fact_daily_usage
GROUP BY date_key, account_id;

CREATE OR REPLACE VIEW analytics.v_usage_hourly_heatmap AS
SELECT
    date_key,
    hour,
    account_id,
    platform,
    SUM(dau_hourly) AS dau_hourly,
    SUM(messages) AS messages
FROM analytics.fact_hourly_usage
GROUP BY date_key, hour, account_id, platform;

CREATE OR REPLACE VIEW analytics.v_quality_by_model_and_eval AS
SELECT
    e.date_key,
    e.account_id,
    m.model_name,
    e.eval_name,
    SUM(e.n) AS total_runs,
    AVG(e.avg_score) AS avg_score,
    AVG(e.median_score) AS median_score,
    AVG(e.ftr_rate) AS ftr_rate
FROM analytics.fact_daily_evals e
JOIN analytics.dim_model m ON m.model_id = e.model_id
GROUP BY e.date_key, e.account_id, m.model_name, e.eval_name;

CREATE OR REPLACE VIEW analytics.v_latency_by_model_platform AS
SELECT
    l.date_key,
    l.account_id,
    m.model_name,
    l.platform,
    AVG(l.p50_ms) AS p50_ms,
    AVG(l.p90_ms) AS p90_ms,
    AVG(l.p99_ms) AS p99_ms,
    AVG(l.avg_ms) AS avg_ms
FROM analytics.fact_daily_latency l
JOIN analytics.dim_model m ON m.model_id = l.model_id
GROUP BY l.date_key, l.account_id, m.model_name, l.platform;

CREATE OR REPLACE VIEW analytics.v_latency_by_region AS
SELECT
    r.date_key,
    r.account_id,
    m.model_name,
    reg.region_name,
    AVG(r.p50_ms) AS p50_ms,
    AVG(r.p90_ms) AS p90_ms,
    AVG(r.p99_ms) AS p99_ms
FROM analytics.fact_daily_region_latency r
JOIN analytics.dim_model m ON m.model_id = r.model_id
JOIN analytics.dim_region reg ON reg.region_id = r.region_id
GROUP BY r.date_key, r.account_id, m.model_name, reg.region_name;

CREATE OR REPLACE VIEW analytics.v_cost_by_model AS
SELECT
    c.date_key,
    c.account_id,
    m.model_name,
    SUM(c.cost_usd) AS cost_usd,
    SUM(c.total_tokens) AS total_tokens,
    SUM(c.cache_hits) AS cache_hits
FROM analytics.fact_daily_cost c
JOIN analytics.dim_model m ON m.model_id = c.model_id
GROUP BY c.date_key, c.account_id, m.model_name;

CREATE OR REPLACE VIEW analytics.v_cost_per_success AS
SELECT
    c.date_key,
    c.account_id,
    m.model_name,
    CASE WHEN SUM(s.sessions) = 0 THEN NULL ELSE SUM(c.cost_usd) / SUM(s.sessions)::numeric END AS cost_per_session
FROM analytics.fact_daily_cost c
LEFT JOIN analytics.fact_daily_usage s
    ON s.date_key = c.date_key AND s.account_id = c.account_id AND s.model_id = c.model_id
JOIN analytics.dim_model m ON m.model_id = c.model_id
GROUP BY c.date_key, c.account_id, m.model_name;

CREATE OR REPLACE VIEW analytics.v_safety_by_category AS
SELECT
    s.date_key,
    s.account_id,
    cat.name,
    SUM(s.triggered) AS triggered,
    SUM(s.blocked) AS blocked,
    SUM(s.transformed) AS transformed
FROM analytics.fact_daily_safety s
JOIN analytics.dim_safety_category cat ON cat.safety_id = s.safety_id
GROUP BY s.date_key, s.account_id, cat.name;

CREATE OR REPLACE VIEW analytics.v_feature_adoption AS
SELECT
    f.date_key,
    f.account_id,
    feat.feature_name,
    SUM(f.users) AS users,
    SUM(f.events) AS events,
    SUM(f.active_users_feature) AS active_users_feature
FROM analytics.fact_daily_feature_usage f
JOIN analytics.dim_feature feat ON feat.feature_id = f.feature_id
GROUP BY f.date_key, f.account_id, feat.feature_name;

CREATE OR REPLACE VIEW analytics.v_prompt_template_perf AS
SELECT
    p.date_key,
    p.account_id,
    t.template_name,
    SUM(p.uses) AS uses,
    AVG(p.avg_quality) AS avg_quality,
    AVG(p.avg_latency_ms) AS avg_latency_ms,
    AVG(p.avg_cost_usd) AS avg_cost_usd
FROM analytics.fact_daily_prompt_templates p
JOIN analytics.dim_prompt_template t ON t.template_id = p.template_id
GROUP BY p.date_key, p.account_id, t.template_name;

CREATE OR REPLACE VIEW analytics.v_experiment_results AS
SELECT
    e.date_key,
    e.account_id,
    exp.name AS experiment_name,
    var.name AS variant_name,
    SUM(e.exposures) AS exposures,
    SUM(e.conversions) AS conversions,
    AVG(e.conv_rate) AS conv_rate,
    AVG(e.avg_cost_usd) AS avg_cost_usd,
    AVG(e.avg_latency_ms) AS avg_latency_ms
FROM analytics.fact_daily_experiments e
JOIN analytics.dim_experiment exp ON exp.experiment_id = e.experiment_id
JOIN analytics.dim_experiment_variant var ON var.variant_id = e.variant_id
GROUP BY e.date_key, e.account_id, exp.name, var.name;

CREATE OR REPLACE VIEW analytics.v_error_taxonomy AS
SELECT
    err.date_key,
    err.account_id,
    d.class,
    d.code,
    d.source,
    SUM(err.occurrences) AS occurrences,
    SUM(err.sessions_impacted) AS sessions_impacted,
    SUM(err.users_impacted) AS users_impacted
FROM analytics.fact_daily_error_taxonomy err
JOIN analytics.dim_error_class d ON d.error_id = err.error_id
GROUP BY err.date_key, err.account_id, d.class, d.code, d.source;

CREATE OR REPLACE VIEW analytics.v_retention_cohorts AS
SELECT
    cohort_week,
    account_id,
    week_n,
    SUM(retained_users) AS retained_users,
    AVG(retention_pct) AS retention_pct
FROM analytics.fact_weekly_retention
GROUP BY cohort_week, account_id, week_n;

CREATE OR REPLACE VIEW analytics.v_bi_audit AS
SELECT
    b.date_key,
    b.account_id,
    d.title,
    SUM(b.views) AS views,
    SUM(b.unique_viewers) AS unique_viewers,
    SUM(b.exports) AS exports
FROM analytics.fact_daily_bi_audit b
JOIN bi.dashboards d ON d.dashboard_id = b.dashboard_id
GROUP BY b.date_key, b.account_id, d.title;

CREATE OR REPLACE VIEW analytics.v_release_annotations AS
SELECT
    r.release_id,
    r.version,
    r.released_at
FROM analytics.dim_release r;

CREATE OR REPLACE VIEW analytics.v_exec_overview AS
SELECT
    f.date_key,
    f.account_id,
    f.model_id,
    m.model_name,
    f.platform,
    SUM(f.dau) AS dau,
    SUM(f.sessions) AS sessions,
    SUM(f.messages) AS messages,
    AVG(NULLIF(f.first_turn_resolution_rate, 0)) AS ftr_rate,
    AVG(lat.p90_ms) AS p90_latency_ms,
    SUM(cost.cost_usd) AS cost_usd,
    CASE WHEN SUM(f.sessions) = 0 THEN 0 ELSE SUM(safe.triggered)::numeric / SUM(f.sessions)::numeric END AS safety_trigger_rate
FROM analytics.fact_daily_usage f
LEFT JOIN analytics.fact_daily_latency lat
    ON lat.date_key = f.date_key AND lat.account_id = f.account_id AND lat.model_id = f.model_id
LEFT JOIN analytics.fact_daily_cost cost
    ON cost.date_key = f.date_key AND cost.account_id = f.account_id AND cost.model_id = f.model_id
LEFT JOIN analytics.fact_daily_safety safe
    ON safe.date_key = f.date_key AND safe.account_id = f.account_id
LEFT JOIN analytics.dim_model m ON m.model_id = f.model_id
GROUP BY f.date_key, f.account_id, f.model_id, m.model_name, f.platform;

CREATE OR REPLACE VIEW analytics.v_model_quality AS
SELECT
    e.date_key,
    e.account_id,
    m.model_name,
    e.eval_name,
    SUM(e.n) AS n,
    AVG(e.avg_score) AS avg_score,
    AVG(e.median_score) AS median_score,
    AVG(e.ftr_rate) AS ftr_rate
FROM analytics.fact_daily_evals e
JOIN analytics.dim_model m ON m.model_id = e.model_id
GROUP BY e.date_key, e.account_id, m.model_name, e.eval_name;

CREATE OR REPLACE VIEW analytics.v_tool_health AS
SELECT
    t.date_key,
    t.account_id,
    tool.tool_name,
    SUM(t.calls) AS calls,
    SUM(t.success) AS success,
    SUM(t.failed) AS failed,
    AVG(t.avg_duration_ms) AS avg_duration_ms,
    CASE WHEN SUM(t.calls) = 0 THEN 0 ELSE SUM(t.failed)::numeric / SUM(t.calls)::numeric END AS failure_rate
FROM analytics.fact_daily_tool_usage t
JOIN analytics.dim_tool tool ON tool.tool_id = t.tool_id
GROUP BY t.date_key, t.account_id, tool.tool_name;

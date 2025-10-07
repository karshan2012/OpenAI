-- Seed roles
INSERT INTO authz.roles (role_id, role_name) VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin'),
    ('00000000-0000-0000-0000-000000000002', 'executive'),
    ('00000000-0000-0000-0000-000000000003', 'pm'),
    ('00000000-0000-0000-0000-000000000004', 'analyst'),
    ('00000000-0000-0000-0000-000000000005', 'ops'),
    ('00000000-0000-0000-0000-000000000006', 'safety'),
    ('00000000-0000-0000-0000-000000000007', 'support')
ON CONFLICT (role_id) DO NOTHING;

-- Accounts
INSERT INTO authz.accounts (account_id, name) VALUES
    ('10000000-0000-0000-0000-000000000001', 'Acme Corp'),
    ('10000000-0000-0000-0000-000000000002', 'Globex')
ON CONFLICT (account_id) DO NOTHING;

INSERT INTO analytics.dim_account (account_id, account_name, plan, created_at) VALUES
    ('10000000-0000-0000-0000-000000000001', 'Acme Corp', 'enterprise', now() - interval '180 days'),
    ('10000000-0000-0000-0000-000000000002', 'Globex', 'plus', now() - interval '90 days')
ON CONFLICT (account_id) DO NOTHING;

-- Users
INSERT INTO authz.users (user_id, email, password_hash) VALUES
    ('20000000-0000-0000-0000-000000000001', 'exec@acme.test', NULL),
    ('20000000-0000-0000-0000-000000000002', 'ops@acme.test', NULL),
    ('20000000-0000-0000-0000-000000000003', 'analyst@acme.test', NULL),
    ('20000000-0000-0000-0000-000000000004', 'exec@globex.test', NULL)
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO authz.user_accounts (user_id, account_id) VALUES
    ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001'),
    ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001'),
    ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001'),
    ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000002')
ON CONFLICT DO NOTHING;

INSERT INTO authz.user_roles (user_id, role_id) VALUES
    ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002'),
    ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000005'),
    ('20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004'),
    ('20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000002')
ON CONFLICT DO NOTHING;

-- Dashboards
INSERT INTO bi.dashboards (dashboard_id, slug, title, description) VALUES
    ('30000000-0000-0000-0000-000000000001', 'overview', 'Executive Overview', 'Top-level KPIs'),
    ('30000000-0000-0000-0000-000000000002', 'quality', 'Quality', 'Model evaluation metrics'),
    ('30000000-0000-0000-0000-000000000003', 'conversations', 'Conversations', 'Session analytics'),
    ('30000000-0000-0000-0000-000000000004', 'ops', 'Operations', 'Latency and reliability'),
    ('30000000-0000-0000-0000-000000000005', 'tools', 'Tools', 'Tool usage'),
    ('30000000-0000-0000-0000-000000000006', 'safety', 'Safety', 'Safety monitoring'),
    ('30000000-0000-0000-0000-000000000007', 'costs', 'Costs', 'Spend tracking'),
    ('30000000-0000-0000-0000-000000000008', 'growth', 'Growth', 'Growth KPIs'),
    ('30000000-0000-0000-0000-000000000009', 'session', 'Sessions', 'Session drilldowns'),
    ('30000000-0000-0000-0000-00000000000a', 'prompts', 'Prompts', 'Prompt templates'),
    ('30000000-0000-0000-0000-00000000000b', 'experiments', 'Experiments', 'Experiment outcomes'),
    ('30000000-0000-0000-0000-00000000000c', 'features', 'Features', 'Feature adoption'),
    ('30000000-0000-0000-0000-00000000000d', 'errors', 'Errors', 'Error taxonomy'),
    ('30000000-0000-0000-0000-00000000000e', 'regions', 'Regions', 'Geo performance'),
    ('30000000-0000-0000-0000-00000000000f', 'hourly', 'Hourly Usage', 'Hourly usage heatmap'),
    ('30000000-0000-0000-0000-000000000010', 'admin-bi-usage', 'BI Usage', 'Dashboard adoption'),
    ('30000000-0000-0000-0000-000000000011', 'releases', 'Releases', 'Release annotations'),
    ('30000000-0000-0000-0000-000000000012', 'coverage', 'Coverage', 'Coverage matrix')
ON CONFLICT (dashboard_id) DO NOTHING;

-- Dashboard role mappings
INSERT INTO bi.dashboard_role_access (dashboard_id, role_id, can_view) VALUES
    ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', true),
    ('30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000005', true),
    ('30000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000005', true),
    ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000005', true),
    ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-00000000000b', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-00000000000c', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-00000000000d', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-00000000000e', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-00000000000f', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000004', true),
    ('30000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000004', true)
ON CONFLICT DO NOTHING;

-- Populate static dimensions
INSERT INTO analytics.dim_model (model_id, model_name, provider, context_window, is_default) VALUES
    ('40000000-0000-0000-0000-000000000001', 'gpt-4o', 'OpenAI', 128000, true),
    ('40000000-0000-0000-0000-000000000002', 'gpt-4o-mini', 'OpenAI', 64000, false),
    ('40000000-0000-0000-0000-000000000003', 'gpt-4o-audio', 'OpenAI', 64000, false)
ON CONFLICT (model_id) DO NOTHING;

INSERT INTO analytics.dim_tool (tool_id, tool_name, provider, category) VALUES
    ('50000000-0000-0000-0000-000000000001', 'Search', 'Internal', 'retrieval'),
    ('50000000-0000-0000-0000-000000000002', 'Calendar', 'Internal', 'productivity'),
    ('50000000-0000-0000-0000-000000000003', 'Docs', 'Internal', 'productivity')
ON CONFLICT (tool_id) DO NOTHING;

INSERT INTO analytics.dim_safety_category (safety_id, name) VALUES
    (1, 'toxicity'),
    (2, 'self-harm'),
    (3, 'personal-data'),
    (4, 'hate')
ON CONFLICT (safety_id) DO NOTHING;

INSERT INTO analytics.dim_feature (feature_id, feature_name, area) VALUES
    ('60000000-0000-0000-0000-000000000001', 'Memory', 'Personalization'),
    ('60000000-0000-0000-0000-000000000002', 'Voice Mode', 'Experience'),
    ('60000000-0000-0000-0000-000000000003', 'Team Spaces', 'Collaboration')
ON CONFLICT (feature_id) DO NOTHING;

INSERT INTO analytics.dim_prompt_template (template_id, template_name, version) VALUES
    ('70000000-0000-0000-0000-000000000001', 'Support Escalation', 'v1'),
    ('70000000-0000-0000-0000-000000000002', 'Sales Outreach', 'v2'),
    ('70000000-0000-0000-0000-000000000003', 'Code Review', 'v1')
ON CONFLICT (template_id) DO NOTHING;

INSERT INTO analytics.dim_experiment (experiment_id, name, status) VALUES
    ('80000000-0000-0000-0000-000000000001', 'Prompt Brevity', 'running'),
    ('80000000-0000-0000-0000-000000000002', 'Latency Optimization', 'running')
ON CONFLICT (experiment_id) DO NOTHING;

INSERT INTO analytics.dim_experiment_variant (variant_id, experiment_id, name, is_control) VALUES
    ('81000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000001', 'Control', true),
    ('81000000-0000-0000-0000-000000000002', '80000000-0000-0000-0000-000000000001', 'Variant A', false),
    ('81000000-0000-0000-0000-000000000003', '80000000-0000-0000-0000-000000000002', 'Control', true),
    ('81000000-0000-0000-0000-000000000004', '80000000-0000-0000-0000-000000000002', 'Variant B', false)
ON CONFLICT (variant_id) DO NOTHING;

INSERT INTO analytics.dim_region (region_id, region_code, region_name) VALUES
    ('90000000-0000-0000-0000-000000000001', 'in', 'India'),
    ('90000000-0000-0000-0000-000000000002', 'us', 'United States'),
    ('90000000-0000-0000-0000-000000000003', 'eu', 'Europe')
ON CONFLICT (region_id) DO NOTHING;

INSERT INTO analytics.dim_platform_version (version_id, platform, app_version) VALUES
    ('91000000-0000-0000-0000-000000000001', 'ios', '5.2.1'),
    ('91000000-0000-0000-0000-000000000002', 'android', '6.0.0')
ON CONFLICT (version_id) DO NOTHING;

INSERT INTO analytics.dim_error_class (error_id, class, code, source) VALUES
    ('92000000-0000-0000-0000-000000000001', 'Timeout', '504', 'platform'),
    ('92000000-0000-0000-0000-000000000002', 'Tool Failure', 'T001', 'tooling'),
    ('92000000-0000-0000-0000-000000000003', 'Model', 'M002', 'model'),
    ('92000000-0000-0000-0000-000000000004', 'Network', 'N100', 'network')
ON CONFLICT (error_id) DO NOTHING;

INSERT INTO analytics.dim_release (release_id, version, released_at) VALUES
    ('93000000-0000-0000-0000-000000000001', '2024.05', now() - interval '25 days'),
    ('93000000-0000-0000-0000-000000000002', '2024.06', now() - interval '10 days'),
    ('93000000-0000-0000-0000-000000000003', '2024.07', now())
ON CONFLICT (release_id) DO NOTHING;

-- dim_date
INSERT INTO analytics.dim_date (date_key, iso_week, iso_year, month_num, month_name, quarter_num, year_num)
SELECT
    d::date,
    EXTRACT(ISODOW FROM d::date),
    EXTRACT(ISOYEAR FROM d::date),
    EXTRACT(MONTH FROM d::date)::int,
    TO_CHAR(d::date, 'Month'),
    EXTRACT(quarter FROM d::date)::int,
    EXTRACT(YEAR FROM d::date)::int
FROM generate_series((current_date - 29), current_date, interval '1 day') d
ON CONFLICT (date_key) DO NOTHING;

-- Usage seeds (30 days)
WITH daily AS (
    SELECT d::date AS date_key FROM generate_series((current_date - 29), current_date, interval '1 day') d
)
INSERT INTO analytics.fact_daily_usage (date_key, account_id, model_id, platform, country_code, dau, sessions, messages, conversation_depth_avg, first_turn_resolution_rate)
SELECT
    daily.date_key,
    acct.account_id,
    model.model_id,
    platform,
    country,
    (100 + (random() * 50))::int,
    (200 + (random() * 100))::int,
    (1000 + (random() * 500))::int,
    ROUND(2 + random(), 2),
    ROUND(70 + random() * 10, 2)
FROM daily
CROSS JOIN (VALUES ('10000000-0000-0000-0000-000000000001'), ('10000000-0000-0000-0000-000000000002')) AS acct(account_id)
CROSS JOIN (VALUES ('40000000-0000-0000-0000-000000000001'), ('40000000-0000-0000-0000-000000000002')) AS model(model_id)
CROSS JOIN (VALUES ('web'),('ios'),('android')) AS platforms(platform)
CROSS JOIN (VALUES ('IN'),('US')) AS countries(country)
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_latency (date_key, account_id, model_id, tool_id, platform, p50_ms, p90_ms, p99_ms, avg_ms, timeouts, errors, retries)
SELECT
    u.date_key,
    u.account_id,
    u.model_id,
    tools.tool_id,
    u.platform,
    (200 + random() * 50)::int,
    (400 + random() * 80)::int,
    (600 + random() * 120)::int,
    (300 + random() * 60)::int,
    (random()*10)::int,
    (random()*8)::int,
    (random()*5)::int
FROM analytics.fact_daily_usage u
LEFT JOIN (VALUES ('50000000-0000-0000-0000-000000000001'), ('50000000-0000-0000-0000-000000000002'), ('50000000-0000-0000-0000-000000000003')) AS tools(tool_id)
    ON true
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_cost (date_key, account_id, model_id, input_tokens, output_tokens, total_tokens, cache_hits, cost_usd)
SELECT
    u.date_key,
    u.account_id,
    u.model_id,
    (u.messages * 400)::bigint,
    (u.messages * 300)::bigint,
    (u.messages * 700)::bigint,
    (u.messages * 0.2)::bigint,
    ROUND(u.messages * 0.002, 3)
FROM analytics.fact_daily_usage u
GROUP BY u.date_key, u.account_id, u.model_id, u.messages
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_safety (date_key, account_id, safety_id, triggered, blocked, transformed, review_required)
SELECT
    u.date_key,
    u.account_id,
    s.safety_id,
    (random()*10)::int,
    (random()*4)::int,
    (random()*5)::int,
    (random()*2)::int
FROM analytics.fact_daily_usage u
CROSS JOIN analytics.dim_safety_category s
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_evals (date_key, account_id, model_id, eval_name, n, avg_score, median_score, stdev_score, ftr_rate)
SELECT
    u.date_key,
    u.account_id,
    u.model_id,
    eval_name,
    50 + (random()*20)::int,
    ROUND(3 + random(), 3),
    ROUND(3 + random(), 3),
    ROUND(random(), 3),
    ROUND(70 + random()*15, 2)
FROM analytics.fact_daily_usage u
CROSS JOIN (VALUES ('helpfulness'), ('correctness')) AS evals(eval_name)
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_tool_usage (date_key, account_id, tool_id, calls, success, failed, avg_duration_ms)
SELECT
    u.date_key,
    u.account_id,
    tool_id,
    (random()*200)::int,
    (random()*150)::int,
    (random()*50)::int,
    (400 + random()*120)::int
FROM analytics.fact_daily_usage u
JOIN analytics.dim_tool t ON true
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_growth (date_key, account_id, new_users, returning_users, activations, d1_retention, w4_retention, feature_adoptions)
SELECT
    u.date_key,
    u.account_id,
    (random()*30)::int,
    (random()*60)::int,
    (random()*20)::int,
    ROUND(40 + random()*20, 2),
    ROUND(20 + random()*15, 2),
    (random()*80)::int
FROM analytics.fact_daily_usage u
GROUP BY u.date_key, u.account_id
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_hourly_usage (date_key, hour, account_id, model_id, platform, dau_hourly, sessions, messages)
SELECT
    u.date_key,
    h,
    u.account_id,
    u.model_id,
    u.platform,
    GREATEST(1, (u.dau / 24)::int + (random()*3)::int),
    GREATEST(1, (u.sessions / 24)::int + (random()*3)::int),
    GREATEST(5, (u.messages / 24)::int + (random()*10)::int)
FROM analytics.fact_daily_usage u
CROSS JOIN generate_series(0, 23) h
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_session_summary (session_id, account_id, user_id, model_id, started_at, ended_at, turns, success, avg_latency_ms, total_tokens, cost_usd, safety_flags, tool_calls)
SELECT
    gen_random_uuid(),
    u.account_id,
    '20000000-0000-0000-0000-000000000001',
    u.model_id,
    (u.date_key + make_interval(hours => (random()*23)::int)),
    (u.date_key + make_interval(hours => (random()*23)::int, minutes => 5)),
    (random()*8)::int,
    random() > 0.2,
    (300 + random()*120)::int,
    (random()*2000)::int,
    ROUND(random()*2, 3),
    (random()*2)::int,
    (random()*3)::int
FROM analytics.fact_daily_usage u
LIMIT 500;

INSERT INTO analytics.fact_daily_feature_usage (date_key, account_id, feature_id, users, events, active_users_feature)
SELECT
    u.date_key,
    u.account_id,
    feat.feature_id,
    (random()*80)::int,
    (random()*200)::int,
    (random()*50)::int
FROM analytics.fact_daily_usage u
JOIN analytics.dim_feature feat ON true
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_prompt_templates (date_key, account_id, template_id, uses, avg_quality, avg_latency_ms, avg_cost_usd)
SELECT
    u.date_key,
    u.account_id,
    temp.template_id,
    (random()*120)::int,
    ROUND(3 + random(), 3),
    (400 + random()*150)::int,
    ROUND(random()*1.5, 3)
FROM analytics.fact_daily_usage u
JOIN analytics.dim_prompt_template temp ON true
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_experiments (date_key, account_id, experiment_id, variant_id, exposures, conversions, conv_rate, avg_cost_usd, avg_latency_ms)
SELECT
    u.date_key,
    u.account_id,
    exp.experiment_id,
    var.variant_id,
    (random()*300)::int,
    (random()*80)::int,
    ROUND(random(), 3),
    ROUND(random()*1.2, 3),
    (400 + random()*160)::int
FROM analytics.fact_daily_usage u
JOIN analytics.dim_experiment exp ON true
JOIN analytics.dim_experiment_variant var ON var.experiment_id = exp.experiment_id
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_error_taxonomy (date_key, account_id, error_id, occurrences, sessions_impacted, users_impacted)
SELECT
    u.date_key,
    u.account_id,
    err.error_id,
    (random()*20)::int,
    (random()*15)::int,
    (random()*10)::int
FROM analytics.fact_daily_usage u
JOIN analytics.dim_error_class err ON true
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_cache (date_key, account_id, model_id, region_id, requests, cache_hits, hit_rate)
SELECT
    u.date_key,
    u.account_id,
    u.model_id,
    reg.region_id,
    (random()*500)::int,
    (random()*400)::int,
    ROUND(random(), 3)
FROM analytics.fact_daily_usage u
JOIN analytics.dim_region reg ON true
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_region_latency (date_key, account_id, model_id, region_id, p50_ms, p90_ms, p99_ms)
SELECT
    u.date_key,
    u.account_id,
    u.model_id,
    reg.region_id,
    (250 + random()*70)::int,
    (420 + random()*80)::int,
    (650 + random()*140)::int
FROM analytics.fact_daily_usage u
JOIN analytics.dim_region reg ON true
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_platform_version_health (date_key, account_id, version_id, crashes, errors, sessions, error_rate)
SELECT
    u.date_key,
    u.account_id,
    ver.version_id,
    (random()*10)::int,
    (random()*20)::int,
    (random()*200)::int,
    ROUND(random(), 3)
FROM analytics.fact_daily_usage u
JOIN analytics.dim_platform_version ver ON true
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_notifications (date_key, account_id, sends, opens, ctr)
SELECT
    u.date_key,
    u.account_id,
    (random()*500)::int,
    (random()*300)::int,
    ROUND(random(), 3)
FROM analytics.fact_daily_usage u
GROUP BY u.date_key, u.account_id
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_weekly_retention (cohort_week, week_n, account_id, retained_users, retention_pct)
SELECT
    (current_date - interval '6 weeks')::date + (7 * g)::int,
    w,
    acct.account_id,
    (random()*200)::int,
    ROUND(random(), 3)
FROM generate_series(0, 4) g
CROSS JOIN generate_series(0, 8) w
CROSS JOIN (VALUES ('10000000-0000-0000-0000-000000000001'), ('10000000-0000-0000-0000-000000000002')) acct(account_id)
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_bi_audit (date_key, account_id, dashboard_id, views, unique_viewers, exports)
SELECT
    u.date_key,
    u.account_id,
    dash.dashboard_id,
    (random()*50)::int,
    (random()*25)::int,
    (random()*5)::int
FROM analytics.fact_daily_usage u
JOIN bi.dashboards dash ON true
ON CONFLICT DO NOTHING;

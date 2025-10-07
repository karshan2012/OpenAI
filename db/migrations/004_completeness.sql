-- Additional completeness data adjustments
INSERT INTO analytics.fact_daily_notifications (date_key, account_id, sends, opens, ctr)
SELECT
    current_date - i,
    '10000000-0000-0000-0000-000000000001',
    200 + i * 5,
    120 + i * 3,
    0.45
FROM generate_series(0, 6) AS g(i)
ON CONFLICT (date_key, account_id) DO UPDATE SET
    sends = EXCLUDED.sends,
    opens = EXCLUDED.opens,
    ctr = EXCLUDED.ctr;

INSERT INTO analytics.dim_prompt_template (template_id, template_name, version)
VALUES ('70000000-0000-0000-0000-000000000004', 'Finance Summary', 'v1')
ON CONFLICT DO NOTHING;

INSERT INTO analytics.fact_daily_prompt_templates (date_key, account_id, template_id, uses, avg_quality, avg_latency_ms, avg_cost_usd)
SELECT
    current_date - i,
    '10000000-0000-0000-0000-000000000002',
    '70000000-0000-0000-0000-000000000004',
    40 + i * 2,
    3.8,
    380,
    0.45
FROM generate_series(0, 6) g(i)
ON CONFLICT (date_key, account_id, template_id) DO UPDATE SET
    uses = EXCLUDED.uses,
    avg_quality = EXCLUDED.avg_quality,
    avg_latency_ms = EXCLUDED.avg_latency_ms,
    avg_cost_usd = EXCLUDED.avg_cost_usd;

INSERT INTO analytics.fact_daily_experiments (date_key, account_id, experiment_id, variant_id, exposures, conversions, conv_rate, avg_cost_usd, avg_latency_ms)
SELECT
    current_date - i,
    '10000000-0000-0000-0000-000000000002',
    '80000000-0000-0000-0000-000000000001',
    '81000000-0000-0000-0000-000000000002',
    100 + i * 10,
    40 + i * 3,
    0.35,
    0.75,
    420
FROM generate_series(0, 6) g(i)
ON CONFLICT (date_key, account_id, experiment_id, variant_id) DO UPDATE SET
    exposures = EXCLUDED.exposures,
    conversions = EXCLUDED.conversions,
    conv_rate = EXCLUDED.conv_rate,
    avg_cost_usd = EXCLUDED.avg_cost_usd,
    avg_latency_ms = EXCLUDED.avg_latency_ms;

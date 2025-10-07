CREATE OR REPLACE FUNCTION authz.can_see_account(row_account uuid)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT row_account = ANY (current_setting('app.account_ids', true)::uuid[]);
$$;

ALTER TABLE analytics.fact_daily_usage              ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_latency            ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_cost               ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_safety             ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_evals              ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_tool_usage         ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_growth             ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_session_summary          ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_hourly_usage             ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_feature_usage      ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_prompt_templates   ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_experiments        ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_error_taxonomy     ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_cache              ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_region_latency     ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_platform_version_health ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_notifications      ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_weekly_retention         ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics.fact_daily_bi_audit           ENABLE ROW LEVEL SECURITY;

CREATE POLICY p_usage_rls   ON analytics.fact_daily_usage            USING (authz.can_see_account(account_id));
CREATE POLICY p_lat_rls     ON analytics.fact_daily_latency          USING (authz.can_see_account(account_id));
CREATE POLICY p_cost_rls    ON analytics.fact_daily_cost             USING (authz.can_see_account(account_id));
CREATE POLICY p_safe_rls    ON analytics.fact_daily_safety           USING (authz.can_see_account(account_id));
CREATE POLICY p_eval_rls    ON analytics.fact_daily_evals            USING (authz.can_see_account(account_id));
CREATE POLICY p_tool_rls    ON analytics.fact_daily_tool_usage       USING (authz.can_see_account(account_id));
CREATE POLICY p_growth_rls  ON analytics.fact_daily_growth           USING (authz.can_see_account(account_id));
CREATE POLICY p_sess_rls    ON analytics.fact_session_summary        USING (authz.can_see_account(account_id));
CREATE POLICY p_hour_rls    ON analytics.fact_hourly_usage           USING (authz.can_see_account(account_id));
CREATE POLICY p_feat_rls    ON analytics.fact_daily_feature_usage    USING (authz.can_see_account(account_id));
CREATE POLICY p_ptmp_rls    ON analytics.fact_daily_prompt_templates USING (authz.can_see_account(account_id));
CREATE POLICY p_exp_rls     ON analytics.fact_daily_experiments      USING (authz.can_see_account(account_id));
CREATE POLICY p_err_rls     ON analytics.fact_daily_error_taxonomy   USING (authz.can_see_account(account_id));
CREATE POLICY p_cache_rls   ON analytics.fact_daily_cache            USING (authz.can_see_account(account_id));
CREATE POLICY p_reglat_rls  ON analytics.fact_daily_region_latency   USING (authz.can_see_account(account_id));
CREATE POLICY p_pvh_rls     ON analytics.fact_daily_platform_version_health USING (authz.can_see_account(account_id));
CREATE POLICY p_notif_rls   ON analytics.fact_daily_notifications    USING (authz.can_see_account(account_id));
CREATE POLICY p_ret_rls     ON analytics.fact_weekly_retention       USING (authz.can_see_account(account_id));
CREATE POLICY p_bia_rls     ON analytics.fact_daily_bi_audit         USING (authz.can_see_account(account_id));

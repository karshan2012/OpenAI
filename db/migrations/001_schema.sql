CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS btree_gin;

CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS authz;
CREATE SCHEMA IF NOT EXISTS bi;

-- Authz schema
CREATE TABLE IF NOT EXISTS authz.accounts (
    account_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL
);

CREATE TABLE IF NOT EXISTS authz.users (
    user_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email text UNIQUE NOT NULL,
    password_hash text,
    is_active boolean DEFAULT true
);

CREATE TABLE IF NOT EXISTS authz.roles (
    role_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name text UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS authz.user_roles (
    user_id uuid NOT NULL REFERENCES authz.users(user_id) ON DELETE CASCADE,
    role_id uuid NOT NULL REFERENCES authz.roles(role_id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS authz.user_accounts (
    user_id uuid NOT NULL REFERENCES authz.users(user_id) ON DELETE CASCADE,
    account_id uuid NOT NULL REFERENCES authz.accounts(account_id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, account_id)
);

-- BI schema
CREATE TABLE IF NOT EXISTS bi.dashboards (
    dashboard_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    slug text UNIQUE NOT NULL,
    title text NOT NULL,
    description text
);

CREATE TABLE IF NOT EXISTS bi.dashboard_role_access (
    dashboard_id uuid NOT NULL REFERENCES bi.dashboards(dashboard_id) ON DELETE CASCADE,
    role_id uuid NOT NULL REFERENCES authz.roles(role_id) ON DELETE CASCADE,
    can_view boolean DEFAULT true,
    PRIMARY KEY (dashboard_id, role_id)
);

-- Analytics dimensions
CREATE TABLE IF NOT EXISTS analytics.dim_date (
    date_key date PRIMARY KEY,
    iso_week int,
    iso_year int,
    month_num int,
    month_name text,
    quarter_num int,
    year_num int
);

CREATE TABLE IF NOT EXISTS analytics.dim_account (
    account_id uuid PRIMARY KEY,
    account_name text NOT NULL,
    plan text CHECK (plan IN ('free','plus','enterprise')),
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS analytics.dim_user (
    user_id uuid PRIMARY KEY,
    account_id uuid REFERENCES analytics.dim_account(account_id) ON DELETE CASCADE,
    country_code text,
    platform text CHECK (platform IN ('web','ios','android','api')),
    device_class text CHECK (device_class IN ('mobile','desktop','tablet','other')),
    plan text,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS analytics.dim_model (
    model_id uuid PRIMARY KEY,
    model_name text NOT NULL,
    provider text,
    context_window int,
    is_default boolean DEFAULT false
);

CREATE TABLE IF NOT EXISTS analytics.dim_tool (
    tool_id uuid PRIMARY KEY,
    tool_name text NOT NULL,
    provider text,
    category text
);

CREATE TABLE IF NOT EXISTS analytics.dim_safety_category (
    safety_id smallint PRIMARY KEY,
    name text UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS analytics.dim_region (
    region_id uuid PRIMARY KEY,
    region_code text,
    region_name text
);

CREATE TABLE IF NOT EXISTS analytics.dim_platform_version (
    version_id uuid PRIMARY KEY,
    platform text,
    app_version text
);

CREATE TABLE IF NOT EXISTS analytics.dim_feature (
    feature_id uuid PRIMARY KEY,
    feature_name text,
    area text
);

CREATE TABLE IF NOT EXISTS analytics.dim_prompt_template (
    template_id uuid PRIMARY KEY,
    template_name text,
    version text
);

CREATE TABLE IF NOT EXISTS analytics.dim_experiment (
    experiment_id uuid PRIMARY KEY,
    name text,
    status text
);

CREATE TABLE IF NOT EXISTS analytics.dim_experiment_variant (
    variant_id uuid PRIMARY KEY,
    experiment_id uuid REFERENCES analytics.dim_experiment(experiment_id) ON DELETE CASCADE,
    name text,
    is_control boolean
);

CREATE TABLE IF NOT EXISTS analytics.dim_error_class (
    error_id uuid PRIMARY KEY,
    class text,
    code text,
    source text
);

CREATE TABLE IF NOT EXISTS analytics.dim_release (
    release_id uuid PRIMARY KEY,
    version text,
    released_at timestamptz
);

-- Fact tables
CREATE TABLE IF NOT EXISTS analytics.fact_daily_usage (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    model_id uuid REFERENCES analytics.dim_model(model_id),
    platform text,
    country_code text,
    dau int,
    sessions int,
    messages int,
    conversation_depth_avg numeric(6,2),
    first_turn_resolution_rate numeric(5,2),
    UNIQUE(date_key, account_id, model_id, platform, country_code)
);

CREATE INDEX IF NOT EXISTS idx_fact_daily_usage_date_account ON analytics.fact_daily_usage(date_key, account_id);
CREATE INDEX IF NOT EXISTS idx_fact_daily_usage_model ON analytics.fact_daily_usage(date_key, account_id, model_id);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_latency (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    model_id uuid REFERENCES analytics.dim_model(model_id),
    tool_id uuid REFERENCES analytics.dim_tool(tool_id),
    platform text,
    p50_ms int,
    p90_ms int,
    p99_ms int,
    avg_ms int,
    timeouts int DEFAULT 0,
    errors int DEFAULT 0,
    retries int DEFAULT 0,
    UNIQUE(date_key, account_id, model_id, tool_id, platform)
);

CREATE INDEX IF NOT EXISTS idx_fact_daily_latency_date_account ON analytics.fact_daily_latency(date_key, account_id);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_cost (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    model_id uuid REFERENCES analytics.dim_model(model_id),
    input_tokens bigint,
    output_tokens bigint,
    total_tokens bigint,
    cache_hits bigint DEFAULT 0,
    cost_usd numeric(18,6),
    UNIQUE(date_key, account_id, model_id)
);

CREATE INDEX IF NOT EXISTS idx_fact_daily_cost_date_account ON analytics.fact_daily_cost(date_key, account_id);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_safety (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    safety_id smallint REFERENCES analytics.dim_safety_category(safety_id),
    triggered int,
    blocked int,
    transformed int,
    review_required int DEFAULT 0,
    UNIQUE(date_key, account_id, safety_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_evals (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    model_id uuid REFERENCES analytics.dim_model(model_id),
    eval_name text,
    n int,
    avg_score numeric(6,3),
    median_score numeric(6,3),
    stdev_score numeric(6,3),
    ftr_rate numeric(5,2),
    UNIQUE(date_key, account_id, model_id, eval_name)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_tool_usage (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    tool_id uuid REFERENCES analytics.dim_tool(tool_id),
    calls int,
    success int,
    failed int,
    avg_duration_ms int,
    UNIQUE(date_key, account_id, tool_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_growth (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    new_users int,
    returning_users int,
    activations int,
    d1_retention numeric(5,2),
    w4_retention numeric(5,2),
    feature_adoptions int,
    UNIQUE(date_key, account_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_session_summary (
    session_id uuid PRIMARY KEY,
    account_id uuid REFERENCES analytics.dim_account(account_id),
    user_id uuid REFERENCES analytics.dim_user(user_id),
    model_id uuid REFERENCES analytics.dim_model(model_id),
    started_at timestamptz,
    ended_at timestamptz,
    turns int,
    success boolean,
    avg_latency_ms int,
    total_tokens int,
    cost_usd numeric(18,6),
    safety_flags int,
    tool_calls int
);

CREATE INDEX IF NOT EXISTS idx_fact_session_summary_account_started ON analytics.fact_session_summary(account_id, started_at DESC);

CREATE TABLE IF NOT EXISTS analytics.fact_hourly_usage (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    hour int CHECK (hour BETWEEN 0 AND 23),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    model_id uuid REFERENCES analytics.dim_model(model_id),
    platform text,
    dau_hourly int,
    sessions int,
    messages int,
    UNIQUE(date_key, hour, account_id, model_id, platform)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_feature_usage (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    feature_id uuid REFERENCES analytics.dim_feature(feature_id),
    users int,
    events int,
    active_users_feature int,
    UNIQUE(date_key, account_id, feature_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_prompt_templates (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    template_id uuid REFERENCES analytics.dim_prompt_template(template_id),
    uses int,
    avg_quality numeric(6,3),
    avg_latency_ms int,
    avg_cost_usd numeric(18,6),
    UNIQUE(date_key, account_id, template_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_experiments (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    experiment_id uuid REFERENCES analytics.dim_experiment(experiment_id),
    variant_id uuid REFERENCES analytics.dim_experiment_variant(variant_id),
    exposures int,
    conversions int,
    conv_rate numeric(6,3),
    avg_cost_usd numeric(18,6),
    avg_latency_ms int,
    UNIQUE(date_key, account_id, experiment_id, variant_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_error_taxonomy (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    error_id uuid REFERENCES analytics.dim_error_class(error_id),
    occurrences int,
    sessions_impacted int,
    users_impacted int,
    UNIQUE(date_key, account_id, error_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_cache (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    model_id uuid REFERENCES analytics.dim_model(model_id),
    region_id uuid REFERENCES analytics.dim_region(region_id),
    requests int,
    cache_hits int,
    hit_rate numeric(6,3),
    UNIQUE(date_key, account_id, model_id, region_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_region_latency (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    model_id uuid REFERENCES analytics.dim_model(model_id),
    region_id uuid REFERENCES analytics.dim_region(region_id),
    p50_ms int,
    p90_ms int,
    p99_ms int,
    UNIQUE(date_key, account_id, model_id, region_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_platform_version_health (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    version_id uuid REFERENCES analytics.dim_platform_version(version_id),
    crashes int,
    errors int,
    sessions int,
    error_rate numeric(6,3),
    UNIQUE(date_key, account_id, version_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_notifications (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    sends int,
    opens int,
    ctr numeric(6,3),
    UNIQUE(date_key, account_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_weekly_retention (
    id bigserial PRIMARY KEY,
    cohort_week date,
    week_n int,
    account_id uuid REFERENCES analytics.dim_account(account_id),
    retained_users int,
    retention_pct numeric(6,3),
    UNIQUE(cohort_week, week_n, account_id)
);

CREATE TABLE IF NOT EXISTS analytics.fact_daily_bi_audit (
    id bigserial PRIMARY KEY,
    date_key date REFERENCES analytics.dim_date(date_key),
    account_id uuid REFERENCES analytics.dim_account(account_id),
    dashboard_id uuid REFERENCES bi.dashboards(dashboard_id),
    views int,
    unique_viewers int,
    exports int,
    UNIQUE(date_key, account_id, dashboard_id)
);


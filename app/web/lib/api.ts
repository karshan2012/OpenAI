import 'server-only';

const API_BASE_URL = process.env.API_BASE_URL ?? 'http://localhost:3001/api';

export interface ApiResponse<T> {
  data: T;
}

async function fetchFromApi<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(options?.headers ?? {})
    },
    cache: 'no-store'
  });
  if (!res.ok) {
    throw new Error(`API request failed: ${res.status}`);
  }
  const json = (await res.json()) as ApiResponse<T>;
  return json.data;
}

export async function getOverview(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/overview?${params.toString()}`);
}

export async function getQuality(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/models/quality?${params.toString()}`);
}

export async function getLatency(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/latency?${params.toString()}`);
}

export async function getTools(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/tools/health?${params.toString()}`);
}

export async function getSafety(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/safety?${params.toString()}`);
}

export async function getCosts(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/costs?${params.toString()}`);
}

export async function getCostPerSuccess(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/costs/per-success?${params.toString()}`);
}

export async function getGrowth(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/retention?${params.toString()}`);
}

export async function getPrompts(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/prompts?${params.toString()}`);
}

export async function getExperiments(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/experiments?${params.toString()}`);
}

export async function getFeatures(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/features?${params.toString()}`);
}

export async function getErrors(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/errors?${params.toString()}`);
}

export async function getRegionsLatency(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/regions/latency?${params.toString()}`);
}

export async function getPlatformHealth(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/regions/platform-health?${params.toString()}`);
}

export async function getRegionCache(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/regions/cache?${params.toString()}`);
}

export async function getHourly(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/hourly?${params.toString()}`);
}

export async function getBiUsage(params: URLSearchParams) {
  return fetchFromApi<Record<string, unknown>[]>(`/bi-usage?${params.toString()}`);
}

export interface SessionSummary {
  session_id: string;
  account_id: string;
  user_id: string;
  model_id: string;
  started_at: string;
  ended_at: string | null;
  turns: number;
  success: boolean;
  avg_latency_ms: number;
  total_tokens: number;
  cost_usd: string;
  safety_flags: number;
  tool_calls: number;
}

export async function getSessions(params: URLSearchParams) {
  return fetchFromApi<SessionSummary[]>(`/sessions?${params.toString()}`);
}

export async function getSession(id: string) {
  return fetchFromApi<SessionSummary>(`/session/${id}`);
}

export async function getCatalog() {
  return fetchFromApi<Record<string, { endpoint: string; view: string; component: string; drill: string }>>('/_catalog');
}

export async function getReleases() {
  return fetchFromApi<Record<string, unknown>[]>(`/releases`);
}

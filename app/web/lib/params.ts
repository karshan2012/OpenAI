export function createParams(searchParams: Record<string, string | string[] | undefined>) {
  const params = new URLSearchParams();
  Object.entries(searchParams).forEach(([key, value]) => {
    if (!value) return;
    if (Array.isArray(value)) {
      value.forEach((val) => params.append(key, val));
    } else {
      params.set(key, value);
    }
  });
  return params;
}

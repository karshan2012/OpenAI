export function formatNumber(value: unknown, options: Intl.NumberFormatOptions = {}) {
  const num = typeof value === 'number' ? value : Number(value ?? 0);
  return new Intl.NumberFormat('en-IN', options).format(num);
}

export function formatPercent(value: unknown) {
  const num = typeof value === 'number' ? value : Number(value ?? 0);
  return `${num.toFixed(2)}%`;
}

export function formatCurrency(value: unknown) {
  const num = typeof value === 'number' ? value : Number(value ?? 0);
  return new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'USD', maximumFractionDigits: 2 }).format(num);
}

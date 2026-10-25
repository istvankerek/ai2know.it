/**
 * Datum, penz es szam formazas – lokalizacio segedeletek
 */

/** Datum formazas (HU: 2026.04.11, EN: 04/11/2026) */
export function formatDate(date: Date, locale = 'hu-HU'): string {
  return new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date);
}

/** Relativ ido ("3 perccel ezelott") */
export function formatRelativeTime(date: Date, locale = 'hu-HU'): string {
  const rtf = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' });
  const diffMs = date.getTime() - Date.now();
  const diffMin = Math.round(diffMs / 60000);
  if (Math.abs(diffMin) < 60) return rtf.format(diffMin, 'minute');
  const diffHours = Math.round(diffMin / 60);
  if (Math.abs(diffHours) < 24) return rtf.format(diffHours, 'hour');
  return rtf.format(Math.round(diffHours / 24), 'day');
}

/** Penznem formazas (HUF: "1 500 Ft", EUR: "€1,500") */
export function formatCurrency(
  amount: number,
  currency = 'HUF',
  locale = 'hu-HU',
): string {
  return new Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount);
}

/** Szam formazas (HU: 1 500 000,5) */
export function formatNumber(value: number, locale = 'hu-HU'): string {
  return new Intl.NumberFormat(locale).format(value);
}

---
name: i18n-setup
description: >
  Nemzetkoziesites es lokalizacio: react-i18next konfiguracio, nyelvi fajlok,
  datum/szam/penznem formazas, idozona, mertekegysegek.
  Triggerek: "i18n", "lokalizacio", "nyelv", "forditas", "locale",
  "timezone", "mertekegyseg", "datum formatum".
  NE hasznald: UI komponens generalas, business logika.
model: claude-sonnet-4-6
---

# i18n Setup

## Felelossegek
- react-i18next konfiguracio (src/lib/i18n/config.ts)
- Nyelvi fajlok struktura (hu/, en/)
- Namespace-ek (common, admin, validation, modules/*)
- Datum formazas (HU: YYYY.MM.DD, US: MM/DD/YYYY)
- Ido formazas (12h / 24h)
- Szam formazas (HU: 1 500 000,5 | US: 1,500,000.5)
- Penznem (HUF: "1 500 Ft" | EUR: "€1,500" | USD: "$1,500")
- Idozona kezeles (Europe/Budapest default)
- Het kezdo napja (HU: hetfo, US: vasarnap)
- Relativ ido ("3 perccel ezelott", "2 hours ago")
- Tobbes szam kezeles (nyelvfuggo)
- AG Grid lokalizacio (magyar felulet)
- useTranslation() hook hasznalata komponensekben

## Helyes output pelda

```typescript
// apps/frontend/src/lib/i18n/config.ts
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

import huCommon from '@/locales/hu/common.json';
import huValidation from '@/locales/hu/validation.json';
import enCommon from '@/locales/en/common.json';
import enValidation from '@/locales/en/validation.json';

export const SUPPORTED_LANGUAGES = ['hu', 'en'] as const;
export const DEFAULT_LANGUAGE = 'hu';

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: {
      hu: { common: huCommon, validation: huValidation },
      en: { common: enCommon, validation: enValidation },
    },
    fallbackLng: DEFAULT_LANGUAGE,
    supportedLngs: SUPPORTED_LANGUAGES,
    interpolation: { escapeValue: false },
    detection: {
      order: ['localStorage', 'navigator'],
      caches: ['localStorage'],
    },
  });

export default i18n;
```

```typescript
// apps/frontend/src/lib/i18n/localize.ts
const LOCALE_MAP = { hu: 'hu-HU', en: 'en-US' } as const;
const TIMEZONE = 'Europe/Budapest';

/**
 * Datum formazas az aktualis nyelv szerint.
 * HU: 2026.04.12., EN: Apr 12, 2026
 */
export function formatDate(date: Date, locale: keyof typeof LOCALE_MAP): string {
  return new Intl.DateTimeFormat(LOCALE_MAP[locale], {
    year: 'numeric',
    month: locale === 'hu' ? '2-digit' : 'short',
    day: 'numeric',
    timeZone: TIMEZONE,
  }).format(date);
}

/**
 * Penznem formazas. HU: "1 500 Ft", EUR: "€1,500.00"
 */
export function formatCurrency(
  amount: number,
  currency: 'HUF' | 'EUR' | 'USD',
  locale: keyof typeof LOCALE_MAP
): string {
  return new Intl.NumberFormat(LOCALE_MAP[locale], {
    style: 'currency',
    currency,
    maximumFractionDigits: currency === 'HUF' ? 0 : 2,
  }).format(amount);
}
```

```json
// apps/frontend/src/locales/hu/common.json
{
  "app": { "title": "{{PROJECT_NAME}}", "loading": "Betoltes..." },
  "actions": { "save": "Mentes", "cancel": "Megse", "delete": "Torles" },
  "errors": { "required": "Kotelezo mezo", "invalid": "Ervenytelen ertek" }
}
```

## Helytelen output pelda (NE csinald igy)

```typescript
// ❌ Hardcoded string komponensben
<button>Save</button>

// ❌ Sajat date formatter
const formatted = `${d.getFullYear()}.${d.getMonth() + 1}.${d.getDate()}.`;

// ❌ Idozona figyelmen kivul hagyva
new Date().toLocaleString()

// ❌ Nincs pluralizalas
`${count} item${count > 1 ? 's' : ''}`  // helyette: t('items', { count })
```

## Szabalyok
1. SOHA hardcoded szoveg — minden `useTranslation()` hook-on keresztul
2. Datum/szam/penznem MINDIG `Intl.*` API (nincs sajat formatter)
3. Idozona default: `Europe/Budapest` (konfiguralhato)
4. Het kezdo napja: HU=hetfo, US=vasarnap
5. Pluralizalas: `t('items', { count })` — nyelvfuggo
6. Namespace-ek: `common`, `validation`, `admin`, `modules/{name}`
7. Locale fajlok strukturalt JSON (nem flat)

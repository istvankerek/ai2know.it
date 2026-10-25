---
name: i18n-required
description: >
  Minden user-facing string t() hook-on at, hu + en kulcsok szinkronban.
  Hardcoded szoveg TILOS UI/email/notification kontextusban.
  Aktivalodik: uj komponens, form, modal, email template, notification,
  alert, toast, button label, error message, placeholder, label, title.
  Triggerek: "uj komponens", "label", "placeholder", "error message",
  "email template", "toast", "alert szoveg", "button szoveg", "form mezo",
  "title", "header szoveg", "user-facing copy", "i18n".
license: Everengine v7.0
priority: P1
model: claude-haiku-4-5-20251001
related_skills:
  - i18n-setup
  - hungarian-docs
  - brand-auditor
---

# i18n Required — minden szoveg t() hook-on at

## Vasszabaly
> **Egyetlen user-facing szoveg sem lehet hardcoded.** Minden string `t("key")`
> hivason megy at, es a `hu.ts` + `en.ts` fajlokban PARHUZAMOSAN definialt.

## Mikor aktivalodik
- Uj `.tsx` / `.jsx` komponens letrehozasa user-facing kontextusban
- Uj email template (`docker/backend/templates/email/*.mjml` vagy hasonlo)
- Uj notification / alert / toast szoveg
- Uj form label, placeholder, error message
- Uj page title, header, button label
- Hibauzenet (UI-on lathato)

## Mit ELLENORIZ

### 1. Forditasi fajlok parhuzamossaga
```
docker/console/src/lib/translations/hu.ts
docker/console/src/lib/translations/en.ts
```
**MINDIG egyszerre frissitsd mindkettot.** A kulcskeszletnek azonosnak kell lennie:
soha ne legyen `hu`-ban olyan kulcs ami `en`-ben nincs (es forditva).

Ellenorzes:
```bash
# Minden hu kulcs van-e en-ben?
diff <(grep -oE '"[a-z._]+":' hu.ts | sort -u) \
     <(grep -oE '"[a-z._]+":' en.ts | sort -u)
```

### 2. Hardcoded szoveg detektalas (anti-pattern)
```tsx
// ❌ TILOS
<button>Mentes</button>
<input placeholder="Add meg az email cimet" />
toast.error("Sikertelen mentes")
throw new Error("Felhasznalo nem talalhato")

// ✅ Helyesen
<button>{t("common.save")}</button>
<input placeholder={t("user.email_placeholder")} />
toast.error(t("common.save_failed"))
throw new Error(t("error.user_not_found"))
```

### 3. Kulcs elnevezesi konvencio
| Tipus | Format | Pelda |
|-------|--------|-------|
| Common (cross-modul) | `common.{action}` | `common.save`, `common.cancel`, `common.loading` |
| Modul-specifikus | `{module}.{section}_{element}` | `tickets.list_title`, `tickets.add_button` |
| Hibauzenet | `error.{context}_{type}` | `error.network_timeout`, `error.validation_failed` |
| Status | `{module}.status_{value}` | `tickets.status_open`, `tickets.status_closed` |
| Tablazat oszlop | `{module}.col_{field}` | `users.col_email`, `users.col_created_at` |
| Menu | `app.{module}` / `sub.{module}.{page}` | `app.tickets`, `sub.tickets.list` |

### 4. Datum / penz / szam formazas
```tsx
// ❌ TILOS hardcoded format
<span>{user.created_at.toLocaleDateString()}</span>     // mindig 'en-US'
<span>{price.toFixed(2)} HUF</span>                      // hardcoded valuta

// ✅ Helyesen
import { formatDate, formatCurrency } from "@/lib/i18n/localize";
<span>{formatDate(user.created_at, locale)}</span>
<span>{formatCurrency(price, locale, currency)}</span>
```

### 5. Plurals (tobbes szam)
```tsx
// ❌ Egyszerusites tobbes szamhoz nelkul
<span>{count} elem</span>    // angolul: "1 items" rosszul hangzik

// ✅ Helyesen (i18next plural)
<span>{t("module.item_count", { count })}</span>
// hu.ts: "module.item_count_one": "{count} elem", "module.item_count_other": "{count} elem"
// en.ts: "module.item_count_one": "{count} item", "module.item_count_other": "{count} items"
```

## Email template kulon szabaly

Emailek MJML-ben vagy HTML template-ben szintugy:
- Templet egy `i18n_key` placeholder-t hasznal
- A template render-ido kapja meg a forditasokat
- Subject line is forditando

```mjml
<mj-text>{{ t.greeting }}, {{ user.name }}!</mj-text>
<mj-button href="{{ link }}">{{ t.cta_label }}</mj-button>
```

## Notification / Push / Slack / Telegram

Ugyanugy: a payload egy i18n_key + locale kombinacio. A worker
generalja a vegleges szoveget a felhasznalo `preferred_locale`-javal.

```python
await notify(
    user_id=user_id,
    channel="slack",
    template_key="ticket.assigned",
    locale=user.preferred_locale,  # 'hu' vagy 'en'
    data={"ticket_id": ticket.id, "assignee": assignee.name},
)
```

## Auto-detect (review utan)

A `code-review` skill / `parallel-reviewer-orchestrator` ellenorzi:
- Van-e `>` jellal kezdodo statikus szoveg JSX-ben
- Van-e `placeholder=`, `aria-label=`, `title=` hardcoded ertekkel
- Van-e `Error("...")` hardcoded angol/magyar szovegel

## Tiltasok

❌ Hardcoded user-facing szoveg `.tsx`/`.jsx` komponensben
❌ Hardcoded szoveg `Error()` constructor-ban (hibauzenet)
❌ Forditasi kulcs csak az egyik nyelven (hu+en KOTELEZO)
❌ Toast/alert/notification i18n nelkul
❌ Datum/szam formazas locale-tol fuggetlenul

## Hivatkozott
- Sister skill: `i18n-setup` (react-i18next config, locale fajlok)
- Sister skill: `hungarian-docs` (magyar dokumentacio iras)
- Rules: `.claude/rules/module-implementation.md` (1. elv: i18n discipline)

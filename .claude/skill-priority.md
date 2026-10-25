# Skill Priority – P0/P1/P2 Kategorizalas

> **Verzio:** v2.3.2
> **Forras:** `specification/everengine-v2.3.2-patch-finomhangolas.md`

"One great file beats 50 random uploads" – nem a mennyiseg szamit, hanem a minoseg.

68 skill van a rendszerben. Nem mindegyik kell minden projektben, es nem mindegyiket kell a bootstrap-nal legenerani. A prioritas szint megmondja melyik mikor kell.

## Szintek

| Priority | Jelentes | Mikor generaljuk | Skill szam |
|----------|----------|-------------------|-----------|
| **P0 – Core** | Minden projektben, minden nap | Bootstrap-nal automatikusan | 15 |
| **P1 – Standard** | A legtobb projektben kell | Bootstrap-nal opcionalisan (kerdezd meg) | 25 |
| **P2 – Specialist** | Projekt-specifikus, igeny szerint | Kesobb, kezzel hozzaadva | 28 |

---

## P0 – Core (15 skill) – Mindig generalodik

Ezek nelkul a projekt nem mukodik rendesen:

| # | Skill | Miert Core |
|---|-------|-----------|
| 1 | `code-review` | Minden PR-hez kell |
| 2 | `code-style` | Konzisztens kod, hook-kal ervenyesitve |
| 3 | `unit-test-writer` | Teszt nelkul nincs deploy |
| 4 | `crud-generator` | Minden modul ebbol indul |
| 5 | `list-view` | Minden modulnak van listaja |
| 6 | `form-builder` | Minden modulnak van form-ja |
| 7 | `skillpass-auth` | Auth nelkul semmi nem megy (egyetlen IdP) |
| 8 | `roles-permissions` | Jogosultsag nelkul nem biztonsagos |
| 9 | `security-audit` | Biztonsagi alapelvek betartatasa |
| 10 | `secret-detection` | Hook-kent automatikusan fut |
| 11 | `i18n-setup` | Magyar lokalizacio alap |
| 12 | `docker-setup` | Minden Docker-ben fut |
| 13 | `skeleton-loading` | UX alap – ne villanjon az oldal |
| 14 | `activity-log` | Audit trail kotelezo |
| 15 | `session-continuity` | COORDINATION.md kezeles |

---

## P1 – Standard (25 skill) – Bootstrap-nal valaszthato

| # | Skill | Mikor kell |
|---|-------|-----------|
| 16 | `dashboard-widgets` | Ha van admin dashboard |
| 17 | `profile-system` | Ha van felhasznalo profil |
| 18 | `appearance-settings` | Ha van tema/nyelv valtas |
| 19 | `notification-system` | Ha van ertesites |
| 20 | `email-mailgun` | Ha van email kuldes |
| 21 | `taxonomy-system` | Ha vannak kategoriak/cimkek |
| 22 | `file-upload` | Ha van fajl feltoltes |
| 23 | `file-manager` | Ha van fajlkezelo admin |
| 24 | `alert-system` | Ha van rendszer-szintu ertesites |
| 25 | `api-keys-management` | Ha van kulso API hozzaferes |
| 26 | `monitoring-setup` | Ha van prod monitoring |
| 27 | `worker-management` | Ha vannak hatterfeladatok |
| 28 | `backup-strategy` | Ha van prod adat |
| 29 | `deploy-pipeline` | Ha van deploy folyamat |
| 30 | `db-migration` | Ha van adatbazis |
| 31 | `caddy-gateway` | Ha van Caddy proxy |
| 32 | `cloudflare-cdn` | Ha van Cloudflare |
| 33 | `integration-test` | Ha vannak API endpoint-ok |
| 34 | `hungarian-docs` | Ha magyar dokumentacio kell |
| 35 | `docs-generator` | Ha van automatikus docs |
| 36 | `api-documentation` | Ha van publikus API |
| 37 | `refactor` | Ha van legacy kod |
| 38 | `maintenance-mode` | Ha van prod rendszer |
| 39 | `safedata-mode` | Ha van prod adatbazis |
| 40 | `autodream` | Ha van rendszeres fejlesztes |

---

## P2 – Specialist (28 skill) – Igeny szerint

| # | Skill | Mikor kell |
|---|-------|-----------|
| 41 | `ai-chat-admin` | Ha van AI chat funkcio |
| 42 | `tf-intelligent-menu` | Ha van TF.js intelligencia |
| 43 | `vector-search` | Ha van Qdrant/RAG |
| 44 | `scraper` | Ha van web scraping |
| 45 | `spider` | Ha van site crawling |
| 46 | `login-history` | Ha van belepesi naplo |
| 47 | `analytics-dashboard` | Ha van szerver analitika |
| 48 | `backup-manager-ui` | Ha van backup admin UI |
| 49 | `support-faq` | Ha van support rendszer |
| 50 | `changelog-generator` | Ha van release notes |
| 51 | `e2e-test` | Ha van Playwright E2E |
| 52 | `module-marketplace` | Ha van bovitmeny rendszer |
| 53 | `theme-system` | Ha van tema kezelo |
| 54 | `ci-cd-setup` | Ha van GitHub Actions |
| 55 | `s3-storage` | Ha van S3 konfig |
| 56 | `auto-scale` | Ha van auto-scaling |
| 57 | `server-migration` | Ha van szerver mozgatas |
| 58 | `command-palette` | Ha van Ctrl+K navigacio |
| 59 | `feature-flags` | Ha van feature toggle |
| 60 | `data-import` | Ha van CSV/Excel import |
| 61 | `webhook-manager` | Ha van webhook kuldes |
| 62 | `scheduled-tasks` | Ha van cron UI |
| 63 | `skill-router` | Ha van intelligens routing |
| 64 | `auto-iterate` | Ha van auto-fix loop |
| 65 | `prompt-templates` | Ha van prompt konyvtar |
| 66 | `runbook-generator` | Ha van incident kezeles |
| 67 | `onboarding-wizard` | Ha van onboarding flow |
| 68 | `coming-soon-notify` | Ha van "hamarosan" funkcio |

---

## Bootstrap hasznalat

A `/bootstrap-project` parancs automatikusan telepiti a P0 skill-eket, kerdez a P1-ekrol, es kihagyja a P2-ket.

Kesobb P2 skill-t hozzaadni: `/bootstrap {skill-name}`

## Skill Authoring Best Practice

Minden SKILL.md kotelezo reszei:

```markdown
---
name: skill-name
description: >
  [Trigger leiras + NE hasznald leiras]
---

# Skill Neve

## Mikor aktivalodik
- [Trigger lista]

## Mikor NE aktivalodjon
- [Negativ trigger lista]

## Helyes output pelda          <- KOTELEZO!
[Valodi, mukodo kod pelda]

## Helytelen output pelda       <- AJANLOTT
[Tipikus hibak ❌ jelolessel]

## Szabalyok
[5-10 pontos szabalylista]
```

Referencia: `specification/everengine-v2.3.2-patch-finomhangolas.md` – 3. szekcio.

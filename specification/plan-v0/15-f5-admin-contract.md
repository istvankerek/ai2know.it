# F5 – Admin API contract az aibos.space felé

> Cél: minden régi admin funkció contract-first admin API-n érhető el, amelyet az aibos.space
> konzol fogyaszt. Az ai2know.it nem épít admin felületet (L-15).
> Routing: STANDARD (contract), CRITICAL (auth middleware). Skillek: `aibos-admin-contract`,
> `permission-rbac`, `audit-trail-mandatory`, `api-documentation`.

## 1. Contract (előbb a contract, utána a kód – L-05)

- [ ] `contracts/admin/ai2know-admin.yaml` + `.json` a `templates/admin-contract` alapján.
- [ ] `contracts/authorization/permissions.json` – kódok `ai2know.{modul}.{akció}` formában.
- [ ] `contracts/authorization/role-matrix.csv` – aibos operátori szerepkörök → jogok.
- [ ] Validátor a CI-ban; az aibos csapat mock szerver ellen kezdhet.

## 2. Modulok és jogok (első kör)

| Modul | Végpontok | Permission kódok | Régi megfelelő |
|-------|-----------|------------------|----------------|
| members | list, view, edit (kohorsz, handle, státusz), link (kézi, indokkal), archive | `ai2know.members.{list,view,edit,link,archive}` | `/users`, `/api/users` CRUD |
| partners | list, view, create, edit, archive, export | `ai2know.partners.*` | `/business`, `/business/export`, `/business/import`, `/partnereink` |
| referral_codes | list, view, create, edit, archive, stats | `ai2know.referral_codes.*` | `users.code`, `/affiliate`, `/csapatom` riportok |
| coupons | list, view, create, edit, archive, redemptions | `ai2know.coupons.*` | `/kedvezmenyek`, `/fetch-coupons`, `orders.coupons` |
| orders_report | list (aggregátum) | `ai2know.orders_report.list` | `/fetch-orders`, `/orders-report` |
| share_links, qr_codes | list, view, archive | `ai2know.share_links.*`, `ai2know.qr_codes.*` | `/share/list`, `/list_qrcodes` |
| redirects | stats (régi host, top útvonalak, hivatkozók, utólagos 404-ek) | `ai2know.redirects.stats` | új |
| assessments | list, view, export | `ai2know.assessments.*` | `/submit-ai-assessment` |
| aiqna | list, answer, publish | `ai2know.aiqna.*` | `/aiqna/answer`, `/aiqna/all-questions` |
| support_tickets | list, view, edit (státusz, válasz) | `ai2know.support_tickets.*` | `/support/tickets` |
| newsletter | export (feliratkozottak a kiküldő felé) | `ai2know.newsletter.export` | `/newsletter_users` |
| audit | list, view | `ai2know.audit.{list,view}` | új |

A végleges lista az owner F4 utáni döntésétől függ (mely funkciók maradnak, 01).

## 3. Implementáció (`a2k-admin-api`)

- [ ] Middleware: aibos workload JWT (JWKS) + `X-Actor-Assertion` (EdDSA/ES256, ≤120 s, kérés-kötés
      `req.m/p/h`, `jti` replay store Redisben).
- [ ] `require_permission("ai2know.x.y")` minden handleren, DENY alapból; teszt: jog nélkül 403.
- [ ] Minden mutáció append-only `audit_log` sort ír (actor, permission, cél, előtte/utána diff,
      `reason` kötelező kézi felülírásnál – L-11).
- [ ] Hibák `https://aibos.space/errors/<slug>` RFC 7807 típussal.
- [ ] Export végpontok: aszinkron job + aláírt, lejáró letöltési link (MinIO presigned).
- [ ] Adattakarékosság: az aibos nem tárol ügyfél-példányt, csak lekérdez (data-minimisation).

## 4. Átadás az aibos csapatnak (az aibos repóban külön terv)

- [ ] Typed kliens crate generálás: `aibos-ai2know-client`.
- [ ] `console/lib/menu-config.ts`: „ai2know.it" kategória, DLA oldalak (`/add`, sosem `/new`).
- [ ] „Menüpont soha nem 404" teszt (L-06).

## Tesztek

- Contract validátor zöld; minden operáción `x-permission`, minden nem-2xx `Problem`.
- Integráció: érvényes workload JWT + assertion → 200; lejárt assertion, újrahasznált `jti`,
  rossz body hash, hiányzó jog → 401/403.
- Audit: minden mutáló végpont után pontosan egy audit sor.

## Kimenet

- Az aibos konzol mockkal és élő non-prod backenddel is működik az első modulokra.

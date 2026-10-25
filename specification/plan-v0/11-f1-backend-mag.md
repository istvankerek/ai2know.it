# F1 – Backend mag (Rust/Axum)

> Cél: futó, tesztelt backend váz adatmodellel, hibakezeléssel, JWT validációval és a publikus
> contracttal – üzleti funkció még nélkül.
> Routing: STANDARD. Skillek: `code-style`, `db-migration`, `permission-rbac`, `tdd-enforcer`.

## 1. Workspace

- [ ] Cargo workspace (`apps/backend` + `crates/a2k-*`, lásd 02 / 3), közös `[workspace.dependencies]`.
- [ ] `a2k-common`: konfiguráció env-ből (hiányzó kötelező kulcs = induláskor hiba, nincs csendes
      default), RFC 7807 `Problem` típus (`https://ai2know.it/errors/<slug>`), UUID v7, `ip_hash`
      (HMAC-SHA256, aktuális + előző kulcs).
- [ ] Megfigyelhetőség: `tracing` JSON log (request id, nincs PII), Prometheus `/metrics`,
      `/healthz` (élő), `/readyz` (DB + NATS + Redis).
- [ ] Middleware: request id, timeout, body limit, CORS whitelist (`https://ai2know.it`, test
      host), security headerek.

## 2. Adatbázis (sqlx migrációk, `ai2know` séma)

- [ ] Migrációk a 04 / 2. fejezet szerint: `members`, `legacy_link_candidates`, `partners`,
      `referral_codes`, `referral_events`, `coupons`, `coupon_redemptions`, `share_links`,
      `share_hits`, `qr_codes`, `coupon_owners`, `redirect_hits`, `assessments`,
      `support_tickets`, `audit_log`, `outbox`.
- [ ] `audit_log`: UPDATE/DELETE tiltó trigger (append-only), teszt bizonyítja.
- [ ] `redirect_hits`, `referral_events`: havi partíció (nagy írási volumen).
- [ ] Minden migráció `up` + `down`, `make migrate` és restart-teszt (L-08).

## 3. Auth alap (`a2k-auth`)

- [ ] skillpass JWKS letöltés a discovery-ből, cache 1 óra, `kid` váltásnál újratöltés.
- [ ] RS256 validáció: `iss = https://skillpass.id`, `aud = SKILLPASS_CLIENT_ID`, `exp`, `nbf`.
- [ ] `AuthMember` extractor: JWT → `members` sor (nincs → 401 RFC 7807, nem csendes vendég).
- [ ] `require_cohort(...)` segéd a kohorszhoz kötött tartalmakhoz (nem jogosultság).
- [ ] aibos workload JWT + actor assertion extractor váz (F5 tölti ki a végpontokat).

## 4. Publikus contract

- [ ] `contracts/public/ai2know-public.yaml` (utoipa-ból generálva, CI-ban diff-ellenőrzés).
- [ ] TypeScript kliens generálás az `apps/web` számára (`openapi-typescript`), zod sémák.
- [ ] Lapozás cursor alapú, verzió az URL-ben (`/api/v1`).

## 5. Outbox és események

- [ ] `outbox` → NATS JetStream publikáló worker (at-least-once, idempotencia kulcs).
- [ ] Események: `member.linked`, `referral.attributed`, `coupon.redeemed`, `redirect.hit`
      (aggregálható), `assessment.submitted`.

## Tesztek (előbb piros, aztán zöld)

- Konfiguráció: hiányzó `SKILLPASS_ISSUER` → induláskor hiba.
- JWT: rossz `aud`, lejárt `exp`, ismeretlen `kid`, rossz aláírás → 401 Problem.
- Audit: `UPDATE audit_log` → DB hiba.
- Migráció: `up → down → up` tiszta, restart után `/readyz` 200.
- Problem formátum: minden 4xx/5xx `application/problem+json`.

## Kimenet

- `apps/backend` Docker image, `make local` alatt fut, health/ready/metrics zöld, contract generált.

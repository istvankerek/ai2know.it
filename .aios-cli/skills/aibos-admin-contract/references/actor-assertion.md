# Actor Assertion — összefoglaló

**Forrás:** `/Users/everengine/Documents/dev/aibos` @ `7e30ba5` (2026-10-06)  
Hivatkozott fájlok: `contracts/external/actor-assertion.md` (normatív spec, ADR-006)

> A normatív specifikáció az `actor-assertion.md` ADR-ban él. Ez az összefoglaló
> a partner implementálók számára készült — hivatkozz az ADR-ra vitás esetben.

---

## Mi az actor assertion?

Kétfaktoros M2M hitelesítési minta: a workload JWT (gépi azonosítás) mellett
az actor assertion tanúsítja, hogy melyik emberi operátor nevében történik a
művelet, és pontosan melyik kéréshez kötődik.

```
Authorization: Bearer <workload_jwt>       ← gépi azonosítás (M2M)
X-Actor-Assertion: <jws_compact>           ← emberi operátor + kéréskötés
```

---

## JWS formátum

- **Algoritmus:** `EdDSA` (Ed25519) vagy `ES256`; más alg → 401
- **`typ` header:** `"aibos-actor+jwt"` — eltérés → 401
- **Élettartam:** max `exp - iat = 120 s`
- **Egyedi azonosító:** `jti` (UUIDv4), replay store-ban ellenőrzött

---

## Kötelező claim-ek

| Claim | Érték |
|-------|-------|
| `iss` | `"https://aibos.space"` (pontos egyezés) |
| `aud` | A partner API base URL-je (pl. `"https://api.aibootcamp.hu/admin"`) |
| `sub` | SkillPass `sub` (operátor Kratos UUID) |
| `sub_iss` | `"https://skillpass.id"` |
| `wl` | Workload `client_id` (egyeznie kell a Bearer token `client_id`-jával) |
| `tenant` | `company_id` UUID vagy `null` (cross-tenant) |
| `scp` | Engedélyezett scope-ok listája (pl. `["aibootcamp.courses.edit"]`) |
| `auth_ref` | `{"aal": "aal1"│"aal2", "auth_time_ref": "<ISO-8601>"}` |
| `req` | Request binding — lásd alább |
| `jti` | UUIDv4 |
| `iat`, `nbf`, `exp` | Unix timestamp másodpercben |

Opcionális: `reason` (max 500 kar.), `ticket`, `corr` (correlation ID).

---

## Request binding (`req` claim)

```json
{
  "m": "PATCH",
  "p": "/api/admin/v1/courses/uuid-of-course",
  "h": "sha256:<hex(SHA-256(raw UTF-8 request body))>"
}
```

- `m`: nagybetűs HTTP metódus
- `p`: normalizált path, query string nélkül, trailing slash nélkül
- `h`: `"sha256:" + hex(SHA-256(body))` — GET/DELETE esetén üres string hash-e

Eltérés bármelyik mezőnél → 401.

---

## High-risk műveletek

Ha az endpoint `step_up: true` flag-gel van jelölve (delete, publish, bulk
override), az assertion `auth_ref.aal` értékének `"aal2"` kell lennie
(TOTP-vel hitelesített munkamenet). `aal1` esetén 403 `stepup-required`.

---

## Partner middleware implementálási sorrend

1. Workload JWT validáció: `iss=https://aibos.space`, `aud=https://api.{partner}.hu/admin`, scope-ok, `exp`
2. `X-Actor-Assertion` header kiolvasása
3. `typ` ellenőrzés (`"aibos-actor+jwt"`)
4. JWKS lekérés: `https://aibos.space/.well-known/aibos-jwks.json` (1 óra cache, kid-miss esetén egyszeri újratöltés)
5. Aláírás + `alg` ellenőrzés, denylist check
6. `exp/nbf/iat` + clock skew (≤30 s)
7. `jti` replay: `INSERT ... ON CONFLICT DO NOTHING RETURNING jti` — ha üres → 401
8. `req.m/p/h` egyezés
9. `wl == workload client_id`
10. `tenant == path tenant`
11. `scp` tartalmaz minden szükséges permission-t
12. `aal` >= szükséges szint
13. Audit log bejegyzés

---

## RFC 7807 hibatérkép (aibos → partner)

| Feltétel | HTTP | `type` slug |
|----------|------|------------|
| Workload JWT hiányzik/érvénytelen | 401 | `missing-workload-token` |
| Assertion hiányzik | 401 | `missing-actor-assertion` |
| `typ` eltérés | 401 | `invalid-assertion-type` |
| Tiltott `alg` | 401 | `disallowed-algorithm` |
| Ismeretlen `kid` | 401 | `unknown-signing-key` |
| Lejárt | 401 | `assertion-expired` |
| `exp - iat > 120s` | 401 | `assertion-lifetime-exceeded` |
| `jti` replay | 401 | `assertion-replayed` |
| `req` eltérés | 401 | `request-binding-mismatch` |
| `wl` ≠ workload `client_id` | 401 | `workload-mismatch` |
| `tenant` eltérés | 403 | `tenant-mismatch` |
| Hiányos `scp` | 403 | `insufficient-scope` |
| `aal1` + high-risk | 403 | `stepup-required` |

Teljes `type` URI: `https://aibos.space/errors/<slug>`

---

## JWKS kulcsrotáció (partner teendők)

- Tervezett rotáció: 30 naponta; mindkét kulcs aktív ≥24 óráig
- Kompromittálás: azonnali cache invalidáció
- Partner cache TTL: 1 óra; `kid`-miss esetén egyszeri újratöltés kötelező
- Denylist ellenőrzés minden validálásnál

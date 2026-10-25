# M2M client_credentials referencia

> Forrás: `skillpass` repo @ `24048cd` (2026-10-06)
> Autoritatív: `docs/partner-integracio.md` 3–3a. szakasz

## Hitelesítés

A gépi kliens `client_credentials` grant-ot használ, `client_secret_post`
módszerrel. A tokenhez az `audience` paramétert is küldd (a SkillPass jelenleg
nem kényszeríti, de elvárás):

```bash
curl -X POST https://skillpass.id/oauth2/token \
  -d "grant_type=client_credentials" \
  -d "client_id=$SKILLPASS_M2M_CLIENT_ID" \
  -d "client_secret=$SKILLPASS_M2M_CLIENT_SECRET" \
  -d "scope=trainings:write" \
  -d "audience=https://skillpass.id/api"
```

## Scope → végpont leképzés

| Scope | Végpont |
|-------|---------|
| `trainings:write` | `POST /api/v1/profile/trainings` |
| `entitlements:write` | `POST /api/v1/profile/entitlements`, `PATCH /api/v1/profile/entitlements/{external_id}` |
| `entitlements:read` | `GET /api/v1/profile/entitlements/users/{sub}` |
| `tickets:write` | `POST /api/v1/profile/event-tickets` |
| `credits:write` | `POST /api/v1/profile/credits/balance` |

Least-privilege elv: csak a szükséges scope-ot kérd. Pl. csak képzés-push:
`scope=trainings:write`.

## Token gyorsítótárazás

Gyorsítótárazd a tokent folyamat szinten. A lejárat előtt 60 másodperccel
dobod el (biztonsági ráhagyás):

```typescript
const TOKEN_SKEW_SECONDS = 60;
// expires_at = now + expires_in - TOKEN_SKEW_SECONDS
if (cached && cached.expiresAt > Date.now() / 1000) return cached.value;
```

## Idempotencia

Minden írás idempotens a `(hívó kliens, external_id)` kulcson. A más kliens
által push-olt sorokat nem látod és nem módosíthatod.

## Hibakezelés

| HTTP | Teendő |
|------|--------|
| 401 (`invalid_token`) | Kérj új tokent, ismételd egyszer |
| 403 (`insufficient_scope`) | Ne ismételd, naplózz |
| 404 | Ismeretlen user / nem a te sorod |
| 409 (`credits/stale-snapshot`) | Régebbi `as_of` → ne ismételd |
| 429 / 5xx | Exponential backoff, újrapróbálkozás |

Megjegyzés: 2026-09-12-ig a hiányzó/érvénytelen token is 403-at adott; azóta
helyes 401. Mindkét esetet kezeld.

## Képzés push példa

```typescript
await fetch(`${issuer}/api/v1/profile/trainings`, {
  method: "POST",
  headers: {
    Authorization: `Bearer ${m2mToken}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    user_id:      idTokenSub,           // id_token.sub
    external_id:  "AI-BOOTCAMP-2026",   // idempotencia kulcs
    title:        "AI Bootcamp 2026",
    provider:     "Portál neve",
    entity_ref:   "portal:ai-bootcamp", // hitelesített értékeléshez
    status:       "completed",
    started_at:   "2026-07-01T09:00:00Z",
    completed_at: "2026-08-01T17:00:00Z",
    certificate_url: "https://portal.hu/cert/123",
  }),
});
```

`completed` státuszhoz a `completed_at` kötelező.

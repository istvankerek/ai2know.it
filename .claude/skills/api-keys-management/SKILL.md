---
name: api-keys-management
description: >
  API kulcs generalas, kezeles, rotacio, rate limiting per key,
  scope-olt hozzaferes, audit log.
  Triggerek: "api key", "api kulcs", "token generalas", "api hozzaferes".
  NE hasznald: felhasznaloi auth (-> skillpass-auth), session token.
model: claude-sonnet-4-6
---

# API Keys Management

## Felelossegek
- API key generalas (prefix: ek_live_, ek_test_)
- Key scope (milyen endpoint-okhoz fer hozza)
- Rate limit per key
- Key rotacio (expiry + auto-regeneralas)
- Key revoke
- Usage tracking (melyik key hany hivast csinalt)
- Admin UI: /admin/settings/api-keys
- Audit log minden key muveletrol

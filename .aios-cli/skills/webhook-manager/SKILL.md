---
name: webhook-manager
description: >
  Webhook rendszer: kulso rendszerek ertesitese esemenyek utan,
  retry logika, signature verification, webhook log.
  Triggerek: "webhook", "callback", "event notification".
  NE hasznald: in-app notification, email, belso esemenyek.
model: claude-sonnet-4-6
---

# Webhook Manager

## Felelossegek
- Webhook endpoint regisztracio (admin UI)
- Event tipusok konfiguracio (CRUD esemenyek)
- HTTP POST kuldes (JSON payload)
- HMAC signature (webhook secret)
- Retry logika (exponential backoff, max 5 proba)
- Webhook log (kuldes idopont, statusz, valasz)
- Admin UI: /admin/settings/webhooks

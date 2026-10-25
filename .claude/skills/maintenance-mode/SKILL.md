---
name: maintenance-mode
description: >
  Karbantartasi mod: Caddy szintu + backend szintu intercept,
  admin IP whitelist, 503 oldal, tervezett karbantartas ertesites.
  Triggerek: "maintenance", "karbantartas", "leallitas".
  NE hasznald: normal uzemeles, deploy, feature fejlesztes.
model: claude-haiku-4-5-20251001
---

# Maintenance Mode

## Felelossegek
- Caddy szintu 503 intercept
- Backend middleware (maintenance.rs)
- Admin IP whitelist (admin felulet elerheto marad)
- Tervezett karbantartas ertesites (alert-system)
- make maintenance-on / make maintenance-off

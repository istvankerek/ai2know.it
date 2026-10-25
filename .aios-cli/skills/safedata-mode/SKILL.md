---
name: safedata-mode
description: >
  Csak olvashato mod: irasi muveletek letiltasa, 423 Locked valasz,
  DB karbantartas, migracio alatti vedelem.
  Triggerek: "safedata", "read-only", "csak olvashato", "locked".
  NE hasznald: normal uzemeles, maintenance mode.
model: claude-haiku-4-5-20251001
---

# SafeData Mode

## Felelossegek
- Backend middleware (safedata.rs)
- 423 Locked valasz irasi muveletekre
- Admin UI toggle (/admin/settings/maintenance)
- DB migracio elotti automatikus bekapcsolas

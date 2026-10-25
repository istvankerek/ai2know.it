---
name: db-migration
description: >
  Adatbazis migracio: inkrementalis, visszafordithato (up+down),
  dry-run, seed data, schema diff.
  Triggerek: "migracio", "migration", "schema valtozas", "db alter", /db-migrate.
  NE hasznald: seed data (-> egyedi script), backup (-> backup-strategy).
model: claude-sonnet-4-6
---

# DB Migration

## Felelossegek
- Idopecsetes migracios fajlok (migrations/postgres/, migrations/mongodb/)
- UP + DOWN migracio (visszafordithato)
- Dry-run lehetoseg
- Schema diff (jelenlegi vs uj)
- Schema-per-service betartas
- Index letrehozas (FK, gyakori szurok)
- ./scripts/migrate.sh
- Prod migracio: L1 APPROVE + Plan Mode kotelzo!

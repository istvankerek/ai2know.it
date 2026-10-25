# Plan-v0 – Implementációs jegyzetek

## 2026-10-18 – Előkészítés (a terv előtt, owner kérésére)

- Elvégezve: skeleton 8.0.0 telepítve a `/Users/everengine/Documents/dev/ai2know.it` mappába
  (`install.sh`, 24 fájlban `{{PROJECT_NAME}}` → `ai2know.it`); regisztráció a skeleton
  `projects/projects.list` és `projects/ai2know.it.md` fájljaiban; `/backup/` a `.gitignore`-ban;
  `git init -b main` (commit nincs).
- Ellenőrzés: `git check-ignore` a backup readme-re, `.env`-re, zipre és SQL dumpra → mind ignorált;
  `git status` 0 fájlt mutat a `backup/` alól.
- Átvizsgálás: a legacy forrás (hu, en, auth, orders, tracker, backup, backup_server, caddy, docs)
  és a 2026-10-17-es dump aggregált elemzése (PII nem került a plan mappába).
- Eltérés a tervtől: nincs (még nincs elfogadott terv).

## {{DATUM}} – F{{X}}: {{fázis neve}}

- Elvégezve:
- Eltérés a tervtől:
- Teszt:
- Validáció: `tests/skeleton-validation/run-all.sh` →
- Commit:

## Telepítés és smoke

- Környezet:
- Parancs:
- Smoke:
- Migráció után restart-teszt (L-08):

---
name: deploy-pipeline
description: >
  Deploy pipeline: pre-flight check, build, migrate, deploy, health check,
  rollback terv, environment kezeles (test/prod).
  Triggerek: "deploy", "telepites", "release", /deploy.
  NE hasznald: lokalis fejlesztes, docker compose up.
model: claude-sonnet-4-6
---

# Deploy Pipeline

## Felelossegek
- Pre-flight check (tesztek, lint, type check)
- Build (frontend dist/, backend binary)
- DB migracio (automatikus)
- Deploy (Docker image push + restart)
- Health check (deploy utan)
- Rollback terv es script
- Environment kezeles (test/prod)
- Prod deploy: L1 APPROVE kotelzo!

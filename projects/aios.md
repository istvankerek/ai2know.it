---
name: aios
path: /Users/everengine/Documents/dev/aios
deployed_version: 7.7.0
type: existing
status: needs-merge
last_sync: 2026-06-14
github_remote: https://github.com/istvankerek/aios.git
---

# aiOS

## Cel
AI-driven OS management platform. Domain registrar, cost tracking, infrastructure
monitoring + AI chat interface.

## Tech stack
- Backend: Rust/Axum
- Dashboard: Vite + React Router v7
- DB: PostgreSQL (schema-per-service)
- Cache: Redis
- AI: Claude API + RAG (Qdrant)

## Status notes
- 2026-05-03: skeleton 7.4.0 initial sync (no `.skeleton-version` korabban)
- Saját 33KB CLAUDE.md (project-specific, NEM cseréljük)
- 21 uncommitted change a sync előtt — user feature munka
- Latest commit: `ee7089f2 v0.19.1: API port fix (8000), CostPage nullsafe, migration column fix`

## Skeleton komponensek
- v7.4 hozzaadva: `.claude/{agents,hooks,skills,workflows,...}/`
- Existing `.claude/settings.json` MEGMARAD (manualis merge ha kell)
- Saját `aios-versions/` mappa (24 verzio history) erintetlen

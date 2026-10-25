---
name: aibos
path: /Users/everengine/Documents/dev/aibos
deployed_version: 7.7.0
type: new
status: bootstrapped
last_sync: 2026-06-14
github_remote: https://github.com/istvankerek/aibos.git
---

# aiBOS

## Cel
AI-driven Business Operating System. CRUD + DLA admin platform AI chat-tel,
modul marketplace-szel, multi-tenant tamogatassal.

## Tech stack
- Backend: Rust/Axum (tervezett)
- Frontend: Vite + React Router v7 + AG Grid Enterprise
- DB: PostgreSQL (schema-per-service)
- AI: Claude API + RAG (Qdrant)
- Auth: aibos-auth (sajat operatori auth, kotelezo TOTP) – az okoszisztema egyetlen kivetele; skillpass.id OIDC csak flag mogott

## Status notes
- 2026-05-03: skeleton 7.4.0 initial bootstrap
- Eredetileg TELJESEN URES mappa
- Nincs github remote — push manualis
- CLAUDE.md template + README.md template + .gitignore copy-olva

## Skeleton komponensek
- Teljes `.claude/` framework (100 skill)
- `crud-dla-module` skill (P0) — kotelezo modul minta
- `aibos-admin-contract` skill — partner admin API-k fogyasztasa (aibos.space konzol)
- `ai-chat-admin` skill — AI chat felulet
- `parallel-reviewer-orchestrator` skill — code review pipeline

## Next steps
1. Nyiss meg egy uj Claude session aibos-ben es kezd a `/project:plan`-nel
2. CLAUDE.md customizalas
3. apps/{frontend,admin,backend,ai-chat}/ scaffold (`bash scripts/create-project.sh` vagy manualis)
4. Github repo: `gh repo create istvankerek/aibos` + push

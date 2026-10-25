---
name: cmn
path: /Users/everengine/Documents/dev/cmn
deployed_version: 7.7.0
type: new
status: bootstrapped
last_sync: 2026-06-14
github_remote: nincs
active_cli: codex
---

# CMN AdStack

## Cel
Modern, nagy forgalmu, eroforras-takarekos hirdeteskezelo, tracking es
weboldal-monitoring rendszer AI-alapu hirdetesajanlo modullal.

## Tech stack
- Runtime: Rust stable, tobb kulonallo kontenerizalt service
- HTTP: Axum vagy Actix Web Tokio runtime-on
- Data: Postgres admin/config/audit, Redis serving cache es bounded Streams, ClickHouse tracking es analytics
- Gateway: Caddy Cloudflare mogott, host alapu routinggal
- AI: kulon `ai-recommender` service es batch training pipeline

## Status notes
- 2026-06-05: skeleton 7.6.0 initial bootstrap a `specification/plan-v0/` alapjan
- A celrepo korabban csak CMN specifikaciot tartalmazott
- A skeleton masolas nem visz at `.git` tartalmat, lokalis `.env` fajlokat vagy skeleton-specifikus tervarchivumot
- A `specification/CMN_CODEX_DEVELOPMENT_INSTRUCTIONS.md` Python/FastAPI nevei logikai service-nevek; a plan-v0 szerint a megvalositas Rust workspace

## Skeleton komponensek
- Multi-CLI shared kernel (`.aios-cli/`)
- Codex CLI projekt layer (`AGENTS.md`, `.codex/`)
- Claude Code skill/rule/hook/agent framework (`.claude/`)
- Validacios es fejlesztoi scriptek (`scripts/`, `tests/skeleton-validation/`)
- Docker, infra, docs es project registry alapstruktura

## CMN service mapping
- `cmn.pics` -> `cmn` loader/embed service
- `a.cmn.pics` -> `admin` admin UI/API service
- `ads.cmn.pics` -> `ads` Redis-first ad serving service
- `t.cmn.pics` -> `click` tracking es 302 redirect service
- `cdn.cmn.pics` -> `cdn` image serving es image-open tracking service

## Kovetkezo lepesek
1. CMN-specifikus Rust workspace scaffold: `Cargo.toml`, `crates/*`, `services/*`
2. Compose alap: Postgres, Redis, ClickHouse, Caddy es minden CMN service
3. Phase 1 acceptance: `docker compose config`, health endpointok, Caddy host routing
4. Phase 2 admin/config modell es Redis cache rebuild

## Hivatkozott
- Plan: `specification/plan-v0/`
- Codex utasitas: `specification/CMN_CODEX_DEVELOPMENT_INSTRUCTIONS.md`

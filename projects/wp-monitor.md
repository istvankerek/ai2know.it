---
name: wp-monitor
path: /Users/everengine/Documents/dev/aibootcamp/wp-monitor
deployed_version: 7.7.0
type: existing
status: synced
last_sync: 2026-06-14
github_remote: https://github.com/istvankerek/wp-monitor.git
active_cli: codex
---

# WP Monitor

## Cel
WordPress / WooCommerce / Elementor management bridge. Monorepo: WP plugin
(`monitor-plugin/`) HMAC-szel beszel egy Next.js + Rust admin app-pal
(`wpmonitor.hu/`).

## Tech stack

### `monitor-plugin/` (WP plugin)
- PHP 7.4+ (8.2 ajanlott)
- WordPress 6.0+, WooCommerce 7.0+, Elementor (Pro)
- WordPress Coding Standards (PHPCS WPCS)
- REST namespace: `ewm/v1` (HMAC-vedett)

### `wpmonitor.hu/` (admin app)
- Backend: Rust + Axum + sqlx
- Frontend: Next.js 14+ App Router + TypeScript strict
- DB: PostgreSQL (schema-per-service)
- Reverse proxy: Caddy
- Container: Docker Compose

## Status notes
- **2026-05-06:** skeleton 7.4.0 initial sync + **Codex CLI-re optimalizalva**
- **Aktiv CLI:** OpenAI Codex (`AIOS_ACTIVE_CLI=codex`) — NEM Claude Code
- **Monorepo strategia:** root `AGENTS.md` + `monitor-plugin/AGENTS.md` + `wpmonitor.hu/AGENTS.md`
- **HMAC bridge:** `EWM_API_KEY` + `EWM_API_SECRET`, ±300s replay window
- **Saját git history:** 3 pre-existing commit (`Initial WP Monitor bridge`, `Add WP Monitor app stack`, `monitor update plugin and admin`)

## Skeleton komponensek
- Multi-CLI shared kernel (`.aios-cli/`)
- 9-script `tests/skeleton-validation/`
- WordPress-specifikus rules: `.claude/rules/wordpress.md`
- v7.3 didaktikai onboarding (`docs/onboarding/two-view-approach.md`)
- v7.4 role-based agentek (referencia, Codex-szel nem aktiv)

## Codex sajatossagok
- A `.claude/skills/` rendszer **nem aktiv** Codex-szel (Claude-specifikus)
- Hookok (PreToolUse / PostToolUse) **nem futnak** Codex-szel
- Az AGENTS.md sablonok (`AGENTS.md`, `*/AGENTS.md`) az **elsodleges konfig**
- `generate-cli-configs.sh codex` regeneralja az AGENTS.md-t (de a customizalt verzio elsobbseget elvez)

## Next steps
1. PHPCS install + `scripts/validate-plugin.sh` zold
2. Rust + TS dependency install (`cd wpmonitor.hu && cargo build && cd services/frontend && npm i`)
3. Docker compose lokalisan: `cd wpmonitor.hu && docker compose -f compose.local.yaml up -d`
4. HMAC env varok beallitasa: `EWM_API_KEY`, `EWM_API_SECRET`, `EWM_BASE_URL`
5. Pelda HMAC hivas: `scripts/hmac-request-example.sh GET /wp-json/ewm/v1/status`

## Hivatkozott
- **Plan:** `specification/plan-v0/`
- **Plugin docs:** `monitor-plugin/DOKUMENTACIO.md`
- **Admin docs:** `wpmonitor.hu/docs/`

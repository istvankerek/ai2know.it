---
name: aiagentday.hu
path: /Users/everengine/Documents/dev/aibootcamp/aiagentday.hu
deployed_version: 7.7.0
type: existing
status: synced
last_sync: 2026-06-14
github_remote: https://github.com/istvankerek/aiagentday.hu.git
active_cli: codex
---

# aiagentday.hu

## Cel
Magyar AI Agent Day esemeny / kepzes landing oldala. Single Next.js 15 + React 19
marketing site, Caddy mogott deploy-olva (titan szerver).

## Tech stack
- Framework: Next.js 15.3+ (App Router)
- Runtime: React 19, React DOM 19
- Nyelv: TypeScript 5.8 strict
- Deployment: Docker + Caddy (titan szerver)
- Domain: aiagentday.hu (+ www redirect)

## Status notes
- **2026-05-06:** skeleton 7.4.0 initial sync + **Codex CLI-re optimalizalva**
- **Aktiv CLI:** OpenAI Codex (`AIOS_ACTIVE_CLI=codex`)
- **Single-app** struktura (NEM monorepo, ellentetben a wp-monitor-rel)
- **Ket ugyanolyan nevu mappa:**
  - `aiagentday.hu/` (repo root) — Git repo, deploy script, specifikacio
  - `aiagentday.hu/aiagentday.hu/` — A tenyleges Next.js alkalmazas

## Skeleton komponensek
- Multi-CLI shared kernel (`.aios-cli/`)
- 9-script `tests/skeleton-validation/`
- v7.3 didaktikai onboarding (`docs/onboarding/two-view-approach.md`)
- v7.4 role-based agentek (referencia, Codex-szel nem aktiv)

## Codex sajatossagok
- Egyetlen root `AGENTS.md` (a wp-monitor monorepo-val ellentetben nincsenek per-subdir AGENTS.md fajlok)
- Tartalmi munka magyarul, ekezetekkel
- A11y WCAG AA alapszint
- Mobile responsive figyelmes (lasd `Fix mobile hero layout` git history pattern)

## Specifikacio mappak
- `specification/ai-agant-day/` — esemeny spec
- `specification/elementor/` — design referenciak (eredeti landing tervek)
- `specification/plan-v0/` — fejlesztesi terv fazisonkent
- `specification/skills/` — kepzes modulok

## Deployment
```bash
./scripts/deploy-domain-to-titan.sh
```
Rsync `.syncignore` szerint (kizar: `.git/`, `node_modules/`, `.next/`, `specification/`).

## Next steps
1. `cd aiagentday.hu && npm install`
2. `npm run dev` lokalisan tesztelve
3. `npm run typecheck` zold
4. Production: `docker compose -f aiagentday.hu/docker-compose.local.yml up -d`
5. Deploy: `./scripts/deploy-domain-to-titan.sh`

## Hivatkozott
- **Plan:** `specification/plan-v0/`
- **Spec:** `specification/ai-agant-day/`
- **Design:** `specification/elementor/`

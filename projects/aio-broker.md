---
name: aio.broker
path: /Users/everengine/Documents/dev/aio-broker
deployed_version: 8.0.0
type: existing
status: production
last_sync: 2026-10-14
github_remote: https://github.com/istvankerek/aio-broker.git
role: service
portal: none
admin: none
---

# AIO Broker

## Cel
Egyetlen publikus gateway az Everengine okoszisztema osszes domainjehez.
Caddy reverse proxy + Cloudflare Tunnel + WAF.

## Tech stack
- Gateway: Caddy
- CDN: Cloudflare Tunnel
- Auth proxy: SkillPass.ID integracio (cel; az app-kod ma meg a korabbi IdP-t hasznalja, lasd Nyitott)

## Status notes
- 2026-10-14: skeleton 7.6.0 → 8.0.0 sync (`./sync.sh --yes --project aio.broker`),
  branch `wip/claude-20260418-2308`, nincs commit. 44 modositott, 16 uj, 3 torolt fajl
  (torolve: `.claude/skills/everpass-auth/`, `.claude/identity/brand-evpass.md`).
  Kezzel karbantartott `CLAUDE.md` megorizve, `AGENTS.md` + `GEMINI.md` ujrageneralva,
  `.codex/skills` + `.gemini/skills` link, `.gitignore` ledger sor, `scripts/aios providers` OK.
- 2026-10-14: a regiszter 7.7.0-t mutatott, de a `.skeleton-version` 7.6.0 volt es nem letezett
  `.aios-cli/` — a 7.7.0 sync korabban valojaban nem futott le. Mostantol 8.0.0 mindketto.
- 2026-05-03: skeleton 7.4.0 sync (commit 31e0293); kesobb 7.6.0 (commit 0145244)
- 398+ commit ahead of `main` — feature-rich wip-en
- Production gateway minden Everengine projekthez

## Nyitott (skeleton-validation 2026-10-14: CLAUDE.md FAIL + Ecosystem FAIL)
1. `CLAUDE.md` kezzel karbantartott, hianyzik belole: "AIOS Skill Source" + `.aios-cli/skills`
   hivatkozas, okoszisztema szabaly ("skillpass.id az egyetlen"), lessons kivonat (L-01..),
   `scripts/aios` hivatkozas. Mintak a generalt `AGENTS.md`-ben. Owner jovahagyas kell a szerkeszteshez.
2. App-szintu IdP: backend (`apps/backend*/src/middleware/auth*.rs`, `modules/auth`), frontend
   (`apps/frontend/src/lib/auth/everpass-client.ts`), migraciok, docs, specification/plan-v0..v3
   meg a korabbi IdP-t hasznaljak (~50 fajl). SkillPass.ID migracio = kulon plan-v,
   plan-v15 4. hullam (`07-f7-flotta-sync-terv.md`).
3. Legacy `.everengine-cli/` (10 git-kovetett fajl) meg a repoban; a sync nem torli, semmi sem
   hivatkozik ra. Torles owner dontes.

## Skeleton komponensek
- Teljes `.claude/` framework (skills, rules incl. `ecosystem.md`, hooks, agents, workflows)
- `.aios-cli/` shared kernel + orchestrator (`scripts/aios`, `routing-policy.toml`, ledger gitignore-olva)
- skillpass-auth / skillpass-portal / skillpass-app-launcher / aibos-admin-contract / local-models / aios-orchestrator skillek
- `templates/{plan,portal,admin-contract}/`, `tests/skeleton-validation/` (v8.0 ecosystem teszttel)
- RTK auto-rewrite (v7.2), role-based agentek (v7.4)

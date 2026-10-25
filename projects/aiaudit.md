---
name: aiaudit
path: /Users/everengine/Documents/dev/aiaudit
deployed_version: 7.7.0
type: new
status: bootstrapped
last_sync: 2026-06-14
github_remote: nincs
active_cli: codex
---

# AI Audit Club

## Cel
Tobb ceges, tobb kampanyos AI audit es AI readiness SaaS portal a
`aiaudit.club` es `portal.aiaudit.club` domainekre.

## Tech stack
- Frontend: publikus landing + portal admin/app felulet
- Backend: multi-tenant assessment API, kampany es kitoltes kezeles
- Compliance: GDPR, AI Act, Infotv., NIS2 es audit naplozas
- AI: tamogato elemzes emberi validacios kapuval

## Status notes
- 2026-06-14: skeleton 7.7.0 initial bootstrap az AIOS shared kernel alapjan
- A celrepo korabban csak `specification/aiaudit_club_portal_atdolgozott_specifikacio.md`
  fajlt tartalmazott
- A bootstrap nem torli a meglevo specifikaciot

## Skeleton komponensek
- Multi-CLI shared kernel (`.aios-cli/`)
- Codex CLI projekt layer (`AGENTS.md`, `.codex/`)
- Claude Code skill/rule/hook/agent framework (`.claude/`)
- Validacios es fejlesztoi scriptek (`scripts/`, `tests/skeleton-validation/`)
- Docker, infra, docs es project registry alapstruktura

## Kovetkezo lepesek
1. Plan-v0 keszitese a specifikacio alapjan
2. Portal es landing architektura dontesek rogzitese
3. Tenant, kampany, tesztkatalogus es kitoltes modellek scaffoldja
4. Compliance, audit trail es jogosultsagi acceptance gate-ek

## Hivatkozott
- Spec: `specification/aiaudit_club_portal_atdolgozott_specifikacio.md`

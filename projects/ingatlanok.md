---
name: ingatlanok
path: /Users/everengine/Documents/dev/ingatlanok
deployed_version: 7.7.0
type: new
status: needs-merge
last_sync: 2026-06-14
github_remote: https://github.com/istvankerek/ingatlanok.git
---

# Ingatlan Monitor

## Cel
Magyar ingatlanpiacot figyelő rendszer: automatikusan gyűjti a hirdetéseket
10+ portálról, deduplikálja, tárolja, és értesít ha egy mentett keresésnek
megfelelő új hirdetés jelenik meg.

## Tech stack
- Backend: Rust (Cargo workspace, multi-crate)
- Database: PostgreSQL
- Scraper: Custom Rust scraper proxy pool-lal
- Notifications: Email/Telegram

## Status notes
- 2026-05-03: skeleton 7.4.0 initial sync (no `.skeleton-version` korabban)
- Saját 26KB CLAUDE.md (project-specific spec — NEM cseréljük)
- Saját `.claude/skills/` (1+ skill) — sync nem felulirja, csak hozzaad
- Latest commits: `55832c8 deploy`, `64d2407 vs code workspace`
- Production scraper futott

## Skeleton komponensek
- v7.4 hozzaadva: `.claude/{agents,hooks,workflows}/`
- Existing `.claude/skills/` MEGMARAD + skeleton skill-ek hozzaadva
- `scraper` skill (P2) — projekt fokozatos hasznalata
- `spider` skill (P2) — URL frontier crawl-hoz

## Next steps
1. Manuális `.claude/settings.json` merge (ha skeleton frissitett valamit)
2. Skill hasznalat: scraper, spider, db-migration
3. Push origin main

# Tech Lead Guide

## Felelossgek
- Kod review jovahagyas (L1 APPROVE muveletek)
- Architektura dontesek (ADR iras, docs/adr/)
- Deploy jovahagyas (prod)
- Security incident eszkalacio

## Claude Code hasznalat
- `/project:review` — kod review minden PR-hez
- `/project:security-scan` — heti biztonsagi scan
- Opus modell jogosultsag architektura dontesekhez
- Plan Mode kotelzo nagy valtoztatasoknal

## Fontos fajlok
- `CLAUDE.md` — fo konfiguracio (modositashoz L1 jovahagyas)
- `.claude/settings.json` — jogosultsagok es hook-ok
- `docs/adr/` — architekturalis dontesek
- `COORDINATION.md` — session allapot

## L1 APPROVE muveletek
- Prod deploy
- Adatbazis migracio
- Uj fuggoseg hozzaadasa
- Docker compose modositas
- Opus modell hasznalat
- Delete muveletek

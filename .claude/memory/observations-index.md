# Observations Index

> **Auto-generated** – ne szerkeszd kezzel.
> Everengine v6.5 Memory v2 (RAD) – Retrieval Augmented Distillation

## SQLite adatbazis

Az observations a `.claude/memory/observations.db` SQLite fajlban tarolodnak.

**Sema:** `_schema.sql`
**Inicializalas:** `sqlite3 observations.db < _schema.sql`

## Observation tipusok

| Tipus | Leiras |
|-------|--------|
| `bugfix` | Javitott hiba, a kivaito ok es megoldas |
| `discovery` | Uj felfedezese a rendszerrol |
| `decision` | Meghozott architektura vagy kod dontes |
| `gotcha` | Meglepetes, amibe belesethetunk |
| `pattern` | Bevalt kod vagy workflow minta |
| `trade-off` | Kompromisszum, amelyet vettunk |
| `how-it-works` | Rendszer mukodese reszletek |

## Hook-ok

| Hook | Event | Funkcioja |
|------|-------|-----------|
| `memory-context-load.sh` | SessionStart | global.md + mistakes.md + top 10 observation betoltese |
| `memory-relevance-check.sh` | UserPromptSubmit | Prompt kulcsszavakra relevans observation kereses |
| `memory-observation-capture.sh` | PostToolUse | Hiba es sikeres minta rogzitese |
| `memory-session-summary.sh` | Summary | Session osszegzese observationokbe |
| `memory-promote-patterns.sh` | SessionEnd | 3+ taggel elfordulo observation promotalasa patterns.md-be |

## Statisztika

<!-- Auto-frissul: sqlite3 observations.db "SELECT type, COUNT(*) FROM observations GROUP BY type" -->

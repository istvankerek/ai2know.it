---
name: memory-curator
description: |
  Memory v2 (RAD) kezelese: observations kereses, mentes, promotalas, cleanup.
  v7.1: minden SQLite write elott consolidation-lock.sh acquire_lock kotelezo
  (race protection autodream-memory-cycle workflow ellen).
  Triggerek: "mentsd ezt", "ezt jegyezd meg", "memory save", "memory search",
  "memory cleanup", "mit tudunk errol", "emlekezz erre", "jegyezd fel".
license: Everengine v6.5 + v7.1
priority: P1
model: claude-sonnet-4-6
---

## v7.1 Consolidation Lock (race protection)

**KOTELEZO** minden SQLite write muvelet (INSERT, UPDATE, DELETE) elott:

```bash
source scripts/consolidation-lock.sh
acquire_lock || exit 1
sqlite3 .claude/memory/observations.db "INSERT INTO observations ..."
# release_lock automatikusan fut a trap-ben (EXIT INT TERM)
```

A lock megelozi hogy concurrent autodream-memory-cycle (vasarnap 19:00) +
manual `/project:memory save` egymasba kapaszkodjon.

Lock fajl: `.claude/memory/.consolidation.lock` (gitignored, transient).
Timeout: 5 perc (300s).

---


# Memory Curator Skill

## Cel
A Memory v2 (RAD – Retrieval Augmented Distillation) rendszer kezelese.
Observations mentese, keresese, promotalasa es takaritasa.

## Eszkozok

### Kereses
```bash
sqlite3 .claude/memory/observations.db \
  "SELECT type, title, content FROM observations WHERE tags LIKE '%{tag}%' OR title LIKE '%{keresett}%' LIMIT 10;"
```

### Mentes
```bash
sqlite3 .claude/memory/observations.db \
  "INSERT INTO observations (session_id, type, title, content, tags) VALUES ('{session}', '{type}', '{cim}', '{tartalom}', '{tagek}');"
```

### Promotalas patterns.md-be
Futtasd a promote hook-ot:
```bash
bash .claude/hooks/memory/memory-promote-patterns.sh
```

### Cleanup (low confidence / regi)
```bash
# 90 napnal regebbi observation-ok torlese
sqlite3 .claude/memory/observations.db \
  "DELETE FROM observations WHERE timestamp < datetime('now', '-90 days') AND type NOT IN ('pattern', 'decision');"
```

## Observation tipusok
- `bugfix` – javitott hiba, okok es megoldas
- `discovery` – uj felfedezese a rendszerrol
- `decision` – meghozott architektura vagy kod dontes
- `gotcha` – meglepetes, amibe belesethetunk
- `pattern` – bevalt kod vagy workflow minta
- `trade-off` – kompromisszum, amelyet vettunk
- `how-it-works` – rendszer mukodese reszletei

## Subcommands

| Parancs | Leiras |
|---------|--------|
| `search <kulcsszo>` | Relevanc observations keresese |
| `save <tipus> <cim> <tartalom> [tagek]` | Uj observation mentese |
| `promote` | 3+ tagekkel rendelkez observationok promotalasa |
| `cleanup` | Regi / low-value observationok torlese |
| `list [tipus]` | Observationok listazasa tipus szerint |
| `stats` | Adatbazis statisztika |

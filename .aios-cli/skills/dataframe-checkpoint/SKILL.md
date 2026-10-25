---
name: dataframe-checkpoint
description: Pandas DataFrame state mentes (feather/parquet) – analyst session resume, hosszu transzformacio mentes, ne kelljen ujra futtatni a DB query-t. AKTIVAL: DATA_ANALYST_LAYER_ENABLED=true. Triggerek: "checkpoint", "save state", "mentsd a df-et", session continuity DA-ben.
license: Everengine v6.3.1
priority: P2 (opcionalis)
model: claude-haiku-4-5-20251001
requires_env: DATA_ANALYST_LAYER_ENABLED=true
---

# Dataframe Checkpoint (opcionalis)

## Funkcio
Hosszu DA pipeline-okon futott DataFrame-eket fastly menteni feather/parquet
formatumban, hogy a kovetkezo session ne kelljen ujra futtatni a 30 perces
DB query-t vagy a komplex JOIN-okat.

## Workflow

```python
# Az analyst session vegen:
df.to_feather("checkpoints/2026-04-25_user-cohort-q1.feather")

# Kovetkezo session-ben:
df = pd.read_feather("checkpoints/2026-04-25_user-cohort-q1.feather")
# Mar van a memoryban → folytathato analyst munka
```

## Konvenciok
- Mappa: `checkpoints/` (gitignored, mert nagy fajl)
- Nevezes: `{date}_{description}.feather`
- Format: feather (gyors, kompakt) elsobbsege
- Format: parquet (cross-tool, sklearn/spark) ha kell
- TTL: 14 nap (cleanup script: `find checkpoints/ -mtime +14 -delete`)

## Mikor NE hasznald
- Kis DataFrame (< 10K sor) – nem ér a checkpoint koltseg
- Hetente datolt scheduled report – inkabb regeneraljon
- Sensitive PII data – ha checkpoint commitolodna véletlenül (lasd .gitignore)

## Forras
- v7.0 master PART 3 Section 67
- Doc: `docs/data-analyst-layer.md`

---
description: Generate weekly token + cost report from ccusage data (v7.5)
---

# /project:token-report — Heti Token + Költség Riport

A `token-report` parancs aktivalja a `token-report-generator` skill-t.

## Mit ad

- Per-projekt + per-modell token breakdown (7 nap)
- Cache hit ratio (>= 0.5 healthy)
- Budget envelope osszevetes (.claude/everengine/budget.yaml)
- Top 3 optimalizacios javaslat (cache 1h breakpoint, subagent Haiku route, batch API)

## Lasd

- `.claude/skills/token-report-generator/SKILL.md`
- `.claude/everengine/budget.yaml`
- `ccusage` tool: https://github.com/ryoppippi/ccusage

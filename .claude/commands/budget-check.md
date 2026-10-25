---
description: Display current BudgetTier consumption + remaining envelope (v7.5)
---

# /project:budget-check — Budget Envelope Check

A `budget-check` parancs aktivalja a `cost-invariant-check` skill-t, ami:

1. Olvasa a `.claude/everengine/budget.yaml`-t (workspace envelope-ok)
2. Lekerdezi a `~/.claude/everengine/cost.jsonl`-t (per-projekt aggregat)
3. Kiszamolja a tier-szintu spend / envelope aranyt
4. Output tabla: Tier | Spent | Envelope | % | Status

## Lepesek

1. Run skill: `cost-invariant-check` (auto-trigger)
2. Show table + envelope warnings (≥90% red, ≥75% yellow)
3. Suggest top 3 cost-reduction recommendations

## Lasd

- `.claude/skills/cost-invariant-check/SKILL.md`
- `.claude/everengine/budget.yaml`
- `.claude/rules/00-token-discipline.md`

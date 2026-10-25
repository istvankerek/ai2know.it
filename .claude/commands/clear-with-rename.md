---
description: Session vege workflow rename + clear + future resume (v7.5)
---

# /project:clear-with-rename — Session Handoff Workflow

A `clear-with-rename` parancs aktivalja a `claude-code-session-handoff` skill-t.

## Mit csinal

1. Kerdezz: "Mi a leiro neve a session-nek?" (`auth-refactor-2026-05-08` minta)
2. Run: `/rename <descriptive-name>`
3. Run: `/clear` (uj kontextus)
4. Kesobb visszateres: `claude -r <descriptive-name>`

Cache-meleg prefix megorzese 5m TTL alatt, goal-preserving summary.

## Mikor NEM

- Mid-feature: hasznald `/compact <focus>` helyette
- Veszelyes kiserletre: hasznald `/branch <name>` helyette

## Lasd

- `.claude/skills/claude-code-session-handoff/SKILL.md`
- `.claude/rules/00-token-discipline.md` 5. pont

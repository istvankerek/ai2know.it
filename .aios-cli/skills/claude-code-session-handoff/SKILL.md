---
name: claude-code-session-handoff
description: >
  Session vege workflow: `/rename` descriptive name → `/clear` uj kontextus →
  kesobb `claude -r <name>` visszatolt. Mid-feature: `/compact <focus>`.
  Cache-meleg prefix megorzese, goal-preserving summary.
  Triggerek: "session vege", "rename and clear", "hand off session",
  "save session for later", /project:clear-with-rename.
license: Everengine v7.5
priority: P2
model: claude-sonnet-4-6
allowed-tools: Read
disable-model-invocation: false
---

# Claude Code Session Handoff

## Mikor hasznald

3 különböző szituációra 3 különböző workflow:

| Szituacio | Helyes parancs | Indok |
|-----------|----------------|-------|
| Uj, fuggetlen task | `/clear` | Friss kontextus, 5m cache meleg lehet meg |
| Folyamatban levo feature, context >70% | `/compact <focus>` | Goal-preserving summary |
| Hosszu session, partialis visszagorgetes | `Esc Esc` → "Summarize from here" | Pontos checkpoint summary |
| Session vege — folytatas kesobb | **`/rename <descriptive-name>`** → exit | Visszakerseheto |
| Folytatas | `claude -r <name>` (vagy `claude -c` last-session) | Resume preserves cached prefix |
| Veszelyes kiserlet | `/branch <name>` (regi `/fork`) | Kontextus atorokloodik |

## "Rename + Clear + Resume" workflow (Analytics Vidhya tip #5)

```bash
# 1. Task befejeztevel, a session lezarasahoz:
/rename auth-refactor-2026-05-08

# 2. Uj kontextus uj taskhoz:
/clear

# 3. Indulj az uj feladaton

# 4. Kesobb visszateres az eredeti session-hoz:
claude -r auth-refactor-2026-05-08
```

**Cache-side effect:** ha `/rename` utan 5 percen belul `claude -r`-rel visszaterzs,
a prefix-cache **meg meleg** (5m TTL), igy a resume cold-start nelkul indul.

## `/compact <focus>` — mid-feature

```
/compact "auth refactor — completed CreateUserEndpoint, still TODO: tests"
```

A `<focus>` szoveg vezerli a summary-t: ami az ehhez kapcsolodik, az **megmarad**;
ami nem, az **eldobodik** (old exploration paths, full log dumps, resolved debug chains).

## Compaction directive (CLAUDE.md-ben)

A CLAUDE.md tartalmazza a "compaction directive"-et, amit a `/compact` figyelembe vesz:

```markdown
## Compaction directive
When compacting, ALWAYS preserve:
- Goal of current task
- Files changed this session
- Failing test names + error lines
- Architecture decisions made
- Next 1–3 actions
DROP:
- Old exploration paths
- Full log dumps
- Resolved debugging chains
```

## Anti-pattern (NE)

- ❌ `/clear` mid-feature (cache-prefix elvesz, tudast is)
- ❌ Auto-compact-ig varni 200K context-nel (kenyszeritett summary rosszabb)
- ❌ `/rename` nelkul exit (resume helyett `claude -c`-t kell hasznalni — kevesbe visszakerseheto)
- ❌ `/branch` minden experimentre (context-fork dragabb mint subagent, ha izolacio kell)

## Output

Erre a skill-re NEM Claude general output-ot. **Te futtatod a parancsokat** a CLI-ben.
Ez a skill csak **dokumentalja** a helyes workflow-t.

## Hivatkozott

- Forras: v7.5 patch / Deliverable 1 / 3.4-3.5
- Rule: `.claude/rules/00-token-discipline.md` (5. pont: /compact 60-70%-nal)
- Command: `/project:clear-with-rename` (`.claude/commands/clear-with-rename.md`)
- Skeleton skill: `session-continuity` (P0, kontextus megorzes broader scope-on)

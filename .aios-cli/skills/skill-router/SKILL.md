---
name: skill-router
description: >
  Hook-alapu intelligens skill aktivalas fajl path alapjan.
  PreToolUse hook: a fajl kontextus alapjan javasolja a megfelelo skill-t.
  Triggerek: automatikus (PreToolUse hook).
  NE hasznald: manualisan – a hook automatikusan fut.
model: claude-haiku-4-5-20251001
---

# Skill Router

## Felelossegek
- PreToolUse hook (.claude/hooks/skill-router.sh)
- Fajl path alapu skill illesztes
- additionalContext javaslat a megfelelo SKILL.md-re
- Minta: test/* -> unit-test-writer, scraper/* -> scraper, stb.

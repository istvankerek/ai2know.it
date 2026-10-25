---
name: secret-detection
description: >
  Secret/credential detektalas kodban, PreToolUse hook, PreCommit guard,
  regex mintak (AWS, OpenAI, Anthropic, GitHub, DB connection string).
  Triggerek: automatikus (PreToolUse hook), "secret scan".
  NE hasznald: manualisan – ez hook-kent fut automatikusan.
model: claude-haiku-4-5-20251001
---

# Secret Detection

## Felelossegek
- PreToolUse hook (.claude/hooks/check-safety.sh)
- Regex mintak: AWS kulcsok, OpenAI/Anthropic tokenek, GitHub tokenek
- DB connection string detektalas
- .env tartalom kiszivargasanak megakadalyozasa
- L0 BLOCK: azonnali megallitas secret talalat eseten
- Okoszisztema mintak (v8.0): aibos services kulcs (`aibs_live_` / `aibs_test_`),
  SkillPass/Hydra/Ory kliens secret ertek, token bongeszo storage-ban, megszunt IdP
- `scripts/aios run`: titok a promptban → megall (exit 3), semmi nem hagyja el a gepet
  (mintak: `.aios-cli/orchestrator/aios/secrets.py`)

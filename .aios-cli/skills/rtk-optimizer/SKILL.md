---
name: rtk-optimizer
description: >
  RTK adoption check + missed savings opportunity-k azonositasa + config tuning.
  Heti audit: rtk session, rtk discover, rtk gain. Hungarian-specific gotchas.
  Triggerek: "rtk", "token savings", "csokkentsuk koltseget", "rtk gain",
  "rtk discover", "miert lassu", "rtk audit", "rtk adoption".
license: Everengine v7.2
priority: P2
model: claude-haiku-4-5-20251001
---

# RTK Optimizer

## A 4 fo optimalizacios kategoria

### 1. Adoption check
```bash
rtk session
# Output: "RTK adoption: 87% across last 10 sessions"
# Ha <90% → vizsgalat
```

### 2. Discover missed opportunities
```bash
rtk discover --since 7
# Output:
# Missed: pip list (8x in 7d) → could save ~3,200 tokens
# Missed: tsc --noEmit (15x) → could save ~12,000 tokens
# Missed: docker logs --tail 100 (4x) → could save ~6,400 tokens
```

### 3. Configuration tuning
```toml
# ~/.config/rtk/config.toml
[hooks]
exclude_commands = []  # Ures = minden megy RTK-n keresztul

[tee]
enabled = true         # Failure recovery
mode = "failures"      # Csak fail eseten
max_files = 50

[tracking]
database_path = "~/.local/share/rtk/history.db"
```

### 4. Per-project optimization
```bash
# Projekt-specifikus exclude (.rtk-config.toml)
echo 'exclude_commands = ["custom-internal-tool"]' >> .rtk-config.toml
```

## Heti audit workflow

```bash
# 1. Adoption
rtk session > /tmp/rtk-session.txt

# 2. Discover
rtk discover --all --since 7 --format json > /tmp/rtk-discover.json

# 3. Gain
rtk gain --since 7 --format json > /tmp/rtk-gain.json

# 4. Slack #dev-tools
cat << EOF | curl -X POST $SLACK_WEBHOOK -d @-
{
  "text": "Weekly RTK Report",
  "attachments": [
    {"title": "Adoption", "text": "$(cat /tmp/rtk-session.txt)"},
    {"title": "Token Savings", "text": "$(cat /tmp/rtk-gain.json | jq '.total_savings')"},
    {"title": "Missed", "text": "$(cat /tmp/rtk-discover.json | jq '.missed | length')"}
  ]
}
EOF
```

## Hungarian-specific gotchas

```
❌ NE hasznald RTK-zott parancsokat NAV szamitasok elott
   - Penzugyi adat ellenorzeshez kell a TELJES output
   - Pelda: rtk pip list → kompresszalt, lehet hogy a verzio string elvesz
   - Helyette: pip list (kozvetlen, no rtk)

❌ NE hasznald rtk-t kritikus prod parancsoknal
   - Database backup verification: kell a teljes hash
   - Pelda: pg_dump | sha256sum → ne RTK-zd a sha256sum-ot

✅ HASZNALD MINDIG:
   - Test futtatas (cargo test, pytest)
   - Build (cargo build, npm build)
   - Git ops (status, log, diff)
   - GitHub CLI (pr list, issue list)
   - Docker/K8s queries
   - AWS resource listing
```

## Tilalmak

❌ RTK config modositas user permission nelkul
❌ Tee log kuldese harmadik fel AI-nak (privacy!)
❌ RTK telemetry override felhasznaloi preference nelkul

## Hivatkozott

- Sister skill: `rtk-tee-recovery` (failure recovery)
- Routine: `.claude/routines/scheduled/daily-rtk-gain-export.yml`
- Workflow: `.claude/workflows/rtk-onboarding.yml`
- Config: `~/.config/rtk/config.toml`
- Forras: v7.2 patch Section 6

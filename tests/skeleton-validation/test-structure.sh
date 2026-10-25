#!/usr/bin/env bash
# Skeleton struktura ellenorzese
E=0
check() { [[ ! -e "$1" ]] && echo "  ❌ Hianyzik: $1" && E=$((E+1)); }

# Gyoker
check "CLAUDE.md"
check "AGENTS.md"
check "README.md"
check ".gitignore"

# .claude/
check ".claude/settings.json"
check ".claude/commands"
check ".claude/rules"
check ".claude/skills"
check ".claude/agents"
check ".claude/hooks"
check ".claude/workflows"
check ".claude/memory"
check ".claude/identity"

# docs/
check "docs/architecture.md"
check "docs/runbooks"
check "docs/adr"
check "docs/onboarding/two-view-approach.md"

# .aios-cli (multi-CLI)
check ".aios-cli/core"
check ".aios-cli/skills"
check ".aios-cli/scripts/generate-cli-configs.sh"

# Codex project layer (v7.6)
check ".codex/config.toml"
check ".codex/agents"
check ".codex/skills"

# Gemini project skill entry
check ".gemini/skills"

[[ $E -eq 0 ]]

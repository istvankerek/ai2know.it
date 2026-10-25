#!/bin/bash
# SessionEnd hook: Prompt dokumentacio Git-ben
# A session vegeztevel menti a session osszefoglalojat
PROMPT_LOG_DIR=".claude/prompt-log"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$PROMPT_LOG_DIR/session_${TIMESTAMP}.md"

# Prompt log konyvtar letezik-e
mkdir -p "$PROMPT_LOG_DIR"

# Session osszefoglalo mentes
cat > "$LOG_FILE" << EOF
# Session Log – ${TIMESTAMP}

## Datum
$(date +"%Y-%m-%d %H:%M:%S")

## Osszefoglalas
[Automatikusan generalva a session vegeztevel]

## Valtoztatott fajlok
$(git diff --name-only HEAD 2>/dev/null || echo "Nincs git info")

## Megjegyzesek
- Session vege: automatikus mentes
EOF

# Git-be adasl ha git repo-ban vagyunk
if git rev-parse --is-inside-work-tree &>/dev/null; then
  git add "$LOG_FILE" 2>/dev/null
fi

# WIP branch figyelmeztetes (v2.3.5)
WIP_BRANCHES=$(git branch --list "wip/claude-*" 2>/dev/null || true)
if [ -n "$WIP_BRANCHES" ]; then
  echo "" >&2
  echo "⚠️  Nem finalizalt WIP branch-ek:" >&2
  echo "$WIP_BRANCHES" >&2
  echo "Futtasd: /finalize" >&2
fi

exit 0

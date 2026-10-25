#!/bin/bash
# PostToolUse hook: automatikus micro-commit minden kod modositas utan.
# CSAK Edit|MultiEdit|Write tool-ok utan fut.
# Cel: "Never lose a line of work" — minden valtozas egy WIP branch-en.
#
# v2.3.5 Pyramid of Success / v3.0 master

set -euo pipefail

json=$(cat)
file_path=$(echo "$json" | jq -r '.tool_input.file_path // empty')

# Csak ha valodi fajl modosult (nem /tmp, nem node_modules, nem target)
if [[ -z "$file_path" ]]; then
  exit 0
fi

case "$file_path" in
  /tmp/*|*/node_modules/*|*/target/*|*/dist/*|*/.git/*)
    exit 0 ;;
esac

# Csak ha Git repo-ban vagyunk
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  exit 0
fi

# Aktualis branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

# Ha nem WIP branch-en vagyunk, hozzuk letre
if [[ "$CURRENT_BRANCH" != wip/claude-* ]]; then
  WIP_BRANCH="wip/claude-$(date +%Y%m%d-%H%M)"
  # Mentjuk melyik branch-rol indultunk
  echo "$CURRENT_BRANCH" > .git/claude-base-branch
  git checkout -b "$WIP_BRANCH" 2>/dev/null || git checkout "$WIP_BRANCH" 2>/dev/null || true
fi

# Auto-commit (--no-verify: ne futtasson pre-commit git hook-ot)
# A Claude Code PreToolUse hook-ok mar lefutottak (check-safety, check-injection)
git add "$file_path" 2>/dev/null || true

# Commit CSAK akkor, ha van staged valtozas
if ! git diff --cached --quiet 2>/dev/null; then
  git commit -m "wip: auto-save ${file_path##*/}" \
    --no-verify \
    --author="Claude Code <claude@everengine.hu>" \
    2>/dev/null || true
fi

exit 0

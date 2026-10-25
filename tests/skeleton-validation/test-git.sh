#!/usr/bin/env bash
# Git hygiene
git rev-parse --is-inside-work-tree &>/dev/null || { echo "  ⏭️ Nem git repo"; exit 0; }

E=0
[[ ! -f .gitignore ]] && { echo "  ❌ .gitignore hianyzik"; exit 1; }

# Kotelezo gitignore mintak (figyelmeztetes only)
for pattern in ".env" "node_modules" "target" ".DS_Store"; do
  grep -q "$pattern" .gitignore || echo "  ⚠️ .gitignore: '$pattern' hianyzik"
done

# CLAUDE.local.md (personal scope) gitignore-ban kell legyen
grep -q "CLAUDE.local.md" .gitignore || echo "  ⚠️ CLAUDE.local.md nincs gitignore-ban"

[[ $E -eq 0 ]]

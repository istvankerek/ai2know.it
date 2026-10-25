#!/usr/bin/env bash
# Agent ellenorzes
E=0
COUNT=$(ls .claude/agents/*.md 2>/dev/null | grep -v INDEX.md | grep -v FORKS.md | wc -l | tr -d ' ')
if [[ $COUNT -lt 5 ]]; then
  echo "  ❌ Keves agent (min 5): $COUNT"
  E=$((E+1))
fi

# Frontmatter check minden agent-en (kiveve INDEX/FORKS)
for a in .claude/agents/*.md; do
  basename=$(basename "$a")
  [[ "$basename" == "INDEX.md" || "$basename" == "FORKS.md" ]] && continue
  grep -q "^name:" "$a" || { echo "  ❌ name: hianyzik: $a"; E=$((E+1)); }
  grep -q "^description:" "$a" || { echo "  ❌ description: hianyzik: $a"; E=$((E+1)); }
  grep -q "^model:" "$a" || { echo "  ❌ model: hianyzik: $a"; E=$((E+1)); }
done

# v7.4 role-based agentek
for r in code-reviewer test-writer security-auditor doc-writer rust-specialist; do
  [[ ! -f ".claude/agents/${r}.md" ]] && { echo "  ❌ v7.4 role agent hianyzik: $r"; E=$((E+1)); }
done

[[ $E -eq 0 ]]

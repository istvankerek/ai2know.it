#!/usr/bin/env bash
# Skill ellenorzes
E=0
COUNT=$(find .claude/skills -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')
if [[ $COUNT -lt 50 ]]; then
  echo "  ❌ Keves skill: $COUNT (min 50)"
  E=$((E+1))
fi

# Kotelezo P0 skill-ek
for s in tdd-enforcer debug-3strike skillpass-auth crud-dla-module memory-curator; do
  if [[ ! -f ".claude/skills/${s}/SKILL.md" ]]; then
    echo "  ❌ Kotelezo P0 skill hianyzik: $s"
    E=$((E+1))
  fi
done

[[ $E -eq 0 ]]

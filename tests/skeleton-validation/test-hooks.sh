#!/usr/bin/env bash
# Hook ellenorzes
E=0

# Alap hookok
for h in .claude/hooks/check-bash-safety.sh .claude/hooks/auto-lint.sh .claude/hooks/rtk-rewrite.sh; do
  if [[ ! -x "$h" ]]; then
    echo "  ❌ Hook nem executable: $h"
    E=$((E+1))
  fi
done

# Agent Teams hooks (v7.4)
for h in .claude/hooks/agent-teams/teammate-idle.sh .claude/hooks/agent-teams/task-created.sh .claude/hooks/agent-teams/task-completed.sh; do
  if [[ ! -x "$h" ]]; then
    echo "  ❌ Agent Teams hook nem executable: $h"
    E=$((E+1))
  fi
done

[[ $E -eq 0 ]]

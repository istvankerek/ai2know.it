#!/usr/bin/env bash
# pre-bash-cap.sh — v7.5 "Lean Mind" PreToolUse Bash hook
# Auto-inject grep/head filtering for known noisy commands (cargo test, pnpm test, ...)
# Komplementer az rtk-rewrite.sh-val: az RTK csak parancs-prefixet csere (rtk git status),
# ez a parancs SUFFIX-ét modositja pipe-okkal.
#
# Output: JSON {"hookSpecificOutput": {"updatedInput": {"command": "..."}}}
# Exit 0: ok, 2: blokkolas (nem hasznaljuk most)

set -e
INPUT=$(cat)

# Csak ha enabled (default true)
if [ "${PRE_BASH_CAP_ENABLED:-true}" != "true" ]; then exit 0; fi

# Parancs kinyerese (grep alapon, jq nelkul)
CMD=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
[ -z "$CMD" ] && exit 0

# Skip ha mar tartalmaz pipe-ot vagy mar filterert (grep/head/tail)
if echo "$CMD" | grep -qE '\|\s*(grep|head|tail|awk|jq)'; then exit 0; fi
# Skip ha heredoc / komplex redirect
if echo "$CMD" | grep -qE "<<EOF|<<'EOF'|<<-EOF"; then exit 0; fi

# Auto-rewrite minta szerint
NEW=""
case "$CMD" in
  *"cargo test"*|*"cargo build"*|*"cargo check"*)
    NEW="$CMD 2>&1 | grep -B1 -A3 -E 'FAILED|panicked|error\[E|warning: unused' | head -150"
    ;;
  *"pnpm test"*|*"npm test"*|*"vitest"*|*"jest"*)
    NEW="$CMD 2>&1 | grep -A5 -E 'FAIL|ERROR|failed' | head -120"
    ;;
  *"pytest"*)
    NEW="$CMD 2>&1 | grep -B1 -A3 -E 'FAILED|ERROR|assert' | head -120"
    ;;
  *"docker logs"*)
    [ -n "$CMD" ] && NEW="$CMD --tail 100"
    ;;
esac

if [ -n "$NEW" ]; then
  ESCAPED=$(echo "$NEW" | sed 's/"/\\"/g')
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\",\"updatedInput\":{\"command\":\"$ESCAPED\"}}}"
fi
exit 0

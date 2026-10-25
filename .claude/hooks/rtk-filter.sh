#!/bin/bash
# .claude/hooks/rtk-filter.sh — PreToolUse Bash hook (v5.4)
#
# Hosszu terminal output-ot RTK (Rust Token Killer) on at szuri:
# - Eltavolit: OK/PASS sorok (csak szam), progress bar, ANSI, duplicate warnings
# - Megtart: FAILED/ERROR, stack trace, perf metrikak, summary
#
# Eredmeny: cargo test 15K → 1.5K token (~90% csokkenes)
#
# Aktivalodik: hosszu output parancsoknal (cargo test, npm test, kubectl logs, gh)

set -e

json=$(cat)
command=$(echo "$json" | jq -r '.tool_input.command // empty')

# Csak akkor aktivalunk, ha hosszu output varhato
PATTERNS=(
  "cargo test"
  "cargo build"
  "npm test"
  "npm run test"
  "kubectl logs"
  "docker logs"
  "gh pr list"
  "gh issue list"
)

needs_filter=0
for pattern in "${PATTERNS[@]}"; do
  if [[ "$command" == *"$pattern"* ]]; then
    needs_filter=1
    break
  fi
done

if [ $needs_filter -eq 0 ]; then
  exit 0
fi

# Ha a 'rtk' parancs nincs telepitve, csak figyelmeztetes
if ! command -v rtk &>/dev/null; then
  echo "{\"hookSpecificOutput\": {\"additionalContext\": \"💡 Token-optim tipp: telepitsd az 'rtk'-t (cargo install rtk) a terminal output szuresehez. Ez a parancs hosszu output-ot ad - ~60-90% token megtakaritast eredmenyezne.\"}}"
  exit 0
fi

# Itt jonne a tenyleges pipe modositas, de PreToolUse hook nem tudja a parancsot megvaltoztatni.
# Csak javaslatot teszunk a fejlesztonek.
echo "{\"hookSpecificOutput\": {\"additionalContext\": \"💡 Hosszu output detektalva. Token-optim: ${command} 2>&1 | rtk filter\"}}"

exit 0

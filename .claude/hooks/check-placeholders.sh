#!/bin/bash
# PostToolUse hook: figyelmeztet ha placeholder maradt a kodban.
# NEM blokkol (exit 0), csak stderr-re irja a figyelmeztetest.
#
# v2.3.5 Pyramid of Success / v3.0 master

json=$(cat)
file_path=$(echo "$json" | jq -r '.tool_input.file_path // empty')

# Csak forrasfajlokra
if [[ -z "$file_path" ]]; then
  exit 0
fi

case "$file_path" in
  *.ts|*.tsx|*.rs|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

# Placeholder minta kereses
if [ ! -f "$file_path" ]; then
  exit 0
fi

FOUND=$(grep -n \
  -e "// TODO" \
  -e "// FIXME" \
  -e "// HACK" \
  -e "/\* placeholder" \
  -e "Not implemented" \
  -e "lorem ipsum" \
  -e "throw new Error(\"Not implemented\")" \
  "$file_path" 2>/dev/null || true)

if [ -n "$FOUND" ]; then
  echo "⚠️  Placeholder detektalva: $file_path" >&2
  echo "$FOUND" >&2
  echo "" >&2
  echo "Kerlek valositsd meg teljesen, vagy jelezd ha nem tudod." >&2
  echo "Lasd: .claude/rules/code-style.md § No Placeholder szabaly" >&2
  # NEM blokkol — csak figyelmeztet
fi

exit 0

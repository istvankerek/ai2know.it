#!/usr/bin/env bash
# pre-read-warn.sh — v7.5 PreToolUse Read hook
# Figyelmeztet ha a Claude > 2000 sor fajlt olvas offset/limit nelkul.
# Exit 0: ok (figyelmeztetes stderr-en, nem blokkol)

set -e
INPUT=$(cat)
[ "${PRE_READ_WARN_ENABLED:-true}" != "true" ] && exit 0

FILE=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
HAS_LIMIT=$(echo "$INPUT" | grep -cE '"limit"[[:space:]]*:[[:space:]]*[0-9]')
HAS_OFFSET=$(echo "$INPUT" | grep -cE '"offset"[[:space:]]*:[[:space:]]*[0-9]')

[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

LINES=$(wc -l < "$FILE" 2>/dev/null || echo 0)
if [ "$LINES" -gt 2000 ] && [ "$HAS_LIMIT" -eq 0 ] && [ "$HAS_OFFSET" -eq 0 ]; then
  echo "[pre-read-warn] FIGYELMEZTETES: $FILE = $LINES sor (>2000). Hasznalj offset+limit-et a token-takarekossagert." >&2
fi
exit 0

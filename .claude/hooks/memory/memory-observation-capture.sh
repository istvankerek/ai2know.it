#!/usr/bin/env bash
# Memory v2 – PostToolUse hook
# Rogziti a jelentes eszkozhivasok eredmenyeit observationkent.
# Bash exit != 0 eseten 'gotcha' observation keletkezik.
# Everengine v6.5 RAD

set -e

MEMORY_DIR="$(cd "$(dirname "$0")/../.." && pwd)/memory"
DB="$MEMORY_DIR/observations.db"

if ! command -v sqlite3 &>/dev/null; then
    exit 0
fi

if [ ! -f "$DB" ]; then
    exit 0
fi

# Tool result beolvasasa stdin-bol (Claude Code hook contract: JSON)
TOOL_JSON=$(cat)

# Tool neve es exit code kinyerese grep/sed segitsegevel
TOOL_NAME=$(echo "$TOOL_JSON" | grep -o '"tool_name":"[^"]*"' | sed 's/"tool_name":"//;s/"$//' 2>/dev/null || echo "")
EXIT_CODE=$(echo "$TOOL_JSON" | grep -o '"exit_code":[0-9]*' | sed 's/"exit_code"://g' 2>/dev/null || echo "")
STDERR_OUT=$(echo "$TOOL_JSON" | grep -o '"stderr":"[^"]*"' | sed 's/"stderr":"//;s/"$//' 2>/dev/null | head -c 500 || echo "")

# Csak Bash tool hibakat rogzitunk
if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

# Ha exit code nem nulla: gotcha observation rogzitese
if [ -n "$EXIT_CODE" ] && [ "$EXIT_CODE" != "0" ]; then
    SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
    TITLE="Bash hiba: exit $EXIT_CODE"
    CONTENT=$(echo "$STDERR_OUT" | head -c 300 | tr "'" '"' | tr '\n' ' ')
    TAGS="bash-error,exit-$EXIT_CODE"

    sqlite3 "$DB" \
        "INSERT INTO observations (session_id, type, title, content, tags) VALUES ('$SESSION_ID', 'gotcha', '$TITLE', '$CONTENT', '$TAGS');" 2>/dev/null || true
fi

exit 0

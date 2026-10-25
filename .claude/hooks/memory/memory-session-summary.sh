#!/usr/bin/env bash
# Memory v2 – Summary event hook
# Session vegen osszegzo observation keszitese a session esemenyeibol.
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

# Session ID
SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%Y%m%d-%H%M%S)}"

# Summary szoveg beolvasasa stdin-bol
SUMMARY_JSON=$(cat)
SUMMARY_TEXT=$(echo "$SUMMARY_JSON" | grep -o '"summary":"[^"]*"' | sed 's/"summary":"//;s/"$//' 2>/dev/null | head -c 500 || echo "")

if [ -z "$SUMMARY_TEXT" ]; then
    # Fallback: alap session-summary
    SUMMARY_TEXT="Session lezarult: $SESSION_ID"
fi

# Sanitizalas: idezojel eltavolitas
SAFE_SUMMARY=$(echo "$SUMMARY_TEXT" | tr "'" '"' | tr '\n' ' ' | head -c 400)

# Session summary observation mentese
sqlite3 "$DB" \
    "INSERT INTO observations (session_id, type, title, content, tags) VALUES ('$SESSION_ID', 'discovery', 'Session osszegzo: $SESSION_ID', '$SAFE_SUMMARY', 'session-summary');" 2>/dev/null || true

echo "[MEMORY] Session summary elmentve (session: $SESSION_ID)" >&2

exit 0

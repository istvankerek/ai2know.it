#!/usr/bin/env bash
# Memory v2 – SessionStart hook
# Betolti a global.md-t, mistakes.md-t es a top 10 observation-t a session kontextusba.
# Everengine v6.5 RAD

set -e

MEMORY_DIR="$(cd "$(dirname "$0")/../.." && pwd)/memory"
DB="$MEMORY_DIR/observations.db"

# global.md betoltese
if [ -f "$MEMORY_DIR/global.md" ]; then
    echo "=== [MEMORY] Global projekt tudas ===" >&2
    cat "$MEMORY_DIR/global.md" >&2
fi

# mistakes.md betoltese
if [ -f "$MEMORY_DIR/mistakes.md" ]; then
    echo "" >&2
    echo "=== [MEMORY] Ne bukj el ugyanugy ===" >&2
    cat "$MEMORY_DIR/mistakes.md" >&2
fi

# Top 10 observation az adatbazisbol
if command -v sqlite3 &>/dev/null && [ -f "$DB" ]; then
    echo "" >&2
    echo "=== [MEMORY] Top 10 observation ===" >&2
    sqlite3 "$DB" \
        "SELECT '[' || type || '] ' || title || ': ' || content FROM observations ORDER BY timestamp DESC LIMIT 10;" >&2 2>/dev/null || true
else
    echo "[MEMORY] sqlite3 nem elerheto vagy DB hianyzik, kihagyas" >&2
fi

# Hook sikeresen lefutott – nincs output a stdout-ra (nem blokkolja a Claude-ot)
exit 0

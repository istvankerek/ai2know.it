#!/usr/bin/env bash
# TeammateIdle hook — Agent Teams (v7.4)
# Aktivalodik: amikor egy teammate befejezett egy feladatot es uresjaratban van
# Cel: feedback kuldes vagy uj feladat kiosztas
# Exit: 0 = ok, 2 = blokkolas (megakadalyozza a teammate folytatast)

set -e

# Hook input (JSON stdin a Claude Code 2026 Q1+ konvencio szerint)
INPUT=$(cat)

# Teammate metadata kinyerese (grep alapu, nem fugg jq-tol)
TEAMMATE_NAME=$(echo "$INPUT" | grep -oE '"teammate_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
LAST_TASK=$(echo "$INPUT" | grep -oE '"last_task"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

# Default: csak log, nem blokkol
echo "[TeammateIdle] ${TEAMMATE_NAME:-unknown} befejezte: ${LAST_TASK:-unknown}" >&2

# Memory observation (opcionalis, ha SQLite + observations.db elerheto)
if [ -n "$LAST_TASK" ] && command -v sqlite3 &> /dev/null; then
    DB="${MEMORY_OBSERVATION_DB:-.claude/memory/observations.db}"
    if [ -f "$DB" ]; then
        sqlite3 "$DB" \
            "INSERT INTO observations (type, source, content, ts) VALUES ('teammate-idle', '${TEAMMATE_NAME:-unknown}', '${LAST_TASK:-unknown}', datetime('now'))" \
            2>/dev/null || true
    fi
fi

exit 0

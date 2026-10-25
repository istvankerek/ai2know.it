#!/usr/bin/env bash
# Memory v2 – SessionEnd hook
# 3+ alkalommal elofordulo tag-u observation-okat promotalja patterns.md-be.
# Everengine v6.5 RAD

set -e

MEMORY_DIR="$(cd "$(dirname "$0")/../.." && pwd)/memory"
DB="$MEMORY_DIR/observations.db"
PATTERNS_FILE="$MEMORY_DIR/patterns.md"
THRESHOLD="${MEMORY_AUTO_PROMOTE_THRESHOLD:-3}"

if ! command -v sqlite3 &>/dev/null; then
    exit 0
fi

if [ ! -f "$DB" ]; then
    exit 0
fi

# Suru tagek keresese (legalabb THRESHOLD alkalommal szerepel)
FREQUENT_TAGS=$(sqlite3 "$DB" \
    "SELECT tag FROM (
        WITH RECURSIVE split(tag, rest) AS (
            SELECT '', tags || ',' FROM observations WHERE tags IS NOT NULL
            UNION ALL
            SELECT substr(rest, 0, instr(rest, ',')), substr(rest, instr(rest, ',')+1) FROM split WHERE rest != ''
        )
        SELECT trim(tag) as tag FROM split WHERE tag != ''
    )
    WHERE tag != 'session-summary' AND tag != 'bash-error'
    GROUP BY tag HAVING COUNT(*) >= $THRESHOLD;" 2>/dev/null || echo "")

if [ -z "$FREQUENT_TAGS" ]; then
    echo "[MEMORY] Nincsenek promotalhato tagek (kuszob: $THRESHOLD)" >&2
    exit 0
fi

# Minden suru taghez: osszes observation kinyerese
while IFS= read -r tag; do
    [ -z "$tag" ] && continue

    EXISTING=$(grep -F "**Tag:** $tag" "$PATTERNS_FILE" 2>/dev/null || echo "")
    if [ -n "$EXISTING" ]; then
        continue
    fi

    OBSERVATIONS=$(sqlite3 "$DB" \
        "SELECT '- [' || type || '] ' || title FROM observations WHERE tags LIKE '%$tag%' LIMIT 5;" 2>/dev/null || echo "")

    if [ -n "$OBSERVATIONS" ]; then
        # Promotalt minta hozzaadasa patterns.md vegere
        {
            echo ""
            echo "### Promotalt minta: $tag"
            echo "**Tag:** $tag"
            echo "**Promotalva:** $(date '+%Y-%m-%d')"
            echo ""
            echo "$OBSERVATIONS"
        } >> "$PATTERNS_FILE"
        echo "[MEMORY] Promotalva: '$tag' -> patterns.md" >&2
    fi
done <<< "$FREQUENT_TAGS"

exit 0

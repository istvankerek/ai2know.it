#!/usr/bin/env bash
# Memory v2 – UserPromptSubmit hook
# Keresi a relevans observation-oket a prompt kulcsszavai alapjan.
# Everengine v6.5 RAD

set -e

MEMORY_DIR="$(cd "$(dirname "$0")/../.." && pwd)/memory"
DB="$MEMORY_DIR/observations.db"

# Prompt beolvasasa stdin-bol (Claude Code hook contract: JSON)
PROMPT_JSON=$(cat)
# Kulcsszavak kinyerese grep/sed segitsegevel (no jq dependency)
PROMPT_TEXT=$(echo "$PROMPT_JSON" | grep -o '"prompt":"[^"]*"' | sed 's/"prompt":"//;s/"$//' 2>/dev/null || echo "")

if [ -z "$PROMPT_TEXT" ]; then
    # Fallback: nyers szoveg keresesi modszer
    PROMPT_TEXT=$(echo "$PROMPT_JSON" | grep -o '"[^"]*"' | tr -d '"' | head -20 | tr '\n' ' ')
fi

if ! command -v sqlite3 &>/dev/null; then
    exit 0
fi

if [ ! -f "$DB" ]; then
    exit 0
fi

# Kulcsszavak kinyerese (elso 5 szo, 4+ karakter)
KEYWORDS=$(echo "$PROMPT_TEXT" | tr ' ' '\n' | grep -E '^.{4,}$' | head -5 | tr '\n' '|' | sed 's/|$//')

if [ -z "$KEYWORDS" ]; then
    exit 0
fi

# LIKE keresek osszeallitasa
LIKE_CLAUSE=""
IFS='|' read -ra KW_ARRAY <<< "$KEYWORDS"
for kw in "${KW_ARRAY[@]}"; do
    if [ -n "$LIKE_CLAUSE" ]; then
        LIKE_CLAUSE="$LIKE_CLAUSE OR tags LIKE '%$kw%' OR title LIKE '%$kw%' OR content LIKE '%$kw%'"
    else
        LIKE_CLAUSE="tags LIKE '%$kw%' OR title LIKE '%$kw%' OR content LIKE '%$kw%'"
    fi
done

RESULTS=$(sqlite3 "$DB" \
    "SELECT '[' || type || '] ' || title || ': ' || content FROM observations WHERE $LIKE_CLAUSE LIMIT 5;" 2>/dev/null || echo "")

if [ -n "$RESULTS" ]; then
    echo "" >&2
    echo "=== [MEMORY] Relevans tapasztalatok ===" >&2
    echo "$RESULTS" >&2
fi

exit 0

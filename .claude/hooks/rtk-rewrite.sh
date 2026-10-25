#!/bin/bash
# .claude/hooks/rtk-rewrite.sh — v7.2
# PreToolUse Bash hook: auto-rewrite parancsokat RTK kompresszalt verziora.
# Pelda: "git status" → "rtk git status" (transzparens a Claude szamara).
#
# Toggle: RTK_AUTO_REWRITE_ENABLED=true (default)
# Skip:  heredoc parancsok, mar rtk-prefixelt, ismeretlen parancsok
# Output: JSON {"updatedInput": {"command": "rtk <original>"}}

set -e

# Hook input: JSON stdin
INPUT=$(cat)

# Toggle ellenorzes
if [ "${RTK_AUTO_REWRITE_ENABLED:-true}" != "true" ]; then
    exit 0
fi

# RTK binary jelen van? (issue #685 workaround: Claude Code restricted PATH miatt
# explicit path expansion szukseges, kulonben a Homebrew install nem talalhato)
RTK_BIN=""
if command -v rtk &> /dev/null; then
    RTK_BIN="rtk"
elif [ -x "/opt/homebrew/bin/rtk" ]; then
    RTK_BIN="/opt/homebrew/bin/rtk"
elif [ -x "/usr/local/bin/rtk" ]; then
    RTK_BIN="/usr/local/bin/rtk"
elif [ -x "$HOME/.cargo/bin/rtk" ]; then
    RTK_BIN="$HOME/.cargo/bin/rtk"
else
    exit 0
fi

# Parancs kinyerese (grep, jq nelkul)
COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"command"[[:space:]]*:[[:space:]]*"//;s/"$//')

if [ -z "$COMMAND" ]; then
    exit 0
fi

# Skip: mar rtk-prefixelt
if echo "$COMMAND" | grep -qE "^[[:space:]]*rtk[[:space:]]"; then
    exit 0
fi

# Skip: heredoc / multi-line / komplex output redirect
if echo "$COMMAND" | grep -qE "<<EOF|<<'EOF'|<<-EOF|>[[:space:]]*/"; then
    exit 0
fi

# Per-projekt exclude lista
DISABLED_LIST="${RTK_AUTO_REWRITE_DISABLED_COMMANDS:-}"
FIRST_WORD=$(echo "$COMMAND" | awk '{print $1}')

if [ -n "$DISABLED_LIST" ]; then
    if echo ",$DISABLED_LIST," | grep -q ",$FIRST_WORD,"; then
        exit 0
    fi
fi

# RTK-supported parancsok (100+ a hivatalos listaban, itt a leggyakoribbak)
SUPPORTED="git|gh|cargo|pytest|npm|pnpm|yarn|docker|kubectl|aws|ls|tree|cat|head|tail|grep|rg|find|jq|ruff|pip|go|tsc|eslint|prettier"

if ! echo "$FIRST_WORD" | grep -qE "^($SUPPORTED)$"; then
    exit 0
fi

# Rewrite output (JSON Hook contract)
# Note: \" escape kell mert a JSON-on belul vagyunk
# Hasznaljuk a felisert RTK_BIN-t, hogy restricted PATH-en is mukodjon (issue #685)
ESCAPED_CMD=$(echo "$COMMAND" | sed 's/"/\\"/g')
echo "{\"updatedInput\":{\"command\":\"$RTK_BIN $ESCAPED_CMD\"}}"

exit 0

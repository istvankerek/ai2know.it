#!/usr/bin/env bash
# post-tool-cost.sh — v7.5 PostToolUse hook
# Tool koltseg + token-hasznalat naplozas JSONL-be.
# Forward to AIOS aios-cost endpoint ha elerheto, fallback local jsonl.

set -e
INPUT=$(cat)
[ "${POST_TOOL_COST_ENABLED:-true}" != "true" ] && exit 0

# jq nelkul, grep-alapu parse
TOOL=$(echo "$INPUT" | grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"tool_name"[[:space:]]*:[[:space:]]*"//;s/"$//')
SESSION=$(echo "$INPUT" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"session_id"[[:space:]]*:[[:space:]]*"//;s/"$//')
TOKENS=$(echo "$INPUT" | grep -oE '"output_tokens"[[:space:]]*:[[:space:]]*[0-9]+' | head -1 | sed 's/^"output_tokens"[[:space:]]*:[[:space:]]*//')
MODEL=$(echo "$INPUT" | grep -oE '"model"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"model"[[:space:]]*:[[:space:]]*"//;s/"$//')
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p "$HOME/.claude/everengine"
LOG="$HOME/.claude/everengine/cost.jsonl"

echo "{\"ts\":\"$TS\",\"session\":\"${SESSION:-unknown}\",\"tool\":\"${TOOL:-unknown}\",\"tokens\":${TOKENS:-0},\"model\":\"${MODEL:-unknown}\"}" >> "$LOG"

# Optional: forward to AIOS aios-cost local endpoint (if running)
if [ -n "${AIOS_COST_URL:-}" ] && command -v curl &> /dev/null; then
  curl -sf -m 1 "$AIOS_COST_URL/aios-cost/record" \
    -H 'Content-Type: application/json' \
    -d "{\"session\":\"$SESSION\",\"tool\":\"$TOOL\",\"tokens\":${TOKENS:-0},\"model\":\"$MODEL\",\"tier\":\"External\"}" \
    >/dev/null 2>&1 || true
fi
exit 0

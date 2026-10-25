#!/usr/bin/env bash
# session-end-report.sh — v7.5 SessionEnd hook
# CSV roll-up + heti tendence-fajl frissites a $HOME/.claude/everengine/sessions/-ben.

set -e
INPUT=$(cat)
[ "${SESSION_END_REPORT_ENABLED:-true}" != "true" ] && exit 0

SESSION=$(echo "$INPUT" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"session_id"[[:space:]]*:[[:space:]]*"//;s/"$//')
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE=$(date +%Y-%m-%d)

DIR="$HOME/.claude/everengine/sessions"
mkdir -p "$DIR"
CSV="$DIR/sessions-${DATE:0:7}.csv"

# Header ha uj fajl
if [ ! -f "$CSV" ]; then
  echo "ts,session_id,tools_used,total_tokens" > "$CSV"
fi

# Aggregalas a cost.jsonl-bol
COST_LOG="$HOME/.claude/everengine/cost.jsonl"
if [ -f "$COST_LOG" ]; then
  TOTAL=$(grep -c "$SESSION" "$COST_LOG" 2>/dev/null || echo 0)
  TOKENS=$(grep "$SESSION" "$COST_LOG" 2>/dev/null | grep -oE '"tokens":[0-9]+' | awk -F: '{s+=$2} END {print s+0}')
  echo "$TS,${SESSION:-unknown},$TOTAL,${TOKENS:-0}" >> "$CSV"
fi
exit 0

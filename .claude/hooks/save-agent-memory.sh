#!/bin/bash
# .claude/hooks/save-agent-memory.sh — PreCompact hook (v5.2)
#
# Kontextus tomorites ELOTT mentse a kulcs informaciokat .agent_memory.md-be.
# A Claude egy LLM hivassal kivonatot keszit (max 50 sor).
#
# Tipus: prompt hook (NEM command), settings.json-ban kell registralni.
# Itt a fallback: ha valamilyen okbol command-kent fut, csak placeholder mentes.

set -e

MEMORY_FILE=".agent_memory.md"
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")

# Header frissites timestamp-tel (a tartalom mar bent van)
if [ -f "$MEMORY_FILE" ]; then
  # macOS sed
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/<!-- Frissult:.*-->/<!-- Frissult: $TIMESTAMP -->/" "$MEMORY_FILE" 2>/dev/null || true
  else
    sed -i "s/<!-- Frissult:.*-->/<!-- Frissult: $TIMESTAMP -->/" "$MEMORY_FILE" 2>/dev/null || true
  fi
fi

# A tenyleges kivonat keszitese a Claude prompt-jaba kerul (settings.json prompt hook).
# Ez a script csak a fajl letezeset es timestamp-et garantalja.

exit 0

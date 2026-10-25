#!/usr/bin/env bash
# pre-compact-backup.sh — v7.5 PreCompact hook
# Session JSONL backup mielott compact tortenne, hogy info ne vesszen el.

set -e
INPUT=$(cat)
[ "${PRE_COMPACT_BACKUP_ENABLED:-true}" != "true" ] && exit 0

SESSION=$(echo "$INPUT" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"session_id"[[:space:]]*:[[:space:]]*"//;s/"$//')
TRIGGER=$(echo "$INPUT" | grep -oE '"trigger"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"trigger"[[:space:]]*:[[:space:]]*"//;s/"$//')
TRIGGER="${TRIGGER:-auto}"
TS=$(date +%Y-%m-%d-%H-%M)

mkdir -p .claude/backups
SRC=".claude/sessions/${SESSION}.jsonl"
DST=".claude/backups/${TRIGGER}-${TS}.jsonl"

if [ -f "$SRC" ]; then
  cp "$SRC" "$DST" 2>/dev/null && echo "[pre-compact-backup] $DST" >&2 || true
fi
exit 0

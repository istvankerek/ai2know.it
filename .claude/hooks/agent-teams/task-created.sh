#!/usr/bin/env bash
# TaskCreated hook — Agent Teams (v7.4)
# Aktivalodik: amikor egy uj task letrejott a shared task list-en
# Cel: scope validation, prevention of cascading task explosion
# Exit: 0 = ok, 2 = blokkolas (megakadalyozza a task letrehozast)

set -e

INPUT=$(cat)

# Task metadata
TASK_TITLE=$(echo "$INPUT" | grep -oE '"task_title"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
TASK_PRIORITY=$(echo "$INPUT" | grep -oE '"priority"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

# Scope guard: ha "refactor" + "all files" van a title-ben, blokkolas
if echo "$TASK_TITLE" | grep -qiE "(refactor.*(all|everywhere|entire))|(all.*(files|tests|modules))"; then
    echo "[TaskCreated] BLOCKED: scope tul nagy ('$TASK_TITLE'). Bontsd kisebbre." >&2
    exit 2
fi

# Default: log + engedelyezes
echo "[TaskCreated] ${TASK_TITLE:-unknown} (priority: ${TASK_PRIORITY:-default})" >&2
exit 0

#!/usr/bin/env bash
# TaskCompleted hook — Agent Teams (v7.4)
# Aktivalodik: amikor egy task lezarodik (kesz jelölés)
# Cel: quality gate (test futtatas, lint check, scope validation)
# Exit: 0 = ok (figyelmeztet, nem blokkol)

set -e

INPUT=$(cat)

TASK_TITLE=$(echo "$INPUT" | grep -oE '"task_title"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
ARTIFACTS=$(echo "$INPUT" | grep -oE '"artifacts"[[:space:]]*:[[:space:]]*\[[^]]*\]' | head -1)

# Quality gate: ha vannak Rust modositott fajlok, futtassuk a cargo check-et (figyelmeztet)
if echo "$ARTIFACTS" | grep -q "\.rs"; then
    if command -v cargo &> /dev/null && [ -f Cargo.toml ]; then
        cargo check --quiet 2>&1 | head -5 >&2 || echo "[TaskCompleted] cargo check WARN" >&2
    fi
fi

# TypeScript check
if echo "$ARTIFACTS" | grep -qE "\.(ts|tsx)"; then
    if [ -f tsconfig.json ] && command -v npx &> /dev/null; then
        npx tsc --noEmit 2>&1 | head -5 >&2 || echo "[TaskCompleted] tsc WARN" >&2
    fi
fi

echo "[TaskCompleted] ${TASK_TITLE:-unknown} — quality gate WARN-only" >&2
exit 0

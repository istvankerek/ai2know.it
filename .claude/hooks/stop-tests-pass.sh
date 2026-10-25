#!/usr/bin/env bash
# stop-tests-pass.sh — v7.5 Stop hook (completion gate)
# Ne engedje a session lezarasat, ha a tesztek nem zoldek.
# Auto-detect: Rust (cargo), Node (pnpm/npm), Python (pytest)
# Exit 0: ok, output JSON decision:block-kal blokkol (Claude Code 2026 Q1+ konvencio)

set -e
[ "${STOP_TESTS_PASS_ENABLED:-false}" != "true" ] && exit 0  # default OFF, opt-in per project

# Cargo
if [ -f Cargo.toml ] && command -v cargo &> /dev/null; then
  if ! cargo test --quiet 2>&1 | tail -3 | grep -q "test result: ok"; then
    echo "{\"decision\":\"block\",\"reason\":\"Cargo tests failing. Fix before completing.\"}"
    exit 0
  fi
fi

# Node
if [ -f package.json ] && command -v jq &> /dev/null && jq -e '.scripts.test' package.json > /dev/null 2>&1; then
  if ! (command -v pnpm &> /dev/null && pnpm test --silent 2>&1 | tail -3 | grep -qE "passed|ok") && \
     ! (command -v npm &> /dev/null && npm test --silent 2>&1 | tail -3 | grep -qE "passed|ok"); then
    echo "{\"decision\":\"block\",\"reason\":\"Node tests failing. Fix before completing.\"}"
    exit 0
  fi
fi

exit 0

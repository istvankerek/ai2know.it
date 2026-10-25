#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TYPE=${1:-all}

has_placeholder() {
  [ -f "$1" ] && grep -q '{{' "$1"
}

run_node_if_ready() {
  local label="$1"
  local dir="$2"
  local command="$3"

  if [ ! -f "$ROOT/$dir/package.json" ]; then
    echo "[Skip] $label: nincs package.json"
    return
  fi

  echo "$label"
  (cd "$ROOT/$dir" && bash -lc "$command")
}

run_rust_if_ready() {
  local label="$1"
  local dir="$2"

  if [ ! -f "$ROOT/$dir/Cargo.toml" ]; then
    echo "[Skip] $label: nincs Cargo.toml"
    return
  fi
  if has_placeholder "$ROOT/$dir/Cargo.toml"; then
    echo "[Skip] $label: skeleton placeholder Cargo.toml"
    return
  fi

  echo "$label"
  (cd "$ROOT/$dir" && cargo test)
}

echo "=== Tesztek ($TYPE) ==="
if [ "$TYPE" = "all" ] || [ "$TYPE" = "unit" ]; then
  run_node_if_ready "[Unit] Frontend..." "apps/frontend" "npx vitest run"
  run_node_if_ready "[Unit] Admin..." "apps/admin" "npx vitest run"
  run_rust_if_ready "[Unit] Backend..." "apps/backend"
  run_rust_if_ready "[Unit] AI chat..." "apps/ai-chat"
fi
if [ "$TYPE" = "all" ] || [ "$TYPE" = "integration" ]; then
  run_node_if_ready "[Integration]..." "tests/integration" "npx vitest run"
fi
if [ "$TYPE" = "all" ] || [ "$TYPE" = "e2e" ]; then
  run_node_if_ready "[E2E] Playwright..." "tests/e2e" "npx playwright test"
fi
echo "=== Tesztek KESZ ==="

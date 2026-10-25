#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE=${1:-check}

has_placeholder() {
  [ -f "$1" ] && grep -q '{{' "$1"
}

run_node_lint_if_ready() {
  local label="$1"
  local dir="$2"

  if [ ! -f "$ROOT/$dir/package.json" ]; then
    echo "[Skip] $label: nincs package.json"
    return
  fi

  echo "$label"
  if [ "$MODE" = "fix" ]; then
    (cd "$ROOT/$dir" && npx eslint src/ --fix)
  else
    (cd "$ROOT/$dir" && npx eslint src/)
  fi
}

run_rust_fmt_if_ready() {
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
  if [ "$MODE" = "fix" ]; then
    (cd "$ROOT/$dir" && cargo fmt)
  else
    (cd "$ROOT/$dir" && cargo fmt -- --check)
  fi
}

echo "=== Lint ($MODE) ==="
run_node_lint_if_ready "[1/5] ESLint (frontend)..." "apps/frontend"
run_node_lint_if_ready "[2/5] ESLint (admin)..." "apps/admin"

if [ -f "$ROOT/package.json" ]; then
  if [ "$MODE" = "fix" ]; then
    echo "[3/5] Prettier write..."
    (cd "$ROOT" && npx prettier --write "apps/**/*.{ts,tsx,css,json}")
  else
    echo "[3/5] Prettier check..."
    (cd "$ROOT" && npx prettier --check "apps/**/*.{ts,tsx,css,json}")
  fi
else
  echo "[Skip] [3/5] Prettier: nincs root package.json"
fi

run_rust_fmt_if_ready "[4/5] Rust format (backend)..." "apps/backend"
run_rust_fmt_if_ready "[5/5] Rust format (ai-chat)..." "apps/ai-chat"
echo "=== Lint KESZ ==="

#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

has_placeholder() {
  [ -f "$1" ] && grep -q '{{' "$1"
}

build_node_if_ready() {
  local label="$1"
  local dir="$2"

  if [ ! -f "$ROOT/$dir/package.json" ]; then
    echo "[Skip] $label: nincs package.json"
    return
  fi

  echo "$label"
  (cd "$ROOT/$dir" && npm run build)
}

build_rust_if_ready() {
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
  (cd "$ROOT/$dir" && cargo build --release)
}

echo "=== Teljes Build ==="
build_node_if_ready "[1/5] Frontend build..." "apps/frontend"
build_node_if_ready "[2/5] Admin build..." "apps/admin"
build_rust_if_ready "[3/5] Backend build..." "apps/backend"
build_rust_if_ready "[4/5] AI chat build..." "apps/ai-chat"

if grep -R -q '{{PROJECT_NAME}}\|{{project-name}}' "$ROOT"/docker "$ROOT"/apps 2>/dev/null; then
  echo "[Skip] [5/5] Docker images: skeleton placeholder mode"
else
  echo "[5/5] Docker images..."
  (cd "$ROOT/docker" && docker compose build)
fi

echo "=== Build KESZ ==="

#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV=${1:-local}

load_env() {
  set -a
  [ -f "$ROOT/environments/.env.example" ] && . "$ROOT/environments/.env.example"
  [ -f "$ROOT/environments/.env.$ENV" ] && . "$ROOT/environments/.env.$ENV"
  set +a
}

template_mode() {
  grep -R -q '{{PROJECT_NAME}}\|{{project-name}}' "$ROOT/CLAUDE.md" "$ROOT/README.md" "$ROOT/apps" "$ROOT/docker" 2>/dev/null
}

compose_files() {
  case "$ENV" in
    local) echo "-f docker-compose.yml -f docker-compose.local.yml" ;;
    test)  echo "-f docker-compose.yml -f docker-compose.test.yml" ;;
    prod)  echo "-f docker-compose.yml -f docker-compose.prod.yml" ;;
    *)
      echo "Ismeretlen deploy env: $ENV" >&2
      exit 1
      ;;
  esac
}

echo "=== Deploy ($ENV) ==="
if [ "$ENV" = "prod" ]; then
  echo "FIGYELEM: Produkcio deploy! L1 jovahagyas szukseges!"
  read -p "Biztosan folytatod? (yes/no): " confirm
  [ "$confirm" != "yes" ] && echo "Megszakitva." && exit 1
  "$ROOT/scripts/backup-manual.sh"
fi

load_env

echo "[1/4] Pre-flight..."
"$ROOT/scripts/test.sh"
if [ -f "$ROOT/package.json" ]; then
  (cd "$ROOT" && npx tsc --noEmit)
else
  echo "[Skip] TypeScript root check: nincs package.json"
fi
"$ROOT/scripts/lint.sh" check

echo "[2/4] Build..."
"$ROOT/scripts/build.sh"

echo "[3/4] Migracio..."
"$ROOT/scripts/migrate.sh"

echo "[4/4] Deploy..."
FILES=$(compose_files)
if template_mode; then
  echo "[Template mode] Docker compose config smoke (kontenerek inditasa nelkul)"
  (cd "$ROOT/docker" && docker compose $FILES config >/dev/null)
else
  (cd "$ROOT/docker" && docker compose $FILES up -d)
fi

echo "=== Deploy KESZ ($ENV) ==="

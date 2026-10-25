#!/usr/bin/env bash
# Docker compose validacio (skip-friendly)
[[ ! -d docker ]] && { echo "  ⏭️ Nincs docker/ konyvtar"; exit 0; }

# Egy compose fajl kell legyen (akar prod akar dev)
COMPOSE_FILES=$(find docker -name "docker-compose*.yml" 2>/dev/null | wc -l | tr -d ' ')
if [[ $COMPOSE_FILES -eq 0 ]]; then
  echo "  ⏭️ Nincs docker-compose*.yml"
  exit 0
fi

# Ha van docker compose CLI, syntax check (warning only — env varok hianyozhatnak)
if command -v docker &> /dev/null; then
  for f in docker/docker-compose*.yml; do
    docker compose -f "$f" config --quiet 2>/dev/null || echo "  ⚠️ Compose validacio fail: $f (lehet missing env var)"
  done
fi
exit 0

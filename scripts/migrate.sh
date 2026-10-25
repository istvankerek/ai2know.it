#!/bin/bash
set -e
ACTION=${1:-up}
echo "=== DB Migracio ($ACTION) ==="
echo "[PostgreSQL] Migracio..."
# TODO: sqlx migrate run / rollback
echo "[MongoDB] Migracio..."
# TODO: mongodb migration tool
echo "=== Migracio KESZ ==="

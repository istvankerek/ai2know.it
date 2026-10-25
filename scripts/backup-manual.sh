#!/bin/bash
set -e
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
echo "=== Manualis Backup ($TIMESTAMP) ==="
mkdir -p backups
echo "[PostgreSQL] pg_dump..."
docker compose exec -T postgres pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" | gzip > "backups/postgres_${TIMESTAMP}.sql.gz"
echo "[MongoDB] mongodump..."
docker compose exec -T mongodb mongodump --archive | gzip > "backups/mongodb_${TIMESTAMP}.archive.gz"
echo "=== Backup KESZ ==="

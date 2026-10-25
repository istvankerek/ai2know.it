#!/bin/bash
set -e
echo "=== Szerver Migracio ==="
echo "FIGYELEM: Teljes rendszer koltoztetes!"
echo "[1/5] Maintenance mode..." # TODO: make maintenance-on
echo "[2/5] Teljes backup..." && ./scripts/backup-manual.sh
echo "[3/5] Docker image-ek mentese..." # TODO: docker save
echo "[4/5] Adatok atmasolasa..." # TODO: rsync/scp
echo "[5/5] DNS switch..." # TODO: Cloudflare API
echo "=== Szerver Migracio KESZ ==="

#!/usr/bin/env bash
# save-rtk-failure-observation.sh — v7.2
# Olvassa a legutobbi RTK tee log-ot, es elment egy memory observation-t
# (claude memory save) bug fix utan, hogy jovobeli session-ok visszakeressek.
#
# Hasznalat:
#   ./scripts/save-rtk-failure-observation.sh [command-name]
#
# Argumentum nelkul: a tee log filename-bol kovetkeztet a parancsra.

set -e

# Path beolvasasa env-bol vagy default
TEE_PATH="${RTK_TEE_LOG_PATH:-$HOME/.local/share/rtk/tee}"

if [ ! -d "$TEE_PATH" ]; then
    echo "[HIBA] RTK tee log mappa nem talalhato: $TEE_PATH"
    echo "Allitsd be: export RTK_TEE_LOG_PATH=/utvonal"
    exit 1
fi

# Legutobbi log
LATEST=$(ls -t "$TEE_PATH/" 2>/dev/null | head -1)

if [ -z "$LATEST" ]; then
    echo "[INFO] Nincs RTK tee log a $TEE_PATH-ban"
    exit 0
fi

LOG_FILE="$TEE_PATH/$LATEST"
COMMAND="${1:-$(echo "$LATEST" | sed 's/\.[0-9]*\.log$//;s/_/ /g')}"

# Memory save (Memory v2 RAD CLI)
if ! command -v claude &> /dev/null; then
    echo "[HIBA] claude CLI nem elerheto"
    exit 1
fi

CONTENT=$(head -50 "$LOG_FILE" 2>/dev/null)

if [ -z "$CONTENT" ]; then
    echo "[INFO] Tee log ures: $LOG_FILE"
    exit 0
fi

claude memory save \
    --type bugfix \
    --title "RTK tee failure: $COMMAND" \
    --content "$CONTENT" \
    --tags "rtk-tee,$(echo "$COMMAND" | awk '{print $1}'),debug" \
    2>&1 || {
        echo "[HIBA] memory save failed"
        exit 1
    }

echo "[OK] RTK failure observation elmentve: $COMMAND"
echo "  Forras: $LOG_FILE"

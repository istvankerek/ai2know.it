#!/bin/bash
# scripts/consolidation-lock.sh
# Race protection a Memory v2 write-okra (v7.1)
# Megelőzi, hogy concurrent autodream + memory save ütközzön.
#
# Használat más scriptekben:
#   source scripts/consolidation-lock.sh
#   acquire_lock || exit 1
#   # ... kritikus szekció ...
#   # release_lock automatikusan fut a trap-ben EXIT INT TERM-re

set -e

LOCK_FILE=".claude/memory/.consolidation.lock"
TIMEOUT=300  # 5 perc max várakozás

# Zárolás megszerzése
# Atomi create: set -o noclobber + shell redirect
acquire_lock() {
    local elapsed=0
    while [ "$elapsed" -lt "$TIMEOUT" ]; do
        if (set -o noclobber; echo "$$" > "$LOCK_FILE") 2>/dev/null; then
            # Trap: bármilyen kilépéskor felszabadítjuk a zárolást
            trap 'release_lock' EXIT INT TERM
            return 0
        fi
        sleep 1
        elapsed=$((elapsed + 1))
    done

    echo "ERROR: Nem sikerült megszerezni a memory lock-ot ${TIMEOUT}s után" >&2
    return 1
}

# Zárolás felszabadítása
release_lock() {
    rm -f "$LOCK_FILE"
}

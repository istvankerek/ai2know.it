#!/bin/bash
# .claude/hooks/check-tdd.sh — v6.2
# PostToolUse hook (Edit|Write): src/**.{rs,ts,tsx} modositasa utan
# ellenorzi hogy van-e hozza tartozo teszt fajl. Ha nincs → warning.
#
# Iron Law: failing test ELOSZOR. Ha a fejleszto kodot ir test nelkul,
# emlekeztet a TDD pipeline-ra.

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Csak forraskod fajlok
case "$FILE_PATH" in
    */src/*.rs|*/src/*.ts|*/src/*.tsx) ;;
    *) exit 0 ;;
esac

# Test fajlokat ne ellenorizzuk
case "$FILE_PATH" in
    *.test.ts|*.test.tsx|*.spec.ts|*.spec.tsx|*_test.rs|*/tests/*) exit 0 ;;
esac

# Belso fajlok kihagyasa
case "$FILE_PATH" in
    */node_modules/*|*/.git/*|*/dist/*|*/build/*|*/target/*) exit 0 ;;
esac

# UI / Layout / Style komponensek (sniff test elfogad)
case "$FILE_PATH" in
    */components/ui/*|*/layouts/*|*/styles/*|*/index.ts|*/index.tsx) exit 0 ;;
esac

# Test fajl path konstrualas
DIR=$(dirname "$FILE_PATH")
BASE=$(basename "$FILE_PATH")
NAME="${BASE%.*}"
EXT="${BASE##*.}"

TEST_CANDIDATES=(
    "${DIR}/${NAME}.test.${EXT}"
    "${DIR}/${NAME}.spec.${EXT}"
    "${DIR}/__tests__/${NAME}.test.${EXT}"
    "${DIR}/../tests/${NAME}.test.${EXT}"
)

# Rust kulon konvencio: ugyanabban a fajlban a #[cfg(test)] modul
if [ "$EXT" = "rs" ]; then
    if grep -q "#\[cfg(test)\]" "$FILE_PATH" 2>/dev/null; then
        exit 0
    fi
    TEST_CANDIDATES+=("${DIR}/${NAME}_test.rs" "${DIR}/tests/${NAME}.rs")
fi

# Van-e teszt?
TEST_FOUND=0
for candidate in "${TEST_CANDIDATES[@]}"; do
    if [ -f "$candidate" ]; then
        TEST_FOUND=1
        break
    fi
done

if [ "$TEST_FOUND" = "1" ]; then
    exit 0
fi

# Warning: nincs teszt
>&2 echo "──────────────────────────────────────────"
>&2 echo "⚠️ TDD Iron Law (5. Aranyszabaly)"
>&2 echo "  Modositott: ${FILE_PATH}"
>&2 echo "  Nincs hozza tartozo teszt fajl."
>&2 echo ""
>&2 echo "  TDD Iron Law: failing test ELOSZOR."
>&2 echo "  Javasolt: ${DIR}/${NAME}.test.${EXT}"
>&2 echo ""
>&2 echo "  Pipeline:"
>&2 echo "    1. RED:    ird a failing tesztet"
>&2 echo "    2. GREEN:  minimum kod ami passzol"
>&2 echo "    3. REFACTOR: tisztitas (mind zold)"
>&2 echo ""
>&2 echo "  Reszletek: .claude/skills/tdd-enforcer/SKILL.md"
>&2 echo "──────────────────────────────────────────"

exit 0

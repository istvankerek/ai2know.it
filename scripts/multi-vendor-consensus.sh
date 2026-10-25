#!/usr/bin/env bash
# multi-vendor-consensus.sh
# Párhuzamosan futtatja a három CLI-t ugyanarra a promptra, majd
# Claude-dal konszenzus összefoglalót generál.
#
# Használat:
#   ./scripts/multi-vendor-consensus.sh "A prompt szövege"
#   ./scripts/multi-vendor-consensus.sh --prompt-file prompts/kerdés.md
#
# Kimenet: outputs/consensus/{TIMESTAMP}/
#   claude.md, codex.md, gemini.md, consensus.md

set -e

# Argumentumok feldolgozása
PROMPT=""
PROMPT_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --prompt-file)
      PROMPT_FILE="$2"
      shift 2
      ;;
    *)
      PROMPT="$1"
      shift
      ;;
  esac
done

# Prompt validálás
if [ -n "${PROMPT_FILE}" ]; then
  if [ ! -f "${PROMPT_FILE}" ]; then
    echo "Hiba: prompt fájl nem található: ${PROMPT_FILE}"
    exit 1
  fi
  PROMPT="$(cat "${PROMPT_FILE}")"
fi

if [ -z "${PROMPT}" ]; then
  echo "Hiba: prompt hiányzik."
  echo "Használat: $0 \"A prompt szövege\""
  echo "         : $0 --prompt-file prompts/kérdés.md"
  exit 1
fi

# Kimenet könyvtár létrehozása
TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
OUTPUT_DIR="outputs/consensus/${TIMESTAMP}"
mkdir -p "${OUTPUT_DIR}"

echo "Multi-Vendor Consensus (v6.4)"
echo "Timestamp: ${TIMESTAMP}"
echo "Output: ${OUTPUT_DIR}"
echo ""

# CLI elérhetőség ellenőrzése
check_cli() {
  local cli_name="$1"
  if command -v "${cli_name}" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

CLAUDE_AVAILABLE=false
CODEX_AVAILABLE=false
GEMINI_AVAILABLE=false

check_cli "claude" && CLAUDE_AVAILABLE=true
check_cli "codex" && CODEX_AVAILABLE=true
check_cli "gemini" && GEMINI_AVAILABLE=true

echo "Elérhető CLI-k:"
echo "  claude: ${CLAUDE_AVAILABLE}"
echo "  codex:  ${CODEX_AVAILABLE}"
echo "  gemini: ${GEMINI_AVAILABLE}"
echo ""

# Prompt mentése referenciának
echo "${PROMPT}" > "${OUTPUT_DIR}/prompt.md"

# Párhuzamos futtatás - háttérben indítjuk a folyamatokat
run_claude() {
  local output_file="$1"
  local prompt="$2"

  if [ "${CLAUDE_AVAILABLE}" = "true" ]; then
    echo "[claude] Futtatás..."
    claude --print "${prompt}" > "${output_file}" 2>&1
    echo "[claude] Kész."
  else
    echo "[claude] Nem elérhető - szimulált mód" > "${output_file}"
    echo "" >> "${output_file}"
    echo "Megjegyzés: A claude CLI nem volt elérhető. Ez egy szimulált placeholder." >> "${output_file}"
    echo "[claude] Szimulált mód - kész."
  fi
}

run_codex() {
  local output_file="$1"
  local prompt="$2"

  if [ "${CODEX_AVAILABLE}" = "true" ]; then
    echo "[codex] Futtatás..."
    codex "${prompt}" > "${output_file}" 2>&1
    echo "[codex] Kész."
  else
    echo "[codex] Nem elérhető - szimulált mód" > "${output_file}"
    echo "" >> "${output_file}"
    echo "Megjegyzés: A codex CLI nem volt elérhető. Ez egy szimulált placeholder." >> "${output_file}"
    echo "[codex] Szimulált mód - kész."
  fi
}

run_gemini() {
  local output_file="$1"
  local prompt="$2"

  if [ "${GEMINI_AVAILABLE}" = "true" ]; then
    echo "[gemini] Futtatás..."
    gemini "${prompt}" > "${output_file}" 2>&1
    echo "[gemini] Kész."
  else
    echo "[gemini] Nem elérhető - szimulált mód" > "${output_file}"
    echo "" >> "${output_file}"
    echo "Megjegyzés: A gemini CLI nem volt elérhető. Ez egy szimulált placeholder." >> "${output_file}"
    echo "[gemini] Szimulált mód - kész."
  fi
}

# Párhuzamos futtatás
echo "CLI-k párhuzamos futtatása..."
run_claude "${OUTPUT_DIR}/claude.md" "${PROMPT}" &
PID_CLAUDE=$!
run_codex "${OUTPUT_DIR}/codex.md" "${PROMPT}" &
PID_CODEX=$!
run_gemini "${OUTPUT_DIR}/gemini.md" "${PROMPT}" &
PID_GEMINI=$!

# Várakozás minden folyamatra
wait "${PID_CLAUDE}" || true
wait "${PID_CODEX}" || true
wait "${PID_GEMINI}" || true

echo ""
echo "Minden CLI futás befejezve. Konszenzus generálása..."

# Konszenzus markdown generálása
CLAUDE_OUTPUT="$(cat "${OUTPUT_DIR}/claude.md" 2>/dev/null || echo '(nincs kimenet)')"
CODEX_OUTPUT="$(cat "${OUTPUT_DIR}/codex.md" 2>/dev/null || echo '(nincs kimenet)')"
GEMINI_OUTPUT="$(cat "${OUTPUT_DIR}/gemini.md" 2>/dev/null || echo '(nincs kimenet)')"

cat > "${OUTPUT_DIR}/consensus.md" << CONSENSUS_EOF
# Multi-Vendor Consensus Elemzés

**Timestamp:** ${TIMESTAMP}
**Prompt:** ${PROMPT}

---

## Claude Válasz

${CLAUDE_OUTPUT}

---

## Codex Válasz

${CODEX_OUTPUT}

---

## Gemini Válasz

${GEMINI_OUTPUT}

---

## Konszenzus Összefoglaló

> Ez a szekció manuálisan töltendő ki, vagy Claude Code-ban a
> multi-vendor-consensus skill automatikusan generálja.

### Egyező pontok (mind a 3 CLI)
- [Elemzés szükséges]

### Eltérések
| Szempont | Claude | Codex | Gemini |
|----------|--------|-------|--------|
| - | - | - | - |

### Ajánlás
[Claude orchestrátor döntése indoklással]

### Konfidencia
- [ ] Magas: mind a 3 egyezik
- [ ] Közepes: 2/3 egyezik
- [ ] Alacsony: mind a 3 eltér (Opus advisor javasolt)
CONSENSUS_EOF

echo ""
echo "Konszenzus fájlok mentve:"
echo "  ${OUTPUT_DIR}/prompt.md"
echo "  ${OUTPUT_DIR}/claude.md"
echo "  ${OUTPUT_DIR}/codex.md"
echo "  ${OUTPUT_DIR}/gemini.md"
echo "  ${OUTPUT_DIR}/consensus.md"
echo ""
echo "Következő lépés: nyisd meg a consensus.md-t és töltsd ki a Konszenzus Összefoglaló szekciót,"
echo "vagy aktiváld a multi-vendor-consensus skill-t Claude Code-ban."

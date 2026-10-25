#!/usr/bin/env bash
# install-rtk.sh
# RTK (Rust Token Killer) telepito es konfiguralo script
# AIOS v7.2 – Multi-CLI RTK integration
#
# FONTOS: Ez egy SABLON script – a fejleszto futtatja manualis
# Automatikusan NEM fut le.
#
# Hasznalat:
#   chmod +x .aios-cli/scripts/install-rtk.sh
#   ./.aios-cli/scripts/install-rtk.sh

set -e

echo "RTK Telepites – AIOS Multi-CLI (v7.2)"
echo "============================================"
echo ""

# ── 1. lepes: RTK binary ellenorzese / telepitese ──────────────────────────
echo "1/6: RTK binary ellenorzese..."
if ! command -v rtk &> /dev/null; then
  echo "  RTK nem talalhato. Telepites megkiserlese..."
  if [[ "$(uname -s)" == "Darwin" ]]; then
    # macOS: Homebrew-val
    if command -v brew &> /dev/null; then
      echo "  macOS + Homebrew: brew install rtk"
      brew install rtk
    else
      echo "  FIGYELMEZETES: Homebrew nem talalhato macOS-en."
      echo "  Kezzel telepitsd: https://brew.sh/ majd: brew install rtk"
      exit 1
    fi
  elif [[ "$(uname -s)" == "Linux" ]]; then
    # Linux: curl install
    echo "  Linux: curl install megkiserlese..."
    if command -v curl &> /dev/null; then
      curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
    else
      echo "  FIGYELMEZETES: sem curl, sem brew nem elerheto."
      echo "  Kezzel telepitsd: https://github.com/rtk-ai/rtk/releases"
      exit 1
    fi
  else
    echo "  FIGYELMEZETES: Ismeretlen platform: $(uname -s)"
    echo "  Kezzel telepitsd: https://github.com/rtk-ai/rtk/releases"
    exit 1
  fi
fi

echo "  RTK verzio: $(rtk --version)"
echo "  OK"
echo ""

# ── 2. lepes: Claude Code integráció ──────────────────────────────────────
echo "2/6: Claude Code integráció (PreToolUse hook + ~/.claude/RTK.md)..."
rtk init -g
echo "  OK: Claude Code hook beallitva"
echo ""

# ── 3. lepes: Codex CLI integráció (opcionális) ───────────────────────────
echo "3/6: Codex CLI ellenorzese..."
if command -v codex &> /dev/null; then
  echo "  Codex talalhato: rtk init -g --codex futtatasa..."
  rtk init -g --codex
  echo "  OK: Codex integráció beallitva (~/.codex/RTK.md + AGENTS.md referencia)"
else
  echo "  Codex nincs telepitve, kihagyva."
  echo "  Ha kesobb telepited: rtk init -g --codex"
fi
echo ""

# ── 4. lepes: Gemini CLI integráció (opcionális) ──────────────────────────
echo "4/6: Gemini CLI ellenorzese..."
if command -v gemini &> /dev/null; then
  echo "  Gemini talalhato: rtk init -g --gemini futtatasa..."
  rtk init -g --gemini
  echo "  OK: Gemini integráció beallitva (~/.gemini/hooks/ + settings.json)"
else
  echo "  Gemini nincs telepitve, kihagyva."
  echo "  Ha kesobb telepited: rtk init -g --gemini"
fi
echo ""

# ── 5. lepes: Ellenorzés ──────────────────────────────────────────────────
echo "5/6: Konfiguráció ellenorzese..."
rtk init --show
echo "  OK"
echo ""

# ── 6. lepes: NAIH compliance – telemetria kikapcsolasa ───────────────────
echo "6/6: NAIH compliance konfiguráció (~/.config/rtk/config.toml)..."
mkdir -p "$HOME/.config/rtk"
cat > "$HOME/.config/rtk/config.toml" << 'TOML'
[telemetry]
# NAIH compliance: Magyarország – csak explicit opt-in engedett
# Az RTK NEM kold adatot harmadik felnek ebben az állásban.
enabled = false

[tracking]
# Helyi SQLite adatbázis az analytics-hez (nem hagyja el a gepet)
database_path = ""

[hooks]
# Üres = minden tamogatott parancs RTK-n megy keresztül
# Kivetelekhez: exclude_commands = ["sajat-belso-eszkoz"]
exclude_commands = []

[tee]
# Failure recovery: a sikertelen parancsok teljes outputja helyi fájlba kerul
# Ez NULLA AI tokent kozt – csak helyi fájl olvasás debugoláskor
enabled = true
mode = "failures"
max_files = 50
TOML

echo "  OK: ~/.config/rtk/config.toml írva"
echo "  Telemetria: KIKAPCSOLVA (NAIH compliance)"
echo "  Tee mode: failures (failure recovery aktív)"
echo ""

echo "============================================"
echo "RTK telepites KESZ"
echo ""
echo "Ellenorzeshez:"
echo "  rtk gain        – token megtakaritasok statisztikája"
echo "  rtk session     – RTK adoption rate az utolso sessionökben"
echo "  rtk discover    – kihagyott lehetosegek felfedezes"
echo ""
echo "NAIH megjegyzes:"
echo "  Az RTK helyi tool (Apache 2.0). Telemetria kikapcsolva."
echo "  A tee log-ok (~/.local/share/rtk/tee/) soha nem hagyjak el"
echo "  a fejleszto gepet és NEM kerulnek git commit-ba."
echo ""
echo "Kovetkezo lepes: nyiss egy uj Claude Code sessiont,"
echo "  futtass egy 'git status'-t, és ellenorizd hogy"
echo "  az RTK hook aktív: rtk session"

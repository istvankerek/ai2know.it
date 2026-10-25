#!/bin/bash
# ============================================================
# sync.sh — Skeleton megosztott fajlok szinkronizalasa
#            a deployed projektekbe
#
# Hasznalat:
#   ./sync.sh                  # mindegyik projektet ellenorzi
#   ./sync.sh --dry-run        # csak mutatja mi valtozna
#   ./sync.sh --project NAME   # csak egy projekt
#   ./sync.sh --force          # akkor is fut, ha a verzio azonos
#   ./sync.sh --yes            # auto-confirm (nem interaktiv)
#
# Mit sync-el (shared, mindig felulirja):
#   .claude/{skills,rules,hooks,commands,agents,output-styles}/
#   .aios-cli/{core,adapters,scripts,skills}/
#   .aios-cli/orchestrator/{aios,policy,tests}/ + scripts/aios (v8.0)
#   templates/{plan,portal,admin-contract}/ (v8.0)
#   Megszunt utvonalak: .aios-cli/removed-paths.txt (az rsync --delete tavolitja el,
#   a dry-run kulon listazza oket)
#   tools/prompts/
#   docs/runbooks/ docs/adr/TEMPLATE.md docs/postmortems/TEMPLATE.md
#   docs/compliance/
#   infrastructure/chaos/
#   infrastructure/monitoring/sli-slo.yml
#   scripts/*.sh (kiveve a projekt-specifikus custom-okat)
#
# Mit NEM sync-el (projekt-specifikus):
#   CLAUDE.md, CLAUDE.local.md, AGENTS.md, GEMINI.md, COORDINATION.md, README.md, Makefile
#   .claude/settings.json, .claude/settings.local.json
#   .mcp.json
#   apps/ src/ tests/
#   tasks/
#   environments/.env.*
#   config/ migrations/
#   infrastructure/caddy/ infrastructure/cloudflare/ infrastructure/postgres/
#   install.sh sync.sh VERSION CHANGELOG.md
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKELETON_ROOT="$SCRIPT_DIR"
VERSION_FILE="$SKELETON_ROOT/VERSION"
CHANGELOG_FILE="$SKELETON_ROOT/CHANGELOG.md"
REGISTRY="$SKELETON_ROOT/projects/projects.list"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
info() { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[HIBA]${NC} $1" >&2; }

# --- Flagek ---
DRY_RUN=0
FORCE=0
AUTO_YES=0
PROJECT_FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)       DRY_RUN=1; shift ;;
    --force)         FORCE=1; shift ;;
    --yes|-y)        AUTO_YES=1; shift ;;
    --project)       PROJECT_FILTER="$2"; shift 2 ;;
    --help|-h)
      sed -n '2,25p' "$0"
      exit 0
      ;;
    *)
      err "Ismeretlen flag: $1"
      exit 1
      ;;
  esac
done

# --- Elofeltetelek ---
if [[ ! -f "$VERSION_FILE" ]]; then
  err "Nincs VERSION fajl: $VERSION_FILE"
  exit 1
fi
if [[ ! -f "$REGISTRY" ]]; then
  err "Nincs projektek regiszter: $REGISTRY"
  exit 1
fi

SKELETON_VERSION=$(tr -d '[:space:]' < "$VERSION_FILE")

# --- Shared path-ok (rsync-re) ---
# Minden path relativ a projekt gyokerehez
SHARED_PATHS=(
  ".claude/skills"
  ".claude/rules"
  ".claude/hooks"
  ".claude/hooks/memory"
  ".claude/commands"
  ".claude/agents"
  ".claude/output-styles"
  ".claude/identity"
  ".claude/identity/audience"
  ".claude/memory"
  ".claude/workflows"
  ".claude/routines"
  ".claude/routines/scheduled"
  ".claude/routines/api-triggered"
  ".claude/routines/webhook"
  ".aios-cli/core"
  ".aios-cli/adapters/claude"
  ".aios-cli/adapters/codex"
  ".aios-cli/adapters/gemini"
  ".aios-cli/scripts"
  ".aios-cli/skills"
  ".aios-cli/orchestrator/aios"
  ".aios-cli/orchestrator/policy"
  ".aios-cli/orchestrator/tests"
  "templates/plan"
  "templates/portal"
  "templates/admin-contract"
  ".codex/agents"
  "experiments/failed-ideas"
  "experiments/prototypes"
  "tools/prompts"
  "docs/runbooks"
  "docs/compliance"
  "docs/onboarding"
  "infrastructure/chaos"
  "tests/skeleton-validation"
)

# Specifikus fajlok (nem mappak)
SHARED_FILES=(
  "docs/adr/TEMPLATE.md"
  "docs/postmortems/TEMPLATE.md"
  "docs/data-analyst-layer.md"
  "infrastructure/monitoring/sli-slo.yml"
  "scripts/build.sh"
  "scripts/test.sh"
  "scripts/lint.sh"
  "scripts/migrate.sh"
  "scripts/seed-db.sh"
  "scripts/deploy.sh"
  "scripts/backup-manual.sh"
  "scripts/server-migrate.sh"
  "scripts/create-project.sh"
  "scripts/setup-worktree.sh"
  "scripts/migrate-loops-to-routines.sh"
  "scripts/multi-vendor-consensus.sh"
  "scripts/import-skill-from-repo.sh"
  "scripts/consolidation-lock.sh"
  "scripts/save-rtk-failure-observation.sh"
  ".aios-cli/scripts/install-rtk.sh"
  ".aios-cli/removed-paths.txt"
  "scripts/aios"
  ".codex/config.toml"
  ".worktreeinclude"
  "requirements-data-analyst.txt"
)

# --- CHANGELOG relevans resz (adott verziora) ---
show_changelog_since() {
  local from_ver="$1"
  local to_ver="$2"
  if [[ ! -f "$CHANGELOG_FILE" ]]; then
    return
  fi
  echo ""
  echo -e "${BOLD}--- CHANGELOG: $from_ver → $to_ver ---${NC}"
  # Kiir minden bejegyzest amig a 'from_ver'-hez nem er
  awk -v from="$from_ver" '
    /^## \[/ {
      # Ha tuljutottunk a from verzion, allj meg
      if (match($0, /\[[^\]]+\]/)) {
        ver = substr($0, RSTART+1, RLENGTH-2)
        if (ver == from) { exit }
      }
      in_section = 1
    }
    in_section { print }
  ' "$CHANGELOG_FILE"
  echo ""
}

# --- Egy projekt szinkronizalasa ---
sync_project() {
  local name="$1"
  local path="$2"
  local deployed_ver="$3"

  echo ""
  echo -e "${BOLD}========================================${NC}"
  echo -e "${BOLD} $name${NC}"
  echo -e "${BOLD}========================================${NC}"
  echo "  Path:     $path"
  echo "  Deployed: $deployed_ver"
  echo "  Skeleton: $SKELETON_VERSION"

  # Projekt letezik?
  if [[ ! -d "$path" ]]; then
    warn "Projekt mappa nem letezik, kihagyva."
    return
  fi

  # .skeleton-version a projektben (authoritative)
  local actual_ver="$deployed_ver"
  if [[ -f "$path/.skeleton-version" ]]; then
    actual_ver=$(tr -d '[:space:]' < "$path/.skeleton-version")
    if [[ "$actual_ver" != "$deployed_ver" ]]; then
      warn "Regiszter ($deployed_ver) != .skeleton-version ($actual_ver). Authoritative: .skeleton-version."
    fi
  fi

  # Naprakesz?
  if [[ "$actual_ver" == "$SKELETON_VERSION" && $FORCE -eq 0 ]]; then
    ok "Naprakesz ($actual_ver)."
    return
  fi

  # Changelog
  show_changelog_since "$actual_ver" "$SKELETON_VERSION"

  # Dry-run osszefoglalo
  echo -e "${CYAN}--- Valtozasok elonezet (dry-run) ---${NC}"
  local changes=0
  for p in "${SHARED_PATHS[@]}"; do
    if [[ -d "$SKELETON_ROOT/$p" ]]; then
      local diff_out
      diff_out=$(rsync -rn --itemize-changes --delete "$SKELETON_ROOT/$p/" "$path/$p/" 2>/dev/null | grep -v '^$' || true)
      if [[ -n "$diff_out" ]]; then
        echo -e "  ${YELLOW}$p/${NC}"
        echo "$diff_out" | sed 's/^/    /'
        changes=$((changes + $(echo "$diff_out" | wc -l | tr -d ' ')))
      fi
    fi
  done
  for f in "${SHARED_FILES[@]}"; do
    if [[ -f "$SKELETON_ROOT/$f" ]]; then
      if [[ ! -f "$path/$f" ]] || ! cmp -s "$SKELETON_ROOT/$f" "$path/$f"; then
        echo -e "  ${YELLOW}$f${NC} (update)"
        changes=$((changes + 1))
      fi
    fi
  done

  # Megszunt utvonalak (v8.0): kulon kiemelve, mert a sync torolni fogja oket
  if [[ -f "$SKELETON_ROOT/.aios-cli/removed-paths.txt" ]]; then
    while IFS= read -r rel; do
      [[ -z "$rel" || "$rel" == \#* ]] && continue
      if [[ -e "$path/$rel" || -L "$path/$rel" ]]; then
        echo -e "  ${RED}TORLODIK (megszunt):${NC} $rel"
        changes=$((changes + 1))
      fi
    done < "$SKELETON_ROOT/.aios-cli/removed-paths.txt"
  fi

  if [[ $changes -eq 0 ]]; then
    ok "Nincs valtozas a megosztott fajlokban."
    # Verzio marker frissites ha eltero
    if [[ "$actual_ver" != "$SKELETON_VERSION" ]]; then
      echo "$SKELETON_VERSION" > "$path/.skeleton-version"
      ok ".skeleton-version frissitve: $SKELETON_VERSION"
    fi
    return
  fi

  echo -e "${BOLD}Osszesen ~$changes valtozas.${NC}"

  # Dry-run mod: itt allj meg
  if [[ $DRY_RUN -eq 1 ]]; then
    warn "Dry-run mod, nincs fizikai valtoztatas."
    return
  fi

  # Confirm
  if [[ $AUTO_YES -eq 0 ]]; then
    read -rp "Folytassam a szinkronizaciot? (i/n): " CONFIRM
    if [[ "$CONFIRM" != "i" && "$CONFIRM" != "I" && "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
      warn "Kihagyva."
      return
    fi
  fi

  # Tenyleges rsync
  info "Sync..."
  for p in "${SHARED_PATHS[@]}"; do
    if [[ -d "$SKELETON_ROOT/$p" ]]; then
      mkdir -p "$path/$p"
      rsync -a --delete "$SKELETON_ROOT/$p/" "$path/$p/"
    fi
  done
  for f in "${SHARED_FILES[@]}"; do
    if [[ -f "$SKELETON_ROOT/$f" ]]; then
      mkdir -p "$(dirname "$path/$f")"
      cp "$SKELETON_ROOT/$f" "$path/$f"
    fi
  done

  # Megszunt, rsync-en kivuli utvonalak: csak a mar celpont nelkuli symlinkeket
  # takaritja a generator; valodi fajlt itt sem torlunk megerosites nelkul.

  # AIOS orchestrator ledger ne kerulhessen git-be (csak hozzafuzes)
  if [[ -f "$path/.gitignore" ]] && ! grep -q "^.aios-cli/orchestrator/.ledger/" "$path/.gitignore"; then
    printf '\n# AIOS orchestrator ledger (v8.0)\n.aios-cli/orchestrator/.ledger/\n__pycache__/\n' >> "$path/.gitignore"
    info ".gitignore: AIOS ledger sor hozzaadva"
  fi

  # AIOS generator: skill index + Codex/Gemini skill entry symlinkek.
  if [[ -x "$path/.aios-cli/scripts/generate-cli-configs.sh" ]]; then
    info "AIOS config generator..."
    (cd "$path" && ./.aios-cli/scripts/generate-cli-configs.sh all)
  fi

  # Verzio frissites
  echo "$SKELETON_VERSION" > "$path/.skeleton-version"

  # Regiszter frissites (deployed_version oszlop)
  # Mindenfeld pipe-osan reformatalva, hogy a non-matching sorok is konzisztensek maradjanak.
  TMP_REG="$(mktemp)"
  awk -v name="$name" -v ver="$SKELETON_VERSION" '
    /^[[:space:]]*#/ || /^[[:space:]]*$/ { print; next }
    {
      # Tamogatott formatok: "NAME | PATH | VER" vagy "NAME PATH VER" (whitespace)
      n = split($0, a, /[[:space:]]*\|[[:space:]]*|[[:space:]]+/)
      if (n < 3) { print; next }
      cur_name = a[1]
      cur_path = a[2]
      cur_ver = (cur_name == name) ? ver : a[3]
      printf "%-11s | %-44s | %s\n", cur_name, cur_path, cur_ver
    }
  ' "$REGISTRY" > "$TMP_REG"
  mv "$TMP_REG" "$REGISTRY"

  ok "Sync kesz: $actual_ver → $SKELETON_VERSION"
}

# --- Fo fut ---
echo -e "${BOLD}Skeleton sync${NC} (skeleton $SKELETON_VERSION)"
echo "Registry: $REGISTRY"
[[ $DRY_RUN -eq 1 ]] && warn "DRY-RUN mod"
[[ $FORCE -eq 1 ]] && warn "FORCE mod"
[[ $AUTO_YES -eq 1 ]] && info "Auto-confirm bekapcsolva"
[[ -n "$PROJECT_FILTER" ]] && info "Projekt szuro: $PROJECT_FILTER"

FOUND=0
while IFS='|' read -r name path deployed_ver; do
  # Trim
  name=$(echo "$name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  path=$(echo "$path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  deployed_ver=$(echo "$deployed_ver" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Kommentek, ures sorok
  [[ -z "$name" || "$name" =~ ^# ]] && continue

  # Szuro
  if [[ -n "$PROJECT_FILTER" && "$name" != "$PROJECT_FILTER" ]]; then
    continue
  fi

  FOUND=1
  sync_project "$name" "$path" "$deployed_ver"
done < "$REGISTRY"

if [[ $FOUND -eq 0 ]]; then
  warn "Nincs projekt a regiszterben (vagy a szuro nem talalt)."
fi

echo ""
ok "Sync vegzett."

#!/bin/bash
set -e

# ============================================================
# create-project.sh — Uj projekt letrehozasa a skeleton-bol
# Hasznalat:
#   bash scripts/create-project.sh \
#     --name "MyApp" \
#     --domain "myapp.hu" \
#     --repo "https://github.com/user/repo.git" \
#     --target "/path/to/new-project"
#
# Opcionalis flag-ek:
#   --slug "my-app"        (auto-generalas --name-bol)
#   --tunnel-id "abc-123"  (Cloudflare tunnel ID)
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKELETON_ROOT="$(dirname "$SCRIPT_DIR")"

# --- Szinek ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[HIBA]${NC} $1" >&2; }

# --- Valtozok ---
NAME=""
SLUG=""
DOMAIN=""
REPO_URL=""
TUNNEL_ID=""
TARGET=""

# --- Argumentum feldolgozas ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name|-n)     NAME="$2"; shift 2 ;;
    --slug)        SLUG="$2"; shift 2 ;;
    --domain|-d)   DOMAIN="$2"; shift 2 ;;
    --repo|-r)     REPO_URL="$2"; shift 2 ;;
    --tunnel-id)   TUNNEL_ID="$2"; shift 2 ;;
    --target|-t)   TARGET="$2"; shift 2 ;;
    --help|-h)
      echo "Hasznalat: bash scripts/create-project.sh [opciok]"
      echo ""
      echo "Kotelezo:"
      echo "  --name, -n      Projekt neve (pl. MyApp)"
      echo "  --domain, -d    Domain nev (pl. myapp.hu)"
      echo "  --repo, -r      Git repo URL (pl. https://github.com/user/repo.git)"
      echo "  --target, -t    Celkonyvtar eleresi utja"
      echo ""
      echo "Opcionalis:"
      echo "  --slug           Kebab-case nev (auto-generalas --name-bol)"
      echo "  --tunnel-id      Cloudflare Tunnel ID"
      echo "  --help, -h       Sugo megjelenites"
      exit 0
      ;;
    *)
      err "Ismeretlen parameter: $1"
      echo "Hasznald a --help flag-et a sugohoz."
      exit 1
      ;;
  esac
done

# --- Interaktiv bekeres ha hianyzik ---
if [[ -z "$NAME" ]]; then
  read -rp "Projekt neve (pl. MyApp): " NAME
fi
if [[ -z "$NAME" ]]; then
  err "A projekt nev kotelezo."
  exit 1
fi

if [[ -z "$DOMAIN" ]]; then
  read -rp "Domain nev (pl. myapp.hu): " DOMAIN
fi
if [[ -z "$DOMAIN" ]]; then
  err "A domain nev kotelezo."
  exit 1
fi

if [[ -z "$REPO_URL" ]]; then
  read -rp "Git repo URL (pl. https://github.com/user/repo.git): " REPO_URL
fi
if [[ -z "$REPO_URL" ]]; then
  err "A repo URL kotelezo."
  exit 1
fi

if [[ -z "$TARGET" ]]; then
  read -rp "Celkonyvtar (pl. /path/to/new-project): " TARGET
fi
if [[ -z "$TARGET" ]]; then
  err "A celkonyvtar kotelezo."
  exit 1
fi

# --- Slug generalas ---
if [[ -z "$SLUG" ]]; then
  SLUG=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
fi

# --- Osszefoglalas es megerosites ---
echo ""
echo "=========================================="
echo " Uj projekt letrehozasa"
echo "=========================================="
echo "  Nev:       $NAME"
echo "  Slug:      $SLUG"
echo "  Domain:    $DOMAIN"
echo "  Repo:      $REPO_URL"
echo "  Tunnel ID: ${TUNNEL_ID:-<nincs megadva>}"
echo "  Cel:       $TARGET"
echo "=========================================="
echo ""
read -rp "Folytassuk? (i/n): " CONFIRM
if [[ "$CONFIRM" != "i" && "$CONFIRM" != "I" && "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  info "Megszakitva."
  exit 0
fi

# --- Celkonyvtar ellenorzes ---
if [[ -d "$TARGET" ]]; then
  warn "A celkonyvtar mar letezik: $TARGET"
  read -rp "Felulirjuk a tartalmat? (i/n): " OVERWRITE
  if [[ "$OVERWRITE" != "i" && "$OVERWRITE" != "I" && "$OVERWRITE" != "y" && "$OVERWRITE" != "Y" ]]; then
    info "Megszakitva."
    exit 0
  fi
fi

# --- 1. Masolas rsync-kel ---
info "Skeleton masolasa: $SKELETON_ROOT -> $TARGET"
mkdir -p "$TARGET"

rsync -a \
  --exclude='.git' \
  --exclude='.DS_Store' \
  --exclude='Thumbs.db' \
  --exclude='node_modules' \
  --exclude='target' \
  --exclude='dist' \
  --exclude='out' \
  --exclude='.next' \
  --exclude='coverage' \
  --exclude='.nyc_output' \
  --exclude='logs' \
  --exclude='*.log' \
  --exclude='*.swp' \
  --exclude='*.swo' \
  --exclude='*.bin' \
  --exclude='*.pb' \
  --exclude='.claude/prompt-log/session_*' \
  --exclude='skeleton.code-workspace' \
  --exclude='CLAUDE.local.md' \
  --exclude='docker-compose.override.yml' \
  --exclude='environments/.env.local' \
  --exclude='environments/.env.test' \
  --exclude='environments/.env.prod' \
  --exclude='infrastructure/cloudflare/credentials.json' \
  --exclude='config/proxies.json' \
  "$SKELETON_ROOT/" "$TARGET/"

ok "Masolas kesz."

# --- 2. Workspace fajl ---
info "Workspace fajl letrehozasa..."
cat > "$TARGET/${SLUG}.code-workspace" << 'WSEOF'
{
	"folders": [
		{
			"path": "."
		}
	],
	"settings": {}
}
WSEOF
ok "${SLUG}.code-workspace letrehozva."

# --- 3. CLAUDE.local.md ---
info "CLAUDE.local.md letrehozasa..."
cat > "$TARGET/CLAUDE.local.md" << 'LOCALEOF'
# Szemelyes beallitasok (gitignored)

## Fejlesztoi preferenciák
## Lokalis kornyezet
LOCALEOF
ok "CLAUDE.local.md letrehozva."

# --- 4. Placeholder csere ---
info "Placeholder-ek csereje..."

# OS detektalas: macOS vs Linux sed szintaxis
if [[ "$(uname)" == "Darwin" ]]; then
  SED_INPLACE=(-i '')
else
  SED_INPLACE=(-i)
fi

# Sed-ben a pipe (|) a delimiter, igy URL-ek is mukodnek
find "$TARGET" -type f \( \
  -name "*.md" -o \
  -name "*.toml" -o \
  -name "*.json" -o \
  -name "*.yml" -o \
  -name "*.yaml" -o \
  -name "*.ts" -o \
  -name "*.tsx" -o \
  -name "*.html" -o \
  -name "*.jsx" -o \
  -name "*.rs" -o \
  -name "Makefile" -o \
  -name "Caddyfile" \
\) \
  -not -path "*/.git/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/target/*" \
  -exec sed "${SED_INPLACE[@]}" \
    -e "s|{{PROJECT_NAME}}|${NAME}|g" \
    -e "s|{{project-name}}|${SLUG}|g" \
    -e "s|{{DOMAIN}}|${DOMAIN}|g" \
    -e "s|{{REPO_URL}}|${REPO_URL}|g" \
    -e "s|{{TUNNEL_ID}}|${TUNNEL_ID}|g" \
    {} +

ok "Placeholder-ek kicserelve."

# --- 5. Git inicializalas ---
info "Git repo inicializalasa..."
cd "$TARGET"
git init
git remote add origin "$REPO_URL"
git add .
git commit -m "chore: initialize project from skeleton template"
ok "Git repo inicializalva, elso commit kesz."

# --- 6. Osszefoglalas ---
echo ""
echo -e "${GREEN}=========================================="
echo " Projekt sikeresen letrehozva!"
echo "==========================================${NC}"
echo ""
echo "  Nev:       $NAME"
echo "  Slug:      $SLUG"
echo "  Domain:    $DOMAIN"
echo "  Repo:      $REPO_URL"
echo "  Cel:       $TARGET"
echo ""
echo "Kovetkezo lepesek:"
echo "  1. cd $TARGET"
echo "  2. cp environments/.env.example environments/.env.local"
echo "  3. make local"
echo "  4. Nyisd meg a ${SLUG}.code-workspace fajlt VS Code-ban"
echo ""

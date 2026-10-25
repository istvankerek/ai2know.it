#!/bin/bash
# scripts/setup-worktree.sh — v8.1 (plan-v16: worktree a projekten BELUL)
# Uj git worktree letrehozas + symlinkek a .worktreeinclude alapjan.
#
# Hasznalat:
#   ./scripts/setup-worktree.sh <branch-nev> [worktree-path]
#
# Pelda:
#   ./scripts/setup-worktree.sh feature/users-export
#   → letrehozza: worktrees/feature-users-export/   (a projekten belul, gitignore-olva)
#   ./scripts/setup-worktree.sh feature/x --legacy-sibling   → regi viselkedes: ../<proj>-feature-x
#   → symlinkek: .claude/, .mcp.json, CLAUDE.md, .env, package.json, ...
#
# Filozofia: a kozos config (Claude konfig, MCP, env) egyetlen forras igazsag,
# minden worktree osztozik rajta. A kod (apps/, src/, tests/) izolalt.

set -e

cd "$(dirname "$0")/.."
PARENT_DIR=$(pwd)
PARENT_NAME=$(basename "$PARENT_DIR")

BRANCH="$1"
SLUG="${BRANCH//\//-}"
LEGACY=0
CUSTOM_PATH=""
for arg in "${@:2}"; do
    case "$arg" in
        --legacy-sibling) LEGACY=1 ;;
        *) CUSTOM_PATH="$arg" ;;
    esac
done
if [ -n "$CUSTOM_PATH" ]; then
    WORKTREE_PATH="$CUSTOM_PATH"
elif [ "$LEGACY" = "1" ]; then
    WORKTREE_PATH="../${PARENT_NAME}-${SLUG}"
else
    WORKTREE_PATH="worktrees/${SLUG}"
fi

if [ -z "$BRANCH" ]; then
    echo "Hasznalat: $0 <branch-nev> [worktree-path]"
    echo ""
    echo "Pelda:"
    echo "  $0 feature/users-export"
    echo "  $0 hotfix/login-bug                  # → worktrees/hotfix-login-bug/"
    echo "  $0 hotfix/login-bug --legacy-sibling  # → ../skeleton-hotfix-login-bug/"
    exit 1
fi

if [ ! -f .worktreeinclude ]; then
    echo "❌ Nincs .worktreeinclude fajl a $PARENT_DIR-ben"
    exit 1
fi

# v8.1: a worktrees/ mappa legyen gitignore-olva (egy projekt = egy mappa)
if [[ "$WORKTREE_PATH" == worktrees/* ]]; then
    mkdir -p worktrees
    if ! grep -qxE 'worktrees/?' .gitignore 2>/dev/null; then
        printf '\n# git worktree-k a projekten belul (v8.1)\nworktrees/\n' >> .gitignore
        echo "📝 .gitignore: worktrees/ hozzaadva"
    fi
fi

echo "🌿 Worktree letrehozasa..."
echo "  Branch: $BRANCH"
echo "  Path:   $WORKTREE_PATH"
echo ""

# Ha a branch mar letezik → checkout, ha nem → uj branch a current HEAD-rol
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git worktree add "$WORKTREE_PATH" "$BRANCH"
else
    git worktree add -b "$BRANCH" "$WORKTREE_PATH"
fi

echo ""
echo "🔗 Symlinkek a .worktreeinclude alapjan..."

# Olvas .worktreeinclude (kommenteket es ures sorokat kihagy)
LINKED=0
SKIPPED=0

while IFS= read -r line; do
    # Trim + skip empty/comment
    item="${line%%#*}"            # remove inline comment
    item="${item## }"             # ltrim
    item="${item%% }"             # rtrim
    item="${item%/}"              # zaro / levagasa (mappa bejegyzesek)
    [ -z "$item" ] && continue

    SOURCE="$PARENT_DIR/$item"
    TARGET="$WORKTREE_PATH/$item"

    if [ ! -e "$SOURCE" ]; then
        echo "  ⚠️  $item (forras nem letezik) – skip"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # Ha a worktree-ben mar letezik (git worktree create create-elte) → backup + symlink
    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
        rm -rf "$TARGET"
    fi

    # Mappa eseten -d nem kell, ln -s mindketto kezeli
    ln -s "$SOURCE" "$TARGET"
    echo "  ✅ $item → symlink"
    LINKED=$((LINKED + 1))
done < .worktreeinclude

echo ""
echo "✅ Kesz!"
echo "  Linkelve: $LINKED"
echo "  Kihagyva: $SKIPPED"
echo ""
echo "Kovetkezo lepes:"
echo "  cd $WORKTREE_PATH"
echo "  claude"

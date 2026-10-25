#!/usr/bin/env bash
# Projekt-szerkezet validacio (v8.1, plan-v16): worktrees/, subprojects/, lezaro scriptek
set -uo pipefail
E=0
fail() { echo "  ❌ $*"; E=$((E+1)); }

for f in .aios-cli/scripts/validate-project-layout.py scripts/close-worktree.sh scripts/setup-worktree.sh \
         templates/subproject/SUBPROJECT.md templates/subproject/subprojects.toml; do
  [[ -f "$f" ]] || fail "Hianyzik: $f"
done
[[ -x scripts/close-worktree.sh ]] || fail "close-worktree.sh nem futtathato"
grep -q 'worktrees/${SLUG}' scripts/setup-worktree.sh || fail "setup-worktree.sh: alapertelmezett ut nem worktrees/<slug>"
grep -q -- '--legacy-sibling' scripts/setup-worktree.sh || fail "setup-worktree.sh: nincs --legacy-sibling"
grep -qxE 'worktrees/?' .gitignore || fail ".gitignore: worktrees/ hianyzik"
grep -qx 'subprojects/\*/' .gitignore || fail ".gitignore: subprojects/*/ hianyzik"
grep -q "L-16" .aios-cli/core/lessons.md || fail "lessons.md: L-16 hianyzik"
grep -q "close-worktree" .claude/commands/finalize.md || fail "finalize.md: nincs worktree lezaras"
# csak a skeletonban (projekt-registry van); a projektekben levo sync.sh masolat nem normativ
[[ ! -f .skeleton-root ]] || grep -q "close-worktree.sh" sync.sh || fail "sync.sh: close-worktree.sh nincs a megosztott fajlok kozott"

python3 .aios-cli/scripts/validate-project-layout.py . >/dev/null || fail "validate-project-layout: a skeleton sajat szerkezete hibas"
python3 -m unittest discover -s .aios-cli/scripts/tests -p 'test_validate_project_layout.py' >/dev/null 2>&1 || fail "validate-project-layout unit tesztek"

# setup/close smoke egy ideiglenes klonon
TMP="$(mktemp -d)"
# a klon a HEAD-et adja; a munkafa (meg nem commitolt) scriptjeit ramasoljuk
SRC="$PWD"
git clone -q . "$TMP/proj" 2>/dev/null && (
  cd "$TMP/proj" && git config user.email t@t && git config user.name t
  mkdir -p scripts .aios-cli/scripts
  cp "$SRC/scripts/setup-worktree.sh" "$SRC/scripts/close-worktree.sh" scripts/
  cp "$SRC/.aios-cli/scripts/validate-project-layout.py" .aios-cli/scripts/
  cp "$SRC/.worktreeinclude" "$SRC/.gitignore" .
  # a beagyazott subprojektek nincsenek a klonban → a lista nelkul validalunk
  git rm -q --ignore-unmatch subprojects.toml >/dev/null 2>&1 || true
  git add -A && git commit -q -m "smoke: munkafa scriptek"
  ./scripts/setup-worktree.sh feature/proba >/dev/null 2>&1 || exit 1
  [[ -d worktrees/feature-proba ]] || exit 1
  python3 .aios-cli/scripts/validate-project-layout.py . >/dev/null || exit 1
  AIOS_MAIN_BRANCH="$(git branch --show-current)" ./scripts/close-worktree.sh --stale --yes >/dev/null 2>&1 || exit 1
  [[ ! -d worktrees/feature-proba ]] || exit 1
) || fail "setup-worktree / close-worktree smoke"
python3 -c "import shutil,sys; shutil.rmtree(sys.argv[1], ignore_errors=True)" "$TMP"

[[ $E -eq 0 ]]

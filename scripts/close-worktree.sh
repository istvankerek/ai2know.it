#!/usr/bin/env bash
# scripts/close-worktree.sh — v8.1 (plan-v16)
# Worktree lezarasa biztonsagosan: csak tiszta (nincs modositas) es beolvasztott vagy
# pusholt branch worktree-je tavolithato el. Valodi munkat sosem torol csendben.
#
# Hasznalat:
#   ./scripts/close-worktree.sh <worktree-path>     # egy worktree
#   ./scripts/close-worktree.sh --stale [--yes]     # minden beolvasztott, tiszta worktree (agent-ek is)
#   ./scripts/close-worktree.sh --list              # allapot tablazat
set -euo pipefail
# AIOS_PROJECT_ROOT: masik projekt worktree-inek kezelese (pl. meg nem sync-elt repo)
cd "${AIOS_PROJECT_ROOT:-$(dirname "$0")/..}"
ROOT="$(pwd -P)"
MAIN_BRANCH="${AIOS_MAIN_BRANCH:-$(git branch --show-current)}"
[ -n "$MAIN_BRANCH" ] || { echo "Detached HEAD: add meg a fovonalat AIOS_MAIN_BRANCH=... formaban" >&2; exit 1; }

include_items() {
  [ -f .worktreeinclude ] || return 0
  sed 's/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//; s|/$||' .worktreeinclude | grep -v '^$'
}

state_of() {
  local wt="$1" head branch dirty merged pushed
  head="$(git -C "$wt" rev-parse HEAD)"
  branch="$(git -C "$wt" branch --show-current || true)"
  # a .worktreeinclude symlinkjei (kozos config) tervezett elteresek, nem szamitanak
  dirty="$(git -C "$wt" status --short --porcelain | awk '{print $NF}' \
    | awk -v items="$(include_items | tr '\n' ' ')" '
        BEGIN { n = split(items, it, " ") }
        { keep = 1; for (i = 1; i <= n; i++) if ($0 == it[i] || index($0, it[i] "/") == 1) { keep = 0; break } }
        keep' | wc -l | tr -d ' ')"
  if git merge-base --is-ancestor "$head" "$MAIN_BRANCH"; then merged=igen; else merged=nem; fi
  pushed=nem
  if [ -n "$branch" ] && git rev-parse --verify -q "refs/remotes/origin/$branch" >/dev/null; then
    git merge-base --is-ancestor "$head" "refs/remotes/origin/$branch" && pushed=igen
  fi
  echo "$branch|$dirty|$merged|$pushed"
}

list_worktrees() {
  git worktree list --porcelain | awk '/^worktree /{print substr($0,10)}' | tail -n +2
}

close_one() {
  local wt="$1" force="${2:-0}"
  [ -d "$wt" ] || { echo "  ⚠️  $wt: nem letezik (git worktree prune)"; return 1; }
  IFS='|' read -r branch dirty merged pushed <<< "$(state_of "$wt")"
  if [ "$dirty" != "0" ]; then
    echo "  ❌ $wt [$branch]: $dirty modositott fajl – elobb commit vagy eldobas (owner dontes)"; return 1
  fi
  if [ "$merged" != "igen" ] && [ "$pushed" != "igen" ]; then
    echo "  ❌ $wt [$branch]: nincs beolvasztva es nincs pusholva – elobb git push -u origin $branch"; return 1
  fi
  if [ "$force" != "1" ]; then
    read -rp "  Lezarom: $wt [$branch] (beolvasztva: $merged, pusholva: $pushed)? (i/n) " ans
    [[ "$ans" =~ ^[iIyY]$ ]] || { echo "  kihagyva"; return 0; }
  fi
  # A .worktreeinclude symlinkjei miatt a git "modified"-nak latja a worktree-t; a sajat
  # dirty-ellenorzesunk mar igazolta, hogy ezen kivul nincs valtozas → --force biztonsagos.
  if git worktree remove --force "$wt"; then
    echo "  ✅ lezarva: ${wt#"$ROOT/"} [$branch] (a branch megmarad)"
  else
    echo "  ❌ ${wt#"$ROOT/"} [$branch]: git worktree remove sikertelen"; return 1
  fi
}

case "${1:-}" in
  --list)
    printf '%-60s %-40s %5s %6s %6s\n' "worktree" "branch" "dirty" "merged" "pushed"
    while IFS= read -r wt; do IFS='|' read -r b d m p <<< "$(state_of "$wt")"; printf '%-60s %-40s %5s %6s %6s\n' "${wt#"$ROOT/"}" "$b" "$d" "$m" "$p"; done < <(list_worktrees)
    ;;
  --stale)
    yes=0; [ "${2:-}" = "--yes" ] && yes=1
    echo "Beolvasztott, tiszta worktree-k lezarasa (fovonal: $MAIN_BRANCH)..."
    while IFS= read -r wt; do
      IFS='|' read -r b d m p <<< "$(state_of "$wt")"
      if [ "$m" = "igen" ] && [ "$d" = "0" ]; then close_one "$wt" "$yes" || true
      else echo "  ⏭️  ${wt#"$ROOT/"} [$b]: marad (beolvasztva: $m, modositott: $d)"; fi
    done < <(list_worktrees)
    git worktree prune
    ;;
  "")
    echo "Hasznalat: $0 <worktree-path> | --stale [--yes] | --list" >&2; exit 1 ;;
  *)
    close_one "$1" 0 ;;
esac

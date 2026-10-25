#!/usr/bin/env bash
# scripts/fleet-sync.sh — v8.1 (plan-v16 F5)
# A regisztralt projektek frissitese a skeletonra, projektenkent sajat branchen,
# az owner nem commitolt fajljainak megorzesevel.
#
# Hasznalat:
#   ./scripts/fleet-sync.sh --dry-run [--project NAME]   # csak mutatja, mi tortenne
#   ./scripts/fleet-sync.sh [--project NAME] [--no-push]
#
# Lepesek projektenkent:
#   1. branch: chore/skeleton-v<VERZIO> (letrehozas az aktualis HEAD-rol, vagy valtas ra)
#   2. a megosztott utvonalakon levo helyi modositasok mentese kulon commitba (a sync felulirna)
#   3. ./sync.sh --yes --force --project NAME
#   4. csak a sync altal erintett utvonalak commitja
#   5. validacio (validate-skills, run-all, validate-project-layout) – nem blokkol, naplo
#   6. git push -u origin <branch> (ha van remote)
set -uo pipefail
cd "$(dirname "$0")/.."
SKELETON_ROOT="$(pwd -P)"
VERSION="$(tr -d '[:space:]' < VERSION)"
BRANCH="chore/skeleton-v${VERSION}"
REGISTRY="projects/projects.list"
DRY_RUN=0; PUSH=1; FILTER=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --no-push) PUSH=0; shift ;;
    --project) FILTER="$2"; shift 2 ;;
    *) echo "Ismeretlen flag: $1" >&2; exit 1 ;;
  esac
done

# A sync altal irt megosztott utvonalak (a sync.sh listaja szerint, top-level)
SHARED_TOP=(.claude .aios-cli .codex scripts tools/prompts docs/runbooks docs/compliance docs/onboarding docs/adr/TEMPLATE.md
            docs/postmortems/TEMPLATE.md docs/data-analyst-layer.md infrastructure/chaos infrastructure/monitoring/sli-slo.yml
            tests/skeleton-validation templates experiments .worktreeinclude requirements-data-analyst.txt
            CLAUDE.md AGENTS.md GEMINI.md .gitignore .skeleton-version)

log() { printf '%s\n' "$*"; }
SUMMARY=()

sync_one() {
  local name="$1" path="$2"
  log ""; log "================ $name ($path)"
  if [[ ! -d "$path/.git" && ! -f "$path/.git" ]]; then log "  kihagyva: nem git repo"; SUMMARY+=("$name|kihagyva (nem git)"); return; fi
  local cur; cur="$(git -C "$path" branch --show-current)"
  if [[ -z "$cur" ]]; then log "  kihagyva: detached HEAD"; SUMMARY+=("$name|kihagyva (detached)"); return; fi
  local dirty_before; dirty_before="$(git -C "$path" status --porcelain | wc -l | tr -d ' ')"
  log "  branch: $cur → $BRANCH   (owner dirty fajlok: $dirty_before)"
  if [[ $DRY_RUN -eq 1 ]]; then
    ./sync.sh --dry-run --force --project "$name" 2>&1 | grep -E "TORLODIK|Osszesen|\(update\)|^\s+\S+/$" | head -40
    SUMMARY+=("$name|dry-run"); return
  fi
  if git -C "$path" show-ref --verify --quiet "refs/heads/$BRANCH"; then git -C "$path" switch -q "$BRANCH"; else git -C "$path" switch -q -c "$BRANCH"; fi

  # 2. megosztott utvonalakon levo helyi modositasok mentese
  local shared_dirty; shared_dirty="$(cd "$path" && git status --porcelain -- "${SHARED_TOP[@]}" 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$shared_dirty" != "0" ]]; then
    (cd "$path" && git add -A -- "${SHARED_TOP[@]}" 2>/dev/null; git commit -q -m "chore(save): helyi módosítások mentése skeleton sync előtt

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>") && log "  mentve: $shared_dirty helyi modositas a megosztott utvonalakon"
  fi

  # 3. sync
  local before after; before="$(cd "$path" && git status --porcelain | awk '{print $NF}' | sort)"
  ./sync.sh --yes --force --project "$name" > "/tmp/fleet-sync-$name.log" 2>&1 || log "  FIGYELEM: sync.sh hibaval tert vissza (log: /tmp/fleet-sync-$name.log)"
  after="$(cd "$path" && git status --porcelain | awk '{print $NF}' | sort)"

  # 4. csak a sync altal erintett utvonalak
  local touched; touched="$(comm -13 <(echo "$before") <(echo "$after"))"
  (cd "$path" && { [[ -n "$touched" ]] && echo "$touched" | xargs git add -A -- 2>/dev/null; git add -A -- .skeleton-version CLAUDE.md AGENTS.md GEMINI.md .gitignore .claude .aios-cli .codex scripts templates tests/skeleton-validation 2>/dev/null; true; })
  if (cd "$path" && ! git diff --cached --quiet); then
    (cd "$path" && git commit -q -m "chore(skeleton): sync v${VERSION} – egységes ökoszisztéma, orchestrator, egy projekt = egy mappa

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>") && log "  commit: skeleton v${VERSION}"
  else
    log "  nincs valtozas a sync utan"
  fi

  # 5. validacio
  local v=""
  (cd "$path" && [[ -x .aios-cli/scripts/validate-skills.sh ]] && .aios-cli/scripts/validate-skills.sh >/dev/null 2>&1) && v+="skills:ok " || v+="skills:HIBA "
  (cd "$path" && python3 "$SKELETON_ROOT/.aios-cli/scripts/validate-project-layout.py" . >/dev/null 2>&1) && v+="layout:ok " || v+="layout:HIBA "
  if [[ -f "$path/tests/skeleton-validation/run-all.sh" ]]; then
    (cd "$path" && bash tests/skeleton-validation/run-all.sh >/dev/null 2>&1) && v+="suite:ok" || v+="suite:HIBA"
  fi
  log "  validacio: $v"

  # 6. push
  local pushed="nincs remote"
  if [[ $PUSH -eq 1 ]] && git -C "$path" remote get-url origin >/dev/null 2>&1; then
    if git -C "$path" push -q -u origin "$BRANCH" 2>/tmp/fleet-push-$name.log; then pushed="pusholva"; else pushed="PUSH HIBA ($(tail -1 /tmp/fleet-push-$name.log | cut -c1-60))"; fi
  fi
  local dirty_after; dirty_after="$(git -C "$path" status --porcelain | wc -l | tr -d ' ')"
  log "  push: $pushed   owner dirty utana: $dirty_after"
  SUMMARY+=("$name|$BRANCH|$v|$pushed|dirty ${dirty_before} → ${dirty_after}")
}

while IFS= read -r line; do
  [[ -z "${line// }" || "$line" =~ ^[[:space:]]*# ]] && continue
  IFS='|' read -r n p _ <<< "$line"; n="${n// /}"; p="${p// /}"
  [[ -n "$FILTER" && "$n" != "$FILTER" ]] && continue
  sync_one "$n" "$p"
done < "$REGISTRY"

log ""; log "================ OSSZEFOGLALO"
printf '%s\n' "${SUMMARY[@]}" | column -t -s '|'

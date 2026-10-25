#!/usr/bin/env bash
# Okoszisztema kanon validacio (v8.0, plan-v15 F1)
# - skillpass.id az egyetlen IdP, aibos.space az admin + kulon auth
# - a korabbi IdP teljesen kivezetve (csak ores fajlok nevesithetik)
set -uo pipefail

E=0
fail() { echo "  ❌ $*"; E=$((E+1)); }

# Owner dontes (2026-10-06): a korabbi IdP teljes kivezetese, tortenti dokumentumokbol is.
# Kivetel csak az ores fajlok: a nevet ismerniuk kell, hogy tiltani / torolni tudjak.
GUARD_FILES=(
  ./tests/skeleton-validation/test-ecosystem.sh
  ./.claude/hooks/check-brand.sh
  ./.claude/hooks/check-safety.sh
  ./.aios-cli/removed-paths.txt
)

# Csak a git altal kovetett / kovetheto fajlok (gitignore-olt szemelyes fajlok kimaradnak)
hits="$(git ls-files -z -co --exclude-standard | xargs -0 grep -IliE "everpass|evpass" 2>/dev/null \
  | sed 's|^|./|' \
  | grep -vxF -f <(printf '%s\n' "${GUARD_FILES[@]}") || true)"
# A skeletonban (projekt-registry van) szigoru hiba; sync-elt projektben figyelmeztetes,
# mert a projekt sajat tortenti dokumentumainak cserejet kulon, projekt-specifikusan vegezzuk.
if [[ -n "${hits}" ]]; then
  if [[ -f .skeleton-root ]]; then
    fail "everpass hivatkozas maradt:"
    echo "${hits}" | sed 's/^/       /'
  else
    echo "  ⚠️  regi IdP hivatkozas a projekt sajat fajljaiban ($(echo "${hits}" | wc -l | tr -d ' ') fajl) – csere kulon lepesben:"
    echo "${hits}" | head -8 | sed 's/^/       /'
  fi
fi


CANON=".aios-cli/core/ecosystem.md"
if [[ -f "${CANON}" ]]; then
  for needle in "skillpass.id" "auth.skillpass.id" "aibos.space" "aibos-auth" "AppManifest"; do
    grep -q "${needle}" "${CANON}" || fail "${CANON}: hianyzik '${needle}'"
  done
else
  fail "Hianyzik: ${CANON}"
fi

[[ -f .claude/rules/ecosystem.md ]] || fail "Hianyzik: .claude/rules/ecosystem.md"
[[ -f .claude/identity/brand-skillpass.md ]] || fail "Hianyzik: .claude/identity/brand-skillpass.md"

# Kezzel karbantartott CLAUDE.md-nel a szabaly a sync-elt .claude/rules/ecosystem.md-n keresztul ervenyes
for f in CLAUDE.md AGENTS.md GEMINI.md; do
  [[ -f "$f" ]] || continue
  if [[ "$f" == CLAUDE.md ]] && ! grep -q "automatikusan generált" "$f"; then
    [[ -f .claude/rules/ecosystem.md ]] || fail "CLAUDE.md kezi, es hianyzik .claude/rules/ecosystem.md"
    continue
  fi
  grep -q "skillpass.id az egyetlen" "$f" || fail "$f: hianyzik az okoszisztema szabaly"
done

for s in skillpass-auth skillpass-portal aibos-admin-contract; do
  [[ -f ".aios-cli/skills/${s}/SKILL.md" ]] || fail "Hianyzik skill: ${s}"
done

for s in everpass-auth everpass-admin-experience; do
  [[ -e ".aios-cli/skills/${s}" || -e ".claude/skills/${s}" ]] && fail "Megszuntetett skill meg letezik: ${s}"
done

# check-safety hook: okoszisztema orok (plan-v15 F5)
hook_blocks() {
  local content="$1" path="${2:-apps/web/lib/x.ts}"
  printf '%s' "{\"tool_input\":{\"file_path\":\"${path}\",\"content\":$(printf '%s' "$content" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}}" \
    | bash .claude/hooks/check-safety.sh >/dev/null 2>&1
  [[ $? -eq 2 ]]
}
OLD_IDP="ever""pass"
hook_blocks "const issuer = 'https://auth.${OLD_IDP}.id'" || fail "check-safety: megszunt IdP issuer nincs blokkolva"
hook_blocks "localStorage.setItem('access_token', tok)" || fail "check-safety: localStorage token nincs blokkolva"
hook_blocks "const k = 'aibs""_live_0123456789abcdef0123'" || fail "check-safety: aibos services kulcs nincs blokkolva"
hook_blocks "SKILLPASS_CLIENT_SECRET=""abcdef0123456789abcdef" || fail "check-safety: SkillPass client secret ertek nincs blokkolva"
hook_blocks "const issuer = process.env.SKILLPASS_ISSUER" && fail "check-safety: ervenyes skillpass kod blokkolva (false positive)"

# Tapasztalatok + orchestrator a generalt konfigokban
[[ -f .aios-cli/core/lessons.md ]] || fail "Hianyzik: .aios-cli/core/lessons.md"
for f in CLAUDE.md AGENTS.md GEMINI.md; do
  [[ -f "$f" ]] || continue
  if [[ "$f" == CLAUDE.md ]] && ! grep -q "automatikusan generált" "$f"; then
    [[ -f .aios-cli/core/lessons.md && -x scripts/aios ]] || fail "CLAUDE.md kezi: lessons.md vagy scripts/aios hianyzik"
    continue
  fi
  grep -q "L-01" "$f" || fail "$f: hianyzik a tapasztalat (lessons) kivonat"
  grep -q "scripts/aios" "$f" || fail "$f: hianyzik az aios orchestrator hivatkozas"
done
[[ -f templates/plan/00-overview.md ]] || fail "Hianyzik: templates/plan/00-overview.md"

# Fiok-felulet szabvany (plan-v16 D-V16-08)
REF=.aios-cli/skills/skillpass-portal/references/partner-account-shell.md
[[ -f "$REF" ]] || fail "Hianyzik: $REF"
for needle in "sp-sidebar__brand" "shell-context" "shellManifest" "/fiok/" "Account Center"; do
  grep -q -- "$needle" "$REF" 2>/dev/null || fail "$REF: hianyzik '$needle'"
done
[[ -f templates/portal/lib/shell/shell-manifest.ts ]] || fail "Hianyzik: templates/portal/lib/shell/shell-manifest.ts"
[[ -f templates/portal/lib/shell/account-shell.example.tsx ]] || fail "Hianyzik: account-shell.example.tsx"
grep -q "L-17" .aios-cli/core/lessons.md || fail "lessons.md: L-17 hianyzik"

[[ $E -eq 0 ]]

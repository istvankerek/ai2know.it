#!/usr/bin/env bash
# CLAUDE.md validacio
E=0
[[ ! -f CLAUDE.md ]] && exit 1

L=$(wc -l < CLAUDE.md)
if [[ $L -gt 600 ]]; then
  echo "  ❌ CLAUDE.md tul hosszu: $L sor (max 600)"
  E=$((E+1))
fi

grep -Eq "Aranyszab[aá]ly" CLAUDE.md || { echo "  ❌ Aranyszabalyok hianyzik"; E=$((E+1)); }
if grep -q "automatikusan generált" CLAUDE.md; then
  grep -q "AIOS Skill Source" CLAUDE.md || { echo "  ❌ AIOS skill source hianyzik"; E=$((E+1)); }
  grep -q ".aios-cli/skills" CLAUDE.md || { echo "  ❌ .aios-cli skill hivatkozas hianyzik"; E=$((E+1)); }
else
  [[ -d .aios-cli/skills ]] || { echo "  ❌ kezi CLAUDE.md, de nincs .aios-cli/skills"; E=$((E+1)); }
fi
grep -qE '(make |npm |cargo |./scripts)' CLAUDE.md || { echo "  ❌ Build parancsok hianyoznak"; E=$((E+1)); }

[[ $E -eq 0 ]]

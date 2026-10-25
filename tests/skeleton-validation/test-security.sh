#!/usr/bin/env bash
# Security baseline
E=0

# Hardcoded secret scan a kodbazisban (kihagyjuk a node_modules / .env / specification / .git)
SECRETS=$(grep -rn --include="*.rs" --include="*.ts" --include="*.tsx" --include="*.sh" \
  -E '(api[_-]?key|secret|password|token)\s*=\s*"[A-Za-z0-9_-]{16,}"' . 2>/dev/null | \
  grep -v node_modules | \
  grep -v ".env" | \
  grep -v "specification/" | \
  grep -v ".git/" | \
  head -5 || true)

if [[ -n "$SECRETS" ]]; then
  echo "  ❌ Hardcoded secret-ek lehetnek:"
  echo "$SECRETS" | head -5
  E=$((E+1))
fi

# Settings.json deny rules
grep -q "rm -rf" .claude/settings.json || { echo "  ❌ rm -rf nincs deny-ban"; E=$((E+1)); }
grep -q "DROP" .claude/settings.json || echo "  ⚠️ DROP nincs deny-ban (figyelmeztetes)"

# .env soha nincs Git-ben
if git ls-files 2>/dev/null | grep -qE "^\.env$"; then
  echo "  ❌ .env Git-ben van!"
  E=$((E+1))
fi

[[ $E -eq 0 ]]

#!/usr/bin/env bash
# Skeleton Validation Test Suite
# Futtatja a 9 validation tesztet a skeleton-en
# Hasznalat: bash tests/skeleton-validation/run-all.sh

set -uo pipefail
echo "🧪 Skeleton Validation Test Suite (v8.1)"
echo "=========================================="
PASS=0; FAIL=0; SKIP=0

run_test() {
  local name="$1" file="$2"
  if [[ ! -f "$file" ]]; then
    echo "⏭️  SKIP: $name"
    SKIP=$((SKIP+1))
    return
  fi
  if bash "$file"; then
    echo "✅ PASS: $name"
    PASS=$((PASS+1))
  else
    echo "❌ FAIL: $name"
    FAIL=$((FAIL+1))
  fi
}

run_test "Structure"        "tests/skeleton-validation/test-structure.sh"
run_test "CLAUDE.md"        "tests/skeleton-validation/test-claude-md.sh"
run_test "Settings"         "tests/skeleton-validation/test-settings.sh"
run_test "Skills"           "tests/skeleton-validation/test-skills.sh"
run_test "Hooks"            "tests/skeleton-validation/test-hooks.sh"
run_test "Agents"           "tests/skeleton-validation/test-agents.sh"
run_test "Codex"            "tests/skeleton-validation/test-codex.sh"
run_test "Docker"           "tests/skeleton-validation/test-docker.sh"
run_test "Git"              "tests/skeleton-validation/test-git.sh"
run_test "Security"         "tests/skeleton-validation/test-security.sh"
run_test "Ecosystem"        "tests/skeleton-validation/test-ecosystem.sh"
run_test "Project layout"   "tests/skeleton-validation/test-project-layout.sh"

echo ""
echo "=========================================="
echo "Eredmeny: ✅ $PASS | ❌ $FAIL | ⏭️ $SKIP"

[[ $FAIL -eq 0 ]]

#!/bin/bash
# scripts/migrate-loops-to-routines.sh — v5.6
# Meglevo /loop hasznalatok azonositasa + Routine konvertalasi javaslat

set -e

cd "$(dirname "$0")/.."

echo "🔍 Meglevo /loop hasznalatok scan-elese..."
echo ""

# Keres .claude/prompt-log/ alatt
LOOPS=$(grep -r "/loop" .claude/prompt-log/ 2>/dev/null | grep -v Binary || true)

if [ -z "$LOOPS" ]; then
    echo "✅ Nincs /loop hasznalat eddigi prompt-log-okban."
    exit 0
fi

echo "$LOOPS" | head -20

echo ""
echo "📋 Javasolt Routine tipusok:"
echo ""
echo "  Sentry monitoring        → .claude/routines/api-triggered/sentry-alert-triage.yml"
echo "  CI watch                 → .claude/routines/webhook/pr-bespoke-review.yml"
echo "  Deploy verification      → .claude/routines/api-triggered/deploy-verification.yml"
echo "  Heti riport / autodream  → .claude/routines/scheduled/weekly-*.yml"
echo "  Auto-iterate failing tst → .claude/routines/scheduled/daily-eval-suite.yml"
echo ""
echo "Ami NE kerujon Routine-ra:"
echo "  - Helyi debugging session"
echo "  - Fejleszto-specifikus monitoring"
echo "  - Egyszeri task"
echo ""
echo "Reszletek: specification/skeleton-specifications/everengine-v5.6-patch-context-economy-routines.md"

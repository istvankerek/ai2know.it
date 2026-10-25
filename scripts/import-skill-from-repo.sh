#!/usr/bin/env bash
# Cross-repo skill import Repomix segitsegevel
# Hasznalat: ./scripts/import-skill-from-repo.sh <github-repo> <skill-nev> [cel-mappa]
# Pelda: ./scripts/import-skill-from-repo.sh everengine/aibos crud-generator
# Everengine v6.5

set -e

REPO="${1:-}"
SKILL_NAME="${2:-}"
TARGET_DIR="${3:-.claude/skills}"

# Argumentumok ellenorzese
if [ -z "$REPO" ] || [ -z "$SKILL_NAME" ]; then
    echo "Hasznalat: $0 <github-repo> <skill-nev> [cel-mappa]"
    echo "Pelda: $0 everengine/aibos crud-generator"
    exit 1
fi

SKILL_TARGET="$TARGET_DIR/$SKILL_NAME"

# Cel mappa letrehozasa ha nem letezik
mkdir -p "$SKILL_TARGET"

echo "Skill import: $REPO -> $SKILL_TARGET"

# Repomix ellenorzese
if ! command -v repomix &>/dev/null; then
    echo "Repomix nem talalhato. Telepites: npm install -g repomix"
    exit 1
fi

# Ideiglenes konyvtar
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Skill letoltese Repomix segitsegevel
echo "Letoltes: github.com/$REPO/tree/main/.claude/skills/$SKILL_NAME"
repomix \
    --remote "https://github.com/$REPO" \
    --include ".claude/skills/$SKILL_NAME/**" \
    --output "$TMPDIR/skill-import.md" 2>/dev/null || {
    echo "Repomix hiba. Probald kozvetlenul:"
    echo "  gh repo clone $REPO /tmp/repo-temp -- --depth=1 --sparse"
    echo "  cp -r /tmp/repo-temp/.claude/skills/$SKILL_NAME $SKILL_TARGET/"
    exit 1
}

# SKILL.md kinyerese az importalt tartalombol
if [ -f "$TMPDIR/skill-import.md" ]; then
    # Adapter komment hozzafuzese a SKILL.md-hez
    {
        echo "<!-- ADAPTER: Magyar adaptacio szukseges lehet. Eredeti: github.com/$REPO -->"
        echo "<!-- Importalva: $(date '+%Y-%m-%d') a import-skill-from-repo.sh segitsegevel -->"
        echo ""
        cat "$TMPDIR/skill-import.md"
    } > "$SKILL_TARGET/SKILL.md"
    echo "Sikeresen importalva: $SKILL_TARGET/SKILL.md"
    echo ""
    echo "Ellenorizd es adaptald a tartalmát:"
    echo "  - Magyar nyelvu dokumentacio"
    echo "  - Everengine voice es anti-style betartasa"
    echo "  - Helyi env valtozok es path-ok frissitese"
else
    echo "Hiba: nem sikerult kinyerni a skill tartalmat."
    exit 1
fi

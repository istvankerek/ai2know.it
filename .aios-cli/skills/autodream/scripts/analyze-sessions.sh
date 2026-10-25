#!/bin/bash
# Autodream: Prompt-log elemzes script
# Futtatas: bash .claude/skills/autodream/scripts/analyze-sessions.sh [napok]

DAYS=${1:-14}
PROMPT_LOG_DIR=".claude/prompt-log"
COORDINATION="COORDINATION.md"

echo "# Autodream Elemzes – $(date +%Y-%m-%d)"
echo "## Vizsgalt idoszak: utolso $DAYS nap"
echo ""

# 1. Session logok elemzese
echo "## Session logok"
if [ -d "$PROMPT_LOG_DIR" ]; then
  session_count=$(find "$PROMPT_LOG_DIR" -name "session_*.md" -mtime -"$DAYS" | wc -l)
  echo "- Session-ok szama: $session_count"
  echo ""
else
  echo "- Nincs prompt-log konyvtar"
fi

# 2. Git history elemzes
echo "## Git History (utolso $DAYS nap)"
if git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "### Commit statisztika"
  commit_count=$(git log --oneline --since="$DAYS days ago" 2>/dev/null | wc -l)
  echo "- Commit-ok szama: $commit_count"
  echo ""

  echo "### Leggyakrabban modositott fajlok (hotspot-ok)"
  git log --since="$DAYS days ago" --name-only --format="" 2>/dev/null | sort | uniq -c | sort -rn | head -10
  echo ""

  echo "### Commit uzenet mintak"
  git log --oneline --since="$DAYS days ago" --format="%s" 2>/dev/null | head -20
  echo ""
else
  echo "- Nem git repo"
fi

# 3. COORDINATION.md allapot
echo "## COORDINATION.md"
if [ -f "$COORDINATION" ]; then
  echo "- Letezik"
  grep -c "?" "$COORDINATION" 2>/dev/null && echo " nyitott kerdes"
else
  echo "- Nem letezik"
fi

echo ""
echo "## Kovetkezo lepes"
echo "Futtasd Claude-dal: 'Elemezd az autodream outputot es keszits riportot'"

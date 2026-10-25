#!/usr/bin/env bash
# settings.json validacio
[[ ! -f .claude/settings.json ]] && exit 1
python3 -c "import json; json.load(open('.claude/settings.json'))" 2>/dev/null || {
  echo "  ❌ Invalid JSON"; exit 1
}
grep -q '"deny"' .claude/settings.json || { echo "  ❌ deny section hianyzik"; exit 1; }
grep -q '"PreToolUse"' .claude/settings.json || { echo "  ❌ PreToolUse hianyzik"; exit 1; }
exit 0

#!/bin/bash
# PreToolUse hook: Veszelyes bash parancsok ellenorzese
# L0 BLOCK — nincs override, exit 2 = BLOCK
json=$(cat)
command=$(echo "$json" | jq -r '.tool_input.command // empty')

if [ -z "$command" ]; then
  exit 0
fi

# --- Veszelyes parancsok (L0 BLOCK) ---
dangerous_patterns=(
  "rm -rf /"
  "rm -rf \*"
  "rm -rf ."
  "DROP TABLE"
  "DROP DATABASE"
  "DELETE FROM"
  "TRUNCATE"
  "docker compose down -v"
  "chmod 777"
  "curl.*| bash"
  "curl.*| sh"
  "wget.*| bash"
  "> /dev/sd"
  "mkfs\."
  "dd if="
)

for pattern in "${dangerous_patterns[@]}"; do
  if echo "$command" | grep -qi "$pattern"; then
    echo "{\"decision\":\"block\",\"reason\":\"L0 BLOCK: Veszelyes parancs detektlva: $pattern\"}"
    exit 2
  fi
done

# --- Figyelmeztetesek (L1 APPROVE — nem block, de jelzes) ---
warn_patterns=(
  "git push.*--force"
  "git reset --hard"
  "npm install"
  "cargo add"
  "docker compose.*prod"
)

for pattern in "${warn_patterns[@]}"; do
  if echo "$command" | grep -qi "$pattern"; then
    echo "{\"hookSpecificOutput\":{\"additionalContext\":\"FIGYELEM: L1 APPROVE szukseges — '$pattern' minta talalhato. Kerj jovahagyast!\"}}"
    exit 0
  fi
done

exit 0

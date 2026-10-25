#!/bin/bash
# PreToolUse hook: Prompt injection scan [v2.3]
# Forras: awesome-claude-code + Trail of Bits security
json=$(cat)
content=$(echo "$json" | jq -r '.tool_input.content // .tool_input.new_string // empty')

if [ -z "$content" ]; then
  exit 0
fi

# --- Prompt injection mintak keresese ---
injection_patterns=(
  "ignore previous instructions"
  "ignore all previous"
  "disregard your instructions"
  "you are now"
  "new instructions:"
  "system prompt:"
  "IMPORTANT: override"
  "forget everything"
  "act as if"
  "pretend you are"
  "jailbreak"
  "<system>"
  "</system>"
)

for pattern in "${injection_patterns[@]}"; do
  if echo "$content" | grep -qi "$pattern"; then
    echo "{\"decision\":\"block\",\"reason\":\"L0 BLOCK: Prompt injection gyanú detektalva: '$pattern' minta. A tartalom elutasitva.\"}"
    exit 2
  fi
done

exit 0

#!/bin/bash
# PostToolUse hook: Automatikus lint + format (Prettier)
# L2 AUTO-FIX — a hook automatikusan javit
json=$(cat)
file_path=$(echo "$json" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ]; then
  exit 0
fi

# Csak TypeScript/JavaScript fajlokra futtatjuk
case "$file_path" in
  *.ts|*.tsx|*.js|*.jsx)
    # Prettier format
    if command -v npx &> /dev/null; then
      npx prettier --write "$file_path" 2>/dev/null
    fi

    # ESLint auto-fix
    if command -v npx &> /dev/null; then
      npx eslint --fix "$file_path" 2>/dev/null
    fi
    ;;
  *.css|*.scss)
    if command -v npx &> /dev/null; then
      npx prettier --write "$file_path" 2>/dev/null
    fi
    ;;
  *.json)
    if command -v npx &> /dev/null; then
      npx prettier --write "$file_path" 2>/dev/null
    fi
    ;;
  *.rs)
    # Rust format
    if command -v rustfmt &> /dev/null; then
      rustfmt "$file_path" 2>/dev/null
    fi
    ;;
esac

exit 0

#!/bin/bash
# PreToolUse hook: intelligens skill routing fajl path alapjan [v2.3]
# Forras: awesome-claude-code/claude-code-infrastructure-showcase
json=$(cat)
file_path=$(echo "$json" | jq -r '.tool_input.file_path // empty')

# Kontextus-fuggo skill javaslat (additionalContext-kent)
context=""

if [[ "$file_path" == *"test"* || "$file_path" == *"spec"* ]]; then
  context="Relevant skill: .claude/skills/unit-test-writer/SKILL.md"
elif [[ "$file_path" == *"migration"* || "$file_path" == *"schema"* ]]; then
  context="Relevant skill: .claude/skills/db-migration/SKILL.md"
elif [[ "$file_path" == *"scraper"* ]]; then
  context="Relevant skill: .claude/skills/scraper/SKILL.md"
elif [[ "$file_path" == *"spider"* ]]; then
  context="Relevant skill: .claude/skills/spider/SKILL.md"
elif [[ "$file_path" == *"endpoint"* || "$file_path" == *"controller"* ]]; then
  context="Relevant skill: .claude/skills/crud-generator/SKILL.md"
elif [[ "$file_path" == *"docker"* || "$file_path" == *"compose"* ]]; then
  context="Relevant skill: .claude/skills/docker-setup/SKILL.md"
elif [[ "$file_path" == *"caddy"* || "$file_path" == *"Caddyfile"* ]]; then
  context="Relevant skill: .claude/skills/caddy-gateway/SKILL.md"
elif [[ "$file_path" == *"monitoring"* || "$file_path" == *"prometheus"* || "$file_path" == *"grafana"* ]]; then
  context="Relevant skill: .claude/skills/monitoring-setup/SKILL.md"
elif [[ "$file_path" == *"i18n"* || "$file_path" == *"locales"* ]]; then
  context="Relevant skill: .claude/skills/i18n-setup/SKILL.md"
elif [[ "$file_path" == *"notification"* || "$file_path" == *"email"* ]]; then
  context="Relevant skill: .claude/skills/notification-system/SKILL.md"
elif [[ "$file_path" == *"auth"* || "$file_path" == *"oidc"* || "$file_path" == *"skillpass"* ]]; then
  context="Relevant skill: .claude/skills/skillpass-auth/SKILL.md"
elif [[ "$file_path" == *"backup"* ]]; then
  context="Relevant skill: .claude/skills/backup-strategy/SKILL.md"
elif [[ "$file_path" == *"worker"* ]]; then
  context="Relevant skill: .claude/skills/worker-management/SKILL.md"
fi

# v8.0: skill katalogus (SkillPass.ID menufa) – az app teljes skill-szekcioja
CATALOG_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../.aios-cli/scripts/build-skill-catalog.py"
if [ -n "$file_path" ] && [ -f "$CATALOG_SCRIPT" ] && command -v python3 >/dev/null 2>&1; then
  rel_path="${file_path#"$PWD"/}"
  app_line=$(python3 "$CATALOG_SCRIPT" --for-path "$rel_path" 2>/dev/null | tr -d '"\\' || true)
  if [ -n "$app_line" ]; then
    context="${context:+$context | }Skill katalogus app: ${app_line}"
  fi
fi

if [ -n "$context" ]; then
  echo "{\"hookSpecificOutput\":{\"additionalContext\":\"$context\"}}"
fi

exit 0

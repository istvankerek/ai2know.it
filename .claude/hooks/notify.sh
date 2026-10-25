#!/bin/bash
# Notification hook: Telegram (critical) / Slack (warning)
# Kornyezeti valtozokbol olvassa a webhook URL-eket

TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

json=$(cat)
title=$(echo "$json" | jq -r '.title // "Claude Code Notification"')
body=$(echo "$json" | jq -r '.body // "No details"')

# Sulyossag meghatarozasa
severity="info"
if echo "$body" | grep -qi "error\|critical\|fail\|block"; then
  severity="critical"
elif echo "$body" | grep -qi "warning\|warn\|figyelem"; then
  severity="warning"
fi

# --- Telegram (critical esemenyek) ---
if [ "$severity" = "critical" ] && [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
  message="🔴 *CRITICAL*: ${title}%0A${body}"
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" \
    -d "text=${message}" \
    -d "parse_mode=Markdown" \
    > /dev/null 2>&1
fi

# --- Slack (warning + critical) ---
if [ "$severity" != "info" ] && [ -n "$SLACK_WEBHOOK_URL" ]; then
  icon="⚠️"
  [ "$severity" = "critical" ] && icon="🔴"

  payload=$(jq -n \
    --arg text "${icon} *${title}*\n${body}" \
    '{text: $text}')

  curl -s -X POST "$SLACK_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    > /dev/null 2>&1
fi

exit 0

#!/bin/bash
# PreToolUse hook: Secret es vedett fajl ellenorzes
# L0 BLOCK — nincs override, exit 2 = BLOCK
json=$(cat)
file_path=$(echo "$json" | jq -r '.tool_input.file_path // empty')
content=$(echo "$json" | jq -r '.tool_input.content // .tool_input.new_string // empty')

# --- Secret minta ellenorzes a tartalomban ---
if [ -n "$content" ]; then
  # API kulcsok, tokenek, jelszavak keresese
  if echo "$content" | grep -qEi '(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|password\s*[:=]\s*["\x27][^"\x27]+["\x27])'; then
    echo '{"decision":"block","reason":"L0 BLOCK: Secret talalhato a tartalomban! Soha ne irj titkos kulcsot kodba."}'
    exit 2
  fi

  # .env tartalom kiszivargasa kodba
  if echo "$content" | grep -qEi '(DATABASE_URL|SECRET_KEY|API_SECRET|PRIVATE_KEY)\s*[:=]'; then
    echo '{"decision":"block","reason":"L0 BLOCK: Kornyezeti valtozo erteke talalhato a tartalomban."}'
    exit 2
  fi

  # --- Okoszisztema orok (v8.0, plan-v15 F5) ---
  # aibos services cegkotott API kulcs
  if echo "$content" | grep -qE 'aibs_(live|test)_[A-Za-z0-9]{16,}'; then
    echo '{"decision":"block","reason":"L0 BLOCK: aibos services API kulcs a tartalomban. Csak env-bol olvashato."}'
    exit 2
  fi

  # SkillPass / Ory kliens secret ertek (a your_* / generate_* minta-ertek megengedett)
  if echo "$content" | grep -E '(SKILLPASS|HYDRA|ORY)_[A-Z_]*SECRET[[:space:]]*[:=][[:space:]]*["\x27]?[A-Za-z0-9_\-]{16,}' \
       | grep -qvE '[:=][[:space:]]*["\x27]?(your_|generate_|change_me)'; then
    echo '{"decision":"block","reason":"L0 BLOCK: SkillPass/Ory kliens secret ertek a tartalomban. Csak env-bol olvashato."}'
    exit 2
  fi

  # Token a bongeszo storage-ban (BFF + httpOnly cookie kotelezo)
  if echo "$content" | grep -qEi '(localStorage|sessionStorage)\.setItem\([^)]*(token|jwt|session)'; then
    echo '{"decision":"block","reason":"L0 BLOCK: token bongeszo storage-ban. SkillPass BFF + httpOnly cookie kotelezo (skillpass-auth skill)."}'
    exit 2
  fi

  # Megszunt IdP (D-V15-02) uj kodban; tortenti dokumentacio kivetel
  case "$file_path" in
    */specification/*|*/CHANGELOG.md|*/.aios-cli/removed-paths.txt) ;;
    *)
      if echo "$content" | grep -qEi 'everpass\.(id|me)'; then
        echo '{"decision":"block","reason":"L0 BLOCK: megszunt IdP. Az egyetlen IdP a skillpass.id (lasd .aios-cli/core/ecosystem.md)."}'
        exit 2
      fi
      ;;
  esac
fi

# --- Vedett fajlok ---
if [ -n "$file_path" ]; then
  case "$file_path" in
    *.env|*.env.local|*.env.test|*.env.prod)
      echo '{"decision":"block","reason":"L0 BLOCK: .env fajl modositasa tiltott!"}'
      exit 2
      ;;
    */credentials.json)
      echo '{"decision":"block","reason":"L0 BLOCK: Credentials fajl modositasa tiltott!"}'
      exit 2
      ;;
    */docker-compose.prod.yml)
      echo '{"decision":"block","reason":"L1 APPROVE: Prod compose modositas jovahagyast igenyel."}'
      exit 2
      ;;
  esac
fi

exit 0

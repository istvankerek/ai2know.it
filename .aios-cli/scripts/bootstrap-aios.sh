#!/usr/bin/env bash
# Bootstrap an AIOS multi-CLI skeleton into a project directory.
#
# Usage:
#   .aios-cli/scripts/bootstrap-aios.sh [target-dir]
#
# Defaults to the current working directory. The script copies the current
# `.aios-cli` skeleton into the target, creates minimal CLI entry folders, and
# generates CLAUDE.md, AGENTS.md, and GEMINI.md from `.aios-cli`.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_AIOS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_ROOT="$(cd "${SOURCE_AIOS_DIR}/.." && pwd)"
TARGET_DIR="$(cd "${1:-.}" && pwd)"

log() {
  printf '✅ %s\n' "$1"
}

info() {
  printf 'ℹ️  %s\n' "$1"
}

fail() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

copy_aios_skeleton() {
  if [[ "${TARGET_DIR}/.aios-cli" == "${SOURCE_AIOS_DIR}" ]]; then
    info "Target already uses this .aios-cli skeleton"
    return
  fi

  if [[ -e "${TARGET_DIR}/.aios-cli" && ! -d "${TARGET_DIR}/.aios-cli" ]]; then
    fail "Target .aios-cli exists but is not a directory"
  fi

  mkdir -p "${TARGET_DIR}/.aios-cli"
  rsync -a --delete \
    --exclude '.DS_Store' \
    "${SOURCE_AIOS_DIR}/" \
    "${TARGET_DIR}/.aios-cli/"
  log "Copied .aios-cli skeleton"
}

ensure_entry_dirs() {
  mkdir -p \
    "${TARGET_DIR}/.claude" \
    "${TARGET_DIR}/.codex" \
    "${TARGET_DIR}/.gemini"

  if [[ ! -f "${TARGET_DIR}/.claude/settings.json" ]]; then
    cat > "${TARGET_DIR}/.claude/settings.json" << 'JSON'
{
  "env": {
    "AIOS_ACTIVE_CLI": "claude"
  },
  "permissions": {
    "allow": [
      "Read *",
      "Write .aios-cli/**",
      "Bash(./.aios-cli/scripts/generate-cli-configs.sh *)",
      "Bash(./.aios-cli/scripts/validate-skills.sh)"
    ],
    "deny": [
      "Bash(rm -rf / *)",
      "Bash(git push --force *)"
    ]
  }
}
JSON
    log "Created .claude/settings.json"
  fi
}

generate_configs() {
  (
    cd "${TARGET_DIR}"
    AIOS_OVERWRITE_CLAUDE=1 ./.aios-cli/scripts/generate-cli-configs.sh all
    ./.aios-cli/scripts/validate-skills.sh
  )
  log "Generated CLAUDE.md, AGENTS.md, GEMINI.md"
}

write_readme_hint() {
  local readme_path="${TARGET_DIR}/AIOS.md"
  if [[ -f "${readme_path}" ]]; then
    return
  fi

  cat > "${readme_path}" << 'MARKDOWN'
# AIOS Multi-CLI Skeleton

Source-of-truth: `.aios-cli`.

Useful commands:

```bash
.aios-cli/scripts/generate-cli-configs.sh all
.aios-cli/scripts/validate-skills.sh
python3 .aios-cli/scripts/build-skill-catalog.py --check
```

Do not edit generated `CLAUDE.md`, `AGENTS.md`, or `GEMINI.md` directly.
Update `.aios-cli/core`, `.aios-cli/adapters`, or `.aios-cli/skills`, then regenerate.
MARKDOWN
  log "Created AIOS.md"
}

info "Source root: ${SOURCE_ROOT}"
info "Target: ${TARGET_DIR}"

copy_aios_skeleton
ensure_entry_dirs
generate_configs
write_readme_hint

log "AIOS bootstrap complete"


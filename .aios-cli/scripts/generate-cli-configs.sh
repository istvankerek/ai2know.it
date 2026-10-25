#!/usr/bin/env bash
# AIOS CLI config generator.
#
# Usage:
#   .aios-cli/scripts/generate-cli-configs.sh [claude|codex|gemini|all] [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AIOS_CLI_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROOT_DIR="$(cd "${AIOS_CLI_DIR}/.." && pwd)"
CORE_DIR="${AIOS_CLI_DIR}/core"
ADAPTERS_DIR="${AIOS_CLI_DIR}/adapters"
SKILLS_DIR="${AIOS_CLI_DIR}/skills"

TARGET="${AIOS_ACTIVE_CLI:-all}"
DRY_RUN=0

for arg in "$@"; do
  case "${arg}" in
    claude|codex|gemini|all)
      TARGET="${arg}"
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    *)
      echo "Unknown argument: ${arg}" >&2
      echo "Usage: ${0} [claude|codex|gemini|all] [--dry-run]" >&2
      exit 1
      ;;
  esac
done

PROJECT_NAME="$(grep -m1 '^# ' "${ROOT_DIR}/CLAUDE.md" 2>/dev/null | sed 's/^# //' || basename "${ROOT_DIR}")"
if [[ -z "${PROJECT_NAME}" || "${PROJECT_NAME}" == "{{PROJECT_NAME}}" ]]; then
  PROJECT_NAME="$(basename "${ROOT_DIR}")"
fi
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

extract_frontmatter_value() {
  local file="$1"
  local key="$2"
  awk -v key="${key}" '
    BEGIN { in_frontmatter = 0; capture = 0; value = "" }
    NR == 1 && $0 == "---" { in_frontmatter = 1; next }
    in_frontmatter && $0 == "---" { exit }
    in_frontmatter && capture && /^[A-Za-z0-9_-]+:/ { exit }
    in_frontmatter && capture {
      line = $0
      sub(/^[[:space:]]+/, "", line)
      if (line != "") {
        if (value != "") value = value " "
        value = value line
      }
      next
    }
    in_frontmatter && $0 ~ "^" key ":" {
      line = $0
      sub("^" key ":[[:space:]]*>?[[:space:]]*", "", line)
      if (line != "") {
        value = line
        print value
        exit
      }
      capture = 1
    }
    END {
      if (capture && value != "") print value
    }
  ' "${file}" | head -1
}

generate_skill_index() {
  echo "## AIOS Skill Source"
  echo
  echo "Source-of-truth: \`.aios-cli/skills\`."
  echo "When a task matches a skill description, read that skill's \`SKILL.md\` before implementing."
  echo "Do not edit generated CLI instructions directly; update \`.aios-cli\` sources and regenerate."
  echo
  echo "### Available Project Skills"
  echo

  # v8.0: app szerint csoportositott, tomor index a skill katalogusbol (SkillPass.ID menufa)
  local catalog_script="${SCRIPT_DIR}/build-skill-catalog.py"
  if [[ -f "${SKILLS_DIR}/catalog.manifest.json" && -f "${catalog_script}" ]] &&
     python3 "${catalog_script}" --check >/dev/null 2>&1; then
    echo "Teljes menünézet: \`.aios-cli/skills/CATALOG.md\`."
    echo
    python3 "${catalog_script}" --index
    return
  fi

  local found=0
  while IFS= read -r -d '' skill_file; do
    found=1
    local name
    local description
    name="$(extract_frontmatter_value "${skill_file}" "name")"
    description="$(extract_frontmatter_value "${skill_file}" "description")"
    if [[ -z "${name}" ]]; then
      name="$(basename "$(dirname "${skill_file}")")"
    fi
    if [[ -z "${description}" ]]; then
      description="No description in SKILL.md."
    fi
    echo "- \`${name}\` — ${description}"
  done < <(find "${SKILLS_DIR}" -mindepth 2 -maxdepth 2 -name SKILL.md -print0 | sort -z)

  if [[ "${found}" == "0" ]]; then
    echo "- No project skills found."
  fi
}

# A routing tabla a policy TOML-bol frissul (egyetlen igazsagforras).
refresh_routing_policy_doc() {
  local doc="${CORE_DIR}/routing-policy.md"
  local aios="${ROOT_DIR}/scripts/aios"
  [[ -x "${aios}" && -f "${doc}" ]] || return 0
  grep -q "AIOS:POLICY-TABLE:BEGIN" "${doc}" || return 0
  local table="${TMP_DIR}/policy-table.md"
  "${aios}" policy-doc > "${table}" || { echo "  FIGYELEM: policy-doc hiba, routing-policy.md valtozatlan" >&2; return 0; }
  local out="${TMP_DIR}/routing-policy.md"
  awk -v table_file="${table}" '
    /AIOS:POLICY-TABLE:BEGIN/ { print; while ((getline line < table_file) > 0) print line; skip = 1; next }
    /AIOS:POLICY-TABLE:END/ { skip = 0 }
    !skip { print }
  ' "${doc}" > "${out}"
  if ! cmp -s "${out}" "${doc}"; then
    if [[ "${DRY_RUN}" == "1" ]]; then
      echo "  DRY-RUN: would refresh .aios-cli/core/routing-policy.md"
    else
      cp "${out}" "${doc}"
      echo "  Frissitve: .aios-cli/core/routing-policy.md (policy tabla)"
    fi
  fi
}
refresh_routing_policy_doc

SKILL_INDEX_FILE="${TMP_DIR}/skill-index.md"
generate_skill_index > "${SKILL_INDEX_FILE}"

fill_template() {
  local template_file="$1"
  local active_cli="$2"

  if [[ ! -f "${template_file}" ]]; then
    echo "[HIBA: sablon nem található: ${template_file}]" >&2
    return 1
  fi

  sed \
    -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
    -e "s|{{ACTIVE_CLI}}|${active_cli}|g" \
    "${template_file}" | \
  awk \
    -v instructions_file="${CORE_DIR}/instructions.md" \
    -v conventions_file="${CORE_DIR}/conventions.md" \
    -v routing_file="${CORE_DIR}/routing-policy.md" \
    -v ecosystem_file="${CORE_DIR}/ecosystem.md" \
    -v lessons_file="${CORE_DIR}/lessons.md" \
    -v skill_index_file="${SKILL_INDEX_FILE}" '
    function print_file(path,    line) {
      while ((getline line < path) > 0) print line
      close(path)
    }
    /\{\{CORE_INSTRUCTIONS\}\}/ { print_file(instructions_file); next }
    /\{\{CORE_CONVENTIONS_SUMMARY\}\}/ { print_file(conventions_file); next }
    /\{\{CORE_ROUTING_POLICY\}\}/ { print_file(routing_file); next }
    /\{\{CORE_ECOSYSTEM\}\}/ { print_file(ecosystem_file); next }
    /\{\{CORE_LESSONS\}\}/ { print_file(lessons_file); next }
    /\{\{SKILL_INDEX\}\}/ { print_file(skill_index_file); next }
    { print }
  '
}

write_generated_file() {
  local path="$1"
  local content_file="$2"

  if [[ "${DRY_RUN}" == "1" ]]; then
    echo "  DRY-RUN: would write ${path}"
    return
  fi

  cp "${content_file}" "${path}"
  echo "  Kész: ${path}"
}

ensure_skill_link() {
  local link_path="$1"
  local target_path="$2"
  local description="$3"

  if [[ -L "${link_path}" ]]; then
    local current_target
    current_target="$(readlink "${link_path}")"
    if [[ "${current_target}" == "${target_path}" ]]; then
      echo "  OK: ${description} already linked"
      return
    fi
    if [[ "${DRY_RUN}" == "1" ]]; then
      echo "  DRY-RUN: would update ${description} symlink"
      return
    fi
    rm "${link_path}"
    ln -s "${target_path}" "${link_path}"
    echo "  Updated: ${description} symlink"
    return
  fi

  if [[ -e "${link_path}" ]]; then
    echo "  Kept: ${description} exists; using generated skill index fallback"
    return
  fi

  if [[ "${DRY_RUN}" == "1" ]]; then
    echo "  DRY-RUN: would create ${description} symlink -> ${target_path}"
    return
  fi

  mkdir -p "$(dirname "${link_path}")"
  ln -s "${target_path}" "${link_path}"
  echo "  Linked: ${description} -> ${target_path}"
}

# A .claude/skills alatti valodi masolatokat a .aios-cli/skills forrasra tukrozi,
# a hianyzo skilleket symlinkkel potolja.
sync_claude_skills() {
  local claude_skills="${ROOT_DIR}/.claude/skills"
  [[ -d "${claude_skills}" && ! -L "${claude_skills}" ]] || return 0

  local src name dest
  for src in "${SKILLS_DIR}"/*/; do
    name="$(basename "${src}")"
    dest="${claude_skills}/${name}"
    if [[ -L "${dest}" ]]; then
      continue
    elif [[ -d "${dest}" ]]; then
      if ! diff -rq "${src}" "${dest}" >/dev/null 2>&1; then
        if [[ "${DRY_RUN}" == "1" ]]; then
          echo "  DRY-RUN: would mirror .claude/skills/${name}"
        else
          rsync -a --delete "${src}" "${dest}/"
          echo "  Mirrored: .claude/skills/${name}"
        fi
      fi
    else
      ensure_skill_link "${dest}" "../../.aios-cli/skills/${name}" ".claude/skills/${name}"
    fi
  done
}

# A megszunt utvonalakra mutato, mar celpont nelkuli symlinkeket eltavolitja.
# Valodi fajlt/mappat NEM torol: azt a sync.sh --apply-removals kezeli megerositessel.
prune_retired_links() {
  local list="${AIOS_CLI_DIR}/removed-paths.txt"
  [[ -f "${list}" ]] || return 0

  local rel path
  while IFS= read -r rel; do
    [[ -z "${rel}" || "${rel}" == \#* ]] && continue
    path="${ROOT_DIR}/${rel}"
    if [[ -L "${path}" && ! -e "${path}" ]]; then
      if [[ "${DRY_RUN}" == "1" ]]; then
        echo "  DRY-RUN: would remove dangling link ${rel}"
      else
        rm "${path}"
        echo "  Removed dangling link: ${rel}"
      fi
    elif [[ -e "${path}" ]]; then
      echo "  FIGYELEM: megszunt utvonal meg letezik: ${rel} (sync.sh --apply-removals)"
    fi
  done < "${list}"
}

setup_skill_links() {
  echo "Skill linkek ellenőrzése ..."
  ensure_skill_link "${ROOT_DIR}/.codex/skills" "../.aios-cli/skills" ".codex/skills"
  ensure_skill_link "${ROOT_DIR}/.gemini/skills" "../.aios-cli/skills" ".gemini/skills"
  sync_claude_skills
  prune_retired_links
}

read -r -d '' RTK_REFERENCE << 'RTK_EOF' || true

## RTK — Token Optimization (v7.2)

This project uses RTK (https://rtk-ai.app, Apache 2.0) for automatic command output
compression. 60-90% token savings on common dev commands.

### How it works
- A PreToolUse hook (Claude/Gemini) or AGENTS.md instructions (Codex) automatically
  rewrites Bash commands to rtk equivalents.
- Example: `git status` → `rtk git status` (transparent, the AI never sees the rewrite).
- 100+ commands supported: git, gh, cargo, pytest, npm, docker, kubectl, aws stb.

### Best practices
- Prefer Bash tool over native Read/Grep/Glob when possible (RTK only intercepts Bash).
- Use `cat`/`head`/`tail` (auto-rewritten to `rtk read`).
- Use `rg`/`grep` (auto-rewritten to `rtk grep`).
- Use `find` (auto-rewritten to `rtk find`).

### Verify
```bash
rtk gain
rtk session
rtk discover
```

### Avoid RTK for
- Critical financial/legal data verification
- Cryptographic verification
- NAV számítások

### Setup
```bash
.aios-cli/scripts/install-rtk.sh
```
RTK_EOF

generate_one() {
  local cli="$1"
  local template="$2"
  local output="$3"
  local temp_output="${TMP_DIR}/${output}"

  echo "Generálás: ${output} ..."
  fill_template "${template}" "${cli}" > "${temp_output}"
  echo "${RTK_REFERENCE}" >> "${temp_output}"
  write_generated_file "${ROOT_DIR}/${output}" "${temp_output}"
}

generate_claude() {
  if [[ -f "${ROOT_DIR}/CLAUDE.md" ]] &&
     ! grep -q "automatikusan generált" "${ROOT_DIR}/CLAUDE.md" &&
     [[ "${AIOS_OVERWRITE_CLAUDE:-0}" != "1" ]]; then
    echo "  Kihagyva: kézzel karbantartott CLAUDE.md megtartva."
    return
  fi
  generate_one "claude" "${ADAPTERS_DIR}/claude/CLAUDE.md.template" "CLAUDE.md"
}

generate_codex() {
  generate_one "codex" "${ADAPTERS_DIR}/codex/AGENTS.md.template" "AGENTS.md"
}

generate_gemini() {
  generate_one "gemini" "${ADAPTERS_DIR}/gemini/GEMINI.md.template" "GEMINI.md"
}

echo "AIOS CLI Config Generator"
echo "Root: ${ROOT_DIR}"
echo "Target: ${TARGET}"
if [[ "${DRY_RUN}" == "1" ]]; then
  echo "Mode: dry-run"
fi
echo

case "${TARGET}" in
  claude)
    generate_claude
    ;;
  codex)
    generate_codex
    ;;
  gemini)
    generate_gemini
    ;;
  all)
    generate_claude
    generate_codex
    generate_gemini
    ;;
  *)
    echo "Ismeretlen target: ${TARGET}" >&2
    echo "Érvényes értékek: claude, codex, gemini, all" >&2
    exit 1
    ;;
esac

setup_skill_links

echo
echo "Generálás kész."

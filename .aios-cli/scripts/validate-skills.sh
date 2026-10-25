#!/usr/bin/env bash
# Validate AIOS project skills and generated multi-CLI skill exposure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AIOS_CLI_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROOT_DIR="$(cd "${AIOS_CLI_DIR}/.." && pwd)"
SKILLS_DIR="${AIOS_CLI_DIR}/skills"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

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

[[ -d "${SKILLS_DIR}" ]] || fail "Missing skills dir: ${SKILLS_DIR}"

skill_count=0
while IFS= read -r -d '' skill_file; do
  skill_count=$((skill_count + 1))
  first_line="$(head -1 "${skill_file}")"
  [[ "${first_line}" == "---" ]] || fail "Missing YAML frontmatter: ${skill_file}"

  name="$(extract_frontmatter_value "${skill_file}" "name")"
  description="$(extract_frontmatter_value "${skill_file}" "description")"
  [[ -n "${name}" ]] || fail "Missing name in ${skill_file}"
  [[ -n "${description}" ]] || fail "Missing description in ${skill_file}"
done < <(find "${SKILLS_DIR}" -mindepth 2 -maxdepth 2 -name SKILL.md -print0)

[[ "${skill_count}" -gt 0 ]] || fail "No skills found under ${SKILLS_DIR}"

if [[ -d "${ROOT_DIR}/.claude/skills" && ! -L "${ROOT_DIR}/.claude/skills" ]]; then
  claude_count="$(find "${ROOT_DIR}/.claude/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
  [[ "${skill_count}" -ge "${claude_count}" ]] || fail ".aios-cli/skills has fewer skills than .claude/skills"
fi

# Okoszisztema alap skillek (plan-v15): skillpass.id = IdP + portal, aibos.space = admin
for core_skill in skillpass-auth skillpass-portal skillpass-app-launcher aibos-admin-contract local-models aios-orchestrator; do
  [[ -f "${SKILLS_DIR}/${core_skill}/SKILL.md" ]] || fail "Missing ecosystem skill: ${core_skill}"
done
grep -q -- "--sp-" "${SKILLS_DIR}/skillpass-portal/references/design-tokens.md" || fail "skillpass-portal tokens reference missing --sp- tokens"
grep -q "AppManifest" "${SKILLS_DIR}/skillpass-portal/references/shell-contract.md" || fail "skillpass-portal shell contract missing AppManifest"

# Megszunt skillek nem tamaszthatok fel
while IFS= read -r rel; do
  [[ -z "${rel}" || "${rel}" == \#* ]] && continue
  [[ -e "${ROOT_DIR}/${rel}" ]] && fail "Retired path still exists: ${rel}"
done < "${AIOS_CLI_DIR}/removed-paths.txt"

for config_file in CLAUDE.md AGENTS.md GEMINI.md; do
  if [[ -f "${ROOT_DIR}/${config_file}" ]]; then
    # a skill index csak a generalt konfigokban kotelezo; kezzel karbantartott CLAUDE.md-nel figyelmeztetes
    if grep -q "automatikusan generált" "${ROOT_DIR}/${config_file}"; then
      grep -q ".aios-cli/skills" "${ROOT_DIR}/${config_file}" || fail "${config_file} missing .aios-cli/skills reference"
      grep -q "skillpass-auth" "${ROOT_DIR}/${config_file}" || fail "${config_file} missing skillpass-auth skill index entry"
    else
      grep -q "skillpass-auth" "${ROOT_DIR}/${config_file}" || echo "WARN: ${config_file} kezzel karbantartott, nincs benne a skill index (skillpass-auth)" >&2
    fi
  fi
done

python3 "${SCRIPT_DIR}/build-skill-catalog.py" --check >/dev/null || fail "Skill catalog invalid (build-skill-catalog.py --check)"

echo "AIOS skills OK: ${skill_count} skills validated"


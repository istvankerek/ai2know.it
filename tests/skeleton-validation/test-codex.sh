#!/usr/bin/env bash
# Codex project layer validation (v7.6)
set -uo pipefail

E=0
check() { [[ ! -e "$1" ]] && echo "  ❌ Hianyzik: $1" && E=$((E+1)); }

check "AGENTS.md"
check ".codex/config.toml"
check ".codex/agents/explorer-fast.toml"
check ".codex/agents/worker-standard.toml"
check ".codex/agents/reviewer-deep.toml"

if [[ -f AGENTS.md ]]; then
  grep -q "Plan-v Workflow" AGENTS.md || { echo "  ❌ AGENTS.md: Plan-v Workflow hianyzik"; E=$((E+1)); }
  grep -q "specification/plan-vN" AGENTS.md || { echo "  ❌ AGENTS.md: plan-vN workflow hianyzik"; E=$((E+1)); }
  grep -q "gpt-5.3-codex" AGENTS.md || { echo "  ❌ AGENTS.md: Codex routing hianyzik"; E=$((E+1)); }
fi

if [[ -f .codex/config.toml ]]; then
  python3 - <<'PY' || E=$((E+1))
import pathlib
import sys

try:
    import tomllib
except ModuleNotFoundError:
    tomllib = None

def fallback_load(text):
    root = {}
    current = root
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("[") and line.endswith("]"):
            current = root
            for part in line[1:-1].split("."):
                current = current.setdefault(part, {})
            continue
        if "=" not in line:
            continue
        key, value = [part.strip() for part in line.split("=", 1)]
        value = value.split("#", 1)[0].strip()
        if value.startswith('"') and value.endswith('"'):
            parsed = value[1:-1]
        elif value.isdigit():
            parsed = int(value)
        else:
            parsed = value
        current[key] = parsed
    return root

def load_toml(path):
    text = path.read_text()
    if tomllib is not None:
        return tomllib.loads(text)
    return fallback_load(text)

paths = [
    pathlib.Path(".codex/config.toml"),
    pathlib.Path(".codex/agents/explorer-fast.toml"),
    pathlib.Path(".codex/agents/worker-standard.toml"),
    pathlib.Path(".codex/agents/reviewer-deep.toml"),
]

for path in paths:
    load_toml(path)

config = load_toml(paths[0])
profiles = config.get("profiles", {})
agents = config.get("agents", {})

assert config.get("model") == "gpt-5.3-codex", "default model"
assert config.get("model_reasoning_effort") == "medium", "default effort"
assert profiles.get("fast", {}).get("model") == "gpt-5.3-codex-spark", "fast profile"
assert profiles.get("deep", {}).get("model") == "gpt-5.5", "deep profile"
assert agents.get("max_threads") == 4, "agent thread cap"

explorer = load_toml(paths[1])
worker = load_toml(paths[2])
reviewer = load_toml(paths[3])

assert explorer.get("model") == "gpt-5.3-codex-spark", "explorer model"
assert explorer.get("sandbox_mode") == "read-only", "explorer sandbox"
assert worker.get("model") == "gpt-5.3-codex", "worker model"
assert worker.get("sandbox_mode") == "workspace-write", "worker sandbox"
assert reviewer.get("model") in {"gpt-5.4", "gpt-5.5"}, "reviewer model"
assert reviewer.get("sandbox_mode") == "read-only", "reviewer sandbox"
PY
fi

[[ $E -eq 0 ]]

#!/bin/bash
# .claude/hooks/intelligent-router.sh — v8.0
# UserPromptSubmit hook: a felhasznaloi prompt-bol kategorizalja a feladatot
# es javasol model + effort + advisor max_uses ertekeket.
#
# v8.0: elsodleges forras az AIOS orchestrator (.aios-cli/orchestrator, routing-policy.toml):
#   tier + CLI/modell lanc + adatosztaly. Ha a python/aios nem elerheto, a regi
#   kulcsszavas heurisztika fut (lent), hogy a hook soha ne torjon.
#
# Kimenet: stderr-re (a hook nem blokkol, csak figyelmeztet/javasol)

set -e

# UserPromptSubmit hook input: JSON stdin-en
# { "prompt": "...", "session_id": "...", ... }
INPUT=$(cat)

# Routing kikapcsolva → no-op
if [ "${AI_ROUTING_ENABLED:-true}" != "true" ]; then
    exit 0
fi

# Auto-detect kikapcsolva → no-op
if [ "${AI_ROUTING_AUTO_DETECT:-true}" != "true" ]; then
    exit 0
fi

# Prompt szoveg kinyerese (jq nelkul is mukodjon → grep alapu)
PROMPT=$(echo "$INPUT" | grep -oE '"prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"prompt"[[:space:]]*:[[:space:]]*"//;s/"$//' || echo "")

if [ -z "$PROMPT" ]; then
    exit 0
fi

# Lower-case osszehasonlitashoz
PROMPT_LC=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# --- Elsodleges: AIOS orchestrator ---
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_DIR="${HOOK_DIR}/../../.aios-cli/orchestrator"
if command -v python3 >/dev/null 2>&1 && [ -d "$ORCH_DIR/aios" ]; then
    if AIOS_SUMMARY=$(PYTHONPATH="$ORCH_DIR" python3 -m aios route "$PROMPT" --json 2>/dev/null | python3 -c '
import json, sys
d = json.load(sys.stdin)
first = d["chain"][0] if d["chain"] else {}
nxt = " -> ".join(s["provider"] + ":" + s["variant"] for s in d["chain"][1:3])
print("TIER=" + d["tier"])
print("DATA=" + d["data_class"])
print("FIRST=" + first.get("provider", "-") + ":" + first.get("variant", "-") + " (" + first.get("model", "-") + ", " + first.get("effort", "-") + ")")
print("NEXT=" + (nxt or "-"))
print("CONFIRM=" + ("igen" if d["requires_confirm"] else "nem"))
' 2>/dev/null); then
        while IFS='=' read -r key value; do
            case "$key" in
                TIER) TIER="$value" ;; DATA) DATA="$value" ;; FIRST) FIRST="$value" ;;
                NEXT) NEXT="$value" ;; CONFIRM) CONFIRM="$value" ;;
            esac
        done <<< "$AIOS_SUMMARY"
        >&2 echo "──────────────────────────────────────────"
        >&2 echo "🧭 AIOS Routing: ${TIER}  (adat: ${DATA})"
        >&2 echo "  Elsodleges: ${FIRST}"
        >&2 echo "  Fallback:   ${NEXT}"
        [ "$CONFIRM" = "igen" ] && >&2 echo "  Kritikus:   plan + explicit jovahagyas kell (aios run --confirm)"
        >&2 echo "  Reszletek:  scripts/aios route \"...\""
        >&2 echo "──────────────────────────────────────────"
        exit 0
    fi
fi

# --- Tartalek: regi kulcsszavas heurisztika ---
# --- Kategorizalo szabaly-szettek ---

# CRITICAL kulcsszavak (architektura, biztonsag, prod, migracio, breaking, irreversible)
CRITICAL_PATTERNS="architektúra|architecture|security audit|biztonsági audit|prod migracio|prod migration|breaking change|drop table|truncate|delete from|prod deploy|élesítés|production deploy|incident response|adr|design doc|threat model"

# COMPLEX kulcsszavak (feature, refactor, design, api endpoint)
COMPLEX_PATTERNS="új feature|new feature|refactor|refaktor|implementáld|implement|tervezd meg|design|api endpoint|új modul|new module|integr|migráci"

# BATCH kulcsszavak (eval, batch, riport, scheduled, worker)
BATCH_PATTERNS="eval suite|batch|riport|report|scheduled|worker|cron|nightly|daily|weekly|autodream|backup verify"

# MECHANICAL kulcsszavak (formatazas, lookup, atnevezes, list)
MECHANICAL_PATTERNS="format|atnevez|rename|listázd|listazd|list|grep|keresd|search for|fajl listaja|file list|prettier|eslint fix"

# Kategorizalas (priority sorrend: CRITICAL > BATCH > COMPLEX > MECHANICAL > STANDARD)
CATEGORY="STANDARD"

if echo "$PROMPT_LC" | grep -qE "$CRITICAL_PATTERNS"; then
    CATEGORY="CRITICAL"
elif echo "$PROMPT_LC" | grep -qE "$BATCH_PATTERNS"; then
    CATEGORY="BATCH"
elif echo "$PROMPT_LC" | grep -qE "$COMPLEX_PATTERNS"; then
    CATEGORY="COMPLEX"
elif echo "$PROMPT_LC" | grep -qE "$MECHANICAL_PATTERNS"; then
    CATEGORY="MECHANICAL"
fi

# --- Javasolt setting kiolvasasa env-bol ---
case "$CATEGORY" in
    CRITICAL)
        MODEL="${AI_MODEL_CRITICAL:-claude-opus-5-5}"
        EFFORT="${AI_EFFORT_CRITICAL:-max}"
        ADVISOR_MAX="${AI_ADVISOR_MAX_USES_CRITICAL:-0}"
        BUDGET="${AI_TASK_BUDGET_CRITICAL:-64000}"
        EMOJI="🔴"
        EXTRA_NOTE="L1 jovahagyas javasolt. Keszits Plan-t (Shift+Tab 2x) mielott vegrehajtanal."
        ;;
    COMPLEX)
        MODEL="${AI_MODEL_COMPLEX_EXEC:-claude-sonnet-5-5}"
        ADVISOR="${AI_MODEL_COMPLEX_ADVISOR:-claude-opus-5-5}"
        EFFORT="${AI_EFFORT_COMPLEX:-xhigh}"
        ADVISOR_MAX="${AI_ADVISOR_MAX_USES_COMPLEX:-3}"
        BUDGET="${AI_TASK_BUDGET_COMPLEX:-32000}"
        EMOJI="🟡"
        EXTRA_NOTE="Sonnet exec + Opus 5.5 advisor (max ${ADVISOR_MAX}x). /plan ajánlott."
        ;;
    BATCH)
        MODEL="${AI_MODEL_BATCH_EXEC:-claude-sonnet-5-5}"
        ADVISOR="${AI_MODEL_BATCH_ADVISOR:-claude-opus-5-5}"
        EFFORT="${AI_EFFORT_BATCH:-high}"
        ADVISOR_MAX="${AI_ADVISOR_MAX_USES_BATCH:-3}"
        BUDGET="${AI_TASK_BUDGET_BATCH:-32000}"
        EMOJI="🔵"
        EXTRA_NOTE="Non-realtime → Batch API (-50%). Sonnet exec + Opus 5.5 advisor."
        ;;
    MECHANICAL)
        MODEL="${AI_MODEL_MECHANICAL:-claude-haiku-4-5-20251001}"
        EFFORT="${AI_EFFORT_MECHANICAL:-low}"
        ADVISOR_MAX="${AI_ADVISOR_MAX_USES_MECHANICAL:-0}"
        BUDGET="${AI_TASK_BUDGET_MECHANICAL:-4000}"
        EMOJI="⚪"
        EXTRA_NOTE="Haiku 4.5, advisor nelkul. /model haiku javasolt."
        ;;
    STANDARD)
        MODEL="${AI_MODEL_STANDARD:-claude-sonnet-5-5}"
        ADVISOR="${AI_MODEL_COMPLEX_ADVISOR:-claude-opus-5-5}"
        EFFORT="${AI_EFFORT_STANDARD:-high}"
        ADVISOR_MAX="${AI_ADVISOR_MAX_USES_STANDARD:-1}"
        BUDGET="${AI_TASK_BUDGET_STANDARD:-16000}"
        EMOJI="🟢"
        EXTRA_NOTE="Sonnet exec + Opus 5.5 advisor (max ${ADVISOR_MAX}x)."
        ;;
esac

# --- Hint a stderr-re (override engedve) ---
if [ "${AI_ROUTING_ALLOW_OVERRIDE:-true}" = "true" ]; then
    OVERRIDE_HINT=" (override: /effort, /model)"
else
    OVERRIDE_HINT=""
fi

>&2 echo "──────────────────────────────────────────"
>&2 echo "${EMOJI} Intelligens Routing: ${CATEGORY}"
>&2 echo "  Model:    ${MODEL}"
[ -n "${ADVISOR:-}" ] && >&2 echo "  Advisor:  ${ADVISOR} (max ${ADVISOR_MAX}x)"
>&2 echo "  Effort:   ${EFFORT}"
>&2 echo "  Budget:   ${BUDGET} tokens${OVERRIDE_HINT}"
>&2 echo "  Note:     ${EXTRA_NOTE}"
>&2 echo "──────────────────────────────────────────"

exit 0

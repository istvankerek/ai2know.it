#!/bin/bash
# .claude/hooks/check-brand.sh — v6.1
# PostToolUse hook (Edit|Write): user-facing fajlok modositasa utan
# gyors anti-style scan a `.claude/identity/anti-style.md` 1-10 kategoria alapjan.
# Talalat → warning a stderr-re (NEM blokkol).

set -e

# Hook input: JSON stdin (a tool result)
INPUT=$(cat)

# Modositott fajl path kinyeres (grep alapu, jq nelkul is mukodjon)
FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')

# Ha nem fajl-modositasi tool → no-op
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Csak user-facing fajlok: md, html, jsx, tsx, mjml, txt
case "$FILE_PATH" in
    *.md|*.html|*.jsx|*.tsx|*.mjml|*.txt) ;;
    *.email.html|*.email.mjml) ;;
    *) exit 0 ;;
esac

# Belso fajlok kihagyasa (nem user-facing)
case "$FILE_PATH" in
    */node_modules/*|*/.git/*|*/dist/*|*/build/*|*/.claude/*|*/specification/*|*/tasks/*|*/COORDINATION.md|*/CLAUDE.md|*/CHANGELOG.md|*/README.md) exit 0 ;;
esac

if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

WARNINGS=0
WARNING_LIST=""

add_warning() {
    WARNINGS=$((WARNINGS + 1))
    WARNING_LIST="${WARNING_LIST}\n  ${1}"
}

# 1. Em-dash (—) tilalom
if grep -qE "—" "$FILE_PATH"; then
    LINE=$(grep -nE "—" "$FILE_PATH" | head -1 | cut -d: -f1)
    add_warning "(${LINE}) Em-dash (—) talalat – cserejjuk pontra vagy kettospontra (anti-style #1)"
fi

# 2. AI-elarulkodo frazisok
AI_PATTERNS="Let's dive|Here's the thing|Here's the kicker|It's not just .* — it's|cannot stress this enough|fast-paced world|digital landscape|future of .* is here|game-changer|paradigm shift|unlock the power of|At the end of the day|It's important to note"
if grep -qiE "$AI_PATTERNS" "$FILE_PATH"; then
    HIT=$(grep -inE "$AI_PATTERNS" "$FILE_PATH" | head -1)
    add_warning "AI-frazis: ${HIT} (anti-style #2)"
fi

# 3. Ures szuperlatívuszok (csak ha kontextus nelkul)
SUPERLATIVES="\binnovativ\b|\bforradalmi\b|\butt[oő]r[oő]\b|\bbest-in-class\b|\bworld-class\b|\bnext-generation\b|\bcutting-edge\b|\brendk[ií]v[uü]li\b"
if grep -qiE "$SUPERLATIVES" "$FILE_PATH"; then
    HIT=$(grep -inE "$SUPERLATIVES" "$FILE_PATH" | head -1)
    add_warning "Ures szuperlatívusz: ${HIT} – cserejjuk konkret szamra/tenyre (anti-style #3)"
fi

# 5. Marketing-szleng
SLANG="\brobust\b|\bscalable\b|\bseamless\b|\bend-to-end platform\b|\benterprise-ready\b"
if grep -qiE "$SLANG" "$FILE_PATH"; then
    HIT=$(grep -inE "$SLANG" "$FILE_PATH" | head -1)
    add_warning "Marketing-szleng: ${HIT} (anti-style #5)"
fi

# 6. Ures igeret
PROMISES="\b100% biztonsag\b|\bgaranta(lt|lva|ltan)\b|\bbarmilyen meretre\b|\bzero downtime\b|\bmindent megoldunk\b"
if grep -qiE "$PROMISES" "$FILE_PATH"; then
    HIT=$(grep -inE "$PROMISES" "$FILE_PATH" | head -1)
    add_warning "Ures igeret: ${HIT} – konkret SLA/fettelt megfogalmazni (anti-style #6)"
fi

# 7. Ures CTA
EMPTY_CTA="\bClick here\b|\bLearn more\b|\bGet started today\b|\bDon't miss out\b|\bLimited time offer\b"
if grep -qiE "$EMPTY_CTA" "$FILE_PATH"; then
    HIT=$(grep -inE "$EMPTY_CTA" "$FILE_PATH" | head -1)
    add_warning "Ures CTA: ${HIT} – konkret action + becsles ido (anti-style #7)"
fi

# 11. Brand-tores: megszunt IdP (everpass.id / everpass.me) hasznalat (plan-v15 D-V15-02)
if grep -qiE "everpass\.(id|me)" "$FILE_PATH"; then
    LINE=$(grep -niE "everpass\.(id|me)" "$FILE_PATH" | head -1 | cut -d: -f1)
    add_warning "(${LINE}) BRAND-TORES: megszunt IdP → 'skillpass.id' (egyetlen IdP)"
fi

# Output (csak ha van warning)
if [ "$WARNINGS" -gt 0 ]; then
    >&2 echo "──────────────────────────────────────────"
    >&2 echo "🎨 Brand check: ${FILE_PATH}"
    >&2 echo "  ⚠️ ${WARNINGS} anti-style talalat:"
    >&2 echo -e "${WARNING_LIST}"
    >&2 echo ""
    >&2 echo "  Reszletek: .claude/identity/anti-style.md"
    >&2 echo "  Auto-fix: /project:brand-check (auto-fix opcioval)"
    >&2 echo "──────────────────────────────────────────"
fi

exit 0

---
name: token-report-generator
description: >
  Heti / havi token + koltseg riport generalas a `ccusage` lokal adatokbol.
  Per-projekt + per-modell breakdown, cache hit ratio, budget envelope osszevetes.
  Top 3 optimalizacios javaslat.
  Triggerek: "weekly token summary", "cost breakdown", "token report", /project:token-report.
license: Everengine v7.5
priority: P2
model: claude-haiku-4-5-20251001
allowed-tools: Bash, Read
disable-model-invocation: false
---

# Token Report Generator

## Cel
Generalja a heti/havi token-koltseg riportot a `ccusage` adatokbol, projekt-szintu
breakdown-nal, cache hit ratio-val es budget-envelope osszevetessel.

## Lepesek

1. **Ccusage adat lekereses (7 nap):**
   ```bash
   npx ccusage@latest monthly --instances --json \
     --since $(date -v -7d +%Y%m%d) 2>/dev/null > /tmp/ccusage-7d.json
   ```

2. **Parse + aggregacio:**
   - Per-projekt input/output token totals
   - Per-modell (Haiku/Sonnet/Opus) breakdown
   - Cache read vs cache create token-arany
   - $ koltseg modellenkent (pricing: 2.2.3. szekcio)

3. **Budget envelope osszevetes:**
   ```bash
   [ -f .claude/everengine/budget.yaml ] && cat .claude/everengine/budget.yaml
   ```
   - Workspace-szintu envelope vs tenyleges spend
   - Tier-szintu (Master/Worker/External/Local) bontas (ha aios-cost crate elerheto)

4. **Cache hit ratio per projekt:**
   ```
   cache_hit_ratio = cache_read / (cache_read + cache_creation + input)
   ```
   - **>= 0.5:** ✅ healthy
   - **0.3 - 0.5:** 🟡 javithato (1h cache breakpoint hianyozhat)
   - **< 0.3:** 🔴 prompt cache underutilized (Drift::PromptCacheUnderutilized)

5. **Output tabla:**
   ```
   | Projekt    | Input | Cache hits | Output | $ Sonnet | $ Opus | $ Cached | Status |
   |------------|-------|------------|--------|----------|--------|----------|--------|
   | aios       | 2.1M  | 65%        | 320K   | $6.30    | $1.20  | $0.85    | ✅     |
   | aibos      | 850K  | 28%        | 180K   | $2.55    | $0.00  | $0.42    | 🔴     |
   | ingatlanok | 540K  | 42%        | 95K    | $1.62    | $0.00  | $0.31    | 🟡     |
   ```

6. **Top 3 optimalizacios javaslat:**
   - "aibos: enable 1h prompt cache on 18K-token system prompt (savings: $8/het)"
   - "skillpass: switch test-runner subagent Haiku-ra (Opus → Haiku, savings: $12/het)"
   - "aios: enable batch on document analysis workflow (50% off, savings: $20/het)"

## Output formatum

Markdown tabla + recommendations. Mentes opcio:
```bash
node_modules/.bin/ccusage monthly --instances --json > docs/cost-reports/$(date +%Y-W%V).json
```

## Output cap

- Max 50 sor output (ne legyen 200K-token output dump)
- Csak az envelope-on tul levo projekteket jelolj 🔴-pal

## Anti-pattern (NE)

- ❌ Cache token-eket "free"-nek tekinteni (a write 1.25-2× input cost!)
- ❌ Output mintha-Sonnet-pricing-on szamolni Opus call-nal
- ❌ Heti cap-et keverni a havi-val (egyertelmu time-window)

## Hivatkozott

- Forras: v7.5 patch / 3.4
- Sister skill: `cost-invariant-check`
- Rule: `.claude/rules/00-token-discipline.md`
- Command: `/project:token-report` (`.claude/commands/token-report.md`)
- Tool: `ccusage` (https://github.com/ryoppippi/ccusage)
- Pricing: 2026 majusi hivatalos (Opus 4.7: $5/$25, Sonnet 4.6: $3/$15, Haiku 4.5: $1/$5)

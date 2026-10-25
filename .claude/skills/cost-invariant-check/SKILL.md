---
name: cost-invariant-check
description: >
  LLM-calling crate audit: minden API-hivasi pontnak (Anthropic / OpenAI / Bedrock)
  van CostTracker + BudgetTier wiring-je? Static analysis, NEM auto-fix.
  Tabla output: crate | tracker_present | tier_consumed | findings.
  Triggerek: "cost audit", "cost invariant", "audit cost crates",
  "verify cost wiring", /project:cost-audit, /project:budget-check.
license: Everengine v7.5
priority: P1
model: claude-haiku-4-5-20251001
allowed-tools: Read, Grep, Glob
disable-model-invocation: false
---

# Cost Invariant Check

## Cel
Verify-eli, hogy minden LLM-calling crate / module rendelkezik `CostTracker`
wiring-gel, es a `BudgetTier` enum **nincs megkerülve** (bypass).

> **Generic version** — a skeleton-szintu verzio NEM aios-specific.
> AIOS-projektben kibovitendo `BudgetTier::External` + `Local` tier-rel.

## Lepesek

1. **Glob:** keresd meg az LLM client utalasokat:
   ```bash
   # Rust
   crates/**/*.rs   |   grep -E "Anthropic|OpenAI|Bedrock"
   # TypeScript
   apps/**/*.ts     |   grep -E "@anthropic-ai/sdk|openai"
   # Python
   src/**/*.py      |   grep -E "anthropic|openai"
   ```

2. **Per-file ellenorzes:** minden talalathoz:
   - **Van `CostTracker::record(...)` a hivas mellett?** (Rust)
   - **Van `recordCost(...)` / `track(...)` callback?** (TS/Python)
   - **Van `BudgetTier` consumed?** (vagy bypass-elve: `BudgetTier::Master.bypass()`)

3. **Output tabla:**

   ```
   | Crate / Module              | API client | tracker_present | tier_consumed | findings |
   |-----------------------------|-----------|-----------------|---------------|----------|
   | crates/aios-ai-router/src   | Anthropic | ✅              | ✅            | OK       |
   | crates/aios-embedder/src    | OpenAI    | ❌              | ❌            | MISSING  |
   | apps/admin/src/ai-chat.ts   | Anthropic | ✅              | ⚠️            | bypass() |
   ```

4. **Findings interpretacio:**
   - **OK** ✅ — minden invariáns teljesul
   - **MISSING** 🔴 — tracker hianyzik (kritikus, blokkold a merge-t)
   - **bypass()** 🟡 — explicit bypass, dokumentaland mi miert
   - **MOCK** ℹ️ — test-only kod, kihagy

5. **Remediation patch javaslat** minden MISSING-re:
   ```rust
   // BEFORE
   let resp = client.messages().create(req).await?;

   // AFTER (suggested patch)
   let resp = client.messages().create(req).await?;
   tracker.record(CostEvent {
       tier: BudgetTier::Worker,
       tokens_input: resp.usage.input_tokens,
       tokens_output: resp.usage.output_tokens,
       model: "claude-sonnet-4-6",
       cache_read: resp.usage.cache_read_input_tokens.unwrap_or(0),
       cache_create: resp.usage.cache_creation_input_tokens.unwrap_or(0),
   })?;
   ```

## Anti-pattern (NE)

- ❌ Auto-fix: a skill **NEM modositja** a kodot. Csak javaslatot ad, az ember dont.
- ❌ Mock-okat erinteni (test-only). A `findings = MOCK` jelolessel kihagy.
- ❌ Cross-tier bypass-t engedni (`BudgetTier::Master` → `BudgetTier::Worker` event-tel).
- ❌ Audit nelkul MERGE engedelyezni `crates/*-cost/` modositasokra.

## Output cap

- Max **80 sor** output. Tabla **+ legfeljebb 5** remediation patch (top priority).
- Tovabbiakra: futtasd ujra `--full` flag-gel (jovobeli kibovites).

## Hivatkozott

- Forras: v7.5 patch / Deliverable 1 / 5.2, Deliverable 2 / 3.7
- Sister skill: `security-audit`, `budget-tier-validation` (AIOS-specifikus)
- Rule: `.claude/rules/00-token-discipline.md`
- AIOS-specific: `crates/aios-cost/src/budget_tier.rs` (Rust) — `BudgetTier::{Master, Worker, External, Local}`
- Command: `/project:cost-audit`

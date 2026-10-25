---
name: ai-agent-reliability
description: >
  AI agent reliability playbook: RETRY (exponential backoff), TIMEOUTS,
  FALLBACK PATHS (Claude→Codex→Gemini), CIRCUIT BREAKERS. Backend engineering
  best practice AI agentekre alkalmazva. Megelozi a cascading failure-t, hanging
  request-et, silent retry-t, infinite retry-t.
  Triggerek: "uj AI integration", "AI fallback", "agent timeout",
  "circuit breaker", "API retry", "cascading failure", "AI reliability".
license: Everengine v7.1
priority: P1
model: claude-sonnet-4-6
advisor:
  model: claude-opus-4-7
  max_uses: 2
---

# AI Agent Reliability Playbook

## A 4 reliability piller

> **Backend engineers tudjak ezt a playbook-ot. Agent builders tanuljak meg the hard way.**
> — Maryam Miradi

### 1. RETRY with exponential backoff

```rust
// apps/backend/src/utils/ai/retry.rs (illusztracio, nem skeleton scope)

use std::time::Duration;
use tokio::time::sleep;

pub struct RetryConfig {
    pub max_attempts: u32,
    pub initial_delay: Duration,
    pub max_delay: Duration,
    pub multiplier: f32,
}

impl Default for RetryConfig {
    fn default() -> Self {
        Self {
            max_attempts: 3,
            initial_delay: Duration::from_millis(500),
            max_delay: Duration::from_secs(30),
            multiplier: 2.0,
        }
    }
}

pub async fn retry_ai_call<T, E, F, Fut>(
    config: RetryConfig,
    operation: F,
) -> Result<T, E>
where
    F: Fn() -> Fut,
    Fut: std::future::Future<Output = Result<T, E>>,
    E: std::fmt::Debug,
{
    let mut delay = config.initial_delay;
    for attempt in 1..=config.max_attempts {
        match operation().await {
            Ok(result) => return Ok(result),
            Err(e) if attempt == config.max_attempts => {
                tracing::error!(?e, attempt, "AI call failed after all retries");
                return Err(e);
            },
            Err(e) => {
                tracing::warn!(?e, attempt, ?delay, "AI call failed, retrying");
                sleep(delay).await;
                delay = std::cmp::min(
                    Duration::from_millis((delay.as_millis() as f32 * config.multiplier) as u64),
                    config.max_delay,
                );
            }
        }
    }
    unreachable!()
}
```

### 2. TIMEOUTS (no hanging)

Minden AI hivasnak EXPLICIT timeout kell:

```rust
pub const TIMEOUT_OPUS_4_7: Duration = Duration::from_secs(120);    // Deep reasoning
pub const TIMEOUT_SONNET_4_6: Duration = Duration::from_secs(60);   // Standard
pub const TIMEOUT_HAIKU_4_5: Duration = Duration::from_secs(15);    // Mechanical
pub const TIMEOUT_VOYAGE_EMBED: Duration = Duration::from_secs(10); // Embedding
```

### 3. FALLBACK PATHS

Multi-CLI architektura (v6.4) termeszetes fallback-et ad. Production fallback chain:

```
Claude Sonnet 4.6 → Codex GPT-5.4 → Gemini 3 Pro
```

Memory observation auto-save fallback trigger eseten (`type='trade-off'`).

### 4. CIRCUIT BREAKER

Closed → Open → HalfOpen state machine. Ha egy AI service folyamatosan fail-el,
fogd vissza ahelyett hogy minden kerest ra engedj.

## Use case matrix

| AI hivas tipus | Retry | Timeout | Fallback | Circuit Breaker |
|----------------|-------|---------|----------|-----------------|
| AI Chat user-facing | ✅ 3 retry | 60s | Claude→Codex | ✅ |
| Background autodream | ✅ 5 retry | 600s | Sonnet→Opus 4.6 | ⚠️ Soft |
| Embedding (Voyage) | ✅ 3 retry | 10s | Voyage→OpenAI ada | ✅ |
| Routine scheduled | ❌ Nincs | 300s | Skip if fails | ⚠️ Soft |
| Webhook sync (PR review) | ✅ 2 retry | 90s | Skip if fails | ❌ Nincs |
| Vector search (Qdrant) | ✅ 3 retry | 5s | Local cache | ✅ |

## 6 anti-pattern (Maryam Miradi figyelmeztetesei)

❌ **Cascading failure** — egyik service down → minden lanc-szintenn down
   ✅ Bulkhead pattern: izolalt thread pool-ok per AI provider

❌ **Hanging request** — timeout nelkul egy AI hivas orokre var
   ✅ Mindig EXPLICIT timeout, modell-specifikus

❌ **Silent retry** — retry-ok logolas nelkul, nehez debugolni
   ✅ Minden retry log-olva (warn level) + memory observation

❌ **Infinite retry** — exponential backoff nelkul DDoS-szel a provider-t
   ✅ Max 3-5 attempt + backoff + jitter

❌ **No fallback** — Anthropic API down → Everengine down
   ✅ Multi-CLI fallback chain (Codex Spark, Gemini)

❌ **Open circuit forever** — ha kinyitottuk, sose teszteljuk ujra
   ✅ Half-open state utan retry test

## Hungarian-specific reliability (illusztracio)

```
1. NAV szamlazas API (BillingClient):
   - Retry: 3x exponential backoff
   - Timeout: 30s per call
   - Fallback: queue locally + retry later (NEM masik provider!)
   - Circuit breaker: 10 failure → 5 perc open

2. Bird SMS magyar telefonszamra:
   - Retry: 2x linear backoff (SMS provider draga rosszul retry)
   - Timeout: 10s per call
   - Fallback: Telnyx alternativa
   - Circuit breaker: 5 failure → 1 perc open

3. SimplePay OTP fizetes:
   - Retry: 0 (SOHA NEM retry payment! → duplicate charge)
   - Timeout: 30s per call
   - Fallback: nincs (user manual retry)
   - Circuit breaker: 3 failure → 10 perc open + admin alert
```

## Output minden reliability incidentnel

```
1. Logolas: tracing::warn!/error! strukturalt
2. Sentry: ha unhandled exception
3. Memory observation: type='trade-off' vagy 'gotcha'
4. Slack alert: ha critical (circuit breaker open / payment fail)
5. Grafana metric: ai_reliability_circuit_breaker_state{provider, state}
```

## Hivatkozott

- v7.1 patch Section 5 (Maryam Miradi: "7 Skills AI Agent Engineer")
- Sister skill: `multi-vendor-consensus` (Claude/Codex/Gemini fallback)
- Sister skill: `cli-router` (per-feladat best provider)
- Sister skill: `monitoring-setup` (Grafana metrikak)

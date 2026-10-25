---
name: context-auditor
description: >
  Context Economy audit. Jelezi ha a kontextus tele megy zajjal, ha /compact
  / /clear szukseges, vagy ha tool output-ot erdemesebb lenne Context Mode-ba
  rakni. Figyelmeztet a budget allocation kilogasokra.
  Triggerek: automatikus (hooks), /project:context-check manualis,
  "lassu a Claude", "draga a session", "sok token"
  NE hasznald: uj session start (baseline), egyszeru query
priority: P2
model: claude-haiku-4-5-20251001
---

# Context Auditor

## Fo funkciok

### 1. Budget violation detection

Minden 10. turn-ben ellenorzi a target budget-et:

```
Target budget allocation (200K kontextusra):
- System (CLAUDE.md + skill headers):     ~5%
- Session context (korabbi uzenetek):     ~15%
- Working memory (tool output, kod):      ~40%
- User messages + reasoning:              ~30%
- Buffer (hallucinacio megelozes):        ~10%
```

Ha valamelyik kategoria > target * 1.5:
- System > 10%? → "CLAUDE.md tul nagy lett, split"
- Session > 25%? → "/compact ajanlott"
- Working > 60%? → "Tool output tul nagy, Context Mode ajanlott"

### 2. Signal/noise ratio analysis

Utolso 20 uzenet scan:
- Ha > 30% duplicate info → "/clear ajanlott"
- Ha > 20% decorative fluff → "Skill description review"

### 3. Pre-flight check (proaktiv)

Mielott nagy feladatba kezdenenk:
- Projekt becsult token merete
- Jelenlegi kontextus
- Javaslat: kell-e /compact vagy uj session

## Output format

```
🔍 Context Audit (/project:context-check)

Current: 45% used (90K / 200K)
  System:       12% (20K) ⚠️ Tul sok (target: 5%)
  Session:      18% (36K) ✅
  Working:      10% (20K) ✅
  User+reasoning: 5% (10K) ✅

Signal/noise: 85% signal (jo)
Recommendations:
  ✅ Continue
  ⚠️ CLAUDE.md review (12% vs 5% target) - split skill-ekbe
```

## Red flags (auto-detection)

- 🚩 Teljes kodbazis olvasas (helyette: code-review-graph)
- 🚩 Teljes log olvasas (helyette: Context Mode)
- 🚩 Hosszu copy-paste chat-be (helyette: fajlba)
- 🚩 Regi uzenetek ujraolvasasa (helyette: /compact 50%-nal)
- 🚩 Parhuzamos temak 1 session-ben (helyette: /clear)

---
name: parallel-reviewer-orchestrator
description: Parhuzamos kod review orchestracio – ket fuggetlen subagent (SPEC + QUALITY) friss kontextusban, decision matrix SHIP × SHIP = ✅ MERGE. v6.2 pattern. Triggerek: /project:review, "review a kodot", "PR review", "merge ready?".
license: Everengine v6.2
priority: P1
model: claude-sonnet-4-6
advisor: claude-opus-4-7
advisor_max_uses: 1
---

# Parallel Reviewer Orchestrator

## Filozofia
Egy reviewer egy szempontot lat. Ket parhuzamos reviewer **fuggetlen friss kontextusban**
megduplazza a vakfolt-fedezetet. Nem konszenzus → kritikus eltérés azonnal lathato.

## Pattern (v6.2)

```
                ┌──────────────────────────────────┐
                │ Parent (Lead) – orchestracio     │
                └──────────────┬───────────────────┘
                               │ spawn parallel
              ┌────────────────┴────────────────┐
              ▼                                  ▼
  ┌──────────────────────┐          ┌──────────────────────┐
  │ Reviewer A: SPEC     │          │ Reviewer B: QUALITY  │
  │ (Sonnet 4.6)         │          │ (Sonnet 4.6 + Opus   │
  │                      │          │   4.7 advisor)       │
  └──────────────────────┘          └──────────────────────┘
              │                                  │
              ▼                                  ▼
         SHIP / FIX                          SHIP / FIX
              └────────────────┬─────────────────┘
                               ▼
                  Decision matrix → MERGE / FIX
```

## Reviewer A: SPEC COMPLIANCE

**Friss kontextus, csak ezeket olvassa:**
- `tasks/todo.md` (a feladat acceptance criteria)
- `git diff main...HEAD` (mit valtoztattal)
- `CLAUDE.md` Aranyszabalyok

**Kerdesek:**
1. Megfelel-e az acceptance criteria-nak? (item-by-item check)
2. Minden elem implementalva? (nincs "TODO holnap")
3. Scope creep-ek? (volt-e olyan modositas amit a feladat nem ker)
4. Aranyszabaly-szegcs? (5. = TDD Iron Law: van-e teszt?)

**Output:** SHIP | FIX (es konkret hianylista)

## Reviewer B: CODE QUALITY (7 szempont)

**Friss kontextus, csak a kodot es a teszteket olvassa.**

1. **Security:** secret, SQL injection, XSS, authz bypass, CORS
2. **Performance:** N+1, O(n²), blocking I/O, missing index
3. **Correctness:** null deref, race condition, missing await, error swallow
4. **Everengine konvenciok:** feature-based fajlnev, Zod validacio, magyar JSDoc, RFC 7807 hibak
5. **Teszt lefedettseg:** coverage javult? Edge case-ek vannak?
6. **Maintainability:** nev-pontossag, cohesion, function meret < 50 sor
7. **Breaking change:** semver, migration plan, backwards compat

**Output:** SHIP | FIX (kategoria + konkret hibalista)

## Decision Matrix

|             | A: SHIP | A: FIX |
|-------------|---------|--------|
| **B: SHIP** | ✅ MERGE | 🟡 FIX (csak A jelez) |
| **B: FIX**  | 🟡 FIX (csak B jelez) | 🔴 BLOCK |

- **MERGE:** mindketten SHIP → folytasd commit-ot
- **FIX (egyik):** lehet hogy false positive, de javitsd ki **vagy** explicit override-old indoklassal
- **BLOCK:** ket fuggetlen reviewer talalt erdemi gondot → STOP, nem mehet ki

## Anti-patterns

❌ **Egy reviewer with both prompts** – elveszti a fuggetlen kontextust, vakfolt nem szunik
❌ **Sequential review** (A utan B) – B latta A megalapotait, anchoring bias
❌ **Same model, same temperature** – minimum: B advisor-t kap (Opus 4.7), A-nak nincs
❌ **Az "esszencia" osszefoglalo** – mindketto kell, ne mergeljuk a riportokat ami elvesz a "konszenzus"-ban

## Hasznalat

```
/project:review
  → Parent: spawn 2 subagent (Task tool)
    → A: SPEC review (fresh context)
    → B: QUALITY review (fresh context)
  → Parent: collect outputs, decision matrix → MERGE / FIX / BLOCK
```

## Ide nem hasznalatos

- Egysoros / format / rename (overhead nagyobb mint nyereseg)
- Hot fix prod incident kozben (egy fast review eleg, kesobb retro)
- Spike / proof-of-concept (nem merge cel)

## Hivatkozott
- Command: `.claude/commands/review.md` (parallel pattern integralva v6.2-ben)
- Sister skill: `code-review` (single-reviewer fallback ha 1 reviewer eleg)
- Sister skill: `agent-teams-coordinator` (ha 3+ reviewer kell QA Team)
- Forras: v7.0 master PART 2 Section 29

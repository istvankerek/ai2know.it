# Agents Index

> Az `.claude/agents/` mappaban **2 axis** mentén kategorizált agentek.
> A kettő **kombinálható** — pl. "Sonnet code-reviewer-ként" = sonnet-worker model + code-reviewer role-prompt.

## Axis 1: Model-based (model selection)

Mit valaszol: **"Milyen modell csinalja?"**

| Agent | Model | Mikor |
|-------|-------|-------|
| [haiku-subagent](haiku-subagent.md)   | Haiku 4.5  | Mechanikus feladatok (lint, format, lookup) |
| [sonnet-worker](sonnet-worker.md)     | Sonnet 4.6 | Alapertelmezett dev (feature, bug fix, refactor) |
| [opus-architect](opus-architect.md)   | Opus 4.7   | Architektura, security audit (L1 APPROVE!) |
| [auto-iterate](auto-iterate.md)       | Sonnet 4.6 | Ralph loop iteracio (test/lint amig zold) |
| [worktree-agent](worktree-agent.md)   | Sonnet 4.6 | Izolalt git worktree fejlesztes |

## Axis 2: Role-based (domain specialist) — v7.4

Mit valaszol: **"Milyen szakertokent csinalja?"**

| Agent | Specialty | Triggerek |
|-------|-----------|-----------|
| [code-reviewer](code-reviewer.md)         | Biztonsag/perf/maintain review | PR review, /project:review |
| [test-writer](test-writer.md)             | Unit/integration/e2e tesztek | uj endpoint, /project:test |
| [security-auditor](security-auditor.md)   | OWASP/dependency/secret audit | /project:security-scan |
| [doc-writer](doc-writer.md)               | Magyar dokumentacio | /project:docs, ADR, README |
| [rust-specialist](rust-specialist.md)     | Rust/Axum/sqlx/Tokio | Rust fajlok, backend endpoint |

## Hogyan kombinald

```
Pelda 1: kis bug fix Haiku-val
  → haiku-subagent (model) + nincs role-prompt

Pelda 2: feature implementaciot review-z biztonsagi szempontbol
  → sonnet-worker (model) + code-reviewer + security-auditor (role-promptok)

Pelda 3: architektura terv Rust microservice-hez
  → opus-architect (model, L1 APPROVE!) + rust-specialist (role-prompt)

Pelda 4: magyar runbook iras
  → haiku-subagent (model, koltseg-hatekony) + doc-writer (role-prompt)
```

## Mikor MELYIK axis-t valaszd

| Helyzet | Axis | Pelda |
|---------|------|-------|
| Nem tudod ki kellene csinalja, csak tudod hogy olcson | Model | haiku-subagent |
| Tudod milyen szakertelem kell, modell mindegy | Role | code-reviewer |
| Tudod mindkettot | Model + Role kombo | sonnet-worker + test-writer |
| Drága dontes előtt allsz | Model (opus-architect, L1 APPROVE) | + opcionalisan role |

## Forras

- **Model-based:** v6.0 + v7.0 master (intelligent routing)
- **Role-based:** v7.4 patch Section 5
- **Forks pattern:** [FORKS.md](FORKS.md) (Phase C-ben jon)

---
name: ask-user-question-orchestrator
description: >
  AskUserQuestion tool intelligens hasznalata. Komplex feladatok elott
  strukturalt kerdeseket general, kattinthato urlapot, hogy a felhasznalo
  ne hagyhasson ki fontos reszleteket. 3 patternt biztosit (feature spec,
  bug fix, brainstorm). Max 7 kerdes egy urlapon (tool fatigue rule).
  Triggerek: "/project:plan", "/project:brainstorm", "kerdezd ki",
  "tisztazzuk", "uj feature", "uj modul", "feature spec".
license: Everengine v7.1
priority: P2
model: claude-haiku-4-5-20251001
---

# AskUserQuestion Orchestrator

## Mikor erdemes az AskUserQuestion tool-t hivni

| Scenario | AUQ tool? |
|----------|-----------|
| Uj feature spec | ✅ IGEN |
| Uj modul scaffold | ✅ IGEN |
| Brainstorm session inditas | ✅ IGEN |
| Architektura dontes | ✅ IGEN |
| Sales / pitch deck specs | ✅ IGEN |
| Bug fix konkret reprodukcioval | ❌ NE (mar van info) |
| Code review (van diff) | ❌ NE |
| Quick CRUD endpoint (mintabol) | ❌ NE |
| Format / lint / rename | ❌ NE |
| Ad-hoc beszelgetes | ❌ NE |

## Question patterns

### Pattern A: Feature spec (max 7 kerdes)
```
1. Feature neve [text]
2. Acceptance criteria (3 mondat) [textarea]
3. Priority [Low / Medium / High / Critical select]
4. Complexity estimate [Simple <1h / Medium 1-4h / Complex 4h+ / Architecture]
5. Affected modules [multi-select from src/modules/]
6. Deadline [date picker]
7. Magyar UI strings needed [Yes / No]
```

### Pattern B: Bug fix (max 5 kerdes)
```
1. Bug rovid leiras [text]
2. Reprodukcios lepesek [textarea]
3. Vart vs aktualis viselkedes [textarea]
4. Severity [Low / Medium / High / Critical]
5. User impact (erintett felhasznalok) [number]
```

### Pattern C: Brainstorm (max 5 kerdes)
```
1. Problema 1 mondatban [text]
2. Audience [Developer / Decision-maker / End-user / Mixed]
3. Tone [Formal & analytical / Conversational direct / Creative exploratory]
4. Output format [Free text / Bullet list / Decision matrix / Pro-con table]
5. Time constraint [Quick / Standard / Deep]
```

## Tiltasok

❌ Tobb mint 7 kerdes egy urlapon (tool fatigue)
❌ Free-text kerdes ahol select eleg lenne
❌ Yes/No kerdes ami egyertelmu kontextusbol
❌ Olyan info amit a CLAUDE.md vagy tasks/todo.md mar tartalmaz
❌ Sensitive info (jelszo, API kulcs) AUQ-n keresztul

## Workflow integracio

- `/project:plan` 0. lepes: Pattern A (Feature spec)
- `/project:brainstorm` 0. lepes: Pattern C (Brainstorm)
- `/project:debug` (ha van) vagy bug fix kontextusban: Pattern B (Bug fix)

## Hivatkozott

- v7.1 patch Section 2 (Ruben Hassid: "Use AskUserQuestion tool")
- Sister command: `/project:plan`, `/project:brainstorm`
- Sister skill: `prompt-quality-boost` (Tier C/D → S/SS auto-fogalmazas)

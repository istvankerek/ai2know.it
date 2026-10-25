---
description: Brainstorming skill aktivalasa – /project:plan ELOTT
---

# Brainstorming

## 0. Initial AskUserQuestion (v7.1)

**Az iteracio elott hivd meg az `AskUserQuestion` tool-t** strukturalt kerdesekkel:

```
AskUserQuestion mezok (5 kerdes):
  • Problema 1 mondatban: [text]
  • Tone preferencia: [Formal & analytical / Conversational direct / Creative exploratory]
  • Audience: [Developer / Decision-maker / End-user / Mixed]
  • Output format: [Free text / Bullet list / Decision matrix / Pro-con table]
  • Time constraint: [Quick (5 min) / Standard (15 min) / Deep (30+ min)]
```

Az AUQ valaszai informaljak a Tier S/SS prompt construction-t (1-5 fazis). Skill: `ask-user-question-orchestrator`.

Aktivalja a `brainstorming` skill-t a kovetkezo otleten/problemen.

## A skill iterativ kerdes-valasz formaban dolgozik (5 fazis)

1. **Cel tisztazas** (Tier SS) – Mi a TENYLEGES problema?
2. **Vakfoltok** (Tier A) – Mit nem latsz? Hol bukik el?
3. **3 alternativa** (Tier S) – Pro/kontra mindegyikhez, ajanlott valasztas
4. **Refinement** – Iterativ finomitas
5. **Atteres /project:plan-re** – Ha tisztabb lett, /plan-be megy

## Mikor hasznalt

✅ "Gondolkodom valamin", "lehet-e", "mi lenne ha"
✅ Uj feature otlet ami meg nem konkret
✅ Architektura kerdes
✅ Tool valasztas (X vs Y vs Z)

## Mikor NE

❌ Mar van konkret terv (akkor /project:plan)
❌ Bug fix konkret hibara
❌ Egyszeru CRUD endpoint

## Workflow

```
/project:brainstorm  →  iteralunk  →  /project:plan  →  vegrehajtas
```

⏸️ Szanj idot. Tier SS minoseg. Ne ugorj at lepest.

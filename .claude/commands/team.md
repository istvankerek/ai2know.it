---
description: Agent Teams inditas – terv + team konfiguracio
---

# Agent Teams Tervezes

⚠️ MINDIG tervezz MIELOTT teammate-eket spawn-olsz!
⚠️ Opus 4.7 alapbol NEM spawn-ol subagent-eket – EXPLICIT kell kerni!

## 1. Feladat elemzes
- Mi a cel?
- Hany fajl erintett?
- Kell-e vita/challenge (→ Agent Teams) vagy eleg az egyiranyu delegalas (→ Subagent)?

## 2. Pattern valasztas (ha Agent Teams kell)
1. **Full-Stack Team** – feature fejlesztes (Lead → Frontend → Backend → Testing → Reviewer)
2. **Debug Debate Team** – komplex bug (3 hipotezis vitazik, anchoring bias elkerulese)
3. **QA Team** – release audit (Security + Perf + UX parhuzamosan)
4. **Writing Team** – dokumentacio (Gatherer → Writer → Editor)

Reszletek: `.claude/rules/agent-teams.md`

## 3. Context-based split (NE role-based!)
- NINCS atfedes (ugyanazt a fajlt ne szerkessze 2 teammate)
- Max 3 teammate (NE 8!) – tokenek linearisan skalazodnak
- Minden teammate kontextusa ~30-40% (NE 80%+)

## 4. Model routing per teammate
- Lead: Sonnet + Opus advisor
- Fejleszto: Sonnet + Opus advisor VAGY Haiku + Opus advisor
- Reviewer: Sonnet (advisor nelkul – olcso, nem dont)

## 5. EXPLICIT spawn utasitas (Opus 4.7!)
NE: "osszd fel a feladatokat"
IGEN: "Spawn 3 teammates in parallel for independent execution."
IGEN: "Use Agent Teams pattern: Full-Stack / Debug Debate / QA / Writing."
IGEN: "Teammate A: frontend, Teammate B: backend, Teammate C: tests"

⏸️ Vard meg a jovahagyasomat mielott spawn-olnal.

Szanj idot a tervezesre. 5 perc tervezes > 10 perc ujraepites.

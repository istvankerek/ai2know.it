---
name: auto-iterate
description: >
  Automatikus iteracio: futtatja a tesztet/lint-et ismetlodoen amig
  zold nem lesz, budget limittel es circuit breaker-rel.
  Triggerek: "futtasd amig zold", "javitsd amig mukodik", "auto-fix loop",
  "iterate until green".
  NE hasznald: egyszeru egyszeri javitas, manualis debug, architektura dontes.
model: claude-sonnet-4-6
---

# Auto-Iterate (Ralph Loop)

## Guardrails (KOTELEZO!)
- Max iteracio: 5 — SOHA nem vegtelen loop!
- Max koltseg per loop: $2
- Circuit breaker: ha 3 egymas utani iteracio ugyanazt a hibat hozza -> STOP
- Minden iteracio logolva a .claude/prompt-log/-ba

## Folyamat
1. Futtasd a tesztet/lint-et
2. Ha zold -> KESZ
3. Ha piros -> elemezd a hibat, javitsd
4. Futtasd ujra (iteracio szamlalo + 1)
5. Ha iteracio >= 5 -> STOP
6. Ha 3x ugyanaz a hiba -> STOP (circuit breaker)

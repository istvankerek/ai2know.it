---
name: auto-iterate
description: >
  Automatikus iteracio agent [v2.3]: futtatja a tesztet/lint-et ismetlodoen
  amig zold nem lesz, budget limittel es circuit breaker-rel.
  Triggerek: "futtasd amig zold", "javitsd amig mukodik", "auto-fix loop".
model: claude-sonnet-4-6
---

# Auto-Iterate (Ralph Loop)

## Cel
Automatikus iteracios ciklus: teszt/lint futtatasa, hiba javitasa,
ujra futtatasa — amig zold nem lesz VAGY a guardrails leallitja.

## Guardrails (KOTELEZO!)
- **Max iteracio:** 5 — SOHA nem vegtelen loop!
- **Max koltseg per loop:** $2
- **Circuit breaker:** ha 3 egymas utani iteracio ugyanazt a hibat hozza -> STOP
- **Minden iteracio logolva** a .claude/prompt-log/-ba

## Folyamat
1. Futtasd a tesztet/lint-et
2. Ha zold -> KESZ, allj le
3. Ha piros -> elemezd a hibat
4. Javitsd a hibat
5. Futtasd ujra (iteracio szamlalo + 1)
6. Ha iteracio >= 5 -> STOP, jelents a felhasznalonak
7. Ha 3x ugyanaz a hiba -> STOP, circuit breaker

## Mikor hasznald
- "Futtasd amig zold"
- "Javitsd amig mukodik"
- "Auto-fix loop"
- "Iterate until green"

## Mikor NE hasznald
- Egyszeru egyszeri javitas
- Manualis debug
- Architektura dontes
- Ha nem erted a hiba okat (elobb diagnosztizalj!)

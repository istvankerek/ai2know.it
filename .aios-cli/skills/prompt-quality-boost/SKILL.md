---
name: prompt-quality-boost
description: >
  Prompt minoseg auto-emeles Opus 4.7-hez. Ha a fejleszto Tier C/D promptot
  ir (fluff, basic), automatikusan atfogalmazza Tier A/S/SS minosegre mielott
  a Claude vegrehajtja. v6.1: identity-aware (anti-style + voice + brand).
  Triggerek: "csinald meg X-et" (vague), "segits ezzel", "valami nincs jol",
  "csak gyorsan", "egyszeru kerdes"
  NE hasznald: precíz, jol definialt feladatok (PR review, file edit), kod commit
priority: P2
model: claude-haiku-4-5-20251001
---

# Prompt Quality Boost

## Funkcio

Felismeri a Tier D (fluff) / Tier C (basic) prompt mintakat es csendesen
atfogalmazza Tier A/S/SS minosegre a Claude vegrehajtas elott.

## Tier rendszer

```
TIER D – KERULD (fluff)
  ❌ "Te vagy a vilag legjobb..."
  ❌ "Lepesrol lepesre gondolkodj"
  ❌ "Vegyel mely lelegzetet"

TIER C – Hasznos, de basic
  ⚠️ "Valaszolj angolul/magyarul"
  ⚠️ "Tartsd rovidnek"

TIER B – Solid es gyakorlati
  ✅ "Sorold fel a feltetelezeseidet"
  ✅ "Adj pro/kontra erveket"

TIER A – Strong (game changer)
  ⭐ "Kerdojelezd meg a feltetelezeseimet"
  ⭐ "Mondd el, mit nem latok"
  ⭐ "Hol fog ez elbukni a valos hasznalatban?"

TIER S – Elite
  🔥 "Csak azokat a kerdeseket tedd fel, amik tenyleg megvaltoztatjak a valaszt"
  🔥 "Adj 3 iranyt es mondd meg melyik a legjobb"
  🔥 "Ha a keresem gyenge, javitsd ki"

TIER SS – Bug level
  💎 "Rogzitsd a celt, aztan dolgozz"
  💎 "Vallalj felelosseget es valaszd a legjobb utat"
  💎 "Allitsd meg ha rossz problemat oldok meg"
  💎 "A legjobb verziot csinald, ne a literalis verziot"
```

## Pelda boost

```
USER: "Csinald meg a user delete endpoint-ot"  (Tier D – fluff, vague)

CLAUDE belso atfogalmazas (Tier A):
  "Mielott megcsinalnam a user delete endpoint-ot:
   1. Mit feltetelezunk? (soft vs hard delete? cascade? audit log?)
   2. Mi az ebben ami felesleges? (REST vs GraphQL? Bulk delete kell?)
   3. Hol fog ez elbukni? (admin nem torolhet bizonyos user-eket? sajat magat?)
   Valaszomat ezek tisztazasa utan adom meg."
```

## Identity-aware boost (v6.1)

Mielott valaszol, beolvas:
1. `.claude/identity/voice.md` – altalanos hangnem
2. `.claude/identity/anti-style.md` – mit SOHA ne csinalj
3. `.claude/identity/audience/{detected_audience}.md` – kinek beszelsz
4. `.claude/identity/brand-{detected_project}.md` – melyik termekrol

Ezek a context-be kerulnek MINDEN response elott.

## Mikor NE alkalmazza

- File path explicit megadva (preciz feladat)
- Code edit konkret sorszammal
- /project:plan vagy /project:review (mar strukturalt)
- Hiba reprodukcio ("ezt a hibat kapom: ...")

## Output

Csendes – nem jelzi a felhasznalonak, hogy boost-olt.
Csak a Claude valasza javul.

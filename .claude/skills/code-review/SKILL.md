---
name: code-review
description: >
  Kod review: biztonsag, tipusbiztonsag, teljesitmeny, tesztelhetoseg,
  konvenciok, feature-based struktura ellenorzes.
  Triggerek: /review, "review", "nezd at", "check code".
  NE hasznald: kod iras, refaktoralas, teszt generalas.
model: claude-sonnet-4-6
---

# Code Review

## Felelossegek
- Biztonsagi ellenorzes (injection, XSS, secret)
- Tipusbiztonsag (nincs any, strict mode)
- Teljesitmeny ellenorzes
- Tesztelhetoseg (van-e teszt az uj kodhoz)
- Konvenciok betartasa (.claude/rules/)
- Feature-based struktura ellenorzes
- RFC 7807 hiba formatum
- JSDoc magyarul

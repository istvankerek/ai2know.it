---
description: Ultra-alapos review – skeptikus senior engineer perspektiva (Opus 4.7)
---

ultrathink

Tedd fel magadnak minden valtoztatasnal:

## 1. "Would a staff engineer approve this?"
- Architektura illeszkedik-e a rendszer egeszhez?
- Van-e rejtett teljesitmeny problema (N+1, O(n^2))?
- Race condition, deadlock lehetoseg?

## 2. "Is there a more elegant way?"
- Overengineering? Ha igen, egyszerusitsd
- Underengineering? Ha igen, javasolj robusztusabbat
- Van-e tervezesi minta (pattern) ami illik?

## 3. "Mi romolhat el?"
- Edge case-ek: null, ures lista, max ertekek, special chars
- Error handling: minden error ag tesztelt?
- Rollback: ha ez deploy-olva hibas, hogyan megy vissza?

## 4. "Security review"
- Auth: ki ferhet hozza?
- Authz: van-e megfelelo permission check?
- Input validation: Zod hasznalt-e minden DTO-n?
- SQL: parameteres query?
- Log: nem logol-e PII-t vagy secret-et?

## 5. "Test coverage"
- Happy path ✅
- Edge cases ✅
- Error cases ✅
- Integration test (endpoint level) ✅

## Tier S/SS prompt minták (v5.5)

### Fix the goal first (Tier SS)
1. **Mi a TENYLEGES cel?** (nem amit kertek, hanem amit el akarnak erni)
2. **Rossz problemat oldok meg?** STOP, jelezz!
3. **Mi a legjobb verzioja ennek?** (nem a literalis verzio)

### Tier S kerdesek minden valtoztatasnal
🔥 Ask only the questions that change the answer:
   - Tenyleg minden mezo kell ebben a DTO-ban?
   - Tenyleg minden endpoint kell ehhez a feature-hez?

🔥 Give 3 directions, pick the winner:
   - Direkt impl vs abstract layer vs eseménykezelt
   - Pro/kontra mindegyikhez
   - Indoklas miert az adott a legjobb

🔥 If the request is weak, fix it:
   - Hianyos spec? → Adj javaslatot mit kerdezzen a fejleszto
   - Konfliktusos kovetelmeny? → Jelezd, oldd fel
   - Antipattern? → Javasolj jobb megkozelitest

## Dontes

Vegen: **SHIP** / **FIX** / **BLOCK** dontes + indoklas (Tier SS minoseg).

- 🟢 SHIP: Kesz, mehet deploy-ra
- 🟡 FIX: Kisebb javitasok szuksegesek (listazd)
- 🔴 BLOCK: Kritikus problema, NE deploy-olj amig nem javitva

Szanj idot ra. Minoseg > sebesseg. Ne hagyj ki lepeseket.

---
name: brainstorming
description: >
  Nyers otlet finomitasa eles gondolkodassa. Iterativ kerdesek, alternativak,
  vakfoltok feltarasa MIELOTT terv keszulne. A /project:plan ELOTT erdemes
  futtatni. Tier S/SS minoseg.
  Triggerek: "gondolkodom valamin", "lehet-e", "mi lenne ha", "otlet:",
  "brainstorming", "otleteles", /project:brainstorm
  NE hasznald: jol definialt feladatok, preciz spec, bug fix konkret hibara
priority: P2
model: claude-sonnet-4-7
advisor:
  model: claude-opus-4-7
  max_uses: 3
---

# Brainstorming Skill

## Folyamat (5 fazis)

### 1. Cel tisztazas (Tier SS)
- Mi a TENYLEGES problema amit megoldanal? (nem a szimptoma)
- Kinek lesz ez jo? (target user)
- Mit nez ki a siker? (merheto!)

### 2. Vakfoltok feltarasa (Tier A)
- Mi az amit nem latsz?
- Hol fog ez elbukni a valos hasznalatban?
- Milyen feltetelezeseket teszel?

### 3. Alternativak generalasa (Tier S)
- Adj 3 kulonbozo iranyt
- Pro/kontra mindegyikhez
- Melyik a legjobb es miert?

### 4. Refinement
- Iterativ finomitas kerdes-valasz formaban
- Minden iteracio: "Most mar tisztabb. De mi van X-szel?"
- Cel: a "rossz problemat megoldani" elkerulese

### 5. Output
- Egyertelmu problema definicio
- Valasztott megoldas iranya + indoklas
- Nyitott kerdesek listaja (ha vannak)
- Atteres: "Most mar ki tudunk tuzni egy /project:plan-t. Akarod?"

## Pelda interakcio

```
USER: "Gondolkodom egy jegyrendelo modulon az aiBOS-hoz"

BRAINSTORMING SKILL:
1. Tisztazas:
   - Milyen jegyek? (event, support, szamla?)
   - Cel felhasznalo: belso admin vagy vegfelhasznalo?
   - Sikermutatok: konverzio? response time?

USER: "Event ticket, vegfelhasznalonak, konverzio fontos"

BRAINSTORMING SKILL:
2. Vakfoltok:
   - Tenyleg uj modul kell? (van-e Magyar piacon dominans alternativa?)
   - Hol bukik el? (fizetes hibas, jegy duplikacio, kapacitas race condition)
   - Feltetelezes: mobil-first? (MA: 70% mobil)

3. Alternativak:
   A) Sajat modul nullarol – ⭐⭐ Teljes kontroll, sok munka
   B) White-label external (TicketSwap, Eventbrite) – ⭐⭐⭐ Gyors, kontroll-vesztes
   C) Hibrid: meglevo API + sajat UI – ⭐⭐⭐⭐ Sebesseg + kontroll
   → Javaslat: C opcio, mert {indoklas}

USER: "OK, C opcio jo"

BRAINSTORMING SKILL:
4. Tisztabb lett. Meg nyitott:
   - Mely external API? (3 jelolt: TicketSwap, EventBee, Bilettak)
   - MVP scope? (csak vasarlas, vagy refund/modositas is?)

USER: "TicketSwap, MVP csak vasarlas"

BRAINSTORMING SKILL:
5. Most mar /project:plan-be lehet menni. Inditod?
```

## Mikor SUCCESS

- A feladat scope-ja TISZTABB lett
- Vakfoltok napvilagra kerultek
- Valasztott irany indokolt
- A fejleszto keszen all a /project:plan-re

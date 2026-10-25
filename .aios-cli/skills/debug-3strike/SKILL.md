---
name: debug-3strike
description: 3 strike rule a debug munkahoz – 3 sikertelen javitasi probalkozas utan kotelezo STOP, /clear es brainstorm. Megakadalyozza a tunnel-vision flailing-et. Triggerek: "ezt a hibat kapom", "nem mukodik", "ujra hiba", "harmadszor probalom", debug munka kozben.
license: Everengine v6.2
priority: P1
model: claude-sonnet-4-6
---

# Debug 3-Strike Rule

## Filozofia
Ha 3 egymast koveto javitasi kiserlet sikertelen → STOP. A kovetkezo iteracio
a problemat _melyebbre_ asna, nem feloldana. Ez tunnel vision (anchoring bias) → reset kell.

## Strike szamlalas

`tasks/todo.md`-ben:
```markdown
## Debug: {hiba-osszefoglalo}

- [ ] Strike 1: {hipotezis} → fix → result: {miert nem mukodott}
- [ ] Strike 2: {hipotezis} → fix → result: {miert nem mukodott}
- [ ] Strike 3: STOP. /clear + /project:brainstorm + 5 Why
```

Minden strike utan FRISSITSD a tasks/todo.md-t mielott a kovetkezot probalod.
Ha a fejleszto vagy te NEM jelolod fel a strike-ot, a szamlalo nem mukodik.

## Strike 1: RTK tee recovery (v7.2)

Strike 1-ben, mielott uj javitast kezdesz, **olvasd be a teljes raw output-ot**
a tee log-bol, ha a parancs RTK-zott:

```bash
# Legutobbi tee log
LATEST=$(ls -t "$RTK_TEE_LOG_PATH/" | head -1)

# Stack trace eleje + vege
cat "$RTK_TEE_LOG_PATH/$LATEST" | head -200
cat "$RTK_TEE_LOG_PATH/$LATEST" | tail -100
```

A kompresszalt output **eleg lehet** (Strike 1 indulashoz), DE a stack trace,
hash, raw bytes, env dump csak a teljes log-ban van. Olvasd be ELOSZOR.

Bug fix utan: `./scripts/save-rtk-failure-observation.sh` — memory mentes
(jovobeli session-ok visszakeresik).

Reszletek: `rtk-tee-recovery` skill.

## Strike 3 protokol

Amikor eljutottal Strike 3-ig:

1. **STOP** – ne probald a 4. javitast
2. **Foglald ossze** mit probaltal:
   ```markdown
   ## 3 strike osszefoglalo
   - Hipotezis 1: ... → cafolat: ...
   - Hipotezis 2: ... → cafolat: ...
   - Hipotezis 3: ... → cafolat: ...

   Mit tudunk biztosan: ...
   Mit NEM tudunk: ...
   ```
3. **/clear** – torold a session kontextust (a sok hibás javitas zavar)
4. **/project:brainstorm** – uj session, friss szem
5. **5 Why analizis** a brainstorm utan:
   - Miert tortenik a hiba? → 1. valasz
   - Miert tortenik az 1. valasz? → 2. valasz
   - ... eljuts a gyokerokhoz (5. valasz)
6. **Megfontolas:** kell-e Agent Teams (Debug Debate Team pattern) – 3 hipotezis parallel

## Anti-patterns

❌ "Csak meg egy probalkozas" (4. strike) – ez a tunnel vision
❌ Strike szamlalas nelkul – a szamlalo nem mukodik ha nem jegyzed
❌ /clear nelkul atterni a 4. hipotezisre – a 3 elozo valasz mar zavar a kontextusban
❌ Brainstorm kihagyasa – a 4. hipotezis ugyanugy az 1-3 vonalaban van

## Kivetelek

- **Crash recovery:** ha a script accidentally elinditott valami torolhetot (rm -rf, drop table),
  a strike szamlalas kivisz a fokuszbol. Eloszor: revert/restore. Strike-ok utan jojjenek.
- **Time pressure:** ha valoban 30 perc van shippelni, az "ezt SOHA nem javitottam meg, de
  a workaround mukodik" elfogadhato → ADR + TODO-removal commitba.

## Pelda log

```markdown
## Debug: 500 error a /api/v1/users POST-on

- [x] Strike 1: Zod schema validacio rossz → fix CreateUserDto.ts
       Result: meg mindig 500 (de mas hibauzenet)
- [x] Strike 2: db connection timeout → pool size emelve 10→20
       Result: meg mindig 500 (timeout megsemmisul, de gyors lett az error)
- [x] Strike 3: STOP – /clear + brainstorm

→ Brainstorm utan: 5 Why kideritette hogy a JWT validacio elotti middleware loop-ol
                   (sajat magat hivja vegtelenul). Strike 4 = root cause fix.
```

## Hivatkozott
- Sister skill: `tdd-enforcer` (failing test eloszor – sokszor megelozi a 3-strike-ot)
- Sister skill: `auto-iterate` (gepi iteracio – DE: 3-strike szamlalassal!)
- Sister skill: `rtk-tee-recovery` (Strike 1: RTK tee log olvasas teljes raw output-ert)
- Script: `scripts/save-rtk-failure-observation.sh` (bug fix utan memory mentes)
- Forras: v7.0 master PART 2 Section 28 + v7.2 patch Section 7

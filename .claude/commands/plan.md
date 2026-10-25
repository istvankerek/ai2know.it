---
description: Terv keszites implementacio ELOTT – NE kodolj, csak tervezz, ird tasks/todo.md-be
---

# Tervezesi fazis

## 0. Pre-flight check (v7.1)

**Mielott elkezded a tervezest, hivd meg az `AskUserQuestion` tool-t** egy
strukturalt urlappal. Ez biztositja hogy a fontos reszletek ne maradjanak ki.

```
AskUserQuestion mezok (default 5 kerdes):
  • Feature/task neve: [text]
  • Acceptance criteria (3 mondat): [textarea]
  • Priority: [Low / Medium / High / Critical]
  • Estimated complexity: [Simple <1h / Medium 1-4h / Complex 4h+ / Architecture]
  • Affected modules (multi-select): [generated from src/modules/ list]
```

Az AUQ valaszai informaljak az alabbi 1-8 lepeseket. Skill: `ask-user-question-orchestrator`.

Mikor kihagyhato: bug fix konkret reprodukcioval, code review (van diff), quick rename / format.

## Tervezesi lepesek

1. Olvasd el: tasks/lessons.md + `.aios-cli/core/lessons.md` (okoszisztema tanulsagok L-01..L-15)
2. Routing: `scripts/aios route "<feladat>"` → tier es modell a terv fejlecebe
3. Komplex feladatnal: kovetkezo `specification/plan-vN/` mappa a `templates/plan/` sablonbol
   (D-Vn-NN owner dontesek, P-Vn-NN javaslatok, okoszisztema checklist); egyszerubbnel tasks/todo.md
4. Ird a tervet fajlba (NE csak a chatbe!)
5. Vard meg a jovahagyast (owner: "mehet")

A kovetkezo feladathoz keszits TERVET. NE irj kodot, NE modosits fajlt!

## 1. Feladat megertes
- Fogalmazd meg a sajat szavaiddal mit kell csinalni
- Az AskUserQuestion (0. lepes) valaszait foglald ide ossze
- Ha tovabb is bizonytalan vagy, KERDEZZ VISSZA mielott terveznel

## 2. Erintett fajlok
Listazd az osszes fajlt ami modosulni fog:
```
[M] src/modules/users/create-user/CreateUserEndpoint.ts  (modositas)
[+] src/modules/users/update-user/UpdateUserEndpoint.ts   (uj fajl)
[+] src/modules/users/update-user/UpdateUserDto.ts         (uj fajl)
[M] tests/unit/users/CreateUser.test.ts                    (modositas)
[+] tests/unit/users/UpdateUser.test.ts                    (uj fajl)
```

## 3. Valtoztatasok osszefoglaloja
Fajlonkent 1-2 mondatban mit fogsz csinalni es miert.

## 4. Kockazatok & Edge case-ek
- Mi romolhat el?
- Milyen edge case-eket kell kezelni?
- Van-e backward compatibility kockazat?

## 5. Fuggosegek
- Szukseges-e uj npm/cargo dependency?
- Van-e mas modul ami erintett (ripple effect)?
- Kell-e DB migracio?

## 6. Komplexitas becsles
- Egyszeru (1-3 fajl, ismert minta)
- Kozepes (4-10 fajl, nemi tervezes kell)
- Komplex (10+ fajl, architekturalis dontes)
- Kritikus (rendszer-szintu valtozas, ADR szukseges)

## 7. Szukseges tesztek
- Milyen unit/integration/e2e teszteket kell irni?
- Milyen meglevo tesztek erintettek?

## 8. Koltseg becsles
- Becsold meg melyik model kell (Haiku/Sonnet/Opus)
- Becsolt token hasznalat (alacsony/kozepes/magas)

---

ALLJ MEG ITT. Vard meg a jovahagyasomat mielott implementalnad.

Szanj idot a tervre. Minoseg a sebesseg elott. Ne hagyj ki lepeseket.

Jovahagyas utan: "Implementald a tervet."
Modositas utan: "Modositsd a tervet: [mi valtozzon]"
Elvetes: "Vedd elo mas megkozeletest: [irany]"

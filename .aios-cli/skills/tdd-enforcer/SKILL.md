---
name: tdd-enforcer
description: TDD Iron Law betartatasa – failing test ELOSZOR (new feature) vagy reproduction test ELOSZOR (bug fix). Red → Green → Refactor pipeline. Triggerek: "uj feature", "bug fix", "uj endpoint", uj fajl src/-ben, "implementald", /bootstrap.
license: Everengine v6.2
priority: P0
model: claude-sonnet-4-6
advisor: claude-opus-4-7
advisor_max_uses: 1
---

# TDD Enforcer (P0 – legfontosabb skill)

## Iron Law
> **Soha nincs production kod failing test nelkul.**
> Ha kodot irsz: failing tesztet eloszor.
> Ha bugot javitasz: reproduction tesztet eloszor (ami a fix NELKUL fail-el).

## Mikor aktivalodik
- Trigger: "uj feature", "implementald", "uj endpoint", "javitsd a bugot",
  "ezt a hibat kapom", uj fajl letrehozasa src/ alatt, /bootstrap, /db-migrate
- Auto: PostToolUse hook (`check-tdd.sh`) figyelmeztet ha src/** modosult test nelkul

## Workflow

### A) Uj feature pipeline (TDD strict)

```
1. RED – Failing test irasa
   └─ Tesztben: arrange-act-assert + magyar nev
   └─ Pelda: src/modules/users/CreateUser/CreateUserEndpoint.test.ts
   └─ Tartalmaz: happy path + 1-2 edge case
   └─ Futtass: ./scripts/test.sh
   └─ Vard: 🔴 RED – verify fail
        Ha veletlen passzol → rossz teszt, ujraird

2. GREEN – Minimum kod ami passzoltat
   └─ Pelda: src/modules/users/CreateUser/CreateUserEndpoint.ts
   └─ NE adj hozza tobbet mint amit a teszt megkovetel
   └─ Futtass: ./scripts/test.sh
   └─ Vard: 🟢 GREEN – verify pass

3. REFACTOR – Tisztitas
   └─ Duplikacio elvetel, beszedesseg javitas
   └─ De: nincs uj funkcionalitas, mind kovi piros, mind kovi zold
   └─ Futtass: ./scripts/test.sh (minden zold)

4. COMMIT
   └─ Egy logikai valtozas = egy commit
   └─ Uzenet: "test+feat: {entitas} {action} TDD ciklus"
```

### B) Bug fix pipeline (reproduction-first)

```
1. REPRODUCTION TEST eloszor
   └─ Ird meg a tesztet ami AKKOR fail-el ha a bug ott van
   └─ Futtass: ./scripts/test.sh
   └─ Vard: 🔴 RED – ha NEM fail-el → rossz teszt, ujraird
   └─ A teszt nev: "regression: {bug-leiras}" vagy "{bug-leiras}-rol-nem-fail-el"

2. FIX – Minimum kod ami megjavitja
   └─ Futtass: ./scripts/test.sh
   └─ Vard: 🟢 GREEN

3. REGRESSION CHECK – Minden mas teszt fut?
   └─ ./scripts/test.sh teljes suite
   └─ Ha mas tortes → rollback, gondolkozz, retry

4. COMMIT
   └─ Uzenet: "fix: {bug-leiras} (+ regression test)"
```

## Mikor lehet kihagyni TDD-t

| Helyzet | TDD szukseges? |
|---------|----------------|
| Uj endpoint, business logic | ✅ KOTELEZO |
| Bug fix | ✅ KOTELEZO (reproduction test) |
| Refaktor (viselkedes nem valtozik) | ⚠️ NE valtoztass tesztet, fut zoldnek |
| UI komponens (sniff test eleg) | 🤝 Smoke test elfogadhato (manual + screenshot) |
| Format/rename/comment | ❌ NEM kell teszt |
| Migration script (DDL) | ✅ Down + up teszteles |

## Anti-patterns (TILOS!)

❌ "Kesobb irom meg a tesztet" – soha nem irodik meg
❌ "Ennek nem kell teszt, egyszeru" – minden uj kodnak kell teszt vagy explicit ok
❌ Test post-hoc generalas (kod utan a teszt nem talal hibat)
❌ "Ez integraciots, nem unit" – mindketto kell, nem vagy-vagy

## Stuck eset (nem tudsz failing tesztet irni)

Ha 5 percig nem talalsz failing tesztet:
1. STOP – nem ertesz a feladatot
2. /project:plan – tervezz
3. /project:brainstorm – kerdezzed magad: "Mit kellene atadnia ennek a kodnak?"

## Hivatkozott
- Hook: `.claude/hooks/check-tdd.sh` (PostToolUse src/** warning)
- Sister skill: `debug-3strike` (3 sikertelen iteracio utan stop)
- Sister skill: `unit-test-writer` (tesztiras tamogatas)
- Forras: v7.0 master PART 2 Section 27 (Iron Law)

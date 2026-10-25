# Subagent Forks (v7.4)

> **Forrás:** v7.4 patch Section 1.4
> **Tipus:** dokumentációs pattern, NEM runtime engine
> **Kapcsolódó:** [INDEX.md](INDEX.md), `.claude/rules/agent-teams.md`

## Mi a Fork?

A **Fork** egy új subagent variant ami a **teljes beszélgetés-historiát örökli**, NEM csak a spawn promptot.

```
Subagent (alapertelmezett):
  Új context window + spawn prompt    →  izolált
  Background nem latott               →  tiszta lap

Fork:
  Teljes parent history + spawn prompt → kontextualis
  Background ismert                    → folytatja
```

## Mikor Subagent vs Fork?

| Helyzet | Választás | Indok |
|---------|-----------|-------|
| Egyszeru lookup, mas kontextus nem szukseges | Subagent | Olcsobb, izolált |
| Ki kell hasznalni a parent munkajat | Fork | Nem kell ujra magyarazni |
| Kockazatos / kiserleti | Subagent | Tiszta lap |
| Konszenzus check (ket vélemény) | Fork (mindketto) | Mindketto lat ugyanazt |
| Nagyfile elemzes parent context-bol | Fork | Idotaposas spórolas |
| Teljesen elteero domain | Subagent | Cross-pollution kockazat |
| Privacy/security sandboxing kell | Subagent | Kontext nem leak |

## Pelda flow-k

### Pelda 1: Code review subagent-tel (izolalt)

```
Parent: [olvas 5 fajlt, 30K token kontext]
  ↓ Task("review CreateUserEndpoint.rs", subagent_type="code-reviewer")
Subagent: [csak a CreateUserEndpoint.rs-t latja, friss kontext]
  ↓ kimenet: review eredmenyek
Parent: [megkapja a review eredmenyeket, 30K token-en felul]
```

### Pelda 2: Continuation fork-kal (kontextualis)

```
Parent: [debugol 3 strike-ig, 80K token kontext]
  ↓ Fork("/clear ekvivalens, de tiszta szemmel folytasd")
Fork: [parent total history, megertes alapja: mi volt a 3 strike]
  ↓ kimenet: Strike 4 hipotezis a teljes elozmeny tukreben
Parent: [megkapja a fork ajanlasat]
```

### Pelda 3: Konszenzus fork x 2 (parallel)

```
Parent: [bonyolult architektura döntés alatt]
  ↓ Fork(name="hipotezis-A", "javasolj A architekturat")
  ↓ Fork(name="hipotezis-B", "javasolj B architekturat")
Forks (parallel): mindketto a teljes parent kontextust latva fogalmazza meg
  ↓ kimenetek: A javaslat + B javaslat
Parent: [osszehasonlitja, donthet]
```

## Token economy

| Mod | Cost |
|-----|------|
| Subagent | Csak a spawn prompt + subagent munka |
| Fork | Parent total context (cache hit ha < 5 perc) + fork munka |

A Fork **dragabb** a Subagent-nel, mert a parent kontextust at kell adni. **Cserebe** nem kell ujra magyarazni.

**Kulcs:** ha a parent kontextus < 5 perc, a prompt cache miatt a Fork koltsege majdnem akkora mint a Subagent. **5 perc ele Fork-ot inditani draga.**

## Anti-patterns

❌ Fork minden feladatra (felesleges koltseg)
❌ Subagent ahova kontext kell (parent magyarazva utan-pottyentget)
❌ 5+ Fork parallel (token explosion, max 3)
❌ Fork sensitive parent kontext utan (cross-pollution kockazat)
❌ Fork olyan domain-be ami a parent-tol elteer (konfuzio)

## Hivatkozott
- Sister: [INDEX.md](INDEX.md) — agent kategoriak
- Rules: `.claude/rules/agent-teams.md`
- Forras: v7.4 patch Section 1.4

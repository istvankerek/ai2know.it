# Agent Teams Szabalyok

Forras: `specification/everengine-v3.2.2-patch-agent-teams.md`

## Subagent vs Agent Teams – Mikor melyiket?

```
SUBAGENT (Task tool):
  Parent → Subagent → Eredmeny vissza parent-nek
  Egyiranyu. A subagent NEM beszel mas subagent-ekkel.
  = Alvallalkozo akit elkuldesz egy feladatra.

AGENT TEAMS:
  Lead ↔ Teammate A ↔ Teammate B ↔ Teammate C
       ↔ Shared Task List ↔
  Peer-to-peer. A teammate-ek EGYMASSAL is beszelnek.
  = Projektcsapat egy szobaban, vitaznak, kihivjak egymast.
```

### Dontesi matrix

| Kerdes | Ha IGEN → | Ha NEM → |
|--------|-----------|----------|
| A feladatok fuggetlenek egymastol? | **Subagent** | Agent Teams |
| Kell hogy az agensek vitazzanak/challenge-eljek egymast? | **Agent Teams** | Subagent |
| Eleg ha az eredmeny visszajon a parent-nek? | **Subagent** | Agent Teams |
| Kell kozos feladatlista es koordinacio? | **Agent Teams** | Subagent |
| Token-hatekonysag a prioritas? | **Subagent** | Agent Teams |
| A feladat 50K+ kodbazison dolgozik es egy agent kontextusa 80%+ lenne? | **Agent Teams** (split) | Subagent |

**Szabaly:** Subagent = alapertelmezett. Agent Teams = CSAK ha a parhuzamos explorrace vagy vita VALODI erteket ad. 3 teammate ≈ 7x token (Anthropic adat).

---

## 4 Production Pattern

### 1. Full-Stack Team (feature fejlesztes)

```
Lead/Architect → Frontend → Backend → Testing → Reviewer
     ↓                                              ↓
     └────────── Shared Task List ──────────────────┘
```

Szekvencialis pipeline. Context-based split:
- Frontend: `apps/admin/src/`, `apps/frontend/src/`
- Backend: `apps/backend/src/modules/`
- Reviewer: SEMMIT nem szerkeszt, csak olvas

### 2. Debug Debate Team (komplex bug) ⭐

```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Hypothesis A │↔ │ Hypothesis B │↔ │ Hypothesis C │
└──────────────┘  └──────────────┘  └──────────────┘
        ↕ challenge & disprove ↕
```

Elkeruli az anchoring bias-t (nem ragad ra az elso hipotezisre). Minden teammate probalja BIZONYITANI a sajat hipotezisét; ha a masik erosebb, ismeri el. **NE hasznald** egyertelmu hibanal (stack trace egyertelmu → subagent eleg).

### 3. QA Team (release audit)

```
┌────────────┐  ┌────────────┐  ┌────────────┐
│  Security  │  │    Perf    │  │     UX     │
│Sonnet+adv  │  │  Sonnet    │  │Haiku+adv   │
└──────┬─────┘  └──────┬─────┘  └──────┬─────┘
       └───────────────┬────────────────┘
                       ▼
                  ┌────────┐
                  │ QA Lead│ (osszesitese + prioritizalas)
                  └────────┘
```

Parhuzamos ellenorzes. Focus-ok: Security → middleware/modules, Perf → modules/workers, UX → components.

### 4. Writing Team (dokumentacio)

```
Context Gatherer → Writer → Editor
```

1. **Gatherer** (Haiku): osszegyujti a relevans kodot, ADR-eket, meglevo docs-ot. NE irjon doksit.
2. **Writer** (Sonnet): megirja a dokumentaciot. Magyar, strukturalt, JSDoc stilus.
3. **Editor** (Sonnet + Opus advisor): atnezi, javitja, konzisztenciat ellenorzi.

---

## Anti-Patterns

### ⚠️ Over-spawning
❌ 8 teammate → 8x token + koordinacios overhead
✅ Max 3 teammate. Ha 4+ kell → bontsd 2 kulon team-re.

### ⚠️ Same-file edits
❌ Frontend es Backend is szerkeszti a `shared/types.ts`-t → merge conflict
✅ Context-based split – minden teammate sajat fajlkeszleten dolgozik.

### ⚠️ Role-based split HELYETT context-based split
❌ "A=tesztelo, B=fejleszto, C=reviewer" → mindegyik ugyanazokat a fajlokat nezi → duplikacio
✅ "A=users modul, B=products modul, C=orders modul" → nincs atfedes

### ⚠️ Plan kihagyasa
❌ "Spawn 3 teammates and figure it out" → token pazarlas, merge conflict
✅ `/plan` ELOSZOR → terv jovahagyasa → AZTAN spawn

### ⚠️ Agent Teams egyszeru feladatra
❌ Agent Teams egyetlen fajl modositasara → 7x token overhead 5 perces feladatra
✅ Subagent (Task tool) egyszeru feladatokra

---

## Kontextus szabaly

- Feladat < 80% kontextus → Subagent eleg
- Feladat > 80% kontextus → Agent Teams, split ~30-40%-ra teammate-enkent
- Session kozben: `/context` → ha > 80% → `/compact` VAGY Agent Teams spawn

---

## Enable konfiguracio

A `.claude/settings.json` tartalmazza:
```json
"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
```

Kovetelmeny: Claude Code v2.1.32+, Opus 4.6 a Team Lead-hez.

## Advisor + Teams egyutt

A teammate-ek is hasznalhatjak az advisor tool-t:
- Lead: Sonnet + Opus advisor
- Teammate A: Sonnet + Opus advisor
- Teammate B: Haiku + Opus advisor (olcsobb, smart fallback)
- Teammate C: Sonnet (reviewer, advisor nelkul)

Ez a legjobb cost/quality arany.

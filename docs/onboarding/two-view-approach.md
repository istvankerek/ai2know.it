# Két-view onboarding pálya

> **Verzió:** v7.3 | **Forrás:** vibinex AgentDevKit + Everengine v6.0–v6.5 evolúció
> **Cél:** új csapattag gyors belépés (1 hét) + senior fejlesztő mély értelmezés (1 hónap+)

---

## Bevezetés

Az Everengine Claude Code framework **két komplementer view-t** használ. Mindkettő ugyanarra a rendszerre vonatkozik, de **különböző kérdésre válaszol**:

| View | Forrás | Mit válaszol? | Mikor |
|------|--------|---------------|-------|
| **Strukturális 5-réteg** | vibinex AgentDevKit | "Mi van benne?" | Onboarding, blog, quick lookup |
| **Filozófiai 7-réteg** | Everengine v6.0–v6.5 | "Miért olyan?" | Architektúra, senior fejlesztő |

A v7.3 patch előtt csak a filozófiai view létezett. A strukturális view **NEM helyettesíti**, **kiegészíti** azt.

---

## Strukturális view (vibinex 5-réteg)

A `.claude/` mappa **tartalmát** strukturálja:

```
agent-dev-kit/
├── CLAUDE.md         ← Layer 1: Memory       (sets rules)
├── skills/           ← Layer 2: Knowledge    (provide expertise)
├── hooks/            ← Layer 3: Guardrail    (enforce quality)
├── agents/           ← Layer 4: Delegation   (delegate work)
└── plugins/          ← Layer 5: Distribution (distribute to team)
```

### Layer 1: CLAUDE.md – Memory

Always loaded. Always active. Az agent **constitutciója**.

- Globális: `~/.claude/CLAUDE.md` (István személyes preferenciák, ~50 sor)
- Projekt: `.claude/CLAUDE.md` (csapat konvenciók, <200 sor)
- Tartalmaz: 9 Aranyszabály, tech stack, conventions, tiltások

### Layer 2: skills/ – Knowledge

On-demand, moduláris, **description-matched auto-invoked**.

- 100+ skill (P0/P1/P2 priority)
- Auto-trigger keyword matching
- SKILL.md + scripts/ + templates/ + assets/

### Layer 3: hooks/ – Guardrail

**Determinisztikus**, NEM AI. Shell scriptek agent event-ekre.

- 19 hook script (PreToolUse, PostToolUse, SessionStart, Stop, ...)
- 5-hook memory lifecycle (v6.5)
- Exit kód 2 = blokkolás

### Layer 4: agents/ – Delegation

Saját context window. **Delegálj munkát** anélkül hogy a fő session pollutálódna.

Két axis (v7.4 patch):

- **Model-based** (haiku-subagent, sonnet-worker, opus-architect, auto-iterate, worktree-agent) — milyen modell csinálja
- **Role-based** (code-reviewer, test-writer, security-auditor, doc-writer, rust-specialist) — milyen szakértőként csinálja

A kettő **kombinálható**: pl. "Sonnet code-reviewer-ként".

### Layer 5: plugins/ – Distribution

Bundle. Ship. Install. **npm packages agent capability-khez**.

- manifest.json + skills/ + agents/ + hooks/ + commands/
- Marketplace-ről telepítés vagy lokális
- Prioritás: enterprise > user > project > plugin

### Plus: Everengine-specifikus dimenziók

A vibinex 5-rétegben **NEM szerepelnek**, de az Everengine-ben **kritikusak**:

| Mappa | Mit ad? | v6.x patch |
|-------|---------|------------|
| `.claude/identity/` | Brand & Identity (anti-style, voice, audience) | v6.1 |
| `.claude/memory/` | RAD memory architecture (SQLite observations) | v6.5 |
| `.claude/workflows/` | Multi-step YAML recipes | v6.5 |
| `.claude/routines/` | Cloud automation (scheduled, webhook, api) | v5.6 |
| `.codex/` | Codex project config + fast/worker/deep agents | v7.6 |
| `.aios-cli/` | Multi-CLI shared kernel (Claude/Codex/Gemini) | v6.4 |

---

## Filozófiai view (Everengine 7-réteg)

A rendszer **evolúcióját** magyarázza. v6.0 → v7.x ívben mindegyik réteg multiplikatív értéket ad.

| Verzió | Réteg | Mit válaszol? | Példa |
|--------|-------|---------------|-------|
| v6.0 | TECHNIKAI | Hogyan dönt? | Intelligens routing (Opus/Sonnet/Haiku) |
| v6.1 | IDENTITÁSI | Ki a rendszer? | Anti-style, voice, brand |
| v6.2 | DISCIPLINÁRIS | Hogyan dolgozik? | TDD Iron Law, 3-strike, parallel review |
| v6.3 | STRUKTURÁLIS | Hogyan szervezi magát? | Project + Personal scope |
| v6.4 | STRATÉGIAI | Vendor freedom? | Multi-CLI shared kernel |
| v6.5 | MNEMONIKUS | Hogyan tanul? | Memory v2 RAD, observations |
| v7.x | OPCIONÁLIS | Domain-specifikus? | RTK token optimization, AskUserQuestion |

A 7 réteg **NEM hierarchikus** — egymással beszélgetnek. Pl. a TECHNIKAI réteg (routing) használja a IDENTITÁSI réteget (brand-aware kommunikáció).

---

## Day 1-7 onboarding (strukturális view)

A **strukturális view gyorsabb belépést** ad. Egy hét alatt érti az új csapattag a rendszert.

### Day 1: Layer 1 (Memory)

- `CLAUDE.md` olvasás (projekt-specifikus + global)
- 9 Aranyszabály memorizálás
- First "Hello World" task (kis bug fix vagy doc módosítás)

### Day 2: Layer 2 (Knowledge)

- `.claude/skills/` áttekintés (`_catalog.csv` ha van, vagy `find .claude/skills -name SKILL.md`)
- 1-2 P0 skill kipróbálás (pl. `tdd-enforcer`, `crud-generator`)
- SKILL.md formátum értelmezés (frontmatter + description + triggers)

### Day 3: Layer 3 (Guardrail)

- `.claude/hooks/` áttekintés
- PreToolUse/PostToolUse értelmezés
- 1 hook lokálisan aktiválás (pl. `auto-lint.sh` PostToolUse-ban)
- `.claude/settings.json` hooks blokk olvasás

### Day 4: Layer 4 (Delegation)

- `.claude/agents/` áttekintés (`INDEX.md` model vs role axis)
- 1 model-based subagent kipróbálás (pl. `sonnet-worker` egy refactor-ra)
- 1 role-based subagent kipróbálás (pl. `code-reviewer` PR-en)
- Agent Team kipróbálás (`/project:team`, ha van)

### Day 5: Layer 5 (Distribution)

- `.claude/plugins/STRUCTURE.md` áttekintés
- `everengine-standards` plugin (jelenleg internal)
- `.mcp.json` 10 MCP server konfiguráció
- `AGENTS.md` + `.codex/config.toml` áttekintés Codex CLI-hez

### Day 6-7: Workflow gyakorlás

- `aibos-feature-dev.yml` workflow végigjátszás
- TDD + parallel review pipeline
- First "real" feature (kis scope)
- `/project:plan` → `/project:review` → ship

---

## Week 2-4: filozófiai view bevezetés

Az új csapattag **Day 7 után** átvált a filozófiai view-ra. Ez ad **mélységet** és **kontextust** a tervezéshez.

### Week 2: TECHNIKAI réteg (v6.0)

- Intelligens routing megértés (`.claude/hooks/intelligent-router.sh`)
- Mikor Opus / Sonnet / Haiku
- Cost tracking (`AI_TASK_BUDGET_*` env vars)
- 5 kategória (CRITICAL / COMPLEX / BATCH / STANDARD / MECHANICAL)

### Week 3: IDENTITÁSI + DISCIPLINÁRIS (v6.1 + v6.2)

- Brand & Identity 14 fájl (`.claude/identity/`)
- Anti-style dictionary (v7.1)
- TDD Iron Law (`tdd-enforcer` skill, P0)
- 3-strike rule (`debug-3strike` skill)
- Parallel review (`parallel-reviewer-orchestrator`)

### Week 4: STRATÉGIAI + MNEMONIKUS (v6.4 + v6.5)

- Multi-CLI használat (`.aios-cli/`, 3 adapter)
- `/project:cli-switch` parancs
- Codex fast-first agentek: `explorer_fast`, `worker_standard`, `reviewer_deep`
- Memory v2 RAD (`.claude/memory/observations.db`)
- Autodream konszolidáció (5 fázis, v7.1)
- Memory curator skill

---

## Hónap 2+: Senior level

A csapattag már **mindkét view-t** ismeri. Most jönnek a v7.x finomítások és saját komponens-fejlesztés.

- **v7.1:** AskUserQuestion integráció, anti-style dictionary, autodream cycle, AI agent reliability, prompt anatomy
- **v7.2:** RTK token optimization (60-90% bash savings), multi-CLI shared kernel, NAIH compliance
- **v7.3:** Strukturális view (ez a doc!)
- **v7.4:** Skeleton bootstrap, role-based agents, Plugins/Forks pattern
- **v7.6:** Codex bridge, Plan-v workflow, fast-first model routing
- **Patch-ek olvasása:** v6.x összes (`specification/skeleton-specifications/`)
- **Saját skill / workflow / hook fejlesztés**

---

## Két view egymás mellett (mátrix)

A két view-t **lefordítható egymásra**. Az alábbi mátrix mutatja a kapcsolatot:

```
STRUKTURÁLIS (mi van)     ↔    FILOZÓFIAI (miért)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Layer 1: CLAUDE.md         →    TECHNIKAI (v6.0) – Hogyan dönt
                                  Intelligens routing, model selection

Layer 2: skills/           →    DISCIPLINÁRIS (v6.2) – Hogyan dolgozik
                                  TDD, 3-strike, parallel review skills

                           →    MNEMONIKUS (v6.5) – Hogyan tanul
                                  Memory curator, autodream skills

Layer 3: hooks/            →    TECHNIKAI (v6.0) – Determinisztikus garanciák
                                  PreToolUse safety, auto-routing hookok

                           →    DISCIPLINÁRIS (v6.2) – TDD enforce
                                  check-tdd.sh, check-placeholders.sh

Layer 4: agents/           →    DISCIPLINÁRIS (v6.2) – Parallel patterns
                                  Subagent + Agent Team koordináció

                           →    STRUKTURÁLIS (v6.3) – Project + Global
                                  Scope-olt agent definíciók

Layer 5: plugins/          →    STRUKTURÁLIS (v6.3) – Csapat governance
                                  Bundle + version + install

                           →    STRATÉGIAI (v6.4) – Vendor independence
                                  Multi-CLI plugin marketplace

+ identity/                →    IDENTITÁSI (v6.1) – Brand & Voice
+ memory/                  →    MNEMONIKUS (v6.5) – RAD architecture
+ workflows/               →    DISCIPLINÁRIS (v6.2) + MNEMONIKUS (v6.5)
+ routines/                →    STRATÉGIAI (v6.4) – Cloud automation
+ .aios-cli/         →    STRATÉGIAI (v6.4) – Multi-CLI kernel
```

A 7-réteg filozófiai view **teljesebb** az Everengine kontextusában (5+3 dimenzió). A vibinex 5-réteg **gyorsabb belépés**.

---

## Mikor melyiket használd?

### Strukturális view → 3 use case

1. **Új csapattag onboarding (Day 1-7)** — gyorsabb belépés
2. **Külső kommunikáció / blog post** — standard ipari terminológia
3. **Quick reference / mental model** — "Hová tegyem ezt? → Layer 2 (Knowledge)"

### Filozófiai view → 3 use case

1. **Mély rendszer-tervezés (architektúra döntés)** — több réteget érint, mélységet ad
2. **Patch / verzió-tervezés** — szervezi a roadmap-et (v6.x → v7.x)
3. **Onboarding senior fejlesztő (Level 4-6)** — kontextust ad a tapasztalt fejlesztőnek

---

## Hivatkozott források

- **vibinex AgentDevKit** infografika sorozat ("Five layers, one stack", kép 1-6)
- **Brij Pandey** ("Each folder is a different dimension of behavior" — v6.3 forrás)
- **Everengine v7.3 patch:** [`specification/skeleton-specifications/everengine-v7.3-patch-structural-view.md`](../../specification/skeleton-specifications/everengine-v7.3-patch-structural-view.md)
- **Everengine v7.0 master PART 1 Section 3:** filozófiai 7-réteg view definíció
- **Skeleton CLAUDE.md "A 6 dimenzio":** rules/commands/skills/agents/memory/identity rétegek

---

> "Each folder is a different dimension of behavior."
> — Brij Pandey
>
> "Five layers, one stack."
> — vibinex AgentDevKit
>
> "Mindkettő igaz. Mindkettő hasznos."
> — Everengine v7.3

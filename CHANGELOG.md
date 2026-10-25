# Changelog

Minden jelentos valtozas dokumentalva van itt. Formatum: [Keep a Changelog](https://keepachangelog.com/),
verziokezeles: [SemVer](https://semver.org/).

## [8.0.0] - 2026-10-06 "Egységes ökoszisztéma + orchestráció"

Egységes ökoszisztéma a skillpass.id / aibos.space szereposztással, futtatható AIOS
orchestrator (Claude Code, Codex, Gemini, helyi modellek), és skill katalógus a
SkillPass.ID menüstruktúrájára. Terv: `specification/plan-v15/`.

### Added
- **AIOS orchestrator:** `scripts/aios` (`route`, `run`, `providers`, `budget`, `explain`,
  `policy-doc`) + `.aios-cli/orchestrator/policy/routing-policy.toml`. 8 tier, fallback lánc,
  circuit breaker, prompt nélküli ledger, helyi MLX / LM Studio / llama.cpp (csak localhost).
- **Adatvédelmi kapu:** érzékeny adat nem mehet Gemini/Codex felé; titok a promptban → stop;
  CRITICAL tier csak `--confirm`-mal.
- **Ökoszisztéma kánon:** `.aios-cli/core/ecosystem.md`, `.claude/rules/ecosystem.md`.
- **Skillek:** `skillpass-auth`, `skillpass-portal`, `skillpass-app-launcher`,
  `aibos-admin-contract`, `local-models`, `aios-orchestrator`.
- **Sablonok:** `templates/portal/` (OIDC session helper + tesztek), `templates/admin-contract/`
  (OpenAPI + permissions + validátor), `templates/plan/`.
- **Skill katalógus:** `.aios-cli/skills/catalog.manifest.json` + `CATALOG.md`
  (app → szekció → skill), `build-skill-catalog.py`.
- **Tapasztalatok:** `.aios-cli/core/lessons.md` (L-01..L-15) minden generált CLI konfigban.
- **Validáció:** `tests/skeleton-validation/test-ecosystem.sh`.

### Changed
- Modell routing: Fable 5.1 (terv), Opus 5.5 (kritikus), Sonnet 5.5 (napi + review),
  Haiku 4.5 (mechanikus). `intelligent-router` és `cli-router` az `aios` policy-ből dolgozik.
- Generált `CLAUDE.md` / `AGENTS.md` / `GEMINI.md`: app szerint csoportosított tömör
  skill index (~40% kisebb), ökoszisztéma + tapasztalatok blokk.
- `generate-cli-configs.sh`: `.claude/skills` másolatok tükrözése a forrásra.
- `check-safety` hook: aibos kulcs, SkillPass/Ory secret, böngésző storage token,
  megszűnt IdP blokkolás.
- `sync.sh`: orchestrator, sablonok, megszűnt útvonalak kiemelése, ledger `.gitignore`.

### Removed
- Megszűnt IdP: a korábbi auth skill, admin reference skill, extractor script és brand fájl
  (lista: `.aios-cli/removed-paths.txt`). Helyette skillpass.id.

### Migration notes
- Projektek: `./sync.sh --dry-run --project <nev>` → review → `./sync.sh --project <nev>`
  (hullámok: `specification/plan-v15/07-f7-flotta-sync-terv.md`).
- Sablon auth env: a korábbi IdP változók helyett `SKILLPASS_*` (`environments/.env.example`).
- aibos.space marad saját operátori auth-tal (kivétel).

## [7.7.0] - 2026-06-14 "AIOS Shared Kernel"

AIOS-alapu multi-CLI shared kernel: `.aios-cli` lett a source-of-truth a core
utasitasokhoz, adapter template-ekhez, scriptekhez es projekt skillekhez.

### Added
- **AIOS shared kernel:** `.aios-cli/{core,adapters,scripts,skills}`.
- **Project skill exposure:** `.codex/skills`, `.gemini/skills`, valamint
  `.claude/skills/admin-experience` linkek az AIOS skill source-ra.
- **Admin UX skill:** `admin-experience` es admin reference skill.
- **Validation:** AIOS skill validator es structure check a skill entry pontokra.

### Changed
- `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` AIOS generatorbol keszul, skill indexszel.
- `sync.sh` mar az `.aios-cli/skills` mappat is szinkronizalja es futtatja az
  AIOS config generatort a celprojektekben.
- Registry, onboarding es RTK hivatkozasok `.everengine-cli` helyett `.aios-cli`
  utvonalat hasznalnak.

### Removed
- Legacy `.everengine-cli/` shared kernel.

### Migration notes
- Deployed projektek: `./sync.sh --yes --force` futtatasa szukseges.
- Root `CLAUDE.md` tovabbra is megorzodik, ha kezzel karbantartott; az
  `AGENTS.md` es `GEMINI.md` generatorbol frissul.

---

## [7.6.0] - 2026-05-11 "Codex Bridge / Fast-first Workflow"

Codex elso osztalyu skeleton tamogatas: root `AGENTS.md`, project-scoped
`.codex/config.toml`, custom Codex agentek, globalis Plan-v workflow memoria,
fast-first routing es non-prod deploy/smoke delivery szabaly.

### Added
- **Plan-v10:** `specification/plan-v10/` fazisonkenti terv + implementation notes.
- **Codex project layer:** root `AGENTS.md`, `.codex/config.toml`,
  `.codex/agents/{explorer-fast,worker-standard,reviewer-deep}.toml`.
- **Global workflow memory:** `~/.everengine/agent-workflow.md` betoltve
  `~/.codex/AGENTS.md` es `~/.claude/CLAUDE.md` alol.
- **Fast-first profiles:** Codex `balanced` default (`gpt-5.3-codex`), `fast`
  (`gpt-5.3-codex-spark`), `deep` (`gpt-5.5`).
- **Validation:** `tests/skeleton-validation/test-codex.sh` es run-all Codex check.

### Changed
- `.aios-cli/core/` es Codex adapter template frissitve Plan-v workflow-ra.
- `sync.sh` es `.worktreeinclude` atveszi a `.codex` reteget, de root `AGENTS.md`
  projekt-specifikus marad.
- `scripts/{test,build,lint,deploy}.sh` template-aware: hianyzo package/Cargo vagy
  placeholder eseten skip/warn, non-prod deploy template modban compose config smoke.
- `CLAUDE.md` 200 soros budgeten belul hivatkozik a Plan-v es Codex bridge flow-ra.

### Migration notes
- Prod deploy tovabbra is explicit jovahagyas koteles.
- Deployed projekteknek root `AGENTS.md`-t sajat dontes szerint kell atvenniuk;
  `.codex/config.toml` es `.codex/agents/` sync-elheto shared layer.

---

## [7.5.0] - 2026-05-09 "Lean Mind"

Token-optimalizációs réteg: output discipline, context window hygiene, model routing
defaults, hook-alapú deterministic enforcement. Forrás: `compass_artifact_*-_text_markdown.md`.

### Added — v7.5 "Lean Mind" Token Optimization
- **Settings env (7 új):** `BASH_MAX_OUTPUT_LENGTH=20000`, `MAX_MCP_OUTPUT_TOKENS=8000`,
  `MAX_THINKING_TOKENS=8000` (10000-rol csokkentve), `CLAUDE_CODE_EFFORT_LEVEL=medium`,
  `CLAUDE_CODE_SUBAGENT_MODEL=claude-haiku-4-5-20251001`, `CLAUDE_CODE_FORK_SUBAGENT=1`,
  `ENABLE_TOOL_SEARCH=true`
- **Rules (2 új, always-on):** `00-token-discipline.md` (7 szabaly), `70-secrets-handling.md`
- **Skills (3 új):** `token-report-generator` (ccusage roll-up), `claude-code-session-handoff`
  (rename + clear + resume workflow), `cost-invariant-check` (LLM-calling crate audit)
- **Hooks (6 új):**
  - `pre-bash-cap.sh` — PreToolUse Bash output filter (grep/head pipe inject cargo/pnpm/pytest-re)
  - `pre-read-warn.sh` — PreToolUse Read >2000 sor warning
  - `post-tool-cost.sh` — PostToolUse token cost log → `$HOME/.claude/everengine/cost.jsonl`
  - `pre-compact-backup.sh` — PreCompact session JSONL backup
  - `session-end-report.sh` — SessionEnd CSV roll-up (havi)
  - `stop-tests-pass.sh` — Stop completion gate (default-OFF, opt-in per project)
- **Commands (3 új):** `/project:budget-check`, `/project:token-report`, `/project:clear-with-rename`
- **Budget template:** `.claude/everengine/budget.yaml` (4 tier: Master/Worker/External/Local, placeholder envelope-ok)
- **CLAUDE.md:** "Token discipline (v7.5 'Lean Mind')" szekcio (1 paragraph, max <200 sor megorizve)
- **Plan:** `specification/plan-v9/` (4 phase + master overview + implementation-notes)

### Changed
- `.claude/settings.json` hooks chain bővítés (6 új hook regisztrálva: PreToolUse Bash/Read,
  PostToolUse, PreCompact, SessionEnd)
- `MAX_THINKING_TOKENS` 10000 → 8000 (forrás-ajánlás)

### Out of scope (projekt-szintű, future patch)
- `aios-cost` Rust crate `BudgetTier::External` + `Local` enum
- `aios-kairos` `CostInvariantWatcher::check_external_tier`
- Prometheus / Grafana `aios_prompt_cache_hit_ratio`, `aios_subagent_opus_cost_ratio`
- KAIROS Prompt-Drift Heartbeat (cosine 0.92) bridge
- Plugin packaging (`everengine-plugin`)

### Migration notes
- **10 HITL kérdés (Q-1..Q-10)** dokumentálva, projekt-szintu `decisions/v7.5.md` valaszolja meg
- **Deployed projektek:** `./sync.sh --yes --force --project <name>` futtatasa szukseges
- **Backwards compat:** semmi nem törik — minden új komponens additív, default-OFF ahol kockázatos (`stop-tests-pass.sh`)
- Forras: `specification/skeleton-specifications/compass_artifact_wf-bef6d0f4-cfac-4635-b717-f769d5bb8a48_text_markdown.md`

---

## [7.4.0] - 2026-05-03

Skeleton bootstrap + Agent Teams platform features. 5 role-based agent komplementer
hozzaadas, 3 Agent Teams hook event support (TeammateIdle, TaskCreated, TaskCompleted),
plugins struktura es Forks pattern dokumentacio, futtathato bootstrap-aios.sh,
9-script skeleton-validation test suite, 2 engine-agnostic workflow template.

### Added — v7.4 Skeleton Bootstrap + Platform Features
- **Agentek (5 role-based):** `code-reviewer`, `test-writer`, `security-auditor`,
  `doc-writer`, `rust-specialist` (komplementer a meglevo 5 model-based agenttel)
- **`agents/INDEX.md`:** 2-axis kategorizacio (model vs role), 4 kombinacios pelda
- **`agents/FORKS.md`:** Subagent Forks pattern doc (context inheritance vs izolált)
- **Agent Teams hookok (3 esemeny):** `.claude/hooks/agent-teams/{teammate-idle,task-created,task-completed}.sh`
  + `.claude/settings.json` hooks blokk +3 event matcher
- **Plugins:** `.claude/plugins/STRUCTURE.md` (manifest.json + skills/agents/hooks/commands/mcp layout)
- **Bootstrap:** `.aios-cli/scripts/bootstrap-aios.sh` (1425 sor, interaktiv,
  16 P0 + 25 P1 placeholder skill generalas zerotól)
- **Skeleton-validation:** `tests/skeleton-validation/` (run-all + 9 test: structure,
  CLAUDE.md, settings, skills, hooks, agents, docker, git, security)
- **Workflows (2 uj):** `.claude/workflows/feature-development.yml` (engine-agnostic feature dev,
  AskUserQuestion + 8 step Agent Teams orchestration), `.claude/workflows/code-review-pipeline.yml`
  (multi-agent SPEC + QUALITY + SECURITY parallel review → opus-architect synthesize)
- **CLAUDE.md uj szekcio:** "Skeleton bootstrap (v7.4)" — clone vs bootstrap kulonbseg

### Changed
- `.claude/settings.json` hooks blokk: +3 Agent Teams event (TeammateIdle, TaskCreated, TaskCompleted)
- CLAUDE.md "Multi-agent" szekcio: agent kategoriak (model + role) + Agent Teams hookok + Plugins/Forks
- `sync.sh` SHARED_PATHS: +`tests/skeleton-validation`, +`docs/onboarding`
- `.gitignore`: +`CLAUDE.local.md` (personal scope, v6.3-bol mar implicit)

### Migration notes
- **NEM toroljuk** a meglevo 5 model-based agentet (haiku/sonnet/opus/auto-iterate/worktree)
- **`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`** mar aktiv (v7.0 ota)
- **bootstrap-aios.sh != create-project.sh:** bootstrap zerotól, create-project skeleton-ből clone
- **Deployed projektek:** `./sync.sh --project <name>` futtatasa szukseges

---

## [7.3.0] - 2026-05-03

Strukturalis 5-reteg view (vibinex AgentDevKit) bevezetese mint **alternativ
didaktikai keret** a meglevo 7-reteg filozofiai view (v6.0-v6.5) mellé.
NEM uj komponens — csak dokumentacio + CLAUDE.md/README.md frissites.

### Added — v7.3 Didaktikai Frame
- **`docs/onboarding/two-view-approach.md`:** 275-soros 2-view onboarding palya
  (Day 1-7 strukturalis + Week 2-4 filozofiai + Honap 2+ senior level)
- **CLAUDE.md uj szekcio:** "Strukturalis 5-reteg view (v7.3, alternativ)" —
  Memory/Knowledge/Guardrail/Delegation/Distribution + Everengine plus-3-dimenzio
- **README.md frissites:** Strukturalis View hangon ujrairva (Layer 1-5 + Everengine specifikus retegek)

### Why
- Uj csapattag onboarding (Day 1-7) gyorsabb belépés
- Külso kommunikacio standard ipari terminologia
- Quick reference / mental model napi hasznalatra

### Forrás
- vibinex AgentDevKit "Five layers, one stack" infografika sorozat (kép 1-6)
- Brij Pandey ("Each folder is a different dimension of behavior") — v6.3 forrás

### Migration notes
- **0 új komponens** — csak dokumentációs réteg
- A meglévő 7-réteg filozófiai view **érintetlen** (v6.0–v6.5 patches)
- Onboarding workflow YAML (junior-onboarding.yml) **out of scope** future patch

---

## [7.2.0] - 2026-04-26

RTK (https://rtk-ai.app) auto-rewrite okoszisztema integralasa. 60-90% bash token-megtakaritas
3 CLI-n at (Claude Code / Codex / Gemini), NAIH compliance default-tal.

### Added — v7.2 RTK Native Integration
- **Hook:** `.claude/hooks/rtk-rewrite.sh` (PreToolUse Bash, auto-rewrite RTK-supported commands → `rtk <cmd>`)
- **Skills:** `rtk-optimizer` (P2, Haiku — adoption check, missed savings), `rtk-tee-recovery` (P2, Haiku — failure recovery local cache-bol)
- **Workflow:** `.claude/workflows/rtk-onboarding.yml` (9-step setup: install → 3 CLI setup → verify → baseline → routine)
- **Routine:** `.claude/routines/scheduled/daily-rtk-gain-export.yml` (napi 02:00 UTC, Prometheus pushgateway)
- **Scripts:** `.aios-cli/scripts/install-rtk.sh` (multi-CLI installer), `scripts/save-rtk-failure-observation.sh` (memory observation auto-save)
- **Env vars:** `RTK_AUTO_REWRITE_ENABLED=true`, `RTK_TELEMETRY_DISABLED=1` (NAIH default), `RTK_TEE_LOG_PATH=$HOME/.local/share/rtk/tee`
- **Multi-CLI:** `generate-cli-configs.sh` RTK_REFERENCE szekcio CLAUDE.md/AGENTS.md/GEMINI.md vegere appendelve
- **`debug-3strike` skill update:** Strike 1 RTK tee log recovery integráció
- **`.aios-cli/core/instructions.md`:** RTK Token Optimization szekcio

### Changed
- `.claude/settings.json` PreToolUse Bash hook sorrend: `check-bash-safety → rtk-rewrite (NEW) → rtk-filter`
- CLAUDE.md uj "RTK Token Optimization (v7.2)" szekcio + "5 reteg" RTK filter → RTK auto-rewrite update

### Migration notes
- **Manualis lepes:** `brew install rtk` (hivatalos Homebrew formula) + `.aios-cli/scripts/install-rtk.sh` (egyszer fejleszto gepen)
- **Deployed projektek:** `./sync.sh --project <name>` futtatasa szukseges
- **Default NAIH compliance:** `RTK_TELEMETRY_DISABLED=1` mar aktiv, override csak explicit user beleegyezessel

---

## [7.1.0] - 2026-04-26

5 erettseg-finomitas: AskUserQuestion tool integralas, anti-style szótár, autodream
5-fazisu memory cycle, AI agent reliability playbook, Hamza Khalid prompt anatomy template.

### Added — v7.1 Refinements
- **Identity:** `.claude/identity/anti-style-dictionary.md` (8 szekció — magyar slop, AI fluff, hivatalos antipatternek, angol marketing, salutation, felkialtojel, em-dash, bekezdes-hossz)
- **Skills:** `ask-user-question-orchestrator` (P2, Haiku — 3 pattern, max 7 kerdes szabaly), `ai-agent-reliability` (P1, Sonnet+Opus advisor — 4 pillér: RETRY, TIMEOUTS, FALLBACK, CIRCUIT BREAKER), `prompt-anatomy-template` (P1, Sonnet — 7-szekcios Hamza Khalid template)
- **Workflow:** `.claude/workflows/autodream-memory-cycle.yml` (5-fazis cron `0 19 * * SUN` — Fork → Distill → Conflict → Prune → Sync)
- **Script:** `scripts/consolidation-lock.sh` (memory write race protection, 5 perc timeout, trap-based cleanup)
- **Memory backup:** `.claude/memory/backup/` mappa SQLite snapshot-okhoz
- **Commands update:** `/project:plan` + `/project:brainstorm` AskUserQuestion 5-mezos urlap szekció eleje
- **`.claude/identity/anti-style.md`:** Section 11 pointer az anti-style-dictionary.md-re
- **`brand-auditor` skill:** auto-loads anti-style-dictionary.md
- **`memory-curator` skill:** kotelezo `consolidation-lock.sh` minden write elott

### Removed
- `.claude/routines/scheduled/weekly-memory-curate.yml` (v6.5 egylepeses, leváltva az autodream-memory-cycle workflow-ra)

### Migration notes
- A weekly-memory-curate.yml routine helyett mostantol az autodream-memory-cycle workflow fut (cron-on, 5-fazisra bontva)
- Memory observation auto-save: `claude memory save` hivasok elott source-old a `consolidation-lock.sh`-t

---

## [7.0.0] - 2026-04-25

Hatalmas integracio: v5.1 -> v7.0 master. 8 patch + master konszolidacio. 14 fazis (lasd `specification/plan-v7/`).

### Added — v5.2 Architektura
- `.agent_memory.md` (PreCompact context save) + hook `save-agent-memory.sh`
- Agent Teams env-ek: `AGENT_TEAMS_REDIS_URL`, `AGENT_TEAMS_MAILBOX_TTL_SECONDS`, `AGENT_TEAMS_LOCK_TIMEOUT_SECONDS`
- Skill: `agent-teams-coordinator` (P2)

### Added — v5.4 Token Optimalizalas
- MCP server: `claude-context` (Zilliz, voyage-code-3 embedding)
- MCP server: `context-mode` (output sandbox, .claude/context-mode.db)
- Hook: `rtk-filter.sh` (PreToolUse Bash, terminal output -60-90%)
- Env: `CONTEXT_MODE_AUTO_THRESHOLD=5000`, `CONTEXT_MODE_PATTERNS`

### Added — v5.5 Prompt Quality (Tier D->SS)
- MCP server: `brave-search`
- Skills: `prompt-quality-boost`, `brainstorming`, `frontend-design` (P1/P2)
- Command: `/project:brainstorm`
- `/project:ultrareview` Tier S/SS prompt mintak

### Added — v5.6 Context Economy + Routines
- **9. Aranyszabaly: "MINDEN TOKEN FIZESSEN"**
- Skill: `context-auditor` (P2, Haiku)
- Command: `/project:context-check`
- `.claude/routines/{scheduled,api-triggered,webhook}/` mappa struktura
- 5 peldarutin: `weekly-autodream`, `daily-cost-report`, `daily-backup-verify`, `deploy-verification`, `pr-bespoke-review`
- `_budget.yml` global limit
- Env: `ROUTINES_DAILY_LIMIT=25`, `ROUTINES_COST_CAP_USD=50`
- Script: `migrate-loops-to-routines.sh`

### Added — v6.0 Intelligens Modell Routing (5 kategoria)
- Routing matrix: CRITICAL/COMPLEX/BATCH/STANDARD/MECHANICAL
- 25+ uj env var: `AI_ROUTING_*`, `AI_MODEL_*`, `AI_EFFORT_*`, `AI_ADVISOR_MAX_USES_*`, `AI_TASK_BUDGET_*`
- Hook: `intelligent-router.sh` (UserPromptSubmit, kategorizal + javasol model+effort+budget)
- MCP swap: Firecrawl out, **hyperbrowser** in (strukturalt scraping)
- CLAUDE.md uj "Modell Routing" szekcio + frissitett "Koltseg"

### Added — v6.1 Brand & Identity
- `.claude/identity/` 14 fajl: about-us, mission, vision, values, voice, anti-style (Ruben Hassid 80%), brand-{aibos,jflow,skillpass}, audience/{developer,decision-maker,end-user,support-agent}
- Skills: `brand-auditor`, `brand-interview` (P2)
- Command: `/project:brand-check`
- Hook: `check-brand.sh` (PostToolUse, anti-style auto-detect md/jsx/tsx)
- Routine: `weekly-brand-audit.yml`
- `prompt-quality-boost` SKILL frissites: identity-aware (voice + anti-style + brand)

### Changed — v6.2 Superpowers (TDD Iron Law)
- **5. Aranyszabaly MODOSULT:** "FUTTASD LE a tesztet" -> "**IRJ failing tesztet ELOSZOR** (TDD Iron Law)"
- Skills: `tdd-enforcer` (P0!), `debug-3strike` (P1), `parallel-reviewer-orchestrator` (P1)
- Hook: `check-tdd.sh` (PostToolUse src/** warning ha nincs teszt)
- `/project:review` UPDATE: parallel pattern (2 subagent SPEC + QUALITY, decision matrix)
- CLAUDE.md uj "Workflow Pipeline" szekcio (7 fazis)

### Added — v6.3 Two-Scope Architecture
- `.worktreeinclude` + `scripts/setup-worktree.sh` (worktree symlinkek)
- Command: `/project:bootstrap-personal` (~/.claude/ wizard)
- CLAUDE.md uj "Ket scope mukodese" + "A 6 dimenzio mental model" szekciok

### Added — v6.3.1 Data Analyst Layer (opcionalis)
- Env: `DATA_ANALYST_LAYER_ENABLED=false` (default off)
- `requirements-data-analyst.txt` (Python deps)
- `docs/data-analyst-layer.md`
- 4 P2 opcionalis skill: `jupyter-notebook-editor`, `auto-viz`, `dataframe-checkpoint`, `data-export-pipeline`

### Added — v6.4 Multi-CLI (vendor freedom)
- `.aios-cli/{core,adapters/{claude,codex,gemini},scripts}/` shared kernel
- `generate-cli-configs.sh` (3 CLI config 1 forrasbol)
- Command: `/project:cli-switch`
- Skills: `multi-vendor-consensus`, `cli-router` (P2)
- Script: `multi-vendor-consensus.sh` (parallel claude+codex+gemini + konszenzus)
- Env: `AIOS_ACTIVE_CLI=claude`

### Added — v6.5 Memory v2 (RAD) + Workflows + Experiments
- `.claude/memory/`: `global.md`, `patterns.md`, `mistakes.md`, `_schema.sql`, `observations.db` (SQLite)
- 5 memory hook: `memory-context-load` (SessionStart), `memory-relevance-check` (UserPromptSubmit), `memory-observation-capture` (PostToolUse), `memory-session-summary` (Stop), `memory-promote-patterns` (SessionEnd)
- Env: `MEMORY_V2_ENABLED=true`, `MEMORY_AUTO_PROMOTE_THRESHOLD=3`, `MEMORY_OBSERVATION_DB`
- Skill: `memory-curator` (P1) | Command: `/project:memory`
- `.claude/workflows/` 3 YAML pelda + `state/` (gitignored)
- Skill: `workflow-runner` (P1) | Command: `/project:workflow`
- `experiments/{failed-ideas,prototypes}/` mappak
- Skills: `failed-experiment-curator`, `internal-comms`, `mcp-builder`, `webapp-testing` (P2)
- Script: `import-skill-from-repo.sh` (Repomix wrapper)
- Routine: `weekly-memory-curate.yml`

### Changed — v7.0 Konszolidacio
- **CLAUDE.md TELJES ATIRAS** (~150 sor, 9 Aranyszabaly, minden v5.2-v7.0 reteg hivatkozva)
- VERSION 5.1.0 -> 7.0.0
- Plan-v7 14 fazis fajl: `specification/plan-v7/`
- `deployed/projects.list` verzio frissites

### Migration notes (v5.1 -> v7.0)
- 5. Aranyszabaly UJ szoveg: failing test ELOSZOR (Iron Law)
- 9. Aranyszabaly UJ: "MINDEN TOKEN FIZESSEN"
- Routing automatikus → minden uj prompt kategorizalva (override: /model, /effort)
- Brand-check hook minden md/jsx-en aktivalt → varhato warning-ok regi tartalmakon
- TDD hook src/** modositasnal warning → uj kodhoz failing test eloszor
- Regi identitas domain deprecated, csere az aktualis IdP domainre (ma: `skillpass.id`) minden uj copy-ban
- Memory v2 SQLite DB inicializalva, hook-ok aktivak — uj observations folyamatosan epulnek
- 11 MCP server (volt 8): + claude-context, context-mode, brave-search, hyperbrowser; - firecrawl

## [5.1.0] - 2026-04-18

### Added
- **Opus 4.7 advisor** integracio (settings.json: `AI_ADVISOR_MODEL=claude-opus-4-7`)
- Uj env vars: `AI_TASK_BUDGET_DEFAULT`, `AI_TASK_BUDGET_COMPLEX`, `AI_MAX_TOKENS_CEILING`, `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING`
- **`/ultrareview`** slash command (skeptikus senior engineer review, SHIP/FIX/BLOCK dontes)
- **pse-skills MCP** entry a `.mcp.json`-ban (skill-kereso SQLite FTS5 + embedding rerank)
- `install.sh` — skeleton bootstrap uj projektbe

### Changed
- CLAUDE.md Koltseg szekcio: **xhigh effort default** (Opus 4.7), `/effort` skala dokumentacio, tokenizer 1.0-1.35x figyelmeztetes
- `/team` command: Opus 4.7 nem spawn-ol alapbol → explicit utasitas szukseges
- Domain rebrand: identitas domain egysegesitese minden aktiv fajlban (ma: `skillpass.id`)

### Migration notes
- `MAX_THINKING_TOKENS` Opus 4.7-en mar nincs hatasa (adaptive reasoning default)
- Promptok literalisabb ertelmezese: explicit instrukciok szuksegesek
- Subagent spawn EXPLICIT kell kerni

## [5.0.0] - 2026-04-17

### Added
- **Chaos engineering:** `infrastructure/chaos/` (8 scenario YAML + schedule.yml)
- **Docs-as-code:** `docs/postmortems/TEMPLATE.md`, `docs/compliance/{gdpr-checklist,audit-trail}.md`, `docs/adr/TEMPLATE.md` (MADR v3)
- **SLI/SLO:** `infrastructure/monitoring/sli-slo.yml`
- **Runbook:** `docs/runbooks/chaos-drill.md`

### Changed
- **8. Aranyszabaly** hozzaadva: "UJ TEMA = /clear VAGY UJ SESSION"
- CLAUDE.md Munkafolyamat: token hatekonysag mintak (preciz javitas 5-7x, batch 3x, session limitek 15-20/30/40)
- CLAUDE.md Koltseg: ultrathink, Batch API (-50%), 1M token context

## [4.2.0] - 2026-04-17

### Added
- **Self-Improvement Loop:** `tasks/todo.md` + `tasks/lessons.md`
- `/plan` command: todo.md-be ir, lessons.md olvasas

### Changed
- settings.json: `Write tasks/**` permission
- settings.json hook wiring: skill-router.sh (PreToolUse), check-placeholders.sh + auto-commit.sh (PostToolUse)

## [4.1.0] - 2026-04-15

### Added
- **code-review-graph MCP** (7. szerver) — blast radius alapu review, 6.8x token csokkentes
- `.code-review-graphignore` — felesleges fajlok kizarasa a graf-bol
- `.claude/skills/code-review/references/graph-review.md` — graph-alapu review utmutato

## [4.0.0] - 2026-04-15

### Added
- `/team` slash command — Agent Teams tervezes + 4 production pattern
- `.claude/rules/agent-teams.md` — Subagent vs Agent Teams dontesi matrix + anti-patterns
- `.claude/commands/team.md`

### Changed
- CLAUDE.md: Multi-agent szekcio (Subagent default, Agent Teams csak ha vita/challenge kell)
- settings.json env: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

## [3.2.0] - 2026-04-15

### Added
- **7. Aranyszabaly:** "MINOSEG > SEBESSEG"
- CLAUDE.md Workflow formula: `/plan → Cel → Lepesek → Review → Vegrehajtas → Finomitas`

### Changed
- Kontextus baseline: `/compact` 70% → 50% (induló kontextus ~15-20%)
- settings.json env: `AI_ADVISOR_*` (5 valtozo) — Advisor Tool integracio
- CLAUDE.md Koltseg szekcio: Sonnet+Opus advisor default

## [3.0.0] - 2026-04-14

### Added
- Elso konszolidacios verzio: 68 skill, 9 hook, 6 MCP
- Feature-based struktura, CLAUDE.md < 200 sor
- 6 Aranyszabaly, Progressive Disclosure

---

**Megjegyzes:** a `deployed/projects.list` minden projektnel nyilvantartja a legutobb szinkronizalt verziot. A `sync.sh` ezt a CHANGELOG-ot jeleniti meg, amikor frissitest javasol.

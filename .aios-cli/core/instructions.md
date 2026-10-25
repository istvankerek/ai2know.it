# AIOS CLI – Egységes Utasítások (v8.0)

> Ez a fájl az egyetlen igazság forrása (single source of truth) minden CLI adapter számára.
> Ne módosítsd közvetlenül – a változtatások az `adapters/` sablonokba mennek, majd
> `scripts/generate-cli-configs.sh` generálja a tényleges konfigurációs fájlokat.

## 9 Aranyszabály (minden feladatra, kivétel nélkül)

1. **KÉRDEZZ VISSZA** mielőtt komplex feladatba kezdenél – ne találgass
2. **MUTASS TERVET** mielőtt kódolnál – plan komplex feladatokhoz
3. **SOHA ne törölj** fájlt vagy adatot explicit jóváhagyás nélkül
4. **SOHA ne commitolj** main-re közvetlenül
5. **ÍRJ failing tesztet ELŐSZÖR** (TDD Iron Law) – soha nincs production kód failing test nélkül
6. **MARADJ A FELADATNÁL** – ne refaktorálj, ne "javíts" olyat amit nem kértek
7. **MINŐSÉG > SEBESSÉG** – szánj időt, ne hagyj ki lépéseket
8. **ÚJ TÉMA = ÚJ SESSION** – ne szennyezd a kontextust
9. **MINDEN TOKEN FIZESSEN** – Context Economy: ha nem ér, ki vele

## Folder=Behavior elv

A `.aios-cli/` skeleton a közös source-of-truth Claude Code, Codex és Gemini
számára. A `.claude/` mappa továbbra is Claude Code belépési pont, de a skillek
közös forrása `.aios-cli/skills`.

A viselkedést a skeleton mappák definiálják:

| Mappa | Mit ad | Példa |
|-------|--------|-------|
| `rules/` | TUDJON | code-style, security, testing |
| `commands/` | CSINÁLJON | /review, /plan, /deploy |
| `skills/` | HOGYAN | tdd-enforcer, brand-auditor |
| `agents/` | KIVE váljon | qa-team, debug-debate |
| `memory/` | EMLÉKEZZEN | patterns, mistakes |
| `identity/` | KOMMUNIKÁLJON | voice, anti-style, brand |

Egy új fájl új viselkedést ad – nincs külön "register" lépés.

## Scope rendszer (v6.3)

| Scope | Path | Tartalom | Commit-elt? |
|-------|------|----------|-------------|
| Project | `.aios-cli/` | Közös CLI skeleton, skill source, adapter template-ek | Igen |
| Claude Entry | `.claude/` | Claude Code hookok, parancsok, identity, belépési linkek | Igen |
| Personal | `~/.claude/` | Cross-project, saját preferenciák | Nem |

Merge szabályok: `permissions.allow` unió, `permissions.deny` unió,
`env` personal felülírja a project-et, hooks mindkettő fut (project → personal).

## Orchestráció és modell routing (v8.0)

Egyetlen policy: `.aios-cli/orchestrator/policy/routing-policy.toml`. Mindhárom CLI és a
hook ugyanazt használja: `scripts/aios route "<feladat>"`.

| Tier | Elsődleges | Mikor |
|------|-----------|-------|
| PLAN | Claude Fable 5.1 | architektúra, plan-vN, ADR |
| CRITICAL | Claude Opus 5.5 (`--confirm`) | prod, migráció, security, adatvesztés |
| STANDARD | Claude Sonnet 5.5 | feature, bug fix, refactor |
| REVIEW | Claude Sonnet 5.5 | review, PR |
| SCOPED | Codex balanced | boilerplate, CRUD scaffold, batch |
| LARGE_CONTEXT | Gemini CLI | >200K token, web kutatás |
| MECHANICAL | helyi MLX / LM Studio / llama.cpp → Haiku 4.5 | rename, formázás, regex |
| CONSENSUS | Claude + Codex + Gemini | kritikus döntés |

Érzékeny adat (PII, titok, ügyféladat, jogi tervezet) → csak helyi modell vagy Claude.
Részletek: `.aios-cli/core/routing-policy.md`, `aios-orchestrator` skill.

## Identity és Brand

Az `.claude/identity/` mappa 14 fájl tartalmazza az ORG identitást.
Minden user-facing tartalom generálás előtt be kell olvasni a releváns fájlokat.

Részletek: `.aios-cli/core/identity-summary.md`

## Munkafolyamat Pipeline (v6.2)

```
Brainstorm → Plan → Execute → Test → Review → Debug → Ship
```

| Fázis | Mikor hagyható ki |
|-------|-------------------|
| Brainstorm | precíz spec, konkrét bug fix |
| Plan | egysoros, rename, format |
| Test | refactor (viselkedés nem változik) |
| Review | format, rename |

## Plan-v Workflow (v8.0)

Komplex Codex vagy Claude Code munka esetén a terv a repo-ban él:

1. Hozd létre a következő `specification/plan-vN/` mappát (sablon: `templates/plan/`).
2. Írd le a tervet fázisonként külön Markdown fájlban.
3. Elfogadott terv után implementálj.
4. Minden fázis után ellenőrizd vissza a megvalósítást a plan mappából.
5. Futtass unit/validation tesztet, majd git save point.
6. Deploy alapból csak non-prod (`local` vagy `test`), utána automatizált smoke.
7. Hibánál javítás, újrateszt, új non-prod deploy/smoke.
8. Végső commit csak akkor, ha az elfogadott terv szerint működik.

Prod deploy csak explicit jóváhagyással mehet (owner: "mehet").

## Multi-CLI (v6.4)

Ez a skeleton három CLI-t támogat egyetlen shared kernel-lel:

| CLI | Erősség | Amikor használd |
|-----|---------|-----------------|
| Claude Code | Komplex reasoning, skills rendszer | Alapértelmezett komplex munkákhoz |
| Codex CLI | Fast-first implementáció, batch, review | Scoped fejlesztés, mechanikus és közepes task |
| Gemini CLI | 2M context, web research, grounding | Nagyon nagy kódbázis audit, web kutatás |

Aktív CLI: `AIOS_ACTIVE_CLI` env var (default: `claude`).
Váltás: `/project:cli-switch claude|codex|gemini`.
Konszenzus: `multi-vendor-consensus` skill kritikus döntéseknél.

## Fast-first Routing (v8.0)

- Codex profilok: `fast` (gpt-5.3-codex-spark), `balanced` (gpt-5.3-codex), `deep` (gpt-5.5).
- Claude: Sonnet 5.5 fejlesztésre, Haiku 4.5 lookupra, Opus 5.5 csak critical gate-tel,
  Fable 5.1 tervezésre.
- Helyi modell (MLX / LM Studio / llama.cpp) mechanikus munkára és gépen maradó adatra.
- Subagent csak független, jól körülhatárolt munkára; max 3 párhuzamos szál alapból.

## RTK Token Optimization (v7.2)

Mindhárom CLI használja az RTK auto-rewrite ökoszisztémát: 60-90% token-megtakarítás
gyakori bash parancsoknál (git, gh, cargo, pytest, npm, docker, kubectl, aws stb.).

- **Claude Code**: PreToolUse Bash hook (`.claude/hooks/rtk-rewrite.sh`)
- **Codex CLI**: AGENTS.md instrukciók
- **Gemini CLI**: PreToolUse hook (`~/.gemini/hooks/rtk-hook-gemini.sh`)

A teljes per-CLI hivatkozás minden generált config (CLAUDE.md / AGENTS.md / GEMINI.md)
végén megjelenik (`.aios-cli/scripts/generate-cli-configs.sh` RTK_REFERENCE szekció).

Telepítés (egyszer, fejlesztő gépén): `.aios-cli/scripts/install-rtk.sh`
NAIH compliance: `RTK_TELEMETRY_DISABLED=1` (default).
Részletek: `rtk-optimizer` skill, `.claude/workflows/rtk-onboarding.yml`.

---
name: aios-orchestrator
description: >
  AIOS orchestrator használata: feladatonként determinisztikusan eldönti a CLI-t
  (Claude Code, Codex, Gemini, helyi MLX / LM Studio / llama.cpp), a modellt, az
  effortot és a fallback láncot, adatvédelmi kapukkal. Triggerek: "melyik modell",
  "melyik CLI", "route", "aios", "delegáld codexnek", "futtasd helyi modellen",
  "költség", "fallback", "orchestráció". NE használd: egyszerű, már folyamatban
  lévő feladat közben minden lépésre (a hook úgyis jelez).
priority: P1
model: claude-haiku-4-5-20251001
related_skills:
  - cli-router
  - local-models
  - multi-vendor-consensus
  - ai-agent-reliability
---

# AIOS Orchestrator

## Mit ad

Egyetlen policy (`.aios-cli/orchestrator/policy/routing-policy.toml`) dönti el, hogy
melyik eszköz kapja a feladatot. Ugyanazt a döntést látja a Claude hook, a Codex
(`AGENTS.md`), a Gemini (`GEMINI.md`) és az ember (`scripts/aios`).

## Parancsok

```bash
scripts/aios route "feladat" [--files ...] [--json]  # javaslat + indoklás
scripts/aios run "feladat" --dry-run                 # mit indítana
scripts/aios run "feladat" [--provider codex]        # indítás fallback lánccal
scripts/aios run "prod migráció ..." --confirm        # CRITICAL csak megerősítéssel
scripts/aios providers                               # mi van telepítve / fut
scripts/aios explain MECHANICAL                      # tier lánc
scripts/aios budget --period week                    # futások, hibák, idő
```

Exit kódok: 0 OK · 1 hiba · 2 nincs futtatható provider · 3 titok a promptban ·
4 megerősítés kell · 5 policy hiba.

## Tier-ek röviden

| Tier | Elsődleges | Mikor |
|------|-----------|-------|
| PLAN | Claude Fable 5.1 | architektúra, plan-vN, ADR |
| CRITICAL | Claude Opus 5.5 | prod, migráció, security, adatvesztés |
| STANDARD | Claude Sonnet 5.5 | feature, bug fix, refactor |
| REVIEW | Claude Sonnet 5.5 | review, PR |
| SCOPED | Codex balanced | boilerplate, CRUD scaffold, batch |
| LARGE_CONTEXT | Gemini CLI | >200K token, web kutatás |
| MECHANICAL | helyi modell → Haiku | rename, formázás, regex, osztályozás |
| CONSENSUS | Claude + Codex + Gemini | kritikus döntés |

A pontos, generált tábla: `.aios-cli/core/routing-policy.md`.

## Szabályok az agentnek

1. Komplex vagy költséges feladat előtt futtasd: `scripts/aios route "<feladat>"`, és
   a javasolt tier-t mondd ki a felhasználónak.
2. `sensitive` adatosztálynál **soha** ne delegálj Gemini vagy Codex felé, akkor sem,
   ha a felhasználó kéri. Kérdezz vissza, és ajánlj helyi modellt.
3. CRITICAL tier: plan-vN + explicit owner jóváhagyás ("mehet") kell, és csak utána
   jöhet a `--confirm`.
4. Titkot soha ne tegyél promptba. Ha az `aios run` 3-as kóddal megáll, ne próbáld
   kerülőúton átadni.
5. Fallback mindig látható: ha a lánc vált, jelezd a felhasználónak.

## Policy módosítás

- Csak a TOML-t szerkeszd, utána futtasd:
  `python3 -m unittest discover -s .aios-cli/orchestrator/tests` és
  `.aios-cli/scripts/generate-cli-configs.sh all` (frissíti a routing táblát).
- Új provider: `kind = "cli"` (binary) vagy `kind = "local"` (csak localhost URL).

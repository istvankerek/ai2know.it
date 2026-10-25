---
name: cli-router
description: |
  Feladathoz legjobb CLI javaslat (Claude Code / Codex / Gemini / helyi modell).
  v8.0-tól az AIOS orchestrator policy-jét használja, nincs saját döntési táblája.
  Triggerek: "melyik CLI", "cli router", "legjobb CLI", "codex vagy claude",
  "gemini vagy claude", "cli javaslat", "which cli", "route to cli".
license: project
priority: P2
model: claude-haiku-4-5-20251001
related_skills:
  - aios-orchestrator
  - local-models
---

# cli-router Skill

## Cél

Megmondja, melyik CLI és modell a legjobb a feladatra. Kerüli a felesleges
kontextusváltást, és optimalizálja a költséget. A döntést **nem maga hozza**, hanem
az `aios route` adja. Így Claude, Codex és Gemini ugyanazt a választ kapja.

## Lépések

1. Futtasd: `scripts/aios route "<feladat>" --json` (érintett fájlokkal: `--files ...`).
2. Válaszolj a lenti formátumban a JSON alapján.
3. Ha a felhasználó másik CLI-t kér, ellenőrizd, hogy a lánc engedi-e
   (`excluded` mező). Érzékeny adatnál nem engedi: ezt mondd ki.

## Válasz formátuma

```
## CLI Javaslat

**Tier:** STANDARD   **Adatosztály:** internal
**Ajánlott:** claude:standard (claude-sonnet-5-5, high)
**Fallback:** codex:balanced → claude:critical
**Indok:** <reasons mezőből, 1-2 sor>
**Indítás:** scripts/aios run "<feladat>"   (vagy a javasolt CLI közvetlenül)
```

CLI váltás session szinten: `/project:cli-switch claude|codex|gemini`.

## Kapcsolódó

- `aios-orchestrator` skill (teljes használat, exit kódok, policy módosítás)
- `.aios-cli/core/routing-policy.md` (generált tábla)
- `multi-vendor-consensus` (CONSENSUS tier)

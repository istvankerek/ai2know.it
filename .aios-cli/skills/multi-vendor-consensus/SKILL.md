---
name: multi-vendor-consensus
description: |
  Kritikus döntéseknél három CLI párhuzamos futtatása és konszenzus elemzés.
  Triggerek: "konszenzus", "vendor consensus", "kritikus döntés", "3 CLI vélemény",
  "multi-vendor", "compare claude codex gemini", "melyik a jobb megoldás".
license: project
priority: P2
model: claude-sonnet-4-6
advisor: claude-opus-4-7
---

# multi-vendor-consensus Skill

## Cél

Magas kockázatú döntéseknél (architektúra, API design, biztonsági megközelítés)
három különböző CLI-t futtat párhuzamosan, majd Claude orchestrátorként elemzi
az eredményeket és konszenzust épít.

## Mikor aktiválódik

- "konszenzus" vagy "vendor consensus" szerepel a promptban
- "kritikus döntés" + architektúra/API/security téma
- Felhasználó explicit kér több véleményt ("mit mondana a Gemini?")
- High-stakes design döntés ahol az anchoring bias kockázatos

## Folyamat

### 1. Prompt előkészítés

A felhasználó promptját normalizáld: távolítsd el a CLI-specifikus utalásokat,
fogalmazd meg CLI-agnosztikusan.

### 2. Párhuzamos futtatás

```bash
./scripts/multi-vendor-consensus.sh "{PROMPT}"
```

Ez párhuzamosan futtatja a három CLI-t és menti az outputot:
```
outputs/consensus/{TIMESTAMP}/
  claude.md
  codex.md
  gemini.md
  consensus.md
```

Ha a script nem elérhető (CLI-k nincsenek telepítve):
Claude maga generál 3 különböző perspektívát szimulálva:
- Claude perspektíva: reasoning + skills fókusz
- Codex perspektíva: implementáció fókusz, pragmatikus
- Gemini perspektíva: nagy kép, kontextus fókusz

### 3. Konszenzus elemzés

Az eredmények elemzésekor:

```markdown
## Konszenzus Elemzés

### Egyező pontok (mind a 3 CLI)
- [lista]

### Eltérések
| Szempont | Claude | Codex | Gemini |
|----------|--------|-------|--------|
| [...]    | [...]  | [...] | [...] |

### Ajánlás
[Claude orchestrátor döntése indoklással]

### Konfidencia
- Magas: ha mind a 3 egyezik
- Közepes: ha 2/3 egyezik
- Alacsony: ha mind a 3 eltér (→ Opus advisor kell)
```

### 4. Opus advisor escalation

Ha konfidencia alacsony (mind a 3 CLI eltér), eskalálj Opus 4.7 advisor-ra:
"A három CLI jelentősen eltérő eredményt adott. Javasolt: Opus 4.7 advisor konzultáció."

## Korlátok

- A script (`multi-vendor-consensus.sh`) csak akkor fut ténylegesen, ha a codex és gemini
  CLI-k telepítve vannak. Claude Code alapból mindig elérhető.
- Szimuláció módban Claude különböző perspektívákból közelíti meg a problémát,
  de ez nem helyettesíti a valódi multi-vendor futtatást.

## Kapcsolódó

- `scripts/multi-vendor-consensus.sh` – CLI script a párhuzamos futtatáshoz
- `.claude/skills/cli-router/SKILL.md` – CLI routing döntési mátrix
- `/project:cli-switch` – aktív CLI váltás

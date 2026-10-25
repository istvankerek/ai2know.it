# Uj Fejleszto Guide

## Elso napod

1. Olvasd el: [Onboarding](../onboarding.md)
2. Allitsd be a kornyezetet: `make local`
3. Ismerkedj meg a strukturaval: `tree -L 2`

## Legfontosabb szabalyok

1. **Kod angolul, dokumentacio magyarul**
2. **Nincs `any` type** — hasznalj `unknown` + type guard
3. **Nincs `console.log`** — hasznald a Logger modult
4. **Tesztet irsz = futtasd le** (`./scripts/test.sh`)
5. **Secret SOHA kodban** — kornyezeti valtozo
6. **Auth = SkillPass.ID, admin = aibos.space** — ne csinalj sajatot

## Claude Code hasznalat

```bash
# Session inditas
claude

# Uj modul letrehozas
/project:bootstrap <modul_nev>

# Kod review
/project:review

# Ha elakadtal
"Kerdezz vissza mielott vegrehajtasz"
```

## Fajl struktura megertese

```
apps/
├── frontend/    # Publikus weboldal (Vite + React Router)
├── admin/       # Admin panel (Vite + React Router + AG Grid)
├── backend/     # API szerver (Rust/Axum)
└── ai-chat/     # AI chat szolgaltatas

.claude/
├── rules/       # Olvasd el mind a 7-et!
├── commands/    # Slash command-ok
└── skills/      # 67 skill — szukseged szerint olvasd
```

## Hol kerj segitseget
- Tech lead: architektura kerdesek, L1 jovahagyas
- Runbooks: docs/runbooks/ — ha valami elromlik
- COORDINATION.md — mi tortent az elozo session-ben

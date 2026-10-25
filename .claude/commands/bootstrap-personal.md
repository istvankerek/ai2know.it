---
name: bootstrap-personal
description: Personal scope (~/.claude/) setup wizard – cross-project konfig, sajat shortcuts, tanulasok
---

# /project:bootstrap-personal

Personal scope setup wizard. A `~/.claude/` mappa felepitese, ami minden projekt-en
osztozva mukodik (cross-project memory, shortcuts, tanulsagok).

## Mire valo

A **Two-Scope architektura** (v6.3) ket szintet hasznal:

| Scope    | Path           | Tartalom                                   |
|----------|----------------|--------------------------------------------|
| Project  | `.claude/`     | Csapat-szintu (commit-elt): rules, commands, skills, identity, memory, workflows, routines |
| Personal | `~/.claude/`   | Cross-project, sajat: shortcuts, tanulsagok, kedvenc commands, sajat agent-ek |

A wizard a **Personal** szintet allitja be — a fejleszto sajat gepen.

## Wizard kerdesek

A skill kerdez (1 valasz / kerdes, NE batch):

### 1. Megszolitas
- Mi a neved? (Pl. "István")
- Tegezol vagy magazol a Claude-ot? (alapertelmezett: tegezes)
- Idozona? (alapertelmezett: Europe/Budapest)
- Munkaido? (alapertelmezett: 09:00-17:00)

### 2. Anti-patterns
- Volt-e mar olyan, amikor a Claude rosszat csinalt? (3 pelda – ezt a `~/.claude/agent-memory/learnings.md`-ba menti)
- Mit utalsz a hangnemen / valaszstilon? (anti-style.md ekvivalens, sajat verzio)

### 3. Cross-project shortcut-ok
- Van-e olyan command amit minden projekt-en hasznalni szeretnel? (pl. `/jegyzeteltem` – bejegyzi a sajat naplodba)
- Van-e olyan skill ami minden projekt-en kell?

### 4. Multi-CLI preferenciak (v6.4)
- Hasznalsz mas CLI-t is? (claude / codex / gemini / mind a 3?)
- Melyik az alapertelmezett?

## Setup output

A wizard letrehozza:

```
~/.claude/
├── CLAUDE.md                  # Cross-project sajat instrukciok
├── settings.json              # Personal scope settings (env, hooks)
├── commands/                  # Sajat commands (cross-project)
│   └── jegyzeteltem.md
├── skills/                    # Sajat skills (cross-project)
├── agents/                    # Sajat ~/.claude/ agentek
├── agent-memory/
│   ├── learnings.md           # Tanulasaim (anti-patterns, sikeres megoldasok)
│   ├── patterns.md            # Megfigyelt mintak
│   └── projects.md            # Projekt-jegyzet (mit csinalok hol)
├── identity/
│   └── personal-voice.md      # Sajat hangnem-preferenciak
└── output-styles/             # Sajat output-style preset-ek
```

## Merge szabalyok (project + personal)

A Claude Code _automatikusan merge-eli_ a ket scope-ot:

| Beallitas       | Merge szabaly                          |
|-----------------|----------------------------------------|
| `permissions.allow` | UNION (mindketto allow-ja erveny) |
| `permissions.deny`  | UNION (mindketto deny-je erveny) |
| `env`           | personal felulirja project-et          |
| `hooks`         | mindkettő futnak (project elobb, personal utana) |
| `commands/`     | nev-utkozes: project nyer (override-olhato) |
| `skills/`       | nev-utkozes: project nyer              |

## Mikor NE futtass

- Ha mar van `~/.claude/` config (eloszor mentsd el!)
- Ha vendegszamitogepen vagy
- Ha a fejleszto NEM ezen a gepen szandekszik fejleszteni (laptop vs munka-PC)

## Kovetkezmenyek

- A `~/.claude/CLAUDE.md` minden projekt-en betoltodik (project CLAUDE.md ELOTT)
- A sajat skill-ek minden projekt-en aktivalodnak (ahol illik)
- A sajat tanulasok (`learnings.md`) megorzodnek session-ok kozott
- A `bootstrap-project --level N` (v6.3 dokumentalva, nem implementalva) hasznalhatja
  ezt a setup-ot kovetkezo projekt-letrehozasnal

## Forras
- v6.3 Two-Scope spec: `specification/skeleton-specifications/everengine-v6.3-patch-two-scope.md`
- v7.0 master PART 1, Section 4-7

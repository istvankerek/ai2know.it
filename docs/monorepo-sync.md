# Monorepo + Sync Script — Megosztott skill-ek kezelese

> **Forras:** [specification/everengine-v2.3.3-shared-management.md](../specification/everengine-v2.3.3-shared-management.md)
> **Statusz:** Reference dokumentum — a skeleton egy projekt template, NEM monorepo. Ez az utmutato azoknak szol, akik tobb Everengine-alapu projektet egy monorepo alatt akarnak kezelni.

## Problema

Ha tobb Everengine projekted van (pl. aiBOS, JourneyFlow, SkillPass.ID), akkor a `.claude/skills/`, `.claude/rules/`, `.claude/hooks/` kb. 60%-a **azonos** minden projektben. Egyetlen skill frissitese jelenleg 3 helyen igenyel modositast.

## Megoldasi opciok osszehasonlitasa

| Szempont | Symlink | Git Submodule | NPM Package | Monorepo | **Monorepo + Sync** |
|----------|---------|---------------|-------------|----------|-------------------|
| Egy helyen frissites | ✅ Azonnal | ⚠️ Pull kell | ⚠️ Update kell | ✅ Azonnal | ✅ Azonnal |
| Reprodukalhatosag | ❌ | ✅ | ✅ | ✅ | ✅ |
| Docker kompatibilitas | ❌ | ✅ | ✅ | ✅ | ✅ |
| CI/CD | ❌ | ⚠️ Bonyolult | ✅ | ✅ | ✅ |
| Mas gepen is mukodik | ❌ | ✅ | ✅ | ✅ | ✅ |
| Onallo deploy | ❌ | ✅ | ✅ | ⚠️ | ✅ |
| Verziokezeles | ❌ | ✅ commit hash | ✅ semver | ✅ tag | ✅ VERSION fajl |
| Rollback | ❌ | ✅ | ✅ | ✅ | ✅ |
| Claude Code kompatibilis | ⚠️ | ⚠️ | ✅ | ✅ | ✅ |
| Fejlesztoi egyszeruseg | ✅ | ❌ | ⚠️ | ✅ | ✅ |
| Setup komplexitas | Alacsony | Kozepes | Magas | Kozepes | Kozepes |

**Ajanlas:** ⭐⭐ Monorepo + Sync Script — a legjobb kompromisszum.

## Ajanlott strukturanak

```
everengine/                              # Git repo gyoker
│
├── packages/
│   └── claude-shared/                   # ⭐ SINGLE SOURCE OF TRUTH
│       ├── VERSION                      # Pl. "3.0.0"
│       ├── CHANGELOG.md
│       ├── skills/                      # 68 skill
│       ├── rules/                       # 7 szabaly
│       ├── hooks/                       # 9 hook script
│       ├── agents/                      # 5 subagent
│       ├── output-styles/
│       ├── commands/shared/             # Kozos slash commandok
│       ├── runbooks/
│       ├── prompts/
│       ├── monitoring/                  # Prometheus, Grafana
│       ├── scripts/shared/
│       └── ag-grid-config/
│
├── projects/
│   ├── aibos/                           # Onallo, deployolhato
│   │   ├── CLAUDE.md                    # Projekt-specifikus
│   │   ├── .claude/
│   │   │   ├── settings.json            # Projekt-specifikus
│   │   │   ├── skills/                  # ← sync-bol jon
│   │   │   ├── rules/                   # ← sync-bol jon
│   │   │   └── commands/
│   │   │       ├── review.md            # ← sync (kozos)
│   │   │       └── deploy.md            # ← projekt-specifikus
│   │   ├── apps/
│   │   ├── docker/
│   │   └── environments/
│   │
│   ├── journeyflow/
│   └── skillpass/
│
├── scripts/
│   └── sync-shared.sh                   # Szinkronizalo script
├── .github/workflows/sync-shared.yml    # CI/CD auto-sync
├── turbo.json                           # Turborepo (opcionalis)
└── Makefile
```

## Szinkronizalasi logika

A `sync-shared.sh` script **3 szintu** felulirasi logikaval dolgozik:

### 1. `--delete` (teljes felulirás)
- **Mit:** `skills/`, `rules/`, `hooks/`, `agents/`, `output-styles/`, `runbooks/`, `ag-grid-config/`
- **Szabaly:** A shared verzio **MINDIG nyer**
- **Projekt-specifikus skill:** Tedd a `packages/claude-shared/skills/project-specific/{project}/` ala, a sync script ide masolja csak az adott projektbe

### 2. `--ignore-existing` (csak uj fajlok)
- **Mit:** `commands/`, `scripts/`
- **Szabaly:** NEM irja felul a projekt-specifikus command-okat, csak a kozoseket adja hozza

### 3. Soha nem szinkronizalt
- **Mit:** `CLAUDE.md`, `settings.json`, `.mcp.json`, `apps/`, `docker/`, `docs/adr/`, `environments/`
- **Szabaly:** Ezekhez a sync script **SOHA nem nyul**

## sync-shared.sh minta (kivonat)

```bash
#!/bin/bash
set -euo pipefail

SHARED_DIR="packages/claude-shared"
PROJECTS_DIR="projects"
PROJECTS=${1:-$(ls "$PROJECTS_DIR")}

for project in $PROJECTS; do
    PROJECT_DIR="$PROJECTS_DIR/$project"
    [ ! -d "$PROJECT_DIR" ] && continue

    # 1. szint — felulirasos sync
    rsync -av --delete "$SHARED_DIR/skills/" "$PROJECT_DIR/.claude/skills/"
    rsync -av --delete "$SHARED_DIR/rules/" "$PROJECT_DIR/.claude/rules/"
    rsync -av --delete "$SHARED_DIR/hooks/" "$PROJECT_DIR/.claude/hooks/"
    chmod +x "$PROJECT_DIR/.claude/hooks/"*.sh

    # 2. szint — csak uj fajlok hozzaadasa
    rsync -av --ignore-existing "$SHARED_DIR/commands/shared/" "$PROJECT_DIR/.claude/commands/"
    rsync -av --ignore-existing "$SHARED_DIR/scripts/shared/" "$PROJECT_DIR/scripts/"
done
```

A teljes scriptet lasd: [specification/everengine-v2.3.3-shared-management.md](../specification/everengine-v2.3.3-shared-management.md) §5.

## Makefile parancsok

```makefile
sync:            ## Minden projekt szinkronizalasa
	./scripts/sync-shared.sh

sync-%:          ## Egy projekt: make sync-aibos
	./scripts/sync-shared.sh $*

sync-check:      ## Eltereses ellenorzes
	./scripts/sync-check.sh
```

## CI/CD auto-sync (GitHub Actions)

```yaml
name: Sync Shared to Projects
on:
  push:
    paths: ['packages/claude-shared/**']
    branches: [main]
jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Sync shared files
        run: ./scripts/sync-shared.sh
      - name: Commit & Push
        run: |
          git config user.name "Everengine Bot"
          git config user.email "bot@everengine.hu"
          git add -A
          git diff --cached --quiet || git commit -m "chore: auto-sync shared v$(cat packages/claude-shared/VERSION)"
          git push
```

## Napi hasznalat

```bash
# 1. Modositsd a megosztott skill-t
vim packages/claude-shared/skills/code-review/SKILL.md

# 2. Verzio bump
echo "3.0.1" > packages/claude-shared/VERSION

# 3. Sync minden projektbe
make sync

# 4. Commit
git add -A
git commit -m "feat(shared): code-review skill v3.0.1"
```

## Mikor NE hasznald

- **Ha csak 1 projekted van** — overkill, tartsd meg a sima skeleton-t
- **Ha a projektjeid teljesen fuggetlenek** — nincs megosztott komponens
- **Ha eltero Claude Code verzioknak akarod hasznalni** — a shared nehez, mert a verziokezeles nem egyszeru

## Kapcsolodo

- Teljes spec: [specification/everengine-v2.3.3-shared-management.md](../specification/everengine-v2.3.3-shared-management.md)
- v3.0 master: [specification/everengine-v3.0-master.md](../specification/everengine-v3.0-master.md) Section X

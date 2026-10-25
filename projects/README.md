# Projects Registry

> Az Everengine skeleton-t hasznalo projektek nyilvantartasa.
> A `sync.sh` ezt a registry-t hasznalja a projektek frissitesere.
> v7.4 patch atnevezte: `deployed/` → `projects/`.

## Fajlok

- `projects.list` — Plain text registry (pipe-separated: `NAME | PATH | DEPLOYED_VERSION`)
- `<name>.md` — per-projekt metadata (frontmatter + leiras)
- `README.md` — ez a fajl

## Hasznalat

### Lista megtekintese
```bash
cat projects/projects.list
ls projects/*.md
```

### Projekt frissitese skeleton verzioval
```bash
./sync.sh --yes --project <NAME>          # Verzio match check + frissites
./sync.sh --yes --force --project <NAME>  # Force update (akar 7.7.0 -> 7.7.0)
./sync.sh --dry-run --project <NAME>      # Csak listazas, nem ir
```

### Uj projekt hozzaadasa

1. **Add a `projects.list`-hez:**
   ```
   <NAME> | <FULL_PATH> | 7.7.0
   ```

2. **Hozz letre `projects/<NAME>.md`-t** (lasd template: barmelyik meglevo file)

3. **Sync first time:**
   ```bash
   cd <FULL_PATH>
   [ ! -d .git ] && git init
   cd /Users/everengine/Documents/dev/skeleton
   ./sync.sh --yes --force --project <NAME>
   ```

## Mit szinkronizal a sync.sh

**Megosztott (mindig frissul):**
- `.claude/skills/`, `.claude/rules/`, `.claude/hooks/`, `.claude/commands/`, `.claude/agents/`
- `.claude/identity/`, `.claude/memory/`, `.claude/workflows/`, `.claude/routines/`
- `.claude/output-styles/` (ha letezik)
- `.aios-cli/{core,adapters/{claude,codex,gemini},scripts,skills}/`
- `tests/skeleton-validation/` (v7.4)
- `docs/onboarding/` (v7.3), `docs/runbooks/`, `docs/compliance/`
- `tools/prompts/`
- `experiments/{failed-ideas,prototypes}/`
- `infrastructure/chaos/`, `infrastructure/monitoring/sli-slo.yml`
- `scripts/*.sh` (15+ script)
- `.worktreeinclude`, `requirements-data-analyst.txt`
- `docs/{adr,postmortems}/TEMPLATE.md`

**Projekt-specifikus (NEM sync-elodik):**
- `CLAUDE.md`, `CLAUDE.local.md`, `README.md` — projekt instrukciok
- `.claude/settings.json` — Claude Code konfig (manualis merge szukseges!)
- `.mcp.json` — MCP server konfig (projekt-specifikus)
- `apps/`, `src/`, `services/`, `crates/` — alkalmazas kod
- `tests/{unit,integration,e2e}/` — projekt tesztek
- `tasks/` — feladatkezeles
- `environments/.env.*` — env fajlok
- `config/` — projekt konfig
- `migrations/` — DB migraciok
- `infrastructure/{caddy,cloudflare}/` — projekt-specifikus infra
- `Makefile`, `COORDINATION.md` — projekt docs
- `.skeleton-version` — deployed verzio marker (sync.sh frissiti)

## Per-projekt metadata `.md` formatum

```markdown
---
name: <project-name>
path: <absolute-path>
deployed_version: 7.7.0
type: existing|new
status: synced|bootstrapped|needs-merge|production
last_sync: 2026-06-14
github_remote: <url> | nincs
---

# <Project Name>

## Cel
<1 mondat>

## Tech stack
- Backend: ...
- Frontend: ...

## Status notes
<frissites datum + megjegyzes>

## Skeleton komponensek
- skeleton komponensek listaja amelyeket hasznal
```

## Type es Status

| Type | Mit jelent |
|------|-----------|
| `existing` | Mar mukodo projekt skeleton-bol |
| `new` | Frissen bootstrap-pelt projekt |

| Status | Mit jelent |
|--------|-----------|
| `synced` | Frissitve a registry-ben definialt verzioval |
| `bootstrapped` | Initial sync futtatva (frissen kiegeszitve) |
| `needs-merge` | Saját content-tel rendelkezik, careful sync szukseges |
| `production` | Production deployment-ben |

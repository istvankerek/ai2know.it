# ai2know.it

> Everengine projekt – v8.0 skeleton (AIOS shared kernel + orchestrator + SkillPass.ID / aibos.space ökoszisztéma)

## Strukturalis View (5-reteg, AgentDevKit)

```
ai2know.it/
├── CLAUDE.md         ← Layer 1: Claude Memory
├── AGENTS.md         ← Codex project instructions
├── .claude/skills/   ← Layer 2: Knowledge    (provide expertise)
├── .claude/hooks/    ← Layer 3: Guardrail    (enforce quality)
├── .claude/agents/   ← Layer 4: Delegation   (delegate work)
├── .codex/agents/    ← Codex fast/worker/deep agents
└── .claude/plugins/  ← Layer 5: Distribution (distribute to team)
```

Plus Everengine-specifikus retegek:

```
├── .claude/identity/    ← Brand & Identity (v6.1)
├── .claude/memory/      ← RAD memory architecture (v6.5)
├── .claude/workflows/   ← Multi-step YAML recipes (v6.5)
├── .claude/routines/    ← Cloud automation (v5.6)
├── .codex/              ← Codex project config (v7.6)
└── .aios-cli/     ← Multi-CLI shared kernel (v6.4+)
```

## Projekt artifacts

```
├── apps/                  # Frontend, admin, backend, ai-chat
├── docker/                # 7 compose fajl
├── infrastructure/        # Caddy, Cloudflare, Monitoring
├── docs/                  # ADR, Runbooks, Onboarding (ket-view)
└── scripts/               # Egyparancs scriptek
```

## Quick start (5 lepes)

```bash
# 1. Repo klonozas
git clone {{REPO_URL}} && cd ai2know.it

# 2. Kornyezeti valtozok
cp environments/.env.example environments/.env.local

# 3. Docker dev kornyezet
make local

# 4. Tesztek
make test

# 5. CLAUDE.md olvasas (Layer 1, 9 Aranyszabaly)
cat CLAUDE.md
```

## Elofeltetelek

- Docker + Docker Compose
- Node.js 20+
- Rust toolchain (rustup)
- Claude Code CLI: `npm i -g @anthropic-ai/claude-code`
- Codex CLI: `npm i -g @openai/codex`

## Tech Stack

| Reteg | Technologia |
|-------|-------------|
| Frontend | Vite 6, React Router v7, TypeScript, Tailwind, shadcn/ui |
| Admin | Vite 6, React Router v7, AG Grid Enterprise |
| Backend | Rust/Axum |
| DB | PostgreSQL, MongoDB, Redis |
| Queue | NATS JetStream |
| Gateway | Caddy + Cloudflare |
| Auth | SkillPass.ID (OAuth2/OIDC), admin: aibos.space |
| Monitoring | Prometheus, Grafana, Loki |

## Fejlesztoi parancsok

```bash
make local          # Docker dev kornyezet
make test           # Minden teszt
make lint           # Lint + format
make migrate        # DB migracio
make backup         # Manualis backup

make deploy ENV=local   # Lokalis deploy
make deploy ENV=test    # Teszt deploy
make deploy ENV=prod    # Produkcio (L1 jovahagyas!)
```

## Codex / Claude workflow

- Komplex munka: `specification/plan-vN/` mappa, fazisonkenti Markdown terv.
- Elfogadott terv utan implementacio, majd fazisonkenti visszaellenorzes.
- Unit/validation utan git save point, non-prod deploy, smoke, javitas ha kell.
- Codex default fast-first: `gpt-5.3-codex`; deep review csak security/prod/architecture.

## Uj projekt bootstrap

```bash
# Skeleton-bol uj projekt scaffold-olas
bash scripts/create-project.sh \
  --name "MyApp" \
  --domain "myapp.hu" \
  --repo "https://github.com/user/repo.git" \
  --target "/path/to/new-project"
```

## Deeper dive (developer onboarding)

- **Day 1-7 (strukturalis view):** [docs/onboarding/two-view-approach.md](docs/onboarding/two-view-approach.md)
- **Week 2-4 (filozofiai view):** v6.0–v6.5 evolucio, see `CLAUDE.md` "A 6 dimenzio" szekcio
- **Hivatkozott:** `specification/skeleton-specifications/everengine-v7.3-*.md`, `specification/plan-v10/`

## Dokumentacio

- [Architektura](docs/architecture.md)
- [API Referencia](docs/api-reference.md)
- [Onboarding (ket-view)](docs/onboarding/two-view-approach.md)
- [ADR-ek](docs/adr/)
- [Runbooks](docs/runbooks/)

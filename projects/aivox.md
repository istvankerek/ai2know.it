---
name: aivox
path: /Users/everengine/Documents/dev/aivox
deployed_version: 8.0.0
type: new
status: bootstrapped
last_sync: 2026-10-13
github_remote: nincs
---

# aivox

## Cel
Teljesen lokalis (Apple Silicon M3 Ultra) AI hangoskonyv- es beszelofejes-video studio: PDF/EPUB + instrukcio -> tobbszereplos, tobbnyelvu (magyar elsodleges, vegyes nyelv) hangoskonyv es video, karaktervarazsloval (foto, hangminta, szemelyiseg).

## Tech stack
- Backend: Rust/Axum API + Python (FastAPI) ML worker-ek (MLX / PyTorch MPS)
- Frontend: Vite 6, React Router v7, TypeScript, Tailwind, shadcn/ui
- DB/Queue: PostgreSQL, Redis, NATS JetStream
- LLM: lokalis (Ollama / MLX-LM)

## Status notes
- 2026-10-13: skeleton 8.0.0 initial bootstrap (install.sh), plan-v0 specifikacio

## Skeleton komponensek
- Teljes `.claude/` framework, `.aios-cli/`, `tests/skeleton-validation/`

## Next steps
1. plan-v0 elfogadasa
2. git init + github remote
3. Phase 0 implementacio

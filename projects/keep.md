---
name: keep
path: /Users/everengine/Documents/dev/keep
deployed_version: 8.0.0
type: new
status: bootstrapped
last_sync: 2026-10-14
github_remote: nincs
---

# keep

## Cel
KEEP / EverKeep: local-first, zero-knowledge agent-munkaallomas es csapat-platform (Rust keepd + Python MLX/CUDA workerek + Tauri kliens, kesobb hub). GENESIS strukturalo rendszer (kep/strukturalatlan -> KEEP-MD -> DOCX/XLSX/PPTX/PDF/kep, javito UI + golden-set tanulas) es tobbgepes worker-flotta (Mac/Linux-GPU/Windows, hub nelkul is).

## Tech stack
- Mag: Rust (axum/tonic/tokio), CozoDB + tantivy, Cedar, loro CRDT, wasmtime
- Workerek: Python (uv) MLX / CUDA / CPU – genesis-local atemeles (doc/ocr/vision/embed/translate/core + uj render/office/codeexec)
- Kliens: Tauri v2 + React/TS (shadcn/ui); Hub (F5+): Rust/Axum + PostgreSQL/Redis/MinIO/Qdrant + Next.js admin

## Status notes
- 2026-10-14: skeleton 8.0.0 initial bootstrap (install.sh)
- 2026-10-14: plan-v0 megirva (F0–F6 + architektura + quality-ops), owner jovahagyasra var

## Skeleton komponensek
- Teljes `.claude/` framework, `.aios-cli/`, `tests/skeleton-validation/`

## Next steps
1. plan-v0 elfogadasa (open-questions Q-06: worker-gepek listaja)
2. git init + github remote
3. F0 alapozas (genesis-local crate/worker import, keepd, keep doctor, CI)

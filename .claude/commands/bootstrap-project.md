# Teljes Projekt Scaffold

Inicializald a teljes projektet a v8.0 skeleton alapjan (okoszisztema: skillpass.id + aibos.space).

## Lepesek

0. **Okoszisztema kerdesek** (AskUserQuestion, lasd `.aios-cli/core/ecosystem.md`):
   - Van bejelentkezo felhasznalo? → `skillpass-auth` (SkillPass.ID OIDC kliens, BFF). Sajat auth TILOS.
   - Van ugyfel-/tagi felulet? → `skillpass-portal` + `skillpass-app-launcher`, sablon: `templates/portal/`.
     Fiok-felulet szabvany (D-V16-08): shell csak `/fiok` alatt vagy az egesz belepett feluleten? Melyik helyi
     szekciok kellenek a "Fiokom" alatt? (`templates/portal/lib/shell/shell-manifest.ts`)
   - Kell kezelofelulet (CRUD, riport, beallitas)? → `aibos-admin-contract`, sablon:
     `templates/admin-contract/`; az admin UI az aibos.space konzolban epul.
   - Milyen M2M scope-ok kellenek (pl. `trainings:write`)? Legszukebb jogosultsag.
   - Penz / szamla / szallitas? → aibos services (`pay` / `invoice` / `delivery.aibos.space`).
   - A valaszokat rogzitsd a `projects/<nev>.md` `role`, `portal`, `admin` mezoiben (skeletonban).

1. **CLAUDE.md kitoltese**:
   - Csereld ki a {{PLACEHOLDER}}-eket a projekt adataival
   - Kerdezz vissza ha valami nem egyertelmu

2. **Kornyezet beallitas**:
   - `environments/.env.example` kitoltese a szukseges valtozokkal
   - `environments/.env.local` letrehozasa fejleszteshez

3. **Docker beallitas**:
   - `docker/docker-compose.yml` konfiguralas (PostgreSQL, MongoDB, Redis, NATS, MinIO, Qdrant, Caddy)
   - `docker/docker-compose.local.yml` dev overrides (hot reload, debug portok)
   - Teszteles: `make local && docker compose ps`

4. **Adatbazis inicializalas**:
   - `infrastructure/postgres/init/01-extensions.sql` — uuid-ossp, pgcrypto
   - `infrastructure/postgres/init/02-schemas.sql` — schema-per-service letrehozas

5. **Backend alapok**:
   - `apps/backend/Cargo.toml` fuggosegek (axum, tokio, sqlx, serde)
   - `apps/backend/src/main.rs` — Axum szerver beallitas
   - Middleware-ek implementalasa

6. **Frontend alapok**:
   - `apps/frontend/` — Vite + React Router v7 init, Tailwind, shadcn/ui
   - `apps/admin/` — Vite + React Router v7 admin init, AG Grid beallitas
   - Mindket app-hoz: index.html, vite.config.ts, src/main.tsx, src/root.tsx, src/routes.ts

7. **Git init**:
   - `git init && git add . && git commit -m "chore: bootstrap v2.3"`

8. **Skill telepites** (lasd: `.claude/skill-priority.md`):
   - **P0 – Core (15 skill)**: mindig automatikusan generalodik
   - **P1 – Standard (25 skill)**: kerdezd meg a felhasznalot melyiket kivanja
   - **P2 – Specialist (28 skill)**: NE generald most, kesobb hozzaadhato `/bootstrap {skill-name}` parancsal

## Fontos

- Kerdezz vissza mielott elkezded!
- Plan Mode hasznalata kotelzo!
- CLAUDE.md {{PLACEHOLDER}}-ek kitoltese elso lepes!

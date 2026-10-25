# ADR-001: Vite + React Router v7 valasztasa

## Allapot
Elfogadva (felulvizsgalva — korabban Next.js 14 volt)

## Kontextus
Kliens-oldali SPA elegseges mind a publikus, mind az admin felulethez.
A backend Rust/Axum kulon szolgaltatas, nincs szukseg Server Components-re.
A korabbi Next.js 14 dontest felulvizsgaltuk.

## Dontes
Vite 6 + React Router v7 (framework mode) mindket frontend alkalmazashoz.

## Indoklas
- Gyorsabb build (Vite vs Webpack/Turbopack)
- Egyszerubb mental model (nincs server/client hatar)
- React Router v7 stabil file-based routing
- shadcn/ui es AG Grid teljes Vite kompatibilitas
- react-i18next: erettebb kliens-oldali i18n (next-intl helyett)
- Nincs szukseg Vercel/Edge futtatokornyezetre
- Docker deployment egyszerubb (statikus fajlok + Caddy)

## Kovetkezmenyek
- Minden komponens kliens-oldali (nincs Server Components, nincs "use client")
- Adatlekeres: React Router loader-ek + TanStack Query
- i18n: react-i18next (nem next-intl)
- Build output: dist/ konyvtar — Caddy szolgalja ki
- Env valtozok: VITE_ prefix kotelzo kliens oldalon
- Route definicio: src/routes.ts + src/routes/ konyvtar

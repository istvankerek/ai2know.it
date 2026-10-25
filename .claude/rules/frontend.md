# Frontend Szabalyok

## Vite + React Router v7
- React Router v7 framework mode (file-based routing)
- Minden komponens kliens-oldali (NINCS Server Components)
- Route definicio: `src/routes.ts` + `src/routes/` konyvtar
- Layout-ok: `root.tsx` es nested layout route-ok
- Adatlekeres: React Router loader-ek + TanStack Query
- Navigacio: `<Link>`, `useNavigate()`, `useParams()`
- Entry point: `index.html` (projekt gyoker)
- Config: `vite.config.ts` (plugin: @vitejs/plugin-react)
- Build output: `dist/` konyvtar
- Dev server port: frontend 3000, admin 3001
- Env valtozok: `VITE_` prefix kotelezo kliens oldalon

## TypeScript
- strict mod kotelzo
- NINCS `any` — lasd: code-style.md
- Zod schema validacio API hivasokhoz

## Stilusok
- **Tailwind CSS** kizarolag — NINCS kulon CSS fajl
- **shadcn/ui** komponensek elsobbsege
- Design tokenek: `apps/admin/src/design-system/tokens.ts`
- Responsive: mobile-first megkozelites

## Admin Panel
- **shadcn/ui DataTable**: egyszeru listak, mobil-barat (SimpleList)
- **AG Grid Enterprise**: osszetett listak, 100K+ sor, pivot (AdvancedList)
- ListPage.tsx: Simple/Advanced ful valto
- ModuleConfig: `apps/admin/src/lib/crud-generator/modules/`
- Dinamikus route-ok: `$module`, `$module/$id` pattern

## i18n (react-i18next)
- Tamogatott nyelvek: HU, EN
- Forditas fajlok: `src/locales/{hu,en}/`
- Datum, penz, szam: `src/lib/i18n/localize.ts`
- UI szovegek: magyarul
- Hook: `useTranslation()` komponensekben

## TF.js
- Browser-side intelligencia (apps/admin/src/lib/tf-admin-intelligence.ts)
- Modell fajlok: `apps/admin/src/models/`
- Adaptiv menu, szint joslas

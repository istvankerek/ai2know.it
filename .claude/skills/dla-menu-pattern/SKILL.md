---
name: dla-menu-pattern
description: >
  DLA (Dashboard / List / Add) menu struktura es URL pattern minden modulnal.
  /{module}/{dashboard|list|add|[id]} URL-ek, redirect oldal, loading.tsx
  skeleton-ek, dark mode classok. SOHA /new — mindig /add. SOHA kulon
  /:id/view es /:id/edit — egyetlen [{id}] inline edit-tel.
  Triggerek: "uj modul", "DLA", "menu struktura", "list page",
  "dashboard page", "add page", "edit page", "URL struktura",
  "menuConfig", "loading skeleton", "dark mode component".
license: Everengine v7.0
priority: P2
model: claude-sonnet-4-6
related_skills:
  - crud-dla-module
  - crud-generator
  - skeleton-loading
  - frontend-design
related_rules:
  - .claude/rules/frontend.md
  - .claude/rules/module-implementation.md
---

# DLA Menu Pattern — egyseges navigacio minden modulnal

> **Ökoszisztéma (v8.0):** a DLA URL szabályok az aibos.space konzolban (MenuCategory → MenuApp →
> MenuSub, minden menüpont permissionnel, soha nem 404) és a skillpass.id Account Centerben
> érvényesek. Partner projekt nem épít saját admin menüt (`aibos-admin-contract`).

## DLA elnevezes
**D**ashboard / **L**ist / **A**dd. Ez a 3 alap-oldal minden modulnak,
plusz egyetlen detail (`[{id}]`) oldal inline szerkesztessel.

## URL struktura (kotelezo)

```
/{module}/                  → 301 redirect /{module}/dashboard
/{module}/dashboard         → KPI grid + recent items
/{module}/list              → kereses + szures + lapozas + tablazat
/{module}/add               → letrehozo form (NEM /new!)
/{module}/[{id}]            → detail + inline edit (NEM /:id/view + /:id/edit!)
```

## Mappastruktura (Next.js App Router)

```
src/app/(app)/{module}/
  page.tsx              → redirect → dashboard
  dashboard/
    page.tsx            → 4 stat card + 5-10 recent item
    loading.tsx         → StatGridSkeleton + TableSkeleton
  list/
    page.tsx            → keresheto / szurheto / lapozott tablazat
    loading.tsx         → PageHeaderSkeleton + TableSkeleton
  add/
    page.tsx            → form
    loading.tsx         → FormSkeleton
  [{id}]/
    page.tsx            → detail + inline edit
    loading.tsx         → DetailSkeleton
```

## menuConfig.ts regisztracio

### APPS Record
```typescript
{module}: {
  id: "{module}",
  labelKey: "app.{module}",
  icon: {LucideIcon},        // CSAK lucide-react
  color: "#{hex}",
  href: "/{module}/dashboard",
  subs: [
    { id: "overview", labelKey: "sub.overview", href: "/{module}/dashboard", icon: LayoutDashboard },
    { id: "list",     labelKey: "sub.{module}.list", href: "/{module}/list", icon: {ListIcon} },
    { id: "add",      labelKey: "sub.{module}.add", href: "/{module}/add", icon: FilePlus2 },
  ],
},
```

⚠️ `id: "add"` (NEM `"new"`) es `href: "/{module}/add"` (NEM `/new`).

### CATEGORIES tomb
```typescript
{ id: "kategoria_id", labelKey: "cat.kategoria", icon: Icon, color: "#hex",
  apps: [..., APPS.{module}] },
```

### resolveActiveApp() bovites
```typescript
if (pathname.startsWith("/{module}")) return "{module}";
```

## Redirect oldal sablon

`src/app/(app)/{module}/page.tsx`:
```tsx
"use client";
import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function {Module}Page() {
  const router = useRouter();
  useEffect(() => { router.replace("/{module}/dashboard"); }, [router]);
  return null;
}
```

## Loading skeleton matrix

| Oldal | loading.tsx tartalma |
|-------|---------------------|
| dashboard | `<StatGridSkeleton />` + `<TableSkeleton />` |
| list      | `<PageHeaderSkeleton />` + `<TableSkeleton />` |
| add       | `<FormSkeleton />` |
| [{id}]    | `<DetailSkeleton />` |

```tsx
import { StatGridSkeleton, TableSkeleton } from "@/components/Skeleton";

export default function Loading() {
  return (
    <div className="space-y-6">
      <StatGridSkeleton />
      <TableSkeleton cols={5} rows={8} />
    </div>
  );
}
```

## Dark mode kotelezo (light + dark variants)

| Elem | Light + Dark |
|------|--------------|
| Oldal hatter | `bg-gray-50 dark:bg-[#13141a]` |
| Kartya hatter | `bg-white dark:bg-[#1a1b23]` |
| Keret | `border-gray-200 dark:border-[#2a2b36]` |
| Szoveg | `text-gray-900 dark:text-gray-100` |
| Halvany szoveg | `text-gray-500 dark:text-gray-400` |
| Tablazat fejlec | `bg-gray-50 dark:bg-[#13141a]` |
| Hover sor | `hover:bg-gray-50 dark:hover:bg-[#13141a]` |
| Elvalaszto | `divide-gray-100 dark:divide-[#2a2b36]` |
| Input bg | `bg-white dark:bg-[#13141a]` |
| Status badge | `bg-{c}-100 text-{c}-700 dark:bg-{c}-900/30 dark:text-{c}-300` |
| Arnyek | `shadow-sm dark:shadow-none` |

⚠️ MINDEN komponensen kotelezo a `dark:` variant.

## Detail oldal — inline edit (NEM kulon /view + /edit)

```tsx
// [{id}]/page.tsx
const [editing, setEditing] = useState(false);
const { data, refetch } = useQuery(["entity", id], () => get{Entity}(id));

return (
  <div>
    {editing ? (
      <EntityForm initial={data} onSave={async (d) => {
        await update{Entity}(id, d);
        setEditing(false);
        refetch();
      }} />
    ) : (
      <EntityDetail data={data} onEdit={() => setEditing(true)} />
    )}
  </div>
);
```

## Tiltasok

❌ `/new` URL az add oldalhoz (mindig `/add`)
❌ Kulon `/:id/view` es `/:id/edit` route-ok (egyetlen `[{id}]` inline edit)
❌ Hardcoded magyar/angol szoveg (mindig `t()` — lasd `i18n-required` skill)
❌ Loading state nelkul (kotelezo `loading.tsx`)
❌ Dark mode nelkuli komponens (mindig `dark:` variant)
❌ MUI / Material UI / Bootstrap (KIZAROLAG shadcn/ui + Tailwind)
❌ Custom icon library (KIZAROLAG `lucide-react`)
❌ Empty state ikon nelkul ("Nincs talalat" + ikon kotelezo)

## Hivatkozott
- Master skill: `crud-dla-module` (10. szekcio: DLA oldalak)
- Sister skill: `frontend-design` (shadcn/ui + Tailwind best practice)
- Sister skill: `skeleton-loading` (loading components)
- Rules: `.claude/rules/frontend.md` (Vite + React Router + shadcn)

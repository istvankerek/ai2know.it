---
name: skeleton-loading
description: >
  Skeleton/shimmer loading pattern, loading waterfall, progressive
  data loading, optimistic UI, suspense boundary-k.
  Triggerek: "skeleton", "loading", "shimmer", "betoltes", "waterfall",
  "suspense", "optimistic".
  NE hasznald: error handling, empty state, uzleti logika.
model: claude-haiku-4-5-20251001
---

# Skeleton Loading

## Felelossegek
- Skeleton komponensek (card, table row, form, dashboard widget)
- Loading waterfall minta (prioritasos betoltes)
- Optimistic UI (mentes kozben mar mutatja az eredmenyt)
- Progressive loading (hero -> sidebar -> widgets -> reszletek)
- Shimmer animacio (CSS-only, nem JS)
- Error boundary-k (loading hiba kezeles)
- Empty state komponensek (nincs adat)

## Helyes output pelda

```tsx
// apps/admin/src/components/ui/skeleton.tsx
import { cn } from '@/lib/utils';

/**
 * Alap skeleton komponens shimmer animacioval.
 * CSS-only (nincs JS), Tailwind animate-pulse hasznalata.
 */
export function Skeleton({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn('animate-pulse rounded-md bg-muted', className)}
      aria-busy="true"
      aria-live="polite"
      {...props}
    />
  );
}

export function UserCardSkeleton() {
  return (
    <div className="flex items-center space-x-4 p-4">
      <Skeleton className="h-12 w-12 rounded-full" />
      <div className="space-y-2">
        <Skeleton className="h-4 w-[250px]" />
        <Skeleton className="h-4 w-[200px]" />
      </div>
    </div>
  );
}
```

```tsx
// apps/admin/src/routes/users/list.tsx
import { Suspense } from 'react';
import { Await, useLoaderData } from 'react-router';

import { UserCardSkeleton } from '@/components/ui/skeleton';
import { UserList } from './UserList';

import type { LoaderData } from './loader';

export default function UsersListPage() {
  const { usersPromise } = useLoaderData() as LoaderData;

  return (
    <div>
      <h1>Felhasznalok</h1>
      <Suspense fallback={<UserListSkeleton count={10} />}>
        <Await resolve={usersPromise} errorElement={<ErrorState />}>
          {(users) => <UserList users={users} />}
        </Await>
      </Suspense>
    </div>
  );
}

function UserListSkeleton({ count }: { count: number }) {
  return (
    <div className="divide-y">
      {Array.from({ length: count }).map((_, i) => (
        <UserCardSkeleton key={i} />
      ))}
    </div>
  );
}
```

## Helytelen output pelda (NE csinald igy)

```tsx
// ❌ "Loading..." szoveg skeleton helyett (layout shift!)
{isLoading ? <p>Loading...</p> : <UserList users={users} />}

// ❌ Spinner a teljes oldalra (rossz UX)
{isLoading && <FullPageSpinner />}

// ❌ JS-alapu shimmer (useEffect + setInterval)
useEffect(() => {
  const id = setInterval(() => setOpacity((o) => o + 0.1), 50);
  return () => clearInterval(id);
}, []);

// ❌ Skeleton ami nem hasonlit a valos layout-ra (layout shift!)
<Skeleton className="h-20 w-full" />  // a valodi kartya 12rem, nem 20
```

## Szabalyok
1. Skeleton alakja KOTELEZO hogy megfeleljen a valos komponens layout-janak (nincs layout shift)
2. Shimmer CSS-only (`animate-pulse` vagy keyframes), SOHA JS-alapu
3. `aria-busy="true"` es `aria-live="polite"` accessibility miatt
4. Suspense + `<Await>` minta React Router v7-ben (NEM `isLoading` flag)
5. Loading waterfall: hero -> sidebar -> widgets -> reszletek (prioritas)
6. Error boundary (`errorElement`) minden `<Await>` korul
7. Optimistic UI: `useOptimistic` hook mentes elott mar mutatja az eredmenyt

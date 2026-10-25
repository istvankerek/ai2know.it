# Route váz – Next.js App Router portál sablon

> Forrás: `skillpass` repo @ `24048cd` (2026-10-06)

## Ajánlott könyvtárstruktúra

```
app/
  [locale]/
    layout.tsx                ← ShellProvider + WorkspaceShell beágyazás
    page.tsx                  ← redirect → /[locale]/dashboard
    (portal)/                 ← route group (közös shellel)
      dashboard/
        page.tsx
        loading.tsx
      trainings/
        page.tsx
        loading.tsx
        [id]/
          page.tsx
          loading.tsx
    auth/                     ← BFF auth útvonalak (nincs shell)
      login/
        route.ts              ← GET: redirect → Hydra authorize
      callback/
        route.ts              ← GET: code csere, cookie set
      refresh/
        route.ts              ← POST: refresh token rotáció
      logout/
        route.ts              ← GET: Hydra + Kratos session zárás

middleware.ts                 ← locale detect + auth guard
```

## layout.tsx (gyökér)

```tsx
import { getShellContext } from "@/lib/skillpass-shell";
import { cookies } from "next/headers";
import { WorkspaceShell, ShellProvider } from "@skillpass/workspace-shell";
import "@skillpass/workspace-shell/shell.css";

export default async function RootLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const session = await getSession(cookies());

  // Ha nincs session, a middleware már átirányított /auth/login-ra
  const shellResult = session
    ? await getShellContext(session.sub, locale as "hu" | "en")
    : null;

  const context = shellResult?.status === "ok" ? shellResult.value : null;

  return (
    <html lang={locale}>
      <body>
        <ShellProvider locale={locale as "hu" | "en"}>
          {context ? (
            <WorkspaceShell context={context} theme="light">
              {children}
            </WorkspaceShell>
          ) : (
            <main>{children}</main>
          )}
        </ShellProvider>
      </body>
    </html>
  );
}
```

## middleware.ts

```typescript
import { NextRequest, NextResponse } from "next/server";

const PUBLIC_PATHS = ["/auth/login", "/auth/callback", "/auth/logout"];

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // Publikus útvonalak átengedése
  if (PUBLIC_PATHS.some((p) => pathname.includes(p))) {
    return NextResponse.next();
  }

  // Session cookie ellenőrzés
  const session = req.cookies.get("sp_session");
  if (!session) {
    const loginUrl = new URL("/auth/login", req.url);
    loginUrl.searchParams.set("return_to", pathname);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"],
};
```

## loading.tsx skeleton minták

```tsx
// app/[locale]/(portal)/dashboard/loading.tsx
export default function DashboardLoading() {
  return (
    <div className="animate-pulse space-y-4 p-6">
      <div className="h-8 w-48 rounded bg-[--sp-bg-subtle]" />
      <div className="grid grid-cols-3 gap-4">
        {[1, 2, 3].map((i) => (
          <div key={i} className="h-32 rounded-[--sp-radius] bg-[--sp-bg-subtle]" />
        ))}
      </div>
    </div>
  );
}
```

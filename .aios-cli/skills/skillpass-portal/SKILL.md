---
name: skillpass-portal
description: >
  Ugyfelportal epites a SkillPass.ID workspace shell-lel. AppManifest /
  NavSection / NavItem / ShellContext tipusok, --sp- design tokenek
  (light/dark), route felépítés [locale]/(account)/..., WCAG akadálymentesség,
  i18n hu+en, Account Center deep linkek (profil, biztonsag, dokumentumok,
  szamlak — partner NEM epiti ujra). WorkspaceShell komponens beagyas.
  Triggerek: "portal", "ugyfelportal", "workspace shell", "skillpass shell",
  "AppManifest", "NavSection", "shell context", "sp token", "deep link",
  "account center", "sidebar", "shell integracio".
  NE hasznald: admin felulet epites (-> aibos-admin-contract),
  profil oldal epites (deep link helyett), sajat auth (-> skillpass-auth).
priority: P1
model: claude-sonnet-5-5
related_skills:
  - skillpass-auth
  - skillpass-app-launcher
  - i18n-required
---

# SkillPass.ID Workspace Shell – Portálépítői útmutató

A partner portál a `@skillpass/workspace-shell` csomagot integrálja:
egységes sidebar navigációt, app switchert, Vault drawert és `--sp-` design
tokeneket kap. **A profil, biztonság, dokumentumok és számlák oldalt nem
építi a partner** — ezek az Account Centerbe mutatnak (deep link).

> Részletek: `references/shell-contract.md`, `references/design-tokens.md`,
> `references/route-skeleton.md`, `references/account-center-deeplinks.md`

---

## 1. Csomag telepítés

```bash
pnpm add @skillpass/workspace-shell
```

Peer dependency: `react ^18.2 || ^19`, `react-dom`.

CSS import (a partner layoutjában, egyszer):

```typescript
import "@skillpass/workspace-shell/shell.css";
```

---

## 2. ShellContext összeállítása (BFF)

A böngésző soha nem hívja közvetlenül a SkillPass-t shell-kontextusért.
A BFF a `shell:read` scope-os access tokennel kéri le, és változtatás nélkül
adja tovább.

```typescript
// BFF route handler (Next.js App Router)
import { getShellContext } from "@/lib/skillpass-shell";

export async function GET() {
  const result = await getShellContext(sub, locale);
  if (result.status !== "ok") {
    // Fallback: saját nav renderelés shell nélkül
    return Response.json(null, { status: 204 });
  }
  return Response.json(result.value);
}
```

Gyorsítótárazás: 60 s (a SkillPass is 60 s-os cache-t tart a szerverén).
Negatív cache: 10 s (szolgáltatás-kiesés esetén is válaszol gyorsan).

---

## 3. WorkspaceShell beágyazás

```tsx
import { WorkspaceShell, ShellProvider } from "@skillpass/workspace-shell";
import "@skillpass/workspace-shell/shell.css";
import Link from "next/link";

// Next.js link adapter (App Router)
const NextLink = React.forwardRef<HTMLAnchorElement, ShellLinkProps>(
  ({ href, ...props }, ref) => <Link href={href} ref={ref} {...props} />
);
NextLink.displayName = "NextLink";

export default function PortalLayout({
  children,
  context,
}: {
  children: React.ReactNode;
  context: ShellContext | null;
}) {
  if (!context) {
    // Fallback: saját nav, shell nélkül
    return <main>{children}</main>;
  }

  return (
    <ShellProvider locale={context.locale} linkComponent={NextLink}>
      <WorkspaceShell
        context={context}
        theme="light"   // vagy "dark" a felhasználói beállítás szerint
        activeHref={usePathname()}
      >
        {children}
      </WorkspaceShell>
    </ShellProvider>
  );
}
```

---

## 4. AppManifest összeállítása

Az `active_app` manifest a Hydra `metadata.launcher`-ből épül, de a partner
BFF-je is szolgálhatja (ha a shell-context végpont nem elérhető).

```typescript
import type { AppManifest } from "@skillpass/workspace-shell/types";

export const PORTAL_MANIFEST: AppManifest = {
  app_id:      "partner-portal",
  name:        "Partner Portal",
  short_name:  "Portal",
  launch_url:  "https://portal.hu",
  icon:        { url: "https://portal.hu/icon.svg" },
  accent:      "#F0731D",
  nav: [
    {
      items: [
        { id: "dashboard", label: { hu: "Vezérlőpult", en: "Dashboard" },
          href: "/dashboard", icon: "Home" },
        { id: "trainings", label: { hu: "Képzéseim", en: "My Trainings" },
          href: "/trainings", icon: "GraduationCap" },
      ],
    },
  ],
  data_scope_note: {
    hu: "Képzési és részvételi adatok innen, a portálból.",
    en: "Training and participation data from this portal.",
  },
};
```

---

## 5. Route felépítés (Next.js App Router)

Részletes: `references/route-skeleton.md`

```
app/
  [locale]/
    layout.tsx          ← ShellProvider + WorkspaceShell
    page.tsx            ← redirect → /[locale]/dashboard
    dashboard/
      page.tsx
    trainings/
      page.tsx
      [id]/
        page.tsx
    auth/
      login/route.ts    ← /auth/login redirect → Hydra authorize
      callback/route.ts ← code csere, cookie set
      refresh/route.ts  ← refresh token rotáció
      logout/route.ts   ← Hydra + Kratos session zárás
```

---

## 6. Design tokenek (`--sp-*`)

A shell CSS-ben definiálva vannak — a partner felülírhatja a saját CSS-ében.
Teljes lista: `references/design-tokens.md`

Legfontosabb tokenek:

```css
/* Felületek */
--sp-bg-canvas: #fbf7f1;   /* tartalom háttér (krém, 0.1.6 óta egyszínű) */
--sp-bg-surface: #ffffff;   /* topbar, sidebar, kártyák */
--sp-border: #e8e4dd;

/* Szöveg */
--sp-text: #1b2340;
--sp-text-muted: #6b7280;

/* Brand */
--sp-brand: #1d6fe0;        /* SkillPass kék */
--sp-accent: #1d6fe0;       /* felülírja a manifest accent értéke */

/* Méretek */
--sp-topbar-h: 68px;
--sp-sidebar-w: 244px;
```

Sötét módhoz a `theme="dark"` prop mellett a `[data-sp-theme="dark"]` CSS
szelektor definiálja a tokeneket (lásd `references/design-tokens.md`).

---

## 7. i18n

```typescript
// A shell beépített hu/en szótárat tartalmaz.
// Saját szövegek a szokásos react-i18next flow-val:
import { useTranslation } from "react-i18next";
const { t } = useTranslation("portal");
```

Minden user-facing string `t()` hívón át — `i18n-required` skill.

---

## 8. Account Center deep linkek

**NE építsd újra** a következő oldalakat — deep link az Account Centerbe:

| Funkció | Deep link |
|---------|-----------|
| Profil szerkesztése | `https://skillpass.id/account/profile` |
| Biztonság és bejelentkezés | `https://skillpass.id/account/security` |
| Dokumentumok | `https://skillpass.id/account/documents` |
| Hozzáférések | `https://skillpass.id/account/access` |
| Számlák | `https://skillpass.id/account/invoices` |
| Értesítések | `https://skillpass.id/account/notifications` |
| Vault főoldal | `https://skillpass.id/account/dashboard` |

Részletes lista és kontextus: `references/account-center-deeplinks.md`

## Fiók-felület szabvány (bejelentkezés után) – D-V16-08

Minden partner projekt belépett felülete ugyanígy épül (forrás: aibootcamp.hu `/fiok`):

- `WorkspaceShell` a csomagból; **SkillPass.ID logó a bal oldali sáv tetején**, alatta az aktív app.
- Nav helyi `shell-manifest.ts`-ből (`SHELL_APP_ID`, `shellNav`, `shellManifest()`), hu+en labelek.
- `/fiok/` áttekintés + `/fiok/<szekció>/` aloldalak, noindex.
- Profil / biztonság / dokumentumok / számlák = Account Center deep link a drawerből, nem helyi oldal.
- Shell-context a BFF-en át (`shell:read`), szerveroldali cache; logout CSRF + back-channel.
- Partner CSS a shellben csak `.workspace-content` / `.workspace-main` / `.workspace-loading`.

Részletek és kódidézetek: `references/partner-account-shell.md`.
Sablon: `templates/portal/lib/shell/shell-manifest.ts`, `account-shell.example.tsx`.


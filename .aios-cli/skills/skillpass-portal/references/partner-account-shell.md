# Partner fiók-felület szabvány (bejelentkezés utáni belső UX)

> Forrás: aibootcamp.hu `apps/web` (élő, commit `1bb8677`, 2026-10-21):
> `src/components/account-shell.tsx`, `src/lib/shell-manifest.ts`, `src/lib/portal-nav.ts`,
> `src/app/[...path]/page.tsx`, `src/app/layout.tsx`; csomag `@skillpass/workspace-shell` **0.1.15**.
> Döntések: aibootcamp.hu `specification/plan-v8/10-dontesek.md` (D-V8-01..08).
> Skeleton döntés: plan-v16 **D-V16-08** – ez a szabvány minden új partner projektnél.

## A szabvány

| Elem | Szabály |
|------|---------|
| Shell | `WorkspaceShell` a `@skillpass/workspace-shell` csomagból (vendor tgz, rögzített verzió). A partner **nem ír saját sidebar/topbar komponenst**. |
| Logó | **SkillPass.ID brandmark + "SkillPass.ID" felirat a bal oldali sáv tetején** (`sp-sidebar__brand`, a csomag adja, "Béta" jelvény a `beta` proppal). Alatta az aktív app blokk (ikon + app név). A topbarban nincs logó. |
| Topbar | hamburger (mobil) · kereső (`onSearch`) · app-pill ("Aktív munkatér" → `AppSwitcher`, az `apps[]` a shell-contextből) · értesítés · súgó (`helpHref`) · avatar → `VaultDrawer`. |
| Drawer | profil / hozzáférések / dokumentumok / biztonság / értesítések **kizárólag SkillPass Account Center linkek** (`skillpass_base_url` + `/account/...`), "Fiókváltás" (`onSwitchAccount`), "Kijelentkezés" (`onLogout`), CTA "SkillPass.ID kezelése". |
| Nav | helyi `shell-manifest.ts`: `SHELL_APP_ID`, `shellNav: NavSection[]`, `shellManifest()`. 1. szekció **"Fiókom"** (áttekintés + helyi funkciók), 2. szekció az app publikus belépői. Minden label `{hu,en}`. Ikon a csomag kurált készletéből (`Home`, `ClipboardList`, `CalendarCheck`, `FileText`, `KeyRound`, `Sparkles`, `Coins`, `MessageSquare`, `ShieldCheck`, `LayoutGrid`, `Globe`, `BookOpen`, `Users`, `Award`). |
| Útvonalak | `/fiok/` = áttekintés (csak dashboard-összefoglaló) + aloldalak `/fiok/<szekció>/` záró `/`-rel, **noindex**. A shell vagy csak `/fiok` alatt (aibootcamp), vagy az egész belépett felületen (aiagentek) – projektenként dokumentált döntés. |
| Shell-kontextus | BFF `GET /api/v1/shell-context` → SkillPass `GET /api/v1/partner/shell-context` a felhasználó tokenjével (`shell:read` scope), ≤60 s cache, zod séma (`user, apps[], notification_count, skillpass_base_url, sync_state, reauth`). Hiba → `sync_state:"offline"`; 401 → újrabelépés-sáv. **Szerveroldali lekérés + cache ajánlott** (aiagentek minta: 60 s pozitív, 10 s negatív cache, 4 s timeout, in-flight dedup). |
| Auth | Rust BFF: `/auth/login`, `/auth/logout` (POST + `X-CSRF-Token`, back-channel logout), `onSwitchAccount` → `/auth/login?returnTo=%2Ffiok%2F&prompt=login&login_hint=<email>`. A böngésző nem kap tokent (lásd `skillpass-auth`). |
| Tokenek | `--sp-*` a csomag `shell.css`-éből (`--sp-brand #1d6fe0`, `--sp-bg-canvas #fbf7f1`, `--sp-text #1b2340`, `--sp-topbar-h 68px`, `--sp-sidebar-w 244px`, `--sp-radius 12px`). App accent a manifestből (aibootcamp: `#f6a41d`). Partner CSS a shellen belül **csak** `.workspace-content` (gutter 16px <640px, 24px felette), `.workspace-main`, `.workspace-loading`. Dark: `data-sp-theme` a SkillPass-ban mentett témából (`ShellContext.theme`). |
| i18n | hu + en minden nav labelen; a nyelvet a host (domain) dönti, a shellben nincs nyelvváltó. |
| Helyi funkciók | rendelések, események/jegyek, letöltések, hozzáférések, ajánlatok, kosár, feliratkozások, adatvédelem + hozzájárulások. **Nem helyi** (deep link): profil, biztonság, dokumentumok, számlák, értesítés-beállítás. |
| Védelem | `/fiok` kizárva az indexelésből; vendég → `<Login>` felület; a tényleges hitelesítés a BFF-ben. |

## Kódidézetek (aibootcamp.hu, normatív)

```tsx
// src/components/account-shell.tsx
<WorkspaceShell context={context} beta linkComponent={NextShellLink}
  activeHref={pathname.endsWith("/") ? pathname : pathname + "/"}
  helpHref="/kapcsolat/"
  onSearch={(q) => router.push("/webshop/?q=" + encodeURIComponent(q))}
  onLogout={logout /* POST /auth/logout + X-CSRF-Token, majd location.assign("/") */}
  onSwitchAccount={switchAccount /* /auth/login?returnTo=%2Ffiok%2F&prompt=login&login_hint=... */}>
  <div className="workspace-content">{children}</div>
</WorkspaceShell>
```

```ts
// src/lib/shell-manifest.ts (kivonat)
export const SHELL_APP_ID = "aibootcamp";
export const shellNav: NavSection[] = [
  { label: { hu: "Fiókom", en: "My account" }, items: [
    { id: "overview", label: { hu: "Áttekintés", en: "Overview" }, href: "/fiok/", icon: "Home" },
    { id: "orders",   label: { hu: "Rendelések", en: "Orders" },   href: "/fiok/rendelesek/", icon: "ClipboardList" },
    /* … esemenyek, letoltesek, hozzaferesek, ajanlatok, kosar, feliratkozasok, adatvedelem */ ] },
  { label: { hu: "AI Bootcamp", en: "AI Bootcamp" }, items: [ /* webshop, esemenyek, cikkek, szakertok, elofizetes */ ] },
];
export function shellManifest(origin: string): AppManifest {
  return { app_id: SHELL_APP_ID, name: "AI Bootcamp", short_name: "Bootcamp",
    launch_url: `${origin}/fiok/`, icon: { url: `${origin}/icon.svg` }, accent: "#f6a41d",
    nav: shellNav, required_entitlements: [], data_scope_note: { hu: "…", en: "…" } };
}
```

## Sablon a skeletonban

`templates/portal/lib/shell/shell-manifest.ts` (nav + manifest), `account-shell.example.tsx`
(beágyazás a callbackekkel). A `bootstrap-project` 0. lépése kérdezi: shell csak `/fiok` alatt
vagy az egész belépett felületen.

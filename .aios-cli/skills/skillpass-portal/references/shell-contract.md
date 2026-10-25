# Shell Kontraktus – típusok és prop-referencia

> Forrás: `skillpass` repo @ `24048cd` (2026-10-06)
> Autoritatív: `packages/workspace-shell/src/types.ts` és
> `specification/plan-v17/02-f2-shell-kontrakt.md`

## Típusok (`@skillpass/workspace-shell/types`)

```typescript
export type ShellLocale = "hu" | "en";

export interface LocalizedText {
  hu: string;
  en: string;
}

export interface NavItem {
  id: string;
  label: LocalizedText;
  href: string;
  /** Ikon neve a kurált ikonkészletből (kebab-case vagy PascalCase). */
  icon: string;
  badge?: string;
}

export interface NavSection {
  label?: LocalizedText;
  items: ReadonlyArray<NavItem>;
}

export interface AppIcon {
  svg?: string;
  url?: string;
}

export interface AppManifest {
  app_id: string;
  name: string;
  short_name?: string;
  launch_url: string;              // abszolút URL
  icon: AppIcon;
  accent: string;                  // pl. "#F0731D"
  nav: ReadonlyArray<NavSection>;
  required_entitlements?: ReadonlyArray<string>;
  status_endpoint?: string;        // v18: M2M pull; v17-ben nem hívódik
  data_scope_note?: LocalizedText; // „Adatok helye" blokk 2. sora
}

export interface ShellUser {
  sub: string;
  name: string;
  email: string;
  avatar_url?: string;
  verified: boolean;
  skillpass_id_short: string;
}

export interface ShellAppEntry {
  manifest: Pick<AppManifest, "app_id" | "name" | "launch_url" | "icon" | "accent">;
  status_line?: string;
  progress?: number;   // 0–100
  active?: boolean;
  access: "active" | "none";
}

export type ShellSyncState = "synced" | "stale" | "offline";

export interface ShellContext {
  locale: ShellLocale;
  user: ShellUser | null;           // null = kijelentkezett állapot is renderel
  active_app: AppManifest;
  apps: ReadonlyArray<ShellAppEntry>;
  notification_count?: number;
  skillpass_base_url: string;       // "https://skillpass.id"
  sync_state?: ShellSyncState;
}
```

## WorkspaceShell props

| Prop | Típus | Kötelező | Alapértelmezés |
|------|-------|----------|----------------|
| `context` | `ShellContext` | **igen** | — |
| `children` | `ReactNode` | **igen** | — |
| `theme` | `"light" \| "dark"` | nem | `"light"` |
| `rightRail` | `ReactNode` | nem | — |
| `contextSlot` | `ReactNode` | nem | — |
| `sidebarFooterSlot` | `ReactNode` | nem | — |
| `activeHref` | `string` | nem | — |
| `onNavigate` | `(item: NavItem) => void` | nem | — |
| `onSearch` | `(query: string) => void` | nem | — |
| `onSelectApp` | `(entry: ShellAppEntry) => void` | nem | — |
| `allAppsHref` | `string` | nem | `${skillpass_base_url}/account/consent` |
| `linkComponent` | `ShellLinkComponent` | nem | belső `<a>` |

## ShellProvider props

| Prop | Típus | Kötelező |
|------|-------|----------|
| `children` | `ReactNode` | **igen** |
| `locale` | `ShellLocale` | nem |
| `messages` | `Partial<ShellMessages>` | nem |
| `linkComponent` | `ShellLinkComponent` | nem |
| `iconRegistry` | `Record<string, ShellIconComponent>` | nem |

## Teszt-horgok (smoke teszteléshez)

| Elem | data-testid |
|------|-------------|
| Shell gyökér | `data-sp-shell="1"` + `data-sp-app="<app_id>"` |
| TopBar | `sp-topbar` |
| App switcher trigger | `sp-app-switcher-trigger` |
| App switcher panel | `sp-app-switcher` |
| Vault trigger | `sp-vault-trigger` |
| Vault drawer | `sp-vault-drawer` |
| Kijelentkezés | `sp-logout` |
| Sidebar | `sp-sidebar` |
| Nav elem | `sp-nav-item` + `data-nav-id` |

## Megjegyzések (v0.1.6)

- A tartalomterület egyszínű `--sp-bg-canvas` háttér (nincs háttérminta).
  A `--sp-bg-pattern` token értéke `none` — a mező megmarad visszafelé
  kompatibilitás miatt, de a shell nem hivatkozik rá.
- Ha `sync_state === "offline"` és `user` nem null, a Vault trigger kompakt
  profilmenüt nyit a Vault drawer helyett.
- Az `allAppsHref` alapértéke 0.1.4 óta `${skillpassBaseUrl}/account/consent`
  (nem `/account/connections`).

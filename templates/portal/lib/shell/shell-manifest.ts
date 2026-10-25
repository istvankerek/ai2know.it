/**
 * Partner portál shell-manifest – a SkillPass.ID workspace shell helyi nav-konfigja.
 * Szabvány: `.aios-cli/skills/skillpass-portal/references/partner-account-shell.md` (D-V16-08).
 * A típusok a `@skillpass/workspace-shell` 0.1.x szerződését tükrözik; a projektben a
 * csomag típusait importáld, ez a fájl a bootstrap kiinduló váza.
 */

export interface LocalizedText {
  hu: string;
  en: string;
}

export interface NavItem {
  id: string;
  label: LocalizedText;
  href: string;
  /** A csomag kurált ikonkészletének neve (pl. Home, ClipboardList, ShieldCheck). */
  icon: string;
  badge?: string;
}

export interface NavSection {
  label: LocalizedText;
  items: NavItem[];
}

export interface AppManifest {
  app_id: string;
  name: string;
  short_name?: string;
  launch_url: string;
  icon: { url: string };
  accent: string;
  nav: NavSection[];
  required_entitlements: string[];
  data_scope_note: LocalizedText;
}

/** A partner app azonosítója a SkillPass launcherben (Hydra client metadata.launcher.app_id). */
export const SHELL_APP_ID = "partner-app";

/** Az app accent színe a shellben (a manifestből jön, a csomag `safeAccent`-tel validálja). */
export const SHELL_ACCENT = "#1d6fe0";

/**
 * Oldalsáv szekciók. 1. "Fiókom": áttekintés + a partner helyi funkciói.
 * 2. az app publikus belépői. Profil / biztonság / dokumentumok / számlák NEM ide:
 * azokat a VaultDrawer linkeli a SkillPass Account Centerbe.
 */
export const shellNav: NavSection[] = [
  {
    label: { hu: "Fiókom", en: "My account" },
    items: [
      { id: "overview", label: { hu: "Áttekintés", en: "Overview" }, href: "/fiok/", icon: "Home" },
      { id: "orders", label: { hu: "Rendelések", en: "Orders" }, href: "/fiok/rendelesek/", icon: "ClipboardList" },
      { id: "access", label: { hu: "Hozzáférések", en: "Access" }, href: "/fiok/hozzaferesek/", icon: "KeyRound" },
      { id: "downloads", label: { hu: "Letöltések", en: "Downloads" }, href: "/fiok/letoltesek/", icon: "FileText" },
      { id: "privacy", label: { hu: "Adatvédelem", en: "Privacy" }, href: "/fiok/adatvedelem/", icon: "ShieldCheck" },
    ],
  },
  {
    label: { hu: "Felfedezés", en: "Explore" },
    items: [
      { id: "catalog", label: { hu: "Katalógus", en: "Catalog" }, href: "/katalogus/", icon: "LayoutGrid" },
      { id: "events", label: { hu: "Események", en: "Events" }, href: "/esemenyek/", icon: "Globe" },
    ],
  },
];

/**
 * A partner app manifestje a shell-context `active_app` mezőjéhez (helyi, normatív).
 * @param origin - A portál origin-je (pl. https://app.example.hu)
 */
export function shellManifest(origin: string): AppManifest {
  return {
    app_id: SHELL_APP_ID,
    name: "Partner App",
    short_name: "Partner",
    launch_url: `${origin}/fiok/`,
    icon: { url: `${origin}/icon.svg` },
    accent: SHELL_ACCENT,
    nav: shellNav,
    required_entitlements: [],
    data_scope_note: {
      hu: "A portál a SkillPass.ID fiókodból a nevedet, e-mail címedet és jogosultságaidat használja.",
      en: "This portal uses your name, e-mail and entitlements from your SkillPass.ID account.",
    },
  };
}

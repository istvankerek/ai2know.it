/**
 * Példa AppManifest egy partner portálhoz.
 *
 * A típusok a `@skillpass/workspace-shell/types` csomagból újradeklarálva
 * (helyi, import nélkül is futtatható). A valódi integrációban a csomag
 * típusait importáld:
 *
 *   import type { AppManifest } from "@skillpass/workspace-shell/types";
 *
 * Forrás: skillpass repo @ 24048cd — packages/workspace-shell/src/types.ts
 */

// ---------------------------------------------------------------------------
// Lokálisan újradeklarált típusok (egyeznek a workspace-shell kontraktussal)
// ---------------------------------------------------------------------------

/** Kétnyelvű szöveg (hu + en). */
export interface LocalizedText {
  hu: string;
  en: string;
}

/** Egy navigációs elem. */
export interface NavItem {
  id: string;
  label: LocalizedText;
  href: string;
  /** Ikon neve a kurált készletből (PascalCase vagy kebab-case). */
  icon: string;
  badge?: string;
}

/** Navigációs szekció opcionális kis kapitális cimkével. */
export interface NavSection {
  label?: LocalizedText;
  items: ReadonlyArray<NavItem>;
}

/** Az alkalmazás ikonja: inline SVG string vagy URL. */
export interface AppIcon {
  svg?: string;
  url?: string;
}

/** Egy munkaterének (alkalmazás) manifesztje. */
export interface AppManifest {
  /** Stabil app-azonosító; egyezik a Hydra metadata.launcher.app_id-vel. */
  app_id: string;
  name: string;
  short_name?: string;
  /** Abszolút belépési URL (csak https://). */
  launch_url: string;
  icon: AppIcon;
  /** Kiemelő szín hexadecimálisan, pl. "#F0731D". */
  accent: string;
  nav: ReadonlyArray<NavSection>;
  required_entitlements?: ReadonlyArray<string>;
  /** v18: M2M pull; v17-ben a csomag nem hívja. */
  status_endpoint?: string;
  /** Az „Adatok helye" blokk 2. sora a Vault drawerben. */
  data_scope_note?: LocalizedText;
}

// ---------------------------------------------------------------------------
// Példa manifest
// ---------------------------------------------------------------------------

/**
 * Típusos példa AppManifest egy képzési portálhoz.
 *
 * Cseréld le az értékeket a valódi portál adataira, majd add át a
 * `WorkspaceShell` `context.active_app` propjának — vagy töltsd be
 * a shell-context végpontból (ajánlott, mert a SkillPass mindig frissen
 * tartja a launcher metaadatokból épített manifesztet).
 */
export const EXAMPLE_PORTAL_MANIFEST = {
  app_id: "example-portal",
  name: "Portál neve",
  short_name: "Portál",
  launch_url: "https://portal.example.hu",
  icon: {
    url: "https://portal.example.hu/icon.svg",
  },
  accent: "#F0731D",
  nav: [
    {
      items: [
        {
          id: "dashboard",
          label: { hu: "Vezérlőpult", en: "Dashboard" },
          href: "/dashboard",
          icon: "Home",
        },
        {
          id: "trainings",
          label: { hu: "Képzéseim", en: "My Trainings" },
          href: "/trainings",
          icon: "GraduationCap",
        },
        {
          id: "access",
          label: { hu: "Hozzáféréseim", en: "My Access" },
          href: "https://skillpass.id/account/access",
          icon: "KeyRound",
        },
      ],
    },
    {
      label: { hu: "Tartalom", en: "Content" },
      items: [
        {
          id: "catalog",
          label: { hu: "Katalógus", en: "Catalog" },
          href: "/catalog",
          icon: "BookOpen",
        },
      ],
    },
  ],
  required_entitlements: ["example-portal-access"],
  data_scope_note: {
    hu: "Képzési és részvételi adatok a portálból.",
    en: "Training and participation data from this portal.",
  },
} as const satisfies AppManifest;

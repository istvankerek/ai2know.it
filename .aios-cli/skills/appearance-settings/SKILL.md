---
name: appearance-settings
description: >
  Megjelenes beallitasok: tema (light/dark/system), szin sema,
  nyelv, lokalizacio, kedvenc menu, lista nezet preferencia, betumeret.
  Triggerek: "appearance", "megjelenes", "tema", "dark mode", "light mode",
  "kedvenc menu", "favourite".
  NE hasznald: profil adatok (-> profile-system), admin beallitasok.
model: claude-sonnet-4-6
---

# Appearance Settings

> **Ökoszisztéma (v8.0):** partner portálban a megjelenés a skillpass workspace shell
> `AppearanceControl`-ját és a `--sp-` tokeneket használja (`skillpass-portal`); saját
> beállítás oldalt csak a skillpass.id és az aibos.space repó épít.

## Felelossegek
- Tema mod: light / dark / system (prefers-color-scheme)
- Szin sema: default, blue, green, purple, custom
- Betumeret: small / medium / large
- Density: compact / comfortable / spacious
- Sidebar: collapsed / expanded
- Kedvenc menupontok (drag & drop sorrend, pin)
- Lista nezet preferencia: simple / advanced (per modul)
- Dashboard widget sorrend
- Alapertelmezett oldal (login utan hova navigaljon)
- Reduced motion (akadalymentesseg)
- High contrast mod

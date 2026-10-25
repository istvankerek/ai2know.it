---
name: profile-system
description: >
  Felhasznaloi profil: fiok, eszkozok, belepesi elozmemyek,
  tevekenyseg naplo, ertesitesek, megjelenes beallitasok.
  Triggerek: "profil", "profile", "fiok", "account", "beallitasok",
  "eszkozok", "devices".
  NE hasznald: admin felhasznalo kezeles (-> crud-generator), auth (-> skillpass-auth). Partner projektben NE epitsd: SkillPass.ID Account Center deep link.
model: claude-sonnet-4-6
---

# Profile System

> **Ökoszisztéma (v8.0):** partner projektben NE építs profil oldalt: SkillPass.ID Account
> Center deep link (`skillpass-portal` → `account-center-deeplinks.md`). Ez a skill a
> skillpass.id repón belüli implementációra vonatkozik.

## Felelossegek
- /profile/account – nev, email, avatar, jelszovaltoztas (SkillPass.ID Account Centerben)
- /profile/devices – aktiv session-ok, eszkoz tipus, kijelentkeztetes
- /profile/login-history – IP, bongeszo, lokacio, datum
- /profile/activity – tevekenyseg naplo (az adott felhasznaloe)
- /profile/notifications – csatorna preferenciak, quiet hours
- /profile/appearance – tema, nyelv, lokalizacio (-> appearance-settings)

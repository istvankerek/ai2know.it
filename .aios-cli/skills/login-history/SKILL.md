---
name: login-history
description: >
  Belepesi elozmemyek: sikeres/sikertelen login-ok, IP, lokacio,
  eszkoz, bongeszo, gyanus tevekenyseg detektalas.
  Triggerek: "login history", "belepesi elozmenyek", "bejelentkezes naplo".
  NE hasznald: activity log (-> activity-log), session kezeles.
model: claude-haiku-4-5-20251001
---

# Login History

> **Ökoszisztéma (v8.0):** csak a skillpass.id (ügyfél) és az aibos.space (operátor) repóban
> implementálandó. Partner projekt a SkillPass.ID Account Center `security`/`activity`
> oldalára linkel (`skillpass-portal` → `account-center-deeplinks.md`).

## Felelossegek
- Login events tabla
- Sikeres / sikertelen / blokkolt kategoriak
- GeoIP lokacio (varos, orszag)
- Device fingerprint (bongeszo, OS, eszkoz tipus)
- Gyanus tevekenyseg detektalas (uj lokacio, sok sikertelen proba)
- Ertesites kuldes gyanus loginrol
- Admin UI: /admin/users/{id}/login-history
- Profil UI: /profile/login-history

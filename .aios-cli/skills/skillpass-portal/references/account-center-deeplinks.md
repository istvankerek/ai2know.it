# Account Center deep linkek

> Forrás: `skillpass` repo @ `24048cd` (2026-10-06)
> Autoritatív: `apps/frontend/src/lib/shell/account-shell-nav.ts`
> és `specification/plan-v17/02-f2-shell-kontrakt.md` 4. fejezet

## Alapelv

A partner portál **nem építi újra** a következő oldalakat. A VaultDrawer
ezekre mutat, a partner csak mélyhivatkozást küld az Account Centerbe.

```
skillpass_base_url = "https://skillpass.id"  (ShellContext-ből)
```

## Oldalak

| Funkció | Útvonal | Ikon |
|---------|---------|------|
| Személyes vezérlőpult | `/account/dashboard` | `Home` |
| Profil szerkesztése | `/account/profile` | `User` |
| Kapcsolatok | `/account/connections` | `Users` |
| Szervezetek | `/account/organizations` | `Building2` |
| Biztonság és bejelentkezés | `/account/security` | `Shield` |
| Képzéseim | `/account/trainings` | `GraduationCap` |
| Hozzáféréseim / előfizetések | `/account/access` | `KeyRound` |
| Eseményjegyek | `/account/event-tickets` | `CalendarCheck` |
| Kreditek | `/account/credits` | `Coins` |
| Számlák | `/account/invoices` | `FileSpreadsheet` |
| Dokumentumok | `/account/documents` | `FileText` |
| Értesítések | `/account/notifications` | `Bell` |
| App-engedélyek (consent) | `/account/consent` | — |

## VaultDrawer mélylinkjei

A `WorkspaceShell` VaultDrawer-e automatikusan hozzárendeli a következő
sorokat (`data-row-id`):

| Sor | `data-row-id` | URL |
|-----|---------------|-----|
| Személyes adatok | `profile` | `${skillpass_base_url}/account/profile` |
| Hozzáféréseim | `access` | `${skillpass_base_url}/account/access` |
| Dokumentumok | `documents` | `${skillpass_base_url}/account/documents` |
| Biztonság | `security` | `${skillpass_base_url}/account/security` |
| Értesítések | `notifications` | `${skillpass_base_url}/account/notifications` |

## AppSwitcher lábléc

| Link | URL |
|------|-----|
| Munkaterek kezelése | `${skillpass_base_url}/account/access` |
| Összes alkalmazás | `${skillpass_base_url}/account/consent` (0.1.4 óta) |

## Mikor kell saját mélyhivatkozást küldeni

Ha a portál navigációban megjelenik egy profil / biztonság / dokumentumok
gomb, az mindig `${skillpass_base_url}/account/<útvonal>` formában nyílik
— lehetőleg új fülön (`target="_blank"`) vagy a Vault drawerrel.

## TILOS

- Profil szerkesztési form a partner portálon
- Jelszóváltás oldal a partner portálon
- Számla letöltési lista a partner portálon (kivéve: a partner saját számlái,
  nem SkillPass-számlák)
- Dokumentumtár oldal a partner portálon (deep link a SkillPass Vault-ba)

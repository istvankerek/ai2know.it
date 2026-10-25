# 06 – Amit a skillpass.id-nek építenie kell

> Kiinduló állapot felderítve 2026-10-20 (skillpass `docs/partner-integracio.md`, plan-v28, v30,
> v37). Az ai2know a skillpass dokumentációban még nem szerepel. Megvalósítás a skillpass repó
> saját plan-jében; ez a lista a megrendelés.

## Összefoglaló

| # | Igény | Van már? | Prioritás | Melyik ai2know fázis kell hozzá |
|---|-------|----------|-----------|---------------------------------|
| 1 | Kliens-regisztráció (OIDC, M2M, launcher, manifest) | minta megvan | P0 | F2 |
| 2 | Curve elvégzés a profilon | **megvan** (`trainings:write`) | P0 | F5 |
| 3 | „Készítette" / alkotások blokk a publikus profilon | nincs | P1 | F5 |
| 4 | Ellenőrzött értékelés partner-entitásra | félkész (stub consumer, entitást csak moderátor hoz létre) | P1 | F5 |
| 5 | Elvégzett képzések a publikus profilon (opt-in) | csak a saját fiók oldalon | P1 | F5 |
| 6 | Szervezet-kapcsolat (munkatér ↔ skillpass szervezet) | nincs partner olvasás | P2 | F9 |
| 7 | Felhasználó-törlés (GDPR) értesítés partnernek | nincs | **P0** (jogi) | F5 |
| 8 | Entitlement a fizetős szinthez | **megvan** (`entitlements:write/read`) | P2 | F11 |
| 9 | `+` átirányítás a skillpass.id domainen | nincs | P1 | F7 |
| 10 | Adatkezelési alap (plan-v37 D-1) | jogi feladat | **P0** | F0 |

## 1. Kliensek és megjelenés a launcherben

- `ai2know-web` – OIDC, PKCE, confidential BFF; scope: `openid offline_access profile email
  shell:read`; redirect: `https://ai2know.it/auth/callback` (apex + `returnTo`, wildcard nincs);
  `backchannel_logout_uri: https://ai2know.it/auth/backchannel-logout`.
- `partner-ai2know-m2m` – `client_credentials`, `audience: https://skillpass.id/api`; scope:
  `trainings:write`, `learning:write`, `contributions:write` (új, 3. pont), `reviews.entities:write`
  (új, 4. pont); F11-től `entitlements:write`.
- Partnerek közötti M2M (05/3): `ai2know-to-superskiller-m2m` és `superskiller-to-ai2know-m2m`
  Hydra kliensek; ehhez a Hydra-nak **új audience-eket** kell kiadnia (`https://superskiller.com/api`,
  `https://ai2know.it/api`). Ez új a skillpass-on, ahol ma csak a saját API az audience.
- `metadata.launcher` + AppManifest: `app_id: ai2know`, `short_name: ai2know`, kategória
  „Tudás", `nav`: Curve-jeim, Feltöltéseim, Munkatereim, Csoportjaim; `status_endpoint`
  (aktív curve-ök, haladás). Ikon host: `ai2know.it` a `CONSENT_LOGO_HOST_ALLOWLIST`-be.
- `metadata.partner_consent`: `{scopes: ["learning.write"], return_origins: ["https://ai2know.it"]}`.

## 2. Curve elvégzés (meglévő API, csak használjuk)

`POST /api/v1/profile/trainings`: `user_id = sub`, `external_id = ai2know:curve:{code}:v{version}`,
`provider = "ai2know.it"`, `entity_ref = ai2know:curve:{code}`, `status`, `completed_at`,
`certificate_url = https://ai2know.it/igazolas/{token}`. Ráadásul xAPI `completed` statement a
`learning:write` scope-pal, ha a felhasználó hozzájárult (partner consent oldal).

## 3. Új: alkotások („Készítette") a publikus profilon

- **Új M2M scope:** `contributions:write`.
- **Végpont:** `PUT /api/v1/passport/contributions/{external_id}` (idempotens upsert, a plan-v28
  `community_contribution` entitására építve):

  ```json
  {
    "user_id": "<sub>",
    "kind": "curve_authored | item_authored | workspace_owned",
    "title": "AI marketing alapok",
    "url": "https://ai2know.it/+ai-marketing-alapok",
    "summary": "12 lépés, workshop után",
    "metrics": { "completions": 148, "rating_count": 37, "rating_avg": 4.6 },
    "visibility_hint": "public",
    "updated_at": "2026-11-02T10:00:00Z"
  }
  ```

  `DELETE` ugyanazon az útvonalon (curve zártra váltás vagy törlés). A metrikákat az ai2know
  naponta frissíti; `rating_avg` csak `rating_count ≥ 5` esetén megy át.
- **Megjelenítés:** új „Alkotások" blokk a publikus profilon (`profile-view/sections/`), a sor-szintű
  láthatósággal (`public|followers|…|private`); **alapból a felhasználó dönti el**, mi látszik
  (az ai2know csak `visibility_hint`-et küld).

## 4. Ellenőrzött értékelés partner-entitásra

- **Új M2M scope:** `reviews.entities:write`; `PUT /api/v1/review/entities/{external_ref}` – a partner a
  saját prefixe alatt (`ai2know:`) regisztrálhat entitást (cím, URL, típus); más prefix 403.
- A `training_completed_consumer` befejezése (ma csak logol): a `(user, entity_ref)` pár
  jogosulttá válik, a felhasználó saját értékelése `is_verified = true`.
- Döntés: az elemek közösségi értékelése az ai2know-ban marad; a skillpass-ra csak a **curve**
  ellenőrzött értékelése megy (P-V3-12).

## 5. Elvégzett képzések a publikus profilon

A `trainings` sorok kapjanak sor-szintű láthatóságot (ugyanaz a `skillpass-access` modell), és
egy „Képzések" blokkot a publikus profilon. Alapértelmezés: `private` (opt-in).

## 6. Szervezet-kapcsolat (P2, II. felvonás)

- Felhasználói token scope: `orgs:read` → `GET /api/v1/profile/me/organizations?role=admin,owner`
  (`id, handle, name, kind, role`).
- Cél: egy ai2know szervezeti munkatér „ellenőrzött" jelölést kap, ha az adminja a skillpass
  szervezetben is admin; a kapcsolat megszűnése esetén a jelölés lekerül (napi ellenőrzés).

## 7. Felhasználó-törlés és hozzájárulás-visszavonás értesítés (P0)

- Ma a partner csak közvetve tudja meg (401/404). GDPR miatt kell egy **kimenő partner értesítés**:
  `POST {partner}/webhooks/skillpass` események: `user.deleted`, `consent.revoked`
  (`client_id`, `scope`), aláírva (HMAC vagy a back-channel logout JWT mintájára aláírt JWT).
- Az ai2know a törléskor: tag adatai törlése/anonimizálása, nyilvános tartalom szerzője
  „törölt felhasználó" lesz vagy a tartalom is törlődik (a felhasználó választása, ÁSZF szerint – Q-V3-04).

## 8. Fizetős szint (F11)

A meglévő `POST /api/v1/profile/entitlements` elég: `kind = course | subscription`,
`product_ref = ai2know:{curve|group|workspace}:{code}`, `source_name = "ai2know.it"`. A shell
`required_entitlements` nem kell (az ai2know maga dönt a hozzáférésről, a skillpass tükröz).

## 9. `+` átirányítás

A skillpass.id Caddy konfigurációjában a 03/5 közös szabály. Ütközés nincs (`/u/…`, `/[locale]/…`).

## 10. Adatkezelési alap

A skillpass plan-v37 D-1 szerint a SuperSkiller.com Zrt. az adatkezelő, az ai2know önálló
adatkezelő → adattovábbítási jogalap (szerződés vagy hozzájárulás) és adatkezelési megállapodás kell
az ai2know üzemeltetőjével, **mielőtt** éles M2M adat megy (Q-V3-04).

# Implementation notes – plan-v3

## Állapot

- 2026-10-20: a plan-v3 tervezet elkészült. Owner jóváhagyásra vár. Kód nem készült.

## Felderítés (2026-10-20, csak olvasás)

- **superskiller:**
  - Rust/Axum + Next BFF, skillpass OIDC és M2M (`learning:write`).
  - Az objektumok uuid + slug azonosítóval, bérlőhöz kötve: kurzus, lecke, küldetés, kompetencia, B2B csoport.
  - Van `outbox_events`. Nincs partner API, kimenő webhook, oEmbed, és közösségi poszt vagy csoport sem.
  - A contract extension overlay-ben bővíthető (plan-v14 D-5).
  - Nincs `+` útvonal.
- **skillpass:**
  - Van: `trainings:write`, `entitlements:write/read` (csak a saját kliens sorai), `learning:write` (consenttel).
  - A review consumer még stub, entitást csak moderátor hoz létre.
  - Nincs partner profil-blokk, partneroldali szervezet-olvasás és kimenő partner webhook.
  - A legutóbbi a plan-v37, ai2know nincs benne.
- **aibootcamp.hu:**
  - Next 16, kézi CSS, tokenek a `globals.css`-ben.
  - Georgia + Manrope, éles sarkok, amber gomb sötét szöveggel.
- **aibos.club:**
  - Partnerportál.
  - Minden belépett skillpass felhasználó automatikusan partner.
  - Nincs partner-státusz API más projektek felé.
  - Van affiliate jutalék-főkönyv.

## Ökoszisztéma-változás: minden backend-hívás az api.sios.ws kapun át (2026-10-25)

Forrás: értesítés a skillpass munkamenetből, ellenőrizve a skillpass repóban:

- `specification/okoszisztema/00-okoszisztema-attekintes.md` A11, valamint `05-sios-ws.md`;
- `specification/szabalykonyv/R0-alapszabalyok.md` SZ-A-01 és SZ-A-10, R1, R2.

Owner döntés a skillpass oldalon (2026-10-25):

- Minden backend-hívás a `https://api.sios.ws` kapun megy. Ez az ai2know saját frontend → saját backend hívásaira is vonatkozik.
- A szolgáltatások a kapu kontextus-tokenjét fogadják.
- A mai skillpass végpontok a régi utak lezárásáig közvetlenül is működnek.

Hatás a plan-v3-ra. Ez **revízió**, az owner döntésére vár (Q-V3-11):

| plan-v3 pont | Mi változik |
|--------------|-------------|
| 05/3, P-V3-19 (partnerek közötti M2M saját audience-szel) | a superskiller ↔ ai2know hívások a kapun át mennek, a `https://api.sios.ws` audience-szel; a saját audience-ek feleslegessé válhatnak |
| 05/6 (HMAC webhookok) | az eseménycsatorna a kapu / eer események mintáját követheti (R1 `consumes`) |
| 06/1 (Hydra kliensek) | az audience `https://api.sios.ws`; a scope-nevek pontos formában (`shell.read`, a `shell:read` álnévként megmarad); a kapu a token `azp`-jét a frontend client_id-jével egyezteti |
| 06/7 (P0: értesítés felhasználó-törlésről) | **részben megoldva:** a `privacy.request` esemény (R2 §10) kezelése 30 napon belül kötelező, a válasz `privacy.completed` (SZ-A-10) |
| 06/4, 06/6 (értékelés, szervezet) | az R0 szerint a skillpass `org.*` és `rating.*` eseményeket ad, ez újranyithatja a P-V3-07 és P-V3-12 javaslatot (ellenőrizni kell) |
| F2 (BFF) | a Connected Site kit átvétele a sios.ws munkamenet jelzése után; csendes belépés `prompt=none` + `offline_access`; back-channel logout (SZ-S-06); a felhasználó kulcsa a `sub` (SZ-S-20) |

Most nincs teendő az éles rendszerben: a változás ütemezett, élesben csak tulajdonosi jóváhagyással.

## Fázisnapló

Az F0-tól kezdve itt rögzítjük az eredményt, a validációt, a deployt és a smoke-ot.

# F6 – Admin (aibos.space) és tartalom

> Contract-first: `../plan-v0/15-f5-admin-contract.md` minta. Routing: STANDARD.
> Skillek: `aibos-admin-contract`, `audit-trail-mandatory`, `brand-auditor`.

## Admin modulok (permission: `ai2know.{modul}.{akció}`)

| Modul | Műveletek |
|-------|-----------|
| `items` | list, view, create, edit, publish, archive, set_visibility (nyilvános minta arány kijelzéssel) |
| `roles` | szerepkör-összeállítás (tagok, sorrend), publish |
| `curves` | list, view, moderate (nyilvános curve-ök), archive, grant_author (`curve_author` képesség) |
| `feedback`, `comments` | moderate |
| `requests` | list, update (új elem / javítás kérések) |
| `link_check` | törött/elavult elemek listája |
| `reports` | keresési „nincs találat", konverzió (teaser → belépés), curve statisztikák, redirectek |
| `audit` | list, view |

## Tartalom

- [ ] Seed: aiagentek (F1 átköltöztetés), régi ai2know (eszközök, linkek, videók, segédanyagok).
- [ ] Új típusok indulási készlete: ≥ 10 compliance guide (AI Act, GDPR, ISO 42001 alapok), ≥ 8
      szerepkör a meglévő skillekből, ≥ 15 tutorial.
- [ ] Nyilvános minta kijelölése típusonként (10–15%).
- [ ] 3–5 bemutató curve (pl. „ChatGPT első lépések", „AI agent eszköztár 7 lépésben").
- [ ] Szerkesztői szabályok: kötelező mezők, alt szöveg, licenc a külső forrású elemeknél,
      „utoljára ellenőrizve" ≤ 6 hónap.

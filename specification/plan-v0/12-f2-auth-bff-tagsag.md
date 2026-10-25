# F2 – Auth BFF, tagság, nyelv

> Cél: skillpass.id belépés a Next.js BFF-en át, tag összekötés a régi fiókkal, referral
> attribúció, nyelv a skillpass szerint, és a régi auth URL-ek működnek.
> Routing: CRITICAL (auth). Skillek: `skillpass-auth`, `skillpass-portal`,
> `skillpass-app-launcher`, `i18n-required`, `security-audit`.

## 1. BFF (apps/web)

- [ ] `templates/portal/lib/auth/oidc-session.ts` átvétele (PKCE, state/nonce, HMAC süti) + a
      18 meglévő unit teszt.
- [ ] Route-ok: `/auth/login`, `/auth/callback`, `/auth/refresh`, `/auth/logout`.
- [ ] Sütik: `a2k_session` (httpOnly, Secure, SameSite=Lax, 7 nap, refresh rotációval),
      `a2k_csrf` (double-submit, SameSite=Strict). Token soha nem JS-ből olvasható helyen.
- [ ] Logout: Hydra logout elfogadás + Kratos browser logout flow a böngésző Cookie headerével (L-13).
- [ ] CSP nonce minden oldalon, `strict-dynamic`.
- [ ] Csendes SSO ellenőrzés (`prompt=none`) a fejlécben „Belépve mint …" állapothoz, nonce ellenőrzéssel.

## 2. Tag összekötés (04 / 3)

- [ ] Callback után: `POST /api/v1/members/session` a backend felé (Bearer = skillpass access token).
- [ ] Backend: `sp_sub` alapján tag; ha nincs, akkor `email_verified` + normalizált e-mail egyezés a
      `legacy_link_candidates`-szel → összekötés, különben új tag (`handle` javaslat a névből, ütközés
      esetén számmal).
- [ ] `a2k_ref` süti feldolgozása első belépéskor: `source_code` és `referred_by_member_id` csak
      akkor íródik, ha még üres (a régi attribúció nyer).
- [ ] Audit: `member.created`, `member.linked`, `referral.attributed`.

## 3. Nyelv (D-V0-05)

- [ ] `resolveLocale(request, session)`: skillpass `locale` → `a2k_locale_hint` → `Accept-Language` → `hu`.
- [ ] `next-intl` prefix nélküli módban, `hu.json` / `en.json` azonos kulcsokkal (CI ellenőrzi).
- [ ] Nincs nyelvváltó UI. A skillpass Account Center nyelvi beállítására deep link a láblécben
      („Nyelv módosítása a SkillPass fiókodban").
- [ ] `Content-Language`, `Vary: Cookie, Accept-Language`.

## 4. Workspace shell a tagi felülethez

- [ ] `AppManifest` (`app_id: ai2know`, accent a régi arculat színe), nav: Csapatom, Kedvenceim,
      Meghívás, Kedvezmények, Felmérés, Támogatás (a végleges lista F4 után).
- [ ] Shell-context lekérés a BFF-ben (`shell:read`, 60 s cache, 10 s negatív cache), fallback
      saját navigáció.
- [ ] App launcher regisztráció (`metadata.launcher`).

## 5. Régi auth URL-ek (megmaradnak, a skillpass felé visznek)

| Régi útvonal | Új viselkedés |
|--------------|---------------|
| `GET /belepes` | `/auth/login?return_to=<előző oldal vagy />` |
| `GET /belepes?logout=true` | `/auth/logout` |
| `POST /belepes`, `POST /kijelentkezes` | 303 → `/auth/login` ill. `/auth/logout` (régi űrlapok) |
| `GET /jelentkezes` | `/auth/login?flow=registration` |
| `GET /jelentkezes/{code}` | `a2k_ref={code}` süti, majd `/auth/login?flow=registration` |
| `GET /elfelejtett-jelszo` | skillpass jelszó-visszaállítás |
| `GET /jelszo-modositas` | Account Center `…/account/security` |
| `GET /profil` | Account Center `…/account/profile` |
| `GET /verify`, `/verify/{token}` | tájékoztató oldal: „a fiókod átkerült a SkillPass-ra" + belépés gomb (régi e-mail linkek) |
| `GET /check-username`, `/check-email` | 410 Gone (Problem) – belső AJAX végpont volt |

## Tesztek

- Unit: PKCE, state/nonce, HMAC aláírás, süti attribútumok, `resolveLocale` minden ága.
- Integráció (backend): összekötés egyező / nem egyező / nem verifikált e-maillel; referral nem
  írja felül a régi attribúciót.
- E2E (Playwright, skillpass test példány): belépés → callback → tagi oldal → logout → csendes SSO
  nem léptet vissza; `/jelentkezes/mkik` → regisztráció → tag `source_code = mkik`.
- Biztonság: token nincs `document.cookie`-ban, nincs localStorage-ben; CSRF hiány → 403.

## Kimenet

- Működő belépés non-prod környezetben, régi auth URL-ek lefedve, összekötés bizonyítva.

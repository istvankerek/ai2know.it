# Plan-v0: ai2know.it újraírás – Rust backend, Next.js frontend, skillpass.id, aibos.space

> Státusz: FELÜLÍRVA a `plan-v1` által (2026-10-18, két felvonás). Referenciaként érvényes marad: `01-legacy-audit.md`, `03-url-atiranyitas-terkep.md`, `04-adatmigracio-modell.md`, valamint a F0 biztonsági pontjai.
> Branch: `main` (még nincs commit; implementáció `feat/*` ágakon)
> Routing: PLAN (architektúra); a fázisok tierje fázisfájlonként megadva.

## Indok (owner kérés, 2026-10-18)

- A `hu.ai2know.it` rendszer (Python FastAPI + Jinja/Bootstrap) teljes átvizsgálása; a fő forrás
  a `hu/`, a többi (en, auth, orders, tracker, …) kiegészítő.
- Újraírás: **Rust backend + Next.js frontend**; auth és felhasználókezelés: **skillpass.id**;
  admin backend: **aibos.space**.
- Adatbázis forrás: `backup/hu.ai2know.it/data/backup/2026-10-17_19-00-01_ai2knowit.sql`.
- Rendszerterv és refaktor, fázisonkénti részletes terv a `specification` mappában.
- Skeleton telepítése a projektbe; a projekt domainje **ai2know.it** (a hu./en. megszűnik).
- Nyelvváltás megszűnik, a nyelv a skillpass.id szerint alakul.
- Minden régi URL átirányítva, az URL-szerkezet megmarad, követéssel
  (`https://hu.ai2know.it/csr` → `https://ai2know.it/csr`).
- A `backup` mappa gitignore.

## Owner döntések (tények – L-01)

| ID | Döntés |
|----|--------|
| D-V0-01 | Backend Rust, frontend Next.js. |
| D-V0-02 | Auth és felhasználókezelés: skillpass.id (saját auth nincs). |
| D-V0-03 | Admin: aibos.space (saját admin felület nincs). |
| D-V0-04 | Egyetlen domain: `ai2know.it`; `hu.ai2know.it` és `en.ai2know.it` megszűnik. |
| D-V0-05 | Nincs nyelvváltás; a nyelv a skillpass.id felhasználói beállításából jön. |
| D-V0-06 | Minden régi URL átirányítva azonos útvonalra, követéssel. |
| D-V0-07 | Fő forrás a `hu/`; a többi kiegészítő. |
| D-V0-08 | Adatforrás a 2026-10-17 19:00-s dump (az éles átálláskor friss dump). |
| D-V0-09 | `backup/` nem kerül gitbe. |

## Javasolt döntések (jóváhagyás kell)

| ID | Javaslat | Indok |
|----|----------|-------|
| P-V0-01 | Repo-szerkezet: `apps/web` (Next.js 16) + `apps/backend` + `crates/a2k-*` (02 / 3) | a testvérprojektek (aibootcamp.hu, aiagentekagyakorlatban.hu) mintája |
| P-V0-02 | Vendég nyelve: `a2k_locale_hint` → `Accept-Language` → `hu`; nincs hreflang | egy URL = egy oldal (D-V0-05) |
| P-V0-03 | A skeleton `apps/frontend`, `apps/admin`, `apps/ai-chat` eltávolítása | Vite appok, nem kellenek; törlés csak jóváhagyással |
| P-V0-04 | Tartalom az aibos-public API-ból (`ai2know-it` portál), egyszeri seed a régi sablonokból | L-12, nincs tartalom a kódban |
| P-V0-05 | Követés a backend `/_legacy` redirectorával, Caddy fallbackkel; IP csak kulcsolt hash; 301 (GET/HEAD) / 308 | a redirect soha nem bukik el, L-10 |
| P-V0-06 | Az üres sablon modulok nem épülnek újra; URL-jük a legközelebbi élő oldalra, a belső API-k 410 | a 42 tábla soha nem kapott adatot |
| P-V0-07 | Felhasználók importja a skillpass.id-be **jelszó-hash nélkül**, első belépés e-mail kóddal (alternatíva: bcrypt hash-ek átvitele) | a régi rendszer nyílt szövegben e-mailezte és naplózta a jelszavakat |
| P-V0-08 | `legacy_link_candidates` (e-mail az összekötéshez) megőrzése 12 hónap, utána törlés | adattakarékosság |
| P-V0-09 | Csak a verifikált fiókok (3 904) kerülnek importra; a többi első belépéskor köthető össze | nem bizonyított e-mail tulajdon |
| P-V0-10 | Telefonszám nem migrál; archívum, majd törlés az átállás + 90 nap után | a portál nem használja |
| P-V0-11 | Business csomag vásárlás `pay.aibos.space` + `invoice.aibos.space`; Számlázz díjbekérő kivezetve | ökoszisztéma kánon |
| P-V0-12 | WooCommerce rendelések nem importálódnak; a backend csak olvas; kupon-tulajdon explicit tábla | a régi regex attribúció pontatlan, PII a cache-ben |
| P-V0-13 | Support jegyek saját táblában, kezelés az aibos-ban; Trello kivezetve | a régi megoldás minden jegyet kiadott bárkinek |
| P-V0-14 | AI felmérés pontozása mind a 25 kérdésre | ma csak 12 számít |
| P-V0-15 | Egy süti banner, Consent Mode v2, GA/OneSignal csak hozzájárulás után | GDPR |
| P-V0-16 | `/feed/` → 410 | 206 k kérés régi RSS olvasóktól |
| P-V0-17 | Az `aitoknow.it` ops aldomainek (pgadmin, c, p, b, o) leállnak, nem irányítanak át | biztonság |

## Ökoszisztéma ellenőrzés

- [x] Auth: skillpass.id OIDC (`skillpass-auth`), saját auth nincs – F2
- [x] Ügyfélfelület: skillpass workspace shell (`skillpass-portal`) a tagi oldalakon – F2
- [x] Admin: aibos.space konzol + contract (`aibos-admin-contract`) – F5
- [x] Tartalom: aibos-public portál-tartalom API – F3
- [x] Pénz: pay / invoice.aibos.space – F4 / 5
- [x] Érzékeny adat: a dump PII, csak helyben, csak helyi modell / Claude (04)

## Dokumentumok

| Fájl | Tartalom |
|------|----------|
| `01-legacy-audit.md` | a régi rendszer átvizsgálása, modulonkénti döntés, biztonsági megállapítások, forgalom |
| `02-celarchitektura.md` | célrendszer, repo-szerkezet, refaktor 50 modulból 7 kontextusba, nyelv, auth, admin, tartalom |
| `03-url-atiranyitas-terkep.md` | host és útvonal szintű redirect térkép, 410 lista, követés, regressziós lista |
| `04-adatmigracio-modell.md` | adatleltár, célséma, felhasználók átvitele a skillpass.id-be, referral megőrzés |
| `90-nyitott-kerdesek.md` | 18 owner kérdés |
| `91-kockazatok.md` | kockázati regiszter |

## Fázisok

| # | Fájl | Tartalom | Függ |
|---|------|----------|------|
| F0 | `10-f0-alapozas.md` | repo, CI, helyi stack, külső regisztrációk, **a régi rendszer azonnali biztonsági javítása** | – |
| F1 | `11-f1-backend-mag.md` | Rust workspace, séma, JWT validáció, publikus contract, outbox | F0 |
| F2 | `12-f2-auth-bff-tagsag.md` | skillpass BFF, tag összekötés, nyelv, workspace shell, régi auth URL-ek | F1 |
| F3 | `13-f3-publikus-frontend-tartalom.md` | nyilvános oldalak, aibos-public tartalom + seed, SEO, consent | F1 (F2-vel párhuzamos) |
| F4 | `14-f4-kozosseg-referral.md` | referral, csapat, affiliate, kedvezmények, business, QR, share, felmérés, Q&A, support | F2 |
| F5 | `15-f5-admin-contract.md` | admin API contract és implementáció az aibos.space felé | F1 (contract már F1 alatt indulhat) |
| F6 | `16-f6-atiranyitas-kovetes.md` | Caddy, redirector, útvonal redirectek, 100% regresszió | F3, F4 |
| F7 | `17-f7-adatmigracio-futtatas.md` | ETL, skillpass import, próbák, egyeztetés | F1, F2, Q-01 |
| F8 | `18-f8-atallas-leallitas.md` | átállás, figyelés, régi rendszer leállítása | minden |

Minden fázis: failing teszt → implementáció → `implementation-notes.md` bejegyzés → validáció →
git save point → non-prod deploy + smoke.

## Elfogadási feltételek

- A régi URL-lista (03 / 5) 100%-a a térkép szerinti státuszt és célt adja, követéssel.
- Belépés és kilépés csak skillpass.id-n át; token nincs JS által olvasható helyen; nincs saját
  jelszókezelés a kódban.
- A tagok és a 142 forrás-kód attribúciója egyezik a forrással (04 / 6).
- Minden régi admin funkció az aibos konzolból érhető el, jogosultsággal és audittal.
- Nincs PII a logokban; nincs nyers IP és telefonszám az `ai2know` sémában.
- Lighthouse ≥ 90, axe 0 kritikus, security scan 0 magas.
- Menüpont soha nem 404 (L-06).

## Telepítés

Non-prod (`local` / `test`) + automatizált smoke. Prod csak az owner „mehet" válasza után (L-03).
Az F0 / 4 (régi éles rendszer biztonsági javítása) is éles művelet: külön „mehet" kell hozzá.

# Plan-v3: ai2know.it – közösségi tudástár, nyitott learning curve, munkaterek

> Státusz: TERVEZET – owner jóváhagyásra vár
> Alap: `../plan-v2/` (érvényes marad mindenben, amit ez a plan nem ír felül – lásd lent).
> Routing: PLAN; fázisonként STANDARD; a fizetős szint, az M2M/webhook biztonság és az éles
> lépések CRITICAL.

## Indok (owner kérés, 2026-10-20)

- **Curve-öt bárki készíthet.** Szintjei: zárt (csak magának), nyilvános, meghívásos, és a
  jövőben fizetős.
- Ez a logika **általánosan a munkaterek szintjén** működjön, és **a csoportoknál is**.
- A **fizetős szintet csak aibos.club partnerek** alkalmazhatják.
- **A superskiller API-t tervezzük meg.**
- **A skillpass.id-hez szükséges dolgokat tervezzük meg.**
- A `/lc` jó, de jobb lehet a **`+` jelölés** (`+learning-curve-neve`), ami **a többi oldalunkon is
  működne**: ha valaki `+nev`-et használ, az egyből bejön.
- **Bárki feltölthet**, a tartalmat **a közösség értékeli és kommenteli**.
- A design **illeszkedjen az aibootcamp.hu stílusához**.

## Owner döntések (tények – L-01)

| ID | Döntés |
|----|--------|
| D-V3-01 | Curve-öt **bárki** (minden belépett tag) készíthet és közzétehet. Szintek: **zárt** (csak magának), **nyilvános**, **meghívásos**, később **fizetős**. |
| D-V3-02 | A szintek egységes hozzáférési logikája **munkatér** és **csoport** szinten is érvényes (nem csak curve-re). |
| D-V3-03 | A **fizetős** szintet csak **aibos.club partner** állíthatja be (munkatér, csoport, curve). |
| D-V3-04 | A curve-ök elérhetők a **`+` jelöléssel** (`+nev`), az ökoszisztéma többi oldalán is. A `/lc` megmarad. |
| D-V3-05 | **Bárki feltölthet** tudáselemet; a **közösség értékel és kommentel**. |
| D-V3-06 | A design az **aibootcamp.hu** stílusát követi. |
| D-V3-07 | A superskiller partner API és a skillpass.id igények ebben a planben **contract-szinten** tervezettek; a megvalósítás a két repó saját plan-jében történik (L-05 contract-first). |

A v2 owner döntései (D-V2-01 … D-V2-08) változatlanul érvényesek.

## Mit ír felül a v2-ből

| v2 | v3 | Miért |
|----|----|-------|
| P-V2-07 (nyilvános közzététel csak `curve_author` képességgel) | **bárki** közzétehet, utólagos moderációval és bizalmi szintekkel (P-V3-10) | D-V3-01 |
| P-V2-08 (hat hozzáférési szabály) | **négy szint** (`private`, `invite`, `public`, `paid`); a hat szabály a **meghívásos** szint meghívási módjai lettek (P-V3-01) | D-V3-01, D-V3-02 |
| P-V2-05 (négy elem-láthatóság) | ugyanaz a négy szint az elemekre is; a `teaser` a **nyilvános szint megjelenítési módja** (P-V3-03) | egy modell mindenre |
| P-V2-12 (`/lc/{slug}`) | kanonikus **`/+{slug}`**, a `/lc/{slug}` 301-alias (P-V3-05) | D-V3-04 |
| 04-integraciok 1–2. fejezet | `05-superskiller-api.md`, `06-skillpass-igenyek.md` | D-V3-07 |
| plan-v1/04-design-mobil (design rész) | `07-design-aibootcamp.md` (a mobil minták maradnak) | D-V3-06 |

## Dokumentumok

| Fájl | Tartalom |
|------|----------|
| `01-hozzaferes-modell.md` | négy szint, egy szabálymotor munkatérre, csoportra, curve-re, elemre; öröklés; fizetős kapu |
| `02-munkater-csoport.md` | munkatér és csoport modell, tagság, szerepek, kapcsolat a skillpass szervezetekkel |
| `03-plusz-url.md` | `+nev` URL és szöveges hivatkozás, ökoszisztéma-szintű feloldás |
| `04-kozossegi-feltoltes.md` | bárki feltölt, értékelés, komment, moderáció, bizalmi szintek, DSA |
| `05-superskiller-api.md` | kétirányú partner contract (végpontok, események, auth, adatminimalizálás) |
| `06-skillpass-igenyek.md` | amit a skillpass.id-nek építenie kell, prioritással |
| `07-design-aibootcamp.md` | tokenek, tipográfia, komponensek, elemtípus-színek, curve-lejátszó |
| `08-dontesek-indoklassal.md` | **minden új javaslat: mit, miért, alternatíva, következmény** |
| `10-fazis-modositasok.md` | a v2 F0–F7 fázisainak változásai + új F11 (fizetős szint) |
| `90-nyitott-kerdesek.md`, `91-kockazatok.md`, `implementation-notes.md` | |

## Fázisok (összefoglaló, részletek: `10-fazis-modositasok.md`)

| # | Tartalom | Változás a v2-höz képest |
|---|----------|--------------------------|
| F0 | alapozás, biztonság, contractok | + `contracts/partner/ai2know-superskiller.v1.yaml`, skillpass igénylista átadása |
| F1 | tudásmag backend | + munkatér, csoport, **közös hozzáférés-motor**, közösségi feltöltés, értékelés, komment |
| F2 | web váz, belépés | + aibootcamp design tokenek, `+` útvonal, `@` munkatér oldalak |
| F3 | katalógusok | + feltöltés UI, értékelés/komment UI, közösségi rangsor |
| F4 | learning curve | bárki készít; négy szint; meghívási módok |
| F5 | integrációk | superskiller contract megvalósítás (ai2know oldal), skillpass igények bekötése |
| F6 | aibos admin, moderáció | + DSA bejelentés-kezelés, bizalmi szintek, moderációs sor |
| F7 | élesítés | + `+` linkek ökoszisztéma-smoke (Caddy szabály minden domainen) |
| **F11** | **fizetős szint** (új, élesítés után) | aibos.club partner kapu, pay.aibos.space, skillpass entitlement |

## Elfogadási feltételek (a v2-n felül)

- Belépett tag 3 lépésben létrehoz egy curve-öt, és zártra / meghívásosra / nyilvánosra állítja;
  a jogosultság-mátrix teszt (4 szint × 4 objektum × 5 szereplő) zöld.
- `https://ai2know.it/+ai-marketing-alapok` megnyitja a curve-öt; ugyanez a
  `aibootcamp.hu/+ai-marketing-alapok`, `superskiller.com/+…`, `skillpass.id/+…` címekről 302-vel.
  Zárt curve-nél jogosulatlan látogató 404-et kap (nem szivárog a létezése).
- Tag feltölt egy promptot; a közösség értékeli (1–5) és kommenteli; a bejelentés (DSA) a konzolban
  megjelenik, a döntésről a feltöltő indoklást kap.
- Fizetős szint a UI-ban csak ellenőrzött aibos.club partnernek jelenik meg; API-n is 403 másnak.
- A felület tokenjei megegyeznek az aibootcamp.hu tokenjeivel (light + dark), axe 0 kritikus.

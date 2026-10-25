# Plan-v2: ai2know.it – AI tudásközpont és Learning Curve platform

> Státusz: TERVEZET – owner jóváhagyásra vár
> Felülírja: `plan-v1` (és a `plan-v0` ütemezését). Referenciaként érvényes marad:
> `../plan-v0/01-legacy-audit.md`, `../plan-v0/03-url-atiranyitas-terkep.md`,
> `../plan-v0/04-adatmigracio-modell.md` (II. felvonás), `../plan-v1/02-katalogus-motor.md`
> (keresés), `../plan-v1/04-design-mobil.md` (mobil, design).
> Routing: PLAN; fázisonként STANDARD, a II. felvonás és az éles lépések CRITICAL.

## Indok (owner kérés, 2026-10-20)

- A döntéseknél legyen leírva, **mit és miért** javaslok → `05-dontesek-indoklassal.md`.
- Belépés nélkül **bizonyos mennyiség legyen látható**, annyi, ami marketingre és SEO-ra jó;
  **a lényeg belépés után**.
- A superskiller.com-mal **összehangolás** kell, nem átvétel.
- Az ai2know.it olyan rendszer, ahol **képzések, workshopok, események után egyedi
  learning curve-öket** lehet készíteni és megosztani – mint egy YouTube playlist, de bármivel a
  tudástárból (linkek, videók, promptok, minden). **Jogosultság rendelhető hozzá.**
- A learning curve-ök **megjelennek a skillpass.id-n**: ki készítette, hányan végezték el, mik a
  visszajelzések; aki elvégzett egyet, annál is megjelenik.
- Típusok: **promptok, linkek, videók (YouTube és bárhonnan), tutorialok, skillek, MCP-k,
  guardrailek, evalok, compliance guide-ok, szerepkörök** (skillek, MCP-k, guardrailek stb.
  gyűjteménye).
- Ezek **mind az ai2know.it-en tárolódnak**, és **mindenhonnan ide hivatkoznak**.
- A tudástár **bekerül a superskillerbe** is, és a superskiller e-learningjei, csoportjai,
  posztjai, tartalmai **behozhatók a learning curve-be**.
- Az „illetve hozzu…" véletlen maradt – lezárva.
- Változatlan: két felvonás; az ügyfélmigráció skillpass.id-be külön kör.

## Owner döntések (tények – L-01)

| ID | Döntés |
|----|--------|
| D-V2-01 | Két felvonás: **I.** tudásközpont + learning curve; **II.** ügyfélmigráció skillpass.id-be külön körben. |
| D-V2-02 | Az ai2know.it a **tudáselemek forrásrendszere** (system of record): itt tárolódnak, mindenhonnan ide hivatkoznak (aiagentek, superskiller, aibootcamp, skillpass). |
| D-V2-03 | Elemtípusok: prompt, link, videó (bármely forrás), tutorial, skill, MCP, guardrail, eval, compliance guide, szerepkör (gyűjtemény). |
| D-V2-04 | **Learning curve**: képzés/workshop/esemény után készülő, megosztható, sorba rendezett elemlista bármely tudáselemből, jogosultsággal. |
| D-V2-05 | A learning curve-ök a skillpass.id-n megjelennek: készítő, elvégzők száma, visszajelzések; az elvégzés a felhasználó profilján. |
| D-V2-06 | Belépés nélkül korlátozott, marketingre/SEO-ra elég tartalom; a lényeg belépés után. |
| D-V2-07 | superskiller.com: összehangolás; a tudástár bekerül a superskillerbe, a superskiller e-learning, csoport, poszt és tartalom behozható a learning curve-be. |
| D-V2-08 | A plan-v0 alapdöntései érvényesek: Rust + Next.js, skillpass.id auth, aibos.space admin, egy domain (`ai2know.it`), nincs nyelvváltás, régi URL-ek követett 301-gyel. |

## Dokumentumok

| Fájl | Tartalom |
|------|----------|
| `01-termekkoncepcio.md` | mi az ai2know.it, szereplők, fő felhasználói utak |
| `02-tudaselem-modell.md` | típusok (szerepkör, compliance guide is), láthatósági szintek, verziók, „mindenhonnan ide hivatkozás" |
| `03-learning-curve.md` | learning curve modell, jogosultság, életciklus, haladás, visszajelzés, statisztika, megosztás |
| `04-integraciok.md` | skillpass.id, superskiller.com, aibos.space, aiagentek / aibootcamp, videóforrások |
| `05-dontesek-indoklassal.md` | **minden javaslat: mit, miért, mi az alternatíva, mi a következmény** |
| `90-nyitott-kerdesek.md`, `91-kockazatok.md`, `implementation-notes.md` | |

## Fázisok

### I. felvonás – tudásközpont és learning curve

| # | Fájl | Tartalom | Függ |
|---|------|----------|------|
| F0 | `10-f0-alapozas-biztonsag.md` | repo, CI, helyi stack, **régi rendszer biztonsági javítása**, külső regisztrációk | – |
| F1 | `11-f1-tudasmag-backend.md` | tudáselem-modell, láthatóság, keresés, publikus/partner API, aiagentek könyvtár átköltöztetése az aibos-ból | F0 |
| F2 | `12-f2-web-vaz-belepes.md` | Next.js váz, mobil design, skillpass belépés, láthatósági kapuk, kezdőlap, kereső | F0 |
| F3 | `13-f3-katalogusok.md` | típusonkénti katalógusok és részletoldalak, szerepkör és compliance guide nézet | F1, F2 |
| F4 | `14-f4-learning-curve.md` | learning curve szerkesztő, megosztás, jogosultság, haladás, visszajelzés, statisztika | F3 |
| F5 | `15-f5-integraciok.md` | skillpass megjelenítés, superskiller kétirányú kapcsolat, aiagentek/aibootcamp hivatkozások, beágyazás | F4 |
| F6 | `16-f6-admin-tartalom.md` | aibos admin contract, moderáció, tartalom seed és bővítés | F1 |
| F7 | `17-f7-elesites-i.md` | test → prod („mehet"), részleges redirect, SEO, figyelés | F3–F6 |

### II. felvonás – ügyfélmigráció skillpass.id-be (külön kör)

| # | Fájl | Tartalom |
|---|------|----------|
| F8 | `20-f8-skillpass-migracio.md` | tagok importja/összekötése, referral attribúció (v0/04) |
| F9 | `21-f9-tagi-funkciok.md` | csapatom, meghívás, affiliate, business, partnerek (v0 F4) |
| F10 | `22-f10-atallas-leallitas.md` | teljes átirányítás, régi rendszer leállítása (v0 F8) |

Minden fázis: failing teszt → implementáció → `implementation-notes.md` → validáció → git save
point → non-prod deploy + smoke. Prod csak „mehet" után (L-03).

## Elfogadási feltételek – I. felvonás

- Mind a 10 elemtípus kereshető és szűrhető; stabil kód és kanonikus URL minden elemhez.
- Belépés nélkül: minden lista és teaser látszik, a kiválasztott nyilvános minta teljes; a teljes
  tartalom belépés után. A keresők a teaser oldalakat indexelik (paywall strukturált adattal).
- Learning curve: létrehozás eseményből/workshopból, megosztás linkkel és QR-ral, jogosultság
  (nyilvános / link / kohorsz / jogosultság-kód / név szerint), haladáskövetés, visszajelzés,
  statisztika; elvégzés megjelenik a skillpass.id profilon.
- superskiller: egy superskiller e-learning lecke és egy csoport/poszt felvehető curve lépésnek;
  egy ai2know elem beágyazható a superskillerben.
- Az aiagentek könyv nyomtatott tools URL-jei 301-gyel az ai2know.it elemeire visznek, 0 törés.
- Mobil Core Web Vitals zöld, Lighthouse ≥ 90, axe 0 kritikus; menüpont soha nem 404.

# Plan-v1: ai2know.it – AI tudásbázis (I. felvonás) + ügyfélmigráció skillpass.id-be (II. felvonás)

> Státusz: FELÜLÍRVA a `plan-v2` által (2026-10-20: learning curve koncepció, ai2know.it mint a tudáselemek forrásrendszere). Referenciaként érvényes: `02-katalogus-motor.md` (keresés), `04-design-mobil.md`, `03-tartalom-forrasok-atvetel.md` 1. és 2.1 fejezet.
> Felülírja: `plan-v0` ütemezését. A v0 referenciaként érvényes dokumentumai:
> `../plan-v0/01-legacy-audit.md`, `../plan-v0/03-url-atiranyitas-terkep.md`,
> `../plan-v0/04-adatmigracio-modell.md`, és a v0 F0 biztonsági pontjai.
> Routing: PLAN (architektúra); fázisonként STANDARD, a II. felvonás CRITICAL (PII, migráció).

## Indok (owner kérés, 2026-10-18)

- A régi oldal szerkezete használható, de **mobilon gyenge** – fel kell erősíteni.
- Az érdemi tartalmú oldalak (`/linkek`, `/videok`, `/appok`, `/ai-kerdesek-es-valaszok`,
  `/kedvezmenyek`, `/qrcode`) legyenek **profi keresők**, az aiagentekagyakorlatban.hu
  promptkeresőjének mintájára (és annál jobbak). A mostani „tools" rész gyenge.
- Az új oldal **valódi AI tudásbázis** legyen, modernebb, jobb szerkezettel.
- Ide kerüljön át a **tools rész az aiagentekagyakorlatban.hu-ról és a superskiller.com-ról**.
- **Két felvonás:** előbb az új oldal és a feljavított szerkezet; az **ügyfelek átmigrálása
  skillpass.id-be külön kör**.

## Átvizsgálás – ami a tervet meghatározza

| Forrás | Tény |
|--------|------|
| hu.ai2know.it tartalom | kicsi: 42 link (5 kategória), 11 videó, ~50 app-elérési link (főleg ChatGPT platformok), 2 kedvezmény, ~20 cheat sheet, üres promptoldal, Q&A törött XSS-sel – **seed, nem tudásbázis** |
| aiagentekagyakorlatban.hu „Eszközök" | **~460 könyvtárelem** (30 prompt, ~339 skill, 32 MCP, 30 guardrail, 30 eval), **~300 szócikk**, 7 eszköztár-pillér, interaktív modulok (LLM működése, Doodle AI), önteszt, felmérő. Adat az **aibos**-ban (`aibos_schema.prompt_library_*`, könyvhöz kötve), keresés kliens oldali részszó-egyezés, URL-állapot és lapozás nélkül |
| aiagentek nyomtatott URL-ek | a könyvben nyomtatott QR/URL (`qrcd.click/3/eszkoztar`, `/eszkoztar`, könyvtár URL-ek) „soha nem törhet" → átköltöztetésnél **örök 301** kell az eredeti hoston |
| superskiller.com | **nincs tools rész** (az „Eszközök" menü 2026-08-29-én költözött az aiagentek repóba); van egy üres `/tudastar` és egy skill-katalógus – Q-V1-02 |

## Owner döntések (tények – L-01)

| ID | Döntés |
|----|--------|
| D-V1-01 | Két felvonás: **I.** új ai2know.it tudásbázis feljavított, mobilbarát szerkezettel; **II.** ügyfélmigráció skillpass.id-be külön körben. |
| D-V1-02 | A tartalmas oldalak (linkek, videók, appok, kedvezmények, Q&A, QR) profi, kereshető katalógusok lesznek, a aiagentek promptkereső mintájára. |
| D-V1-03 | Az aiagentekagyakorlatban.hu tools része az ai2know.it-re költözik (superskiller-ből is, ha van – lásd Q-V1-02). |
| D-V1-04 | A plan-v0 döntései (D-V0-01…09) érvényesek: Rust + Next.js, skillpass.id, aibos.space, egy domain, nincs nyelvváltás, régi URL-ek követett 301-gyel. |

## Javasolt döntések (jóváhagyás kell)

| ID | Javaslat | Indok |
|----|----------|-------|
| P-V1-01 | **Egységes katalógus-motor** minden tudáselem-típusra (eszköz/app, link, videó, prompt, skill, MCP, guardrail, eval, szócikk, segédanyag, kedvezmény, kérdés-válasz) – egy adatmodell, egy keresőfelület, típusonként saját mezők (02) | a mostani 5+ külön böngésző helyett egy, jól tesztelt komponens |
| P-V1-02 | **A tartalom forrása az aibos marad**: a meglévő `prompt_library` táblák általánosítása „knowledge catalog"-gá, **portálhoz** (nem csak könyvhöz) kötve; az ai2know.it kapja a tulajdonjogot, az aiagentek elemei átkerülnek (03) | a 460 elem, a statisztikák, értékelések, kommentek, kérés-folyamat és a konzol már ott van; L-12 (tartalom aibosból) |
| P-V1-03 | **A keresés az ai2know.it Rust backendjében**: olvasó-modell (aibos → szinkron), PostgreSQL FTS magyar szótővel + `unaccent` + `pg_trgm` elírástűrés, facettás szűrés, URL-ben tárolt állapot; szemantikus keresés (Qdrant) a 2. körben (02) | SEO-barát, mobilon gyors, 10 000+ elemre skálázik |
| P-V1-04 | I. felvonásban **a böngészés nyilvános**; belépés (skillpass.id) csak a személyes funkciókhoz: kedvenc, értékelés, komment, kérés, kuponkód felfedése, mentett QR | SEO + a könyv „belépéssel kapod" ígérete teljesül (bármely skillpass fiók) |
| P-V1-05 | I. felvonás alatt a **hu.ai2know.it tovább fut** a tagi funkciókra (belépés, csapatom, business, affiliate); csak a tartalmi URL-ek mennek 301-gyel az ai2know.it-re (Caddy szinten, a régi kódhoz nem nyúlunk) | a régi felhasználók nem veszítik el a belépést a II. felvonásig |
| P-V1-06 | A régi oldal **biztonsági javítása** (v0 F0/4) az I. felvonás első lépése, mert a régi rendszer tovább fut | a nyitott backup szolgáltatás és a kitett titkok nem várhatnak |
| P-V1-07 | **Mobile-first** dizájn: alsó navigációs sáv, teljes képernyős kereső, alulról nyíló szűrőpanel, 44 px érintési célok, Core Web Vitals mobilon is zöld (04) | a fő panasz a mobil |
| P-V1-08 | Az aiagentek tools URL-jei **örökre 301-et adnak** az ai2know.it megfelelő címére, az elemkód (`code`) és a slug megmarad; a `qrcd.click/3/eszkoztar` sor átírható (03) | nyomtatott könyv |

## Dokumentumok

| Fájl | Tartalom |
|------|----------|
| `01-tudasbazis-informacios-architektura.md` | menü, szekciók, URL-ek, kezdőlap, globális kereső |
| `02-katalogus-motor.md` | egységes adatmodell, típusok, keresés, facetták, részletoldal, közösségi funkciók |
| `03-tartalom-forrasok-atvetel.md` | régi seed, aiagentek átvétel, redirectek, superskiller |
| `04-design-mobil.md` | design rendszer, mobil minták, akadálymentesség, teljesítmény |
| `90-nyitott-kerdesek.md`, `91-kockazatok.md`, `implementation-notes.md` | |

## Fázisok

### I. felvonás – az új tudásbázis

| # | Fájl | Tartalom | Függ |
|---|------|----------|------|
| F0 | `10-f0-alapozas-biztonsag.md` | repo, CI, helyi stack, régi rendszer biztonsági javítása, külső regisztrációk | – |
| F1 | `11-f1-katalogus-backend.md` | aibos katalógus általánosítás + ai2know olvasó-modell, keresés, API | F0 |
| F2 | `12-f2-web-vaz-design.md` | Next.js váz, design rendszer, mobil navigáció, kezdőlap, globális kereső, skillpass belépés (könnyű) | F0 |
| F3 | `13-f3-katalogusok.md` | katalógus-motor UI + szekciók: Appok/Eszközök, Linkek, Videók, Kedvezmények, Promptok…Evalok, Szótár, Segédanyagok, Kérdések | F1, F2 |
| F4 | `14-f4-eszkozok-atvetel.md` | Eszköztár pillérek, interaktív modulok, QR generátor, AI felmérés, aiagentek redirectek | F3 |
| F5 | `15-f5-tartalom-admin.md` | tartalom seed + bővítés, aibos konzol (DLA), kérés-folyamat, minőségkapuk | F1 |
| F6 | `16-f6-elesites-i.md` | test → prod (mehet), részleges redirect a régi hostokról, SEO, figyelés | F3–F5 |

### II. felvonás – ügyfélmigráció skillpass.id-be (külön kör)

| # | Fájl | Tartalom | Függ |
|---|------|----------|------|
| F7 | `20-f7-skillpass-migracio.md` | felhasználók importja / összekötése, referral attribúció (v0 04 alapján) | F6 |
| F8 | `21-f8-tagi-funkciok.md` | csapatom, meghívás, affiliate, business, partnerek az új rendszerben (v0 F4) | F7 |
| F9 | `22-f9-atallas-leallitas.md` | teljes átirányítás, régi rendszer leállítása (v0 F8) | F8 |

Minden fázis: failing teszt → implementáció → `implementation-notes.md` → validáció → git save
point → non-prod deploy + smoke. Prod csak „mehet" után (L-03).

## Elfogadási feltételek – I. felvonás

- Minden katalógus kereshető, szűrhető, az állapot URL-ben van (megosztható, vissza gomb működik).
- Keresés p95 < 150 ms szerver oldalon; elírástűrő (pl. „chatgtp" → ChatGPT); ékezet nélkül is talál.
- Mobil (Moto G Power / iPhone SE profil): LCP < 2,5 s, INP < 200 ms, CLS < 0,1; Lighthouse ≥ 90.
- Minden régi tartalmi URL (hu./en.) és minden aiagentek tools URL a térkép szerint 301-et ad,
  követéssel; 0 törött nyomtatott URL.
- Elemenként indexelhető részletoldal (kanonikus URL, strukturált adat), sitemap.
- Menüpont soha nem 404 (L-06); axe 0 kritikus.

## Elfogadási feltételek – II. felvonás

A `plan-v0/04` 6. fejezete és a `plan-v0` elfogadási feltételei (tagok, 142 forrás-kód, admin, PII).

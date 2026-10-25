# 05 – Javasolt döntések indoklással

> Minden javaslatnál: **Mit** javaslok · **Miért** · **Alternatíva és miért nem** ·
> **Következmény** · **Visszafordíthatóság**. A jóváhagyott javaslatból `D-V2-xx` döntés lesz.

---

## A. Architektúra és adat

### P-V2-01 – A tudáselemek és curve-ök az ai2know.it saját adatbázisában élnek; az aibos csak admin felület

- **Mit:** PostgreSQL `ai2know` séma a Rust backendben: elemek, verziók, curve-ök, haladás,
  visszajelzés, keresési index. Az aibos.space konzol az ai2know admin API-ján (contract) kezeli.
- **Miért:** az owner döntése szerint az ai2know.it a forrásrendszer, ide hivatkozik minden (D-V2-02).
  A curve-ök elemekre, verziókra, jogosultságokra és haladásra épülnek – ezek közé idegen kulcs és
  tranzakció kell; két rendszer között ez lassú és törékeny lenne.
- **Alternatíva:** a v1 javaslata (tartalom az aibos-ban, ai2know csak olvasó). Nem ezt javaslom,
  mert akkor az ai2know nem lenne forrásrendszer, a curve-ök idegen adatra hivatkoznának, és az
  ökoszisztéma szabálya szerint az aibos nem tárolhat ügyfél-példányadatot (haladás, visszajelzés).
- **Következmény:** a 461 aiagentek elemet, a ~300 szócikket és a statisztikáikat át kell költöztetni
  az aibos-ból (F1); az aibos-public prompt-library végpontjai kivezetésre kerülnek. Ez tudatos
  eltérés a „tartalom az aibos-ból jön" (L-12) szabálytól – az ai2know maga a tartalomplatform.
- **Visszafordíthatóság:** közepes – a contract miatt az admin oldal független a tárolás helyétől.

### P-V2-02 – Stabil elemkód, kanonikus URL, publikus és partner API, oEmbed beágyazás

- **Mit:** minden elem `code`-ja örök (`/elem/{code}`), olvasó API, partner API, beágyazható kártya,
  oEmbed szolgáltató, rövid link `/e/{code}`.
- **Miért:** „mindenhonnan ide hivatkoznak" – a hivatkozás csak akkor tartós, ha a kód és az URL nem
  változik; az oEmbed-et a superskiller, blogok és Notion-szerű eszközök is értik.
- **Alternatíva:** csak URL-ek (slug). A cím változásával a slug változik → törött hivatkozások.
- **Következmény:** kódkiosztási szabály típusonként; a slug változás 301-et ad.
- **Visszafordíthatóság:** a kódok soha nem változhatnak (ez a lényeg).

### P-V2-03 – Keresés a backendben PostgreSQL FTS-sel (magyar szótő + ékezetfüggetlen + elírástűrés)

- **Mit:** a v1/02 szerinti szerver oldali keresés facettákkal, URL-állapottal; szemantikus
  (Qdrant) keresés csak mért igény esetén.
- **Miért:** SEO-barát (szerver render), mobilon kevés JS, 10 000+ elemre skálázik; a meglévő
  aiagentek kereső kliens oldali részszó-egyezés – 500 elem felett már lassú és pontatlan.
- **Alternatíva:** külön keresőmotor (Meilisearch/Typesense) – jobb elírástűrés, de új üzemeltetett
  komponens; induláskor nem éri meg. Később beköthető, az API nem változik.
- **Következmény:** magyar FTS konfiguráció, szinonimaszótár karbantartása.
- **Visszafordíthatóság:** magas.

### P-V2-04 – Verziózott közzététel elemeknél és curve-öknél

- **Mit:** minden közzététel változtathatatlan verzió; a felvett résztvevő a saját verzióján marad.
- **Miért:** az elvégzés és a visszajelzés csak akkor hiteles, ha tudjuk, *mit* végzett el; a
  skillpass-on megjelenő elvégzés nem változhat utólag a háta mögött.
- **Alternatíva:** egyszerű szerkesztés verzió nélkül – egyszerűbb, de a statisztika és az igazolás
  értelmét veszti.
- **Következmény:** pillanatkép-tárolás (JSON), „frissítés új verzióra" funkció.
- **Visszafordíthatóság:** alacsony (adatmodell-szintű).

---

## B. Láthatóság és belépés

### P-V2-05 – Négy láthatósági szint, alapértelmezett „teaser", 10–15% nyilvános minta típusonként

- **Mit:** `public` / `teaser` / `members` / `restricted` (02/3). Belépés nélkül minden lista, cím,
  összefoglaló és rövid előnézet látszik; a teljes tartalom belépés után.
- **Miért:** az owner kérése: annyi legyen látható, ami marketingre és SEO-ra elég, a lényeg belépés
  után. A teaser oldal indexelhető (a keresők a címet, összefoglalót, metaadatot rangsorolják), a
  nyilvános minta bizalmat épít („ilyen minőséget kapsz"), a zárt rész regisztrációra ösztönöz.
  Mivel a skillpass regisztráció ingyenes, a kapu valójában **lead-gyűjtés**, nem fizetőfal.
- **Alternatíva 1:** minden nyilvános (v1 javaslat) – több SEO, de nincs ok regisztrálni, nincs
  közönségépítés. **Alternatíva 2:** minden zárt – nincs SEO, nincs marketing.
- **Következmény:** szerkesztői feladat a minta kijelölése; a strukturált adat fizetőfal-jelölése
  kötelező, különben a kereső „cloaking"-ként büntetheti.
- **Visszafordíthatóság:** magas – elemenként állítható.

### P-V2-06 – Szócikkek, eszköztár-pillérek és nyilvános curve-vázlatok mindig nyilvánosak

- **Mit:** a `term`, `pillar` típus teljesen nyilvános; nyilvános curve-nél a lépések címe is.
- **Miért:** ezek hozzák a legtöbb „mi az a …" keresést, és ezek vezetnek a zárt elemekhez.
- **Alternatíva:** ezek is teaserek – rontaná a SEO-t, kevés haszonnal.
- **Visszafordíthatóság:** magas.

---

## C. Learning curve

### P-V2-07 – Curve-öt minden tag készíthet privátan; nyilvánosan közzétenni csak „curve_author" képességgel

- **Mit:** mindenki készíthet saját (privát, link-megosztású) curve-öt; nyilvános, kereshető curve
  csak jóváhagyott készítőtől (oktató, partner) – a képességet az aibos konzolban kapja.
- **Miért:** a nyilvános curve-ök az oldal kirakata (minőség, spam ellen); a privát curve a tagi
  érték (mint a saját playlist).
- **Alternatíva:** mindenki nyilvánosan publikálhat – moderációs teher, minőségi kockázat.
- **Visszafordíthatóság:** magas.

### P-V2-08 – Hat hozzáférési szabály, DENY alapból, VAGY kapcsolattal

- **Mit:** nyilvános, link, kohorsz-kód/QR, skillpass jogosultság, név szerinti, e-mail domain (03/3).
- **Miért:** lefedi a valós eseteket: workshop (kód/QR), fizetős képzés (jogosultság), céges
  tréning (domain), mentorálás (név szerint), marketing (nyilvános).
- **Alternatíva:** csak nyilvános/privát – a workshop és a fizetős eset nem kezelhető.
- **Következmény:** a curve-ön belül a `restricted` elem a jogosultnak látszik (képzési anyag).
- **Visszafordíthatóság:** magas (szabályok bővíthetők).

### P-V2-09 – Lépéstípusok: ai2know elem, külső objektum (superskiller, bármely URL), feladat

- **Mit:** a curve lépése lehet tudáselem (verzióval), külső hivatkozás pillanatkép-metaadattal,
  vagy szöveges feladat.
- **Miért:** az owner kérése szerint a superskiller e-learning, csoport, poszt is behozható; a
  workshopok gyakran adnak „csináld meg ezt" feladatot.
- **Alternatíva:** csak ai2know elem – minden külső tartalmat előbb fel kellene vinni elemként.
- **Következmény:** külső hozzáférés-állapot és webhook a superskillertől (Q-V2-02).
- **Visszafordíthatóság:** magas.

### P-V2-10 – Elvégzés kézi jelöléssel + automatikus jelekkel; nincs videónézési idő mérés

- **Mit:** „kész" gomb, automatikus jel megnyitásra/másolásra/letöltésre/superskiller webhookra.
- **Miért:** egyszerű, forrásfüggetlen, adatvédelmileg tiszta; a curve célja a tanulás támogatása,
  nem a vizsgáztatás (az a superskiller).
- **Alternatíva:** lejátszási idő mérése – csak YouTube-nál működne, sütiket és hozzájárulást igényel.
- **Visszafordíthatóság:** magas (kvíz/ellenőrzés a 2. körben bekapcsolható).

### P-V2-11 – Visszajelzés csak elvégzés (vagy ≥ 50% haladás) után; kis számnál nincs átlag

- **Mit:** értékelés 1–5 + szöveg, „ellenőrzött" jelölés elvégzésnél; < 5 értékelésnél csak darabszám.
- **Miért:** hiteles visszajelzés a skillpass-on is (owner kérés), és a kis csoportban ne legyen
  azonosítható, ki mit írt.
- **Visszafordíthatóság:** magas.

### P-V2-12 – Elnevezés: „Learning curve", URL `/lc/{slug}`, csatlakozás `/csatlakozas`

- **Mit:** a termékfogalom „Learning curve" (az owner szóhasználata), rövid, nyomtatható URL.
- **Miért:** megkülönbözteti a superskiller „Utak" fogalmától; a rövid URL QR-ban és szóban is jó.
- **Alternatíva:** „Tanulási út" (`/tanulasi-utak`) – ütközik a superskiller szóhasználatával.
- **Visszafordíthatóság:** közepes (URL-ek nyomtatásba kerülhetnek – döntsünk élesítés előtt).

### P-V2-13 – Másolás (fork) a készítő megnevezésével, ha a készítő engedi

- **Miért:** oktatók egymás curve-jeiből építkeznek; a megnevezés a skillpass „Készítette" értékét növeli.

---

## D. Integrációk

### P-V2-14 – Elvégzés a skillpass-on a meglévő `trainings:write` API-val

- **Mit:** felvételkor `enrolled`, haladáskor `in_progress`, elvégzéskor `completed` +
  `certificate_url` + `entity_ref`.
- **Miért:** a skillpass API ma is megvan, nem kell új fejlesztés a skillpass oldalon; az
  `entity_ref` miatt a felhasználó „ellenőrzött" értékelést is írhat a skillpass-on.
- **Alternatíva:** új, curve-specifikus skillpass API – több munka, ugyanaz az eredmény.
- **Visszafordíthatóság:** magas.

### P-V2-15 – „Készítette" a skillpass-on: contribution rekord + publikus összesítő végpont

- **Mit:** a készítő profilján a curve megjelenik elvégzők számával és értékeléssel; az adat az
  ai2know publikus összesítőjéből jön.
- **Miért:** az owner kérése (ki készítette, hányan végezték el, visszajelzések); az összesítő
  személyes adat nélküli.
- **Következmény:** **új skillpass képesség kell** (passport-api `community_contribution` push vagy
  külső összesítő megjelenítése) – a skillpass repóban külön plan (Q-V2-01).

### P-V2-16 – superskiller: kétirányú hivatkozás, nincs adatmásolás, közös contract

- **Mit:** az ai2know elemek beágyazva a superskillerben; a superskiller objektumai curve lépésként;
  elvégzés-webhook; közös fogalomtár („AI skill" vs. „Kompetencia").
- **Miért:** az owner szerint összehangolás kell, nem átvétel; mindkét rendszer a saját adatának
  gazdája, így nincs szinkronhiba és GDPR-többlet.
- **Alternatíva:** a superskiller tartalmak másolása az ai2know-ba – elavulás, kettős jogosultság.
- **Következmény:** a superskiller oldalon partner API és webhook kell (Q-V2-02).

### P-V2-17 – Az aiagentek könyvtár az ai2know-ra költözik, a nyomtatott URL-ek örök 301-gyel

- **Miért:** D-V2-02 (minden itt tárolódik) + a könyv nyomtatott URL-jei nem törhetnek.

### P-V2-18 – Videó bármely forrásból oEmbed-del, „lite" beágyazással

- **Miért:** „YouTube és mindenhonnan" (owner); a lite beágyazás gyors mobilon és nem tölt sütit
  hozzájárulás előtt.

---

## E. Megvalósítás és bevezetés (a v0/v1-ből megtartva, indoklással)

| ID | Mit | Miért |
|----|-----|-------|
| P-V2-19 | A régi rendszer biztonsági javítása az I. felvonás első lépése | a hu.ai2know.it a II. felvonásig fut; a nyitott backup szolgáltatás és a kitett titkok nem várhatnak |
| P-V2-20 | Az I. felvonás alatt a régi oldal fut a tagi funkciókkal; csak a tartalmi URL-ek mennek 301-gyel | a régi tagok nem veszítik el a belépést a migrációig; a tartalom már az új helyen gyűjt SEO-t |
| P-V2-21 | Mobile-first design (alsó tab sáv, teljes képernyős kereső, alulról nyíló szűrő, curve lejátszó lapozással) | a fő panasz a mobil; a workshop résztvevők QR-ról, telefonon érkeznek |
| P-V2-22 | Repo: `apps/web` (Next.js 16) + `apps/backend` + `crates/a2k-*` | a testvérprojektek mintája, közös tudás és eszközök |
| P-V2-23 | A skeleton Vite appjainak (`apps/frontend`, `apps/admin`, `apps/ai-chat`) eltávolítása | nem kellenek; törlés csak jóváhagyással (3. aranyszabály) |
| P-V2-24 | Nyelv: skillpass `locale` → hint süti → `Accept-Language` → `hu`; nincs nyelvi URL-előtag | D-V0-05 (nincs nyelvváltás); egy URL = egy oldal |
| P-V2-25 | Admin az aibos konzolban contracton át, jogosultság `ai2know.{modul}.{akció}`, append-only audit | ökoszisztéma kánon; partner nem épít admin UI-t |

## F. II. felvonás döntései (változatlanul a v0 szerint, röviden indokolva)

| ID | Mit | Miért |
|----|-----|-------|
| P-V0-07 | Felhasználók importja a skillpass.id-be jelszó-hash nélkül, első belépés e-mail kóddal | a régi rendszer nyílt szövegben e-mailezte és naplózta a jelszavakat; 169 fiók azonos jelszavú |
| P-V0-08 | Az összekötéshez tárolt e-mail 12 hónap után törlődik | adattakarékosság |
| P-V0-09 | Csak verifikált fiókok importja (3 904), a többi első belépéskor köthető össze | nem bizonyított e-mail tulajdon |
| P-V0-10 | Telefonszám nem migrál | nincs rá cél, GDPR |
| P-V0-11…13 | Business csomag aibos pay/invoice-szal; WooCommerce csak olvasva; support saját táblában | ökoszisztéma kánon; a régi megoldások adatot szivárogtattak |

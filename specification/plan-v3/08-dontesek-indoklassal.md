# 08 – Javaslatok indoklással (plan-v3)

Formátum: **mit** javaslok · **miért** · **alternatíva és miért nem** · **következmény** ·
**visszafordíthatóság**. A v2 javaslatai (`../plan-v2/05-dontesek-indoklassal.md`) érvényesek, kivéve
az itt felülírtakat (P-V2-05 részben, P-V2-07, P-V2-08, P-V2-12, P-V2-15).

## A. Hozzáférés

### P-V3-01 – Négy szint, a meghívási módok a „meghívásos" szint alatt

- **Mit:** `private`, `invite`, `public`, `paid`; a v2 hat szabálya (link, kód, név, domain + új:
  munkatér, csoport) a meghívásos szint módjai.
- **Miért:** a felhasználó négy dolgot ért meg könnyen, és ezt kérted. A hat szabály mint „mód" megmarad,
  de nem terheli a választást.
- **Alternatíva:** a v2 hat szabálya egyenrangúan – túl sok döntés a curve-készítőnek; vagy csak három szint
  meghívási módok nélkül – a workshop-kód és a céges domain nem működne.
- **Következmény:** egy UI-választó (4 kártya) + egy „Kik kaphatnak meghívást?" panel.
- **Visszafordítható:** igen, az adatmodell a módokat külön tárolja.

### P-V3-02 – Egy hozzáférés-motor mindenre (munkatér, csoport, curve, elem)

- **Mit:** közös `access_policies` + `invite_grants` + `access_grants` tábla és egy `a2k-access` crate.
- **Miért:** D-V3-02 – ugyanaz a logika legyen mindenhol; egy helyen tesztelhető (jogosultság-mátrix),
  egy helyen auditálható.
- **Alternatíva:** objektumonként külön mezők – négyszeres hibalehetőség és eltérő viselkedés.
- **Következmény:** F1-be kerül (nem F4-be), mert az elemek is erre épülnek.
- **Visszafordítható:** nehezen (alap-architektúra) – ezért most döntsük el.

### P-V3-03 – Az elemek v2 láthatósága a nyilvános szint megjelenítési módja

- **Mit:** `teaser` = `public` + `open_sample=false`; `members` = `public` + `display=list_only`;
  `restricted` = `invite`/`paid`.
- **Miért:** egy modell; a SEO és a 10–15% nyilvános minta szabálya változatlanul működik.
- **Alternatíva:** két külön láthatósági rendszer elemre és curve-re – zavaró a felhasználónak.
- **Visszafordítható:** igen (leképezés).

### P-V3-04 – Az alapértelmezett szint mindig „zárt"; zártabbra váltás nem dob ki senkit

- **Miért:** semmi ne legyen véletlenül nyilvános (adatvédelem, céges anyagok); a résztvevő ne veszítse el
  a félig elvégzett curve-öt egy beállítás miatt.
- **Alternatíva:** alapból nyilvános (több SEO tartalom) – a kockázat nagyobb, mint a nyereség.
- **Visszafordítható:** igen.

## B. `+` jelölés

### P-V3-05 – Kanonikus URL `ai2know.it/+{slug}`, a `/lc/{slug}` örök 301-alias

- **Mit:** a `+` a curve névtere, a `@` a munkatéré; minden ökoszisztéma-domain 302-vel ide küldi a `/+…`
  címet; szövegben `+slug` automatikus link.
- **Miért:** a `+` a path-ban szabványos (RFC 3986), rövid, mondható, nyomtatható, és egyetlen Caddy
  szabállyal minden oldalunkon működik – pontosan amit kértél. A `/lc` tartalék, ha egy linkfelismerő a
  `+`-nál elvágja a linket.
- **Alternatíva:** csak `/lc/{slug}` – működik, de nem „márka"; `@` a curve-re – ütközne a személy/munkatér
  jelöléssel; aldomain (`slug.ai2know.it`) – TLS és SEO szempontból rosszabb.
- **Következmény:** globálisan egyedi slug, foglalt szavak, átnevezésnél örök átirányítás;
  linkfelismerő-smoke F7-ben.
- **Visszafordítható:** a `/lc` alias miatt bármikor (a kanonikus megfordítható).

### P-V3-06 – Zárt / meghívásos curve jogosulatlan látogatónak 404

- **Miért:** a slug gyakran beszédes (pl. „ceg-x-leepites-terv"); a 403 elárulná a létezést.
- **Visszafordítható:** igen.

## C. Munkatér és csoport

### P-V3-07 – Saját munkatér- és csoport-modell az ai2know-ban, opcionális összekötéssel

- **Miért:** a skillpass szervezetei partnernek nem olvashatók, a superskiller csoportjai B2B képzési
  egységek, közösségi csoport sehol nincs. A curve-ök és feltöltések gazdája kell legyen valami.
- **Alternatíva:** a skillpass szervezet mint munkatér – ma nincs hozzá API (06/6 csak P2); a superskiller
  bérlő – csak képzőknek való, és ott nincs közösség.
- **Következmény:** mindenkinek automatikus személyes munkatér (`@handle`); szervezeti munkatér bárkinek.
- **Visszafordítható:** részben (a hivatkozási mezők megengedik a későbbi egyesítést).

### P-V3-08 – Az objektum saját szintje dönt; a konténer csak a felfedezést és a tagság-módot adja

- **Miért:** a személyes munkatér zárt, mégis nyilvános curve-öket tartalmaz – egy „a gyerek nem lehet
  nyitottabb" szabály ezt tiltaná. A csoporttagság mint meghívási mód ugyanazt éri el egyszerűbben.
- **Alternatíva:** szigorú öröklés – egyszerűbb magyarázat, de a fő esetet (személyes nyilvános curve) rontja.
- **Visszafordítható:** igen (öröklési szabály később felvehető opcióként).

### P-V3-09 – Curve-kontextus csak a készítő saját jogosultságáig nyit ki zárt elemet

- **Miért:** különben bárki „kinyithatna" egy idegen zárt elemet azzal, hogy nyilvános curve-be teszi.
- **Visszafordítható:** igen.

## D. Közösség

### P-V3-10 – Bárki közzétehet; spam és visszaélés ellen bizalmi szintek + utólagos moderáció

- **Mit:** T0 (első 3 nyilvános tartalom előmoderáció, napi limit), T1, T2, szerkesztő.
- **Miért:** D-V3-01 és D-V3-05 – a nyitottság a cél; a bizalmi szintek a legkisebb súrlódással védenek
  (a valódi tagnak 3 tartalom után már nincs várakozás).
- **Alternatíva:** minden előmoderáció – lassú, a közösség elhal; semmi moderáció – spam és jogi kockázat.
- **Következmény:** moderációs sor az aibos konzolban; a küszöbök konfigurálhatók.
- **Visszafordítható:** igen (küszöbök).

### P-V3-11 – Kötelező automatikus titok-detektálás feltöltéskor

- **Miért:** promptokba, MCP konfigurációkba gyakran kerül API kulcs; nyilvános közzétételük valós kárt okoz
  a feltöltőnek. Olcsó, determinisztikus regex + entrópia ellenőrzés.
- **Visszafordítható:** igen.

### P-V3-12 – Közösségi elem-értékelés az ai2know-ban; a skillpass-ra csak a curve ellenőrzött értékelése megy

- **Miért:** a skillpass review rendszere ma moderátor által létrehozott entitásokra épül; 460+ (és növekvő)
  elem szinkronja zajos és felesleges. A curve az, ami „elvégzés", ott van értelme az ellenőrzött
  értékelésnek a profilon.
- **Alternatíva:** minden értékelés a skillpass-on – egy forrás, de lassú és a skillpass-t terheli.
- **Visszafordítható:** igen (később tükrözhető).

### P-V3-13 – Közösségi elem `noindex`, amíg el nem éri a minőségi küszöböt

- **Miért:** a nyílt feltöltés SEO-spam célpont; a domain hírneve a meglévő szerkesztői tartalom értéke.
- **Visszafordítható:** igen.

### P-V3-14 – DSA minimum (bejelentés, indoklás, fellebbezés, átláthatósági összesítő) F6-ban

- **Miért:** a felhasználói tartalom tárolásával az ai2know tárhelyszolgáltató; ez jogi kötelezettség,
  nem opció. A szöveg tervezet marad az owner jóváhagyásáig (L-09).
- **Visszafordítható:** nem (jogi minimum).

## E. Fizetős szint

### P-V3-15 – „aibos.club partner" = ellenőrzött eladó, nem minden belépett felhasználó

- **Mit:** az aibos.club-ban ma **minden belépett skillpass felhasználó partnernek számít** (automatikus
  létrehozás). A fizetős szinthez kell egy `seller_status = active` állapot: elfogadott eladói feltételek,
  számlázási adatok, aibos operátori jóváhagyás. Az ai2know ezt egy új aibos.club végponton kérdezi:
  `GET /s2s/v1/partners/by-sub/{sub}/seller-status` (M2M, cache 1 óra) + webhook visszavonáskor.
- **Miért:** pénz és számla csak azonosított, szerződött partnerrel mehet; különben bárki „partner" lenne
  egy belépéssel, és a D-V3-03 értelmét veszti.
- **Alternatíva:** skillpass entitlement (`aibos_club.seller`) – a skillpass `entitlements:read` csak a
  saját kliens sorait adja, így az ai2know nem látná az aibos.club által írt sort; ehhez a skillpass-on
  új, kliensek közötti olvasás kellene.
- **Következmény:** az aibos.club plan-jébe új tétel (eladói státusz + s2s végpont).
- **Visszafordítható:** igen.

### P-V3-16 – A fizetős szint az élesítés után, külön fázisban (F11), flag mögött

- **Miért:** a fizetés jogi és adózási kérdései (ki számláz a vevőnek, jutalék, fogyasztóvédelmi
  tájékoztatás, elállási jog digitális tartalomnál) nincsenek eldöntve (Q-V3-01); az enum és a UI-hely már
  F1-től ott van, így később nem kell migrálni.
- **Visszafordítható:** igen.

## F. Design

### P-V3-17 – Az élő aibootcamp.hu tokenjei, Tailwind-be kötve; a tipográfia az élő oldalé

- **Mit:** azonos CSS változók (light + dark), Georgia címek + Manrope szöveg, éles sarkok; a Tailwind téma
  a változókra mutat.
- **Miért:** a látogató ugyanazt a márkát érezze; a repo szabálya (Tailwind + shadcn) is teljesül.
- **Alternatíva:** a brand skill Montserrat/Inter + 18–28 px sarkai – ez az infografikáké, és eltérne a
  weboldaltól; kézi CSS átvétele – a repo szabályaival ütközik.
- **Visszafordítható:** igen (tokencsere).

## G. Integráció

### P-V3-18 – superskiller: feliratkozás-alapú elvégzés-esemény, nem általános aktivitás-feed

- **Miért:** adatminimalizálás (GDPR): a superskiller csak arról szól, ami egy ai2know curve-ben lépés.
  Kevesebb esemény, kevesebb hibaforrás.
- **Alternatíva:** minden `lesson.completed` esemény az ai2know-nak – egyszerűbb, de túl sok személyes adat.
- **Visszafordítható:** igen.

### P-V3-19 – Partnerek közötti M2M a skillpass Hydra-n, partnerenkénti audience-szel

- **Miért:** egy kiadó, egy kulcskezelés, visszavonás egy helyen; nincs megosztott statikus titok a két
  partner között.
- **Alternatíva:** statikus API kulcs a két rendszer között – egyszerűbb, de rotálni és auditálni nehezebb.
- **Következmény:** a skillpass Hydra-nak új audience-eket kell kiadnia (06/1).
- **Visszafordítható:** igen.

### P-V3-20 – A skillpass „Alkotások" blokk láthatóságáról a felhasználó dönt

- **Miért:** a skillpass profil sor-szintű láthatósága már létezik; egy partner ne tegyen automatikusan
  nyilvánossá semmit a felhasználó profilján.
- **Visszafordítható:** igen.

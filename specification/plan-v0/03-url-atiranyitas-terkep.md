# 03 – URL- és átirányítási térkép

> Owner döntés (D-V0-06): minden régi URL átirányítva, az URL-szerkezet megmarad, az átirányítás
> követett. Példa: `https://hu.ai2know.it/csr` → `https://ai2know.it/csr`.
> Szabály: menüpont és ismert régi URL soha nem fut 404-re (L-06); ezt regressziós teszt őrzi.

## 1. Két réteg

1. **Host réteg (Caddy):** a régi hostok minden kérése az új domain **azonos útvonalára és
   query stringjére** megy. Ez követett (lásd 4).
2. **Útvonal réteg (ai2know.it):** a régi útvonalak az új rendszerben vagy ugyanazon a címen élnek,
   vagy egy ugrással a megfelelő helyre visznek. Láncolt redirect legfeljebb 2 lépés
   (régi host → ai2know.it/régi-út → végleges cél).

Státuszkódok: `GET`/`HEAD` → **301**; más metódus → **308** (a metódus megmarad); megszűnt belső
végpont → **410 Gone** (RFC 7807 JSON); ismeretlen → 404 oldal javaslatokkal.

## 2. Host réteg

| Régi host | Cél | Megjegyzés |
|-----------|-----|-----------|
| `hu.ai2know.it/*` | `https://ai2know.it{path}{?query}` | a fő forrás, a teljes forgalom zöme |
| `en.ai2know.it/*` | `https://ai2know.it{path}{?query}` | + `a2k_locale_hint=en` süti `Domain=ai2know.it`, 180 nap (vendég nyelv) |
| `www.ai2know.it/*` | `https://ai2know.it{path}{?query}` | |
| `auth.ai2know.it/*` | `https://ai2know.it{path}{?query}` | ugyanazok a magyar útvonalak voltak (`/belepes` …) |
| `t.ai2know.it/*` | `https://ai2know.it/` | nincs valódi rövid link; a régi nyílt redirect megszűnik |
| `support.ai2know.it/*` | `https://ai2know.it/support` | |
| `api.`, `app.`, `cdn.`, `portal.`, `sync.`, `test.`, `forum.ai2know.it/*` | `https://ai2know.it/` | ma „Coming soon" oldal |
| `o.`, `pgadmin.`, `c.`, `p.`, `b.aitoknow.it` | **nincs redirect** – leállítás, DNS rekord törlés | belső eszközök, biztonsági okból (P-V0-17) |
| `aitoknow.it`, `www.aitoknow.it` | `https://ai2know.it/` (ha még a miénk) | régi WordPress korszak, Q-04 |
| `live.aibootcamp.space` | nem ennek a projektnek a része | a régi szerver leállítása előtt áthelyezendő (Q-08) |

## 3. Útvonal réteg (ai2know.it)

### 3.1 Változatlan címen élő oldalak (új implementáció)

Tartalom (aibos-public): `/csr`, `/aszf`, `/blaszf`, `/adatkezelesi-tajekoztato`, `/etikai-kodex`,
`/impresszum`, `/facebook-groups`, `/telegram`, `/discord`, `/whatsapp`, `/viber`, `/partnereink`,
`/business-csomag`, `/pro`, `/pontok`, `/aitools`, `/segedanyagok`, `/appok`, `/videok`, `/linkek`,
`/bovitmenyek`, `/promptok`, `/vasarnapestipromptolas`, `/esemenyek`, `/meetups`, `/mastermind`,
`/szakertok`, `/szotar`, `/affiliate` (programleírás).

Funkciók (backend): `/@{handle}`, `/jelentkezes/{code}`, `/csapatom`, `/meghivas`, `/kedvezmenyek`,
`/business`, `/qrcode`, `/share/{uuid}`, `/ai-erettsegi-szint-felmeres`, `/ai-kerdesek-es-valaszok`,
`/support`, `/kedvencek` (Q-10).

Fájlok: `/static/uploads/{fájl}` (byte-azonos, MinIO), `/data/qrcodes/{user}/{fájl}` (megmarad,
GET nem ír számlálót), `/static/images/*` a még hivatkozott képekre.

Platform: `/` (új nyitóoldal), `/robots.txt`, `/sitemap.xml`, `/favicon.ico`,
`/apple-touch-icon*.png`, `/manifest.json`.

### 3.2 Auth útvonalak → skillpass.id (részletek: F2 / 5)

`/belepes`, `/jelentkezes`, `/kijelentkezes`, `/elfelejtett-jelszo`, `/jelszo-modositas`, `/profil`,
`/verify`, `/verify/{token}`.

### 3.3 Átirányítások az új rendszeren belül

| Régi útvonal | Cél | Ok |
|--------------|-----|----|
| `/p/{page}` | `/{page}` | a régi rendszer is így tette |
| `/promtok`, `/promtpok` | `/promptok` | elírások (610 találat) |
| `/login` | `/belepes` | 731 + 135 találat |
| `/register` | `/jelentkezes` | 453 + 86 találat |
| `/en`, `/en/` | `/` | 232 találat |
| `/portal` | `/csapatom` | en: 90 találat |
| `/meetup` | `/meetups` | duplikált modul |
| `/settings` | Account Center `…/account/profile` | skillpass |
| `/notifications` | Account Center `…/account/notifications` | skillpass |
| `/users` | `/` | admin az aibos-ban, nincs publikus link |
| `/feed`, `/posts`, `/posts/feed`, `/news`, `/blogs`, `/newsletter` | `/` (vagy `/hirek`, ha az aibos posts él) | üres sablonok |
| `/forums`, `/groups`, `/follows`, `/friendships`, `/messages`, `/communities`, `/categories`, `/files`, `/oktatok`, `/labels/add` | `/` | üres sablonok |
| `/read-document` | Q-16 (forrás ismeretlen, 645 találat) | |

### 3.4 Megszűnt belső végpontok → 410 Gone

`/check-username`, `/check-email`, `/api/*` (users, posts, categories, tags, ratings, favorites,
invites, csapatom, create-user – utóbbi új M2M végpontra költözik, Q-06), `/aiqna/*`,
`/fetch-coupons`, `/fetch-orders`, `/orders-report`, `/newsletter_users`, `/business/export`,
`/business/import`, `/business/generate_invoice`, `/business/proforma_invoice/*`, `/generate_qr/`,
`/list_qrcodes`, `/share/create`, `/share/list`, `/log-coupon/*`, `/log-invite/*`,
`/submit-ai-assessment`, `/labels*`, `/comments/*`, `/files/*`, `/openapi.json`, `/docs`.

`/feed/` (206 k kérés, régi RSS olvasók): **410** (P-V0-16), hogy a lekérdezők leálljanak.

Kivétel: `/business/sold_packages` – 2,3 k hívás, ismeretlen fogyasztó (Q-09). Amíg nincs döntés,
kompatibilis JSON válasz marad (darabszám, PII nélkül).

### 3.5 Általános normalizálás

- Záró perjel: `/csr/` → `/csr` (301), a gyökér kivétel.
- A query string mindig megmarad (`?utm_*`, `?next=` – utóbbi csak saját domainre mutathat).
- Kis-nagybetű: változatlan (a `/@handle` és a kódok összehasonlítása kisbetűsített).
- Statikus Bootstrap/jQuery fájlok (`/static/css`, `/static/js`, `/static/font`) → 410.

## 4. Követés (tracking)

- A régi hostok kérései a backend `/_legacy` redirectorán mennek át (Caddy `reverse_proxy` a régi
  host blokkokban). A redirector `redirect_hits` sort ír és 301/308-at ad.
- Ha a backend nem válaszol 200 ms-on belül, a Caddy maga ad 301-et ugyanarra a célra
  (`handle_errors`) – az átirányítás soha nem bukik el, csak a követés esik ki (ezt metrika jelzi).
- Rögzített mezők: időpont, régi host, útvonal, query kulcsok (értékek nélkül, kivéve `utm_*`),
  cél, státusz, hivatkozó host, UA család + bot jelző, `ip_hash` (havonta rotált kulcs), nyelvi tipp.
- Az ai2know.it belső 301-ei (3.3) ugyanígy `redirect_hits`-be kerülnek `kind = path` jelöléssel.
- UTM paramétert nem fűzünk hozzá (tiszta kanonikus URL); a forrás a `redirect_hits` táblából
  látszik az aibos `redirects.stats` riportban.
- Böngésző-cache: a 301-et a böngésző megjegyzi, ezért ugyanattól a látogatótól az első kérés
  látszik – ez a migrációs riportnak elég.

## 5. Regressziós URL-lista

`tests/redirects/legacy-urls.csv` (régi URL, elvárt státusz, elvárt `Location`), forrásai:

1. a teljes régi route-leltár (~110 útvonal, 01);
2. a forgalmi lista legalább 300 legnépszerűbb útvonala (hu + en, 01 / 5);
3. mind a 142 forrás-kód `/jelentkezes/{kód}` alakban;
4. a forgalmat kapó `/@{handle}` címek;
5. minden `/static/uploads/*` és `/data/qrcodes/*` fájl;
6. a régi sitemap minden URL-je.

A teszt CI-ban (helyi stack) és smoke-ként test/prod környezetben is fut. Elfogadás: 100% egyezés.

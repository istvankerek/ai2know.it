# 02 – Tudáselem-modell

> A keresés, facetták, kártyák és mobil minták a `../plan-v1/02-katalogus-motor.md` és
> `../plan-v1/04-design-mobil.md` szerint; ez a fájl a v2 változásait rögzíti.

## 1. Típusok

| Típus (`item_type`) | Mi ez | Kulcs mezők (`attributes`) | Belépés után kapott „lényeg" |
|---------------------|-------|----------------------------|------------------------------|
| `prompt` | másolható prompt | cél-LLM, szerep, kimeneti formátum, változók | teljes prompt szöveg, változók, példa kimenet |
| `skill` | AI agent skill (SKILL.md jellegű) | trigger, eszközök, függőségek, forrás (pl. GitHub) | teljes skill tartalom, letöltés |
| `mcp` | MCP szerver leírás és konfiguráció | transport, jogosultságok, telepítés | konfiguráció, telepítési lépések |
| `guardrail` | védőkorlát szabály/minta | kockázat, kategória, szabály | teljes szabály, implementációs minta |
| `eval` | értékelési teszt | metrika, adatkészlet, küszöb | tesztesetek, futtatási útmutató |
| `compliance_guide` | megfelelési útmutató (AI Act, GDPR, ISO 42001, szektor) | jogszabály, kockázati osztály, hatály, felülvizsgálat dátuma | teljes útmutató, ellenőrzőlista |
| `role` | **szerepkör** = gyűjtemény | tagok: skillek, MCP-k, guardrailek, evalok, promptok, compliance guide-ok (típusos hivatkozások, sorrenddel) | csomag letöltés, telepítési leírás |
| `tutorial` | lépésről lépésre útmutató | lépések, időigény, előfeltételek | teljes útmutató |
| `video` | videó **bármely forrásból** | szolgáltató (YouTube, Vimeo, Loom, saját tár, egyéb), külső ID/URL, hossz, előadók, fejezetek, leirat | fejezetek, leirat, kapcsolódó elemek |
| `link` | kurált külső forrás | forrás típusa, nyelv, „utoljára ellenőrizve" | megjegyzések, kapcsolódók |

Kiegészítő típusok (a régi oldal és az aiagentek tartalmai miatt): `tool` (AI app/szolgáltatás),
`term` (szócikk), `resource` (letölthető segédanyag), `pillar` (eszköztár-pillér). A kedvezmények
és a kérdés-válasz a tagi felület részei (nem tudáselemek).

## 2. Közös mezők

`code` (stabil, pl. `PRM-MKT-CNT-001`, `ROL-MKT-ASSIST-001`), `slug`, `title`, `summary`, `teaser`
(a belépés nélkül látható rész), `body` (a lényeg), `category`, `tags[]`, `level`, `locale`,
`visibility` (3. fejezet), `status` (`draft`, `review`, `published`, `archived`), `version`,
`source` + `source_ref`, `license` (pl. GitHub skill eredeti licence), `author`, `cover`,
`external_url`, `published_at`, `updated_at`, `reviewed_at`.

## 3. Láthatóság (D-V2-06)

| Szint | Belépés nélkül | Belépve | Mire |
|-------|----------------|---------|------|
| `public` | teljes tartalom | teljes | marketing minta (szerkesztői válogatás) |
| `teaser` (**alapértelmezett**) | cím, összefoglaló, metaadat, `teaser` (pl. a prompt első 3 sora, a skill leírása tartalom nélkül), kapcsolódó elemek listája | teljes | SEO + regisztrációs kapu |
| `members` | csak listázva névvel, tartalom nem | teljes | értékes, nem SEO-célú elemek |
| `restricted` | nem látszik | csak jogosultsággal (curve, kohorsz, skillpass entitlement) | fizetős képzés anyaga |

- **Mennyiségi szabály:** típusonként a nyilvános minta 10–15% (szerkesztő jelöli ki, a konzol
  mutatja az arányt); a szócikkek (`term`) és a pillérek nyilvánosak (SEO alap); a curve-ök
  vázlata (cím, lépések címe) nyilvános curve-nél belépés nélkül is látszik.
- **SEO szabály:** a teaser oldalak indexelhetők; a zárt rész `isAccessibleForFree: false` +
  `hasPart` jelöléssel (a keresők fizetőfal-irányelve), így nincs „cloaking" büntetés. A
  `members` és `restricted` tartalom soha nincs a HTML-ben belépés nélkül.
- A listák darabszáma mindig a teljes készletet mutatja („339 skill – 45 nyilvános, a többi
  belépés után"), ez maga a marketing.

## 4. Verziók

- Minden közzététel új `version` (változtathatatlan pillanatkép); a curve lépései verzióra
  mutatnak, így egy elvégzett curve tartalma visszakereshető marad.
- Kisebb javítás (elírás) „patch" jelöléssel ugyanazon verzióban, auditálva.

## 5. „Mindenhonnan ide hivatkoznak" (D-V2-02)

| Eszköz | Leírás |
|--------|--------|
| Kanonikus URL | `https://ai2know.it/elem/{code}` → 301 a típusos szép URL-re; a kód soha nem változik |
| Publikus olvasó API | `GET /api/v1/items/{code}` (a láthatóság szerint szűrve), `GET /api/v1/search` |
| Partner API (M2M) | ugyanaz teljes tartalommal, ha a partner a felhasználó nevében (SSO token) kér |
| Beágyazható kártya | `<script src="https://ai2know.it/embed.js">` / `<iframe src="/embed/{code}">` + **oEmbed** végpont – superskiller, aiagentek, blogok |
| Rövid link és QR | `https://ai2know.it/e/{code}` nyomtatható |
| Webhook | elem változás / archiválás esemény a feliratkozott partnereknek |

## 6. Szerepkör (`role`) részletei

- Tagok: típusos hivatkozás `{code, version?, required, note}`; körkörös hivatkozás tiltva.
- Nézet: összefoglaló, „mit tud ez a szerepkör", tagok típusonként, kompatibilitás (melyik
  agent-keretrendszer), compliance megjegyzések.
- Csomag export (belépve): `role-{code}.zip` – SKILL.md-k, MCP konfigurációk, guardrail és eval
  fájlok, README; a licencek tiszteletben tartásával (nem újraterjeszthető forrás csak linkként).
- Egy szerepkör maga is felvehető curve lépésnek.

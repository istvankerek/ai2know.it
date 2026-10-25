# 02 – Katalógus-motor (egységes tudáselem, keresés, facetták)

> Cél: egy motor, ami a mostani aiagentek promptkeresőt (kliens oldali részszó-keresés, URL-állapot
> és lapozás nélkül, csak „legújabb" rendezés működik) professzionális szintre emeli, és minden
> tudáselem-típust kiszolgál.

## 1. Adatmodell

### 1.1 Közös mezők (minden típus)

| Mező | Típus | Megjegyzés |
|------|-------|-----------|
| `code` | text, egyedi, stabil | pl. `PRM-MKT-CNT-001`, `APP-CHATGPT`, `VID-0007` – a könyv kódjai változatlanok |
| `item_type` | enum | `tool`, `extension`, `link`, `video`, `prompt`, `skill`, `mcp`, `guardrail`, `eval`, `term`, `resource`, `discount`, `question`, `pillar` |
| `slug`, `title`, `summary`, `body` | text / markdown | `body` lehet a másolható szöveg (prompt) vagy a cikk |
| `category`, `tags[]` | taxonomy | egységes taxonómia (`taxonomy-system` skill), szekciónként kurált kategóriafa |
| `level` | enum | `kezdo`, `halado`, `gyakorlott` |
| `locale` | `hu` / `en` | a nyelvi változatok külön sorok azonos `code`-dal (02/6) |
| `status` | enum | `draft`, `review`, `published`, `archived` – csak `published` megy ki |
| `source` | text | `ai2know-legacy`, `aiagentek-book`, `editorial`, `user-request` |
| `cover` | media ref | kép/logó (MinIO), alt szöveggel |
| `external_url` | url | kimenő link (eszköz, link, videó) – `rel="noopener"`, kattintás mérve |
| `published_at`, `updated_at`, `reviewed_at` | timestamptz | „utoljára ellenőrizve" jelzés az elavulás ellen |

### 1.2 Típus-specifikus mezők (`attributes` JSON, típusonként zod/serde séma)

| Típus | Mezők |
|-------|-------|
| `tool` / `extension` | szolgáltató, árazás (`ingyenes`/`freemium`/`fizetős`), platformok (web, iOS, Android, macOS, Windows, Chrome), magyar nyelv támogatás, letöltési linkek platformonként, QR kódok (a régi `/appok` ChatGPT QR-jai), alternatívák (`code` lista) |
| `link` | forrás típusa (kutatás, kurzus, közösség, hír), nyelv |
| `video` | YouTube ID, hossz, előadók, felvétel dátuma, fejezetek (időbélyeg), leirat (ha van) |
| `prompt` / `skill` / `mcp` / `guardrail` / `eval` | az aiagentek séma: `llmTarget`, `rolePersona`, `industry`, `outputFormat`, `businessFunction`, `evals`, `guardrails`, `author` |
| `term` | rövid definíció, angol megfelelő, lásd még |
| `resource` | fájl (PDF/PNG) a régi `/static/uploads` URL-lel, oldalszám, előnézet |
| `discount` | partner, kedvezmény mértéke, kuponkód (csak belépve látszik), érvényesség, feltételek, kohorsz-feltétel |
| `question` | kérdés, elfogadott válasz, kérdező (megjelenítési név, ha hozzájárult), moderáció állapota |

### 1.3 Közösségi és mérési táblák (meglévő aibos minta, általánosítva)

`stat` (megtekintés, másolás, kattintás), `rating` (1–5, tagonként egy), `comment` (moderált),
`request` (új elem / javítás kérés – a konzolban kezelve), **új:** `favorite`, `collection`
(tag saját gyűjteményei, megosztható linkkel).

## 2. Hol él az adat (P-V1-02, P-V1-03)

```text
aibos (forrás, írás)                         ai2know.it backend (olvasás, keresés)
──────────────────────                       ─────────────────────────────────────
knowledge_item (portal = ai2know-it)  ──▶   sync worker (ETag + aláírt webhook)
knowledge_item_stat/rating/comment          ──▶ kb_search (PostgreSQL olvasó-modell)
knowledge_item_request                           tsvector (hungarian + unaccent), pg_trgm
aibos konzol: DLA szerkesztés,                   facetta-számlálók
moderálás, kérések                          ◀── statisztika/értékelés/komment írás
                                                 a BFF-en át → aibos-public
```

- Az aibos meglévő `prompt_library_*` táblái **általánosítva** (`item_type` bővítés, `portal_id`
  a `book_id` mellett, `attributes` JSON). A migráció az aibos repóban külön plan (Q-V1-01).
- Az ai2know.it backend a **keresést, facettákat, rangsort, kedvenceket, gyűjteményeket** adja;
  a tartalmat nem szerkeszti.
- Alternatíva (ha az aibos bővítése nem fér bele): a katalógus az ai2know backend saját sémájában,
  admin az aibos konzolban contracton át (v0 F5 minta). Ezt az F1 elején kell eldönteni.

## 3. Keresés

- **Lekérdezés-feldolgozás:** kisbetű, ékezet-mentesítés, magyar szótövezés (`hungarian` FTS
  konfiguráció), szinonimaszótár (pl. „képgenerálás" ↔ „image generation", „gpt" ↔ „chatgpt"),
  elírástűrés `pg_trgm` hasonlósággal, ha az FTS kevés találatot ad.
- **Rangsor:** FTS relevancia (cím súlya A, összefoglaló B, címkék B, törzs C) + népszerűség
  (log megtekintés/másolás) + frissesség + szerkesztői kiemelés; a súlyok konfigurációban.
- **Facetták:** típus, kategória, címke (többes választás), szint, árazás, platform, magyar
  támogatás, nyelv – találatszámmal, a nulla találatú opciók szürkék.
- **Rendezés:** relevancia, legnépszerűbb, legtöbbet másolt, legjobbra értékelt, legújabb, ABC.
- **Lapozás:** kurzor alapú API; a felületen „Továbbiak" gomb + URL-ben `oldal` (SEO-nak és
  vissza gombnak is jó), nincs végtelen görgetés a lábléc elérhetősége miatt.
- **Autocomplete:** 8 javaslat, < 80 ms, előtag + trigram; népszerű keresések.
- **2. kör (opció):** szemantikus keresés Qdrant-tal („hogyan írjak marketing e-mailt" → releváns
  promptok), hibrid rangsor. Csak ha a mérés szerint a kulcsszavas keresés „nincs találat" aránya > 5%.
- **Mérés:** keresési kifejezés (PII-szűrve), találatszám, kattintott pozíció → „nincs találat"
  riport a szerkesztőknek (tartalomhiány-lista).

## 4. API (ai2know backend, `contracts/public/ai2know-public.yaml`)

| Végpont | Leírás |
|---------|--------|
| `GET /api/v1/search?q&type&category&tags&level&…&sort&cursor` | találatok + facetták egy válaszban |
| `GET /api/v1/suggest?q` | autocomplete |
| `GET /api/v1/items/{code}` | részlet + statisztika + értékelés + kapcsolódók |
| `GET /api/v1/sections/{section}` | szekció-kezdőlap blokkjai |
| `POST /api/v1/items/{code}/{view,copy,click}` | mérés (rate limit, bot szűrés) |
| `POST/DELETE /api/v1/me/favorites/{code}`, `…/me/collections` | belépve |
| `POST /api/v1/items/{code}/{rating,comments}`, `POST /api/v1/requests` | belépve, továbbítva az aibos felé |

## 5. Felület (közös komponensek, `apps/web/components/catalog/`)

- `CatalogPage` (szekció-fejléc, darabszám, testvér-szekciók), `SearchBox` (debounce, IME-biztos),
  `FacetBar` (desktop: bal oldali panel; mobil: alulról nyíló lap „Szűrők (3)" gombbal),
  `ActiveFilters` (törölhető chipek), `SortMenu`, `ResultGrid` / `ResultList` (nézetváltó),
  `ItemCard` (típusonként variáns: app logóval és platform-ikonokkal, videó bélyegképpel és
  hosszal, prompt első sorral és „Másolás" gombbal), `ItemDetail`, `CopyButton`, `Rating`,
  `Comments`, `RequestButton`, `FavoriteButton`, `EmptyState`, `CatalogSkeleton`.
- Állapot: URL a forrás (`useSearchParams`), szerver oldali első render (SSR), kliens oldali
  frissítés `startTransition`-nel; vissza gomb visszaállítja a görgetési pozíciót.
- Részletoldal: SSR, kanonikus URL, strukturált adat (`SoftwareApplication`, `VideoObject`,
  `DefinedTerm`, `HowTo`/`CreativeWork`), Open Graph kép generálás (`next/og`).

## 6. Nyelv

A tartalom elsődlegesen magyar (a forrás is az). Ha egy elemnek van `en` változata, a
skillpass/`Accept-Language` szerinti angol látogató azt kapja; ha nincs, a magyart „csak
magyarul" jelzéssel. A UI szövegek hu + en (`i18n-required`).

## 7. Tesztek

- Keresés: ékezet nélküli, elírt, többszavas, magyar ragozott lekérdezések golden-listája
  (pl. „képgeneráló" → Midjourney, DALL·E; „chatgtp" → ChatGPT) – a lista CI-ban fut.
- Facetták: számlálók egyeznek a találatokkal; URL ↔ állapot oda-vissza.
- Teljesítmény: 10 000 szintetikus elemen p95 < 150 ms.
- Komponensek: vitest + Testing Library; E2E: mobil viewporton szűrés, másolás, vissza gomb.

# 04 – Adatmodell és adatmigráció

> Forrás: `backup/hu.ai2know.it/data/backup/2026-10-17_19-00-01_ai2knowit.sql` (PostgreSQL 16.3,
> plain SQL dump) + a modulonkénti SQLite fájlok + a fájl alapú logok.
> Adatosztály: **személyes adat (PII)**. Feldolgozás csak helyben, csak helyi modell vagy Claude
> (routing policy). A dump és a staging adat soha nem kerül gitbe, chatbe, promptba vagy logba (L-04).

## 1. Leltár – mi van ténylegesen az adatban

### 1.1 PostgreSQL (`ai2knowit` DB, `public` séma)

45 tábla, ebből **csak 3 tartalmaz adatot**:

| Tábla | Sor | Megjegyzés |
|-------|-----|-----------|
| `users` | 5 083 | az egyetlen érdemi adatvagyon |
| `roles` | 15 | statikus enum (SuperAdmin … Guest), `permissions` mező üres |
| `business_data` | 1 | a SQLite példány a teljesebb (lásd lent) |
| többi 42 tábla | 0 | scaffold táblák (posts, forums, groups, messages, events, glossary, …) – soha nem használták |

`alembic_version`: 1 migráció (`b9ea25dd5c54` – Django táblák eldobása). A séma nincs migrációval
leírva, `create_all` hozta létre.

### 1.2 `users` profil (aggregált, név és e-mail nélkül)

| Mutató | Érték |
|--------|-------|
| Összes | 5 083 |
| `verified = true` | 3 904 (76,8%) |
| `verified = false` | 1 179 |
| `newsletter = true` | 3 525 |
| `gdpr = true` | 5 082 |
| telefonszám kitöltve | 3 356 |
| `note` kitöltve | 330 |
| `points` ≠ 0 | 0 (a gamifikáció soha nem működött) |
| e-mail duplikátum (kisbetűsítve) | 4 pár |
| username duplikátum | 0 |
| Regisztráció időszaka | 2023-11 → 2026-10 (csúcsok: 2025-09: 1 043, 2026-03: 648, 2024-07: 482) |

**Szerepkörök (`role_id`)** – a 4/5/6 a gyakorlatban **nem jogosultság, hanem kohorsz-jelölő**,
amit a regisztráció a meghívó kódból állított (`modules/auth/crud.py:89-97`): `aisikerkalauz` → 4,
`aibootcamp` / `granitpolus` → 5, `everengine` → 6. Egyetlen hatása: az 1/5/6 lát egy ELTE könyv
kedvezményt. Az új modellben ezért `members.cohort` mező lesz, nem szerepkör.

| role_id | Név | Darab | Új helye |
|---------|-----|-------|----------|
| 3 | User | 4 840 | `cohort = NULL` |
| 4 | Pointer | 105 | `cohort = aisikerkalauz` |
| 5 | Moderator | 87 | `cohort = aibootcamp` (vagy `granitpolus` a kód szerint) |
| 6 | Editor | 49 | `cohort = everengine` |
| 1 | SuperAdmin | 2 | aibos operátor fiók (nem migrál tagként admin joggal) |

**Jelszó-hash formátumok** – ez határozza meg a skillpass.id importot:

| Formátum | Darab | Eredet | skillpass (Kratos) import |
|----------|-------|--------|---------------------------|
| `$2b$` bcrypt | 4 657 | FastAPI passlib | importálható hash-sel |
| `$2y$` bcrypt | 3 | PHP | importálható hash-sel |
| `$P$B` phpass | 103 | WordPress (aitoknow.it korszak) | **ellenőrizendő**, alapból jelszó nélkül |
| 64 hex (sózatlan SHA-256) | 320 | tömeges import | **nem importáljuk** |
| ebből **egyetlen azonos hash** | 169 | közös alapjelszó | biztonsági kockázat, kötelező új jelszó |

**Bejövő forrás / referral kód (`users.code`)** – 142 különböző kód. Top 10: `mkik` 1 228,
`chatgptmagyarul` 700, `nonap` 541, `vasarnapestipromptolas` 460, `everengine` 393,
`aisikerkalauz` 201, `aibootcamp` 185, `elte` 125, `bni` 120, `aktiviskola` 96.
Ez a partner/közösség attribúció – üzleti érték, meg kell őrizni.

### 1.3 SQLite és fájl adatok

| Forrás | Tartalom | Sor | Döntés |
|--------|----------|-----|--------|
| `hu/app/modules/business/data/business.db` | `business_data` (partner cégadatok, `newsletter`, `gdpr`) | 5 | migrál → `partners` |
| `hu/app/modules/share/data/share.db` | `share`, `share_track` (nyers IP!) | 1 / 0 | migrál → `share_links` (IP nélkül) |
| `hu/app/modules/labels/data/labels.db` | `labels` | 0 | nem migrál |
| `orders/orders.db`, `orders/*.json` | a WooCommerce (aibootcamp.hu shop) proxy cache-e: rendelések számlázási PII-vel, kuponok; az API nem a DB-t, hanem az élő WooCommerce-t olvassa | 27 / 10 (+161 / 64 JSON) | **nem migrál**; az új backend közvetlenül a WooCommerce API-t olvassa, csak kupon → tag hozzárendelést tárol (P-V0-12) |
| `tracker/data/tracked_urls_*.db` | `events(ts, ip, ua, url, status)`, 2025-04-30 → 2026-10-17 | 35 540 | **nem migrál**: 32 318 bot próba, 3 168 a hu.ai2know.it-re, a `redirect.json` üres – nincs valódi rövid link. A `t.ai2know.it` 301-gyel a főoldalra visz (03) |
| 0 bájtos SQLite-ok (aiqna, affiliate, plugins, videos, links, categories, sundayprompts) | – | – | nincs mit migrálni |
| `hu/logs/coupons/*.log`, `hu/logs/invites/*.log`, `hu/app/logs/users/*.json` | kupon- és meghívó-használat naplók, user események | fájlok | aggregált import `referral_events`-be, a nyers fájl S3 WORM archívumba |
| `hu/app/static/uploads/*` | PDF/PNG cheat sheetek, kiadványok | ~90 fájl | MinIO, **URL változatlan** (L-12) |
| `hu/data/20240728/GeoLite2-ASN.mmdb` | GeoIP adatbázis | – | nem migrál, friss licencelt példány kell, ha kell |

## 2. Célmodell – `ai2know` séma (PostgreSQL, schema-per-service)

Elvek: a skillpass.id az identitás forrása, nálunk **nincs** név, e-mail, jelszó, telefon a
tagtáblában (csak ami az ai2know saját üzleti logikájához kell). Minden azonosító UUID v7, minden
idő `timestamptz` UTC. Minden admin mutáció append-only `audit_log` sort ír (L-11).

```text
members                 a2k tag (1 sor / skillpass sub)
  id uuid PK, sp_sub uuid UNIQUE NULL, legacy_user_id int UNIQUE NULL,
  handle citext UNIQUE            -- a régi username, a /@handle csatornához
  source_code text NULL           -- users.code (bejövő attribúció)
  referred_by_member_id uuid NULL
  cohort text NULL                -- aisikerkalauz | aibootcamp | granitpolus | everengine (régi role 4/5/6)
  handle_aliases citext[]         -- régi felhasználónevek, hogy a régi /@nev és /jelentkezes/nev linkek éljenek
  newsletter_opt_in bool, newsletter_opt_in_at timestamptz, gdpr_accepted_at timestamptz
  status text                     -- active | awaiting_link | archived
  legacy_registered_at, created_at, updated_at, linked_at

legacy_link_candidates  csak az összekötésig él (P-V0-08 megőrzési idő)
  legacy_user_id int PK, email_norm text, email_verified bool, hash_kind text,
  imported_to_skillpass bool, sp_sub uuid NULL, purge_after timestamptz

partners                a régi business_data (cégadat, nem magánszemély)
  id uuid PK, handle citext UNIQUE, name, tax_number, country, zip, city, address,
  contact_email, is_education bool, is_community bool, newsletter_opt_in bool, created_at

referral_codes          kampány / partner / közösség kód (142 db a users.code-ból)
  code citext PK, kind text (partner|community|event|member|campaign), owner_member_id NULL,
  owner_partner_id NULL, active bool, note text, created_at

referral_events         csatorna látogatás, meghívó, kupon használat (aggregálható)
  id uuid PK, code citext, kind text, occurred_at, landing_path, ip_hash bytea, ua_family text

coupons, coupon_redemptions     (a /kedvezmenyek kódjai + a „kupon másolva" napló)
coupon_owners                   (WooCommerce kuponkód → tag; ma regex a felhasználónévre, P-V0-12)
share_links, share_hits         (ip_hash, nem nyers IP)
qr_codes                        (owner, target_url, minio_key; ~28 felhasználó PNG-i a MinIO-ba)
redirect_hits                   (régi host → új URL, lásd 03 és F6)
assessments                     (AI érettségi felmérés beküldések, ha az owner megtartja)
support_tickets                 (ha valós funkció, lásd 01)
audit_log                       append-only (UPDATE/DELETE trigger tiltja)
outbox                          NATS JetStream kimenő események, aláírt
```

IP kezelés minden táblában: `ip_hash = HMAC-SHA256(ip, havonta rotált kulcs)` – nyers IP nem
tárolódik (L-10).

## 3. Felhasználók átvitele a skillpass.id-re

A felhasználókezelés a skillpass.id-é (D-V0-02). Két út van, a javaslat a kettő kombinációja:

### 3.1 „A" út – tömeges import a skillpass.id-be (javasolt, P-V0-07)

1. **Staging (helyben):** a dumpból `legacy_users` staging tábla egy eldobható, helyi Postgres
   konténerben. Kimenet: osztályozás (verified, hash típus, duplikátum, szerepkör).
2. **Tisztítás:** e-mail normalizálás (trim + kisbetű), a 4 duplikált e-mail pár összevonása
   (a régebbi `registered_at` nyer, a `code` és `newsletter` a „legerősebb" értéket kapja),
   érvénytelen e-mail kiszűrése.
3. **Import a skillpass.id-be** – a skillpass repóban külön, owner által jóváhagyott feladat
   (új M2M scope vagy egyszeri admin job, pl. `identities:import`). Szabályok:
   - Csak `verified = true` (3 904) kerül importra (P-V0-09).
   - **Javasolt (P-V0-07):** minden identitás jelszó-hash **nélkül** megy át (e-mail, név,
     `locale`); első belépés e-mail kóddal, utána a skillpass-on állít jelszót / passkey-t.
   - Alternatíva (ha az owner a súrlódást kisebbre akarja): a bcrypt (`$2b$`, `$2y$`) hash-ek
     átvihetők, így a régi jelszó működik; a phpass és SHA-256 hash ekkor sem megy át.
   - A 169 közös hash-ű fiók soha nem kap jelszót importból.
   - Megjegyzés: a régi rendszer e-mailben, nyílt szövegben küldte ki a jelszavakat, és a
     „jelszó-emlékeztető" azonnal felülírta bárki jelszavát. Ezért erős érv szól amellett, hogy
     **egyetlen hash se menjen át**, és mindenki e-mail kóddal lépjen be először (P-V0-07 B változat).
   - Ha az e-mail már létezik a skillpass.id-ben (pl. aibootcamp felhasználó): **nem írjuk felül**,
     csak összekötjük (a skillpass identitás nyer).
   - `traits.locale` = `hu` (a régi rendszer magyar volt; az en.ai2know.it-n regisztráltak `en`, ha
     a forrás ezt megmondja – lásd 01).
   - Idempotens: kulcs a normalizált e-mail. Újrafuttatható, dry-run móddal.
4. **Visszaírás:** az import `legacy_user_id → sp_sub` párokat ad vissza → `members.sp_sub`
   kitöltése, `status = active`.
5. **Egyeztető riport:** forrás sor = importált + összekötött + kihagyott (okkal). Eltérés esetén
   nincs élesítés.

### 3.2 „B" út – összekötés első belépéskor (mindig él, tartalék)

Aki nem került importra (pl. nem verifikált, vagy az A út nem valósul meg), az a skillpass.id-n
regisztrál/lép be, és az első ai2know.it belépéskor a BFF összeköti:

- feltétel: `email_verified = true` claim a skillpass id_tokenben, és a normalizált e-mail egyezik
  egy `legacy_link_candidates` sorral, amely még nincs összekötve;
- eredmény: a régi `handle`, `source_code`, `cohort`, `newsletter_opt_in` átkerül a tagra;
- audit sor (`member.linked`, forrás: `first_login_email_match`);
- e-mail egyezés nélkül nincs összekötés, kézi összekötés csak aibos-ból, indokkal (L-11).

### 3.3 Mi NEM megy át

| Adat | Miért nem | Hová |
|------|-----------|------|
| jelszó-hash (P-V0-07 szerint egyik sem; alternatívában csak a bcrypt) | a régi rendszer nyílt szövegben e-mailezte a jelszavakat, egy részük sózatlan | sehová, első belépés kóddal |
| telefonszám (3 356) | a skillpass trait-ek között nincs, a portál nem használja | S3 WORM archívum, P-V0-10 szerint törlés |
| `note` (330) | szabad szöveg, PII kockázat | owner átnézi, ami üzleti, az aibos CRM-be |
| `points` | mind 0 | – |
| nyers IP a tracker / share táblákból | adattakarékosság | csak aggregátum |
| SuperAdmin / Admin szerepkör | admin az aibos.space-ben, saját operátori authtal | aibos operátor fiók, külön |

## 4. Referral attribúció megőrzése

- A 142 `users.code` érték → `referral_codes` (kind osztályozás: partner, ha van `partners.handle`
  egyezés; member, ha van `members.handle` egyezés; egyébként campaign/community/event – az owner
  véglegesíti a listát az aibos admin felületen).
- Minden tag `source_code`-ja megmarad → a partner riportok (pl. „mkik: 1 228 regisztráció")
  az új rendszerben is ugyanazt a számot adják. Ez az egyeztető teszt egyik elfogadási feltétele.
- A `/@handle`, `/jelentkezes/{code}` és `?…@handle` belépési pontok ugyanazt a `a2k_ref` sütit
  állítják (30 nap, httpOnly, SameSite=Lax), amit az első skillpass belépés után a tagra írunk.

## 5. Migrációs futtatás (F7) – lépések

1. Friss dump az élő rendszerről (owner indítja, mert az élő szerverhez kell hozzáférés).
2. Helyi staging betöltés → osztályozó riport (aggregált, PII nélkül a plan mappába).
3. Dry-run: `members`, `partners`, `referral_codes`, `coupons`, `share_links`, `qr_codes` ETL
   a non-prod adatbázisba, egyeztető riport.
4. skillpass import dry-run a skillpass non-prod példányán.
5. Owner jóváhagyás → éles import a vágás (F8) ablakában, írásvédett régi rendszer mellett
   (`safedata-mode`), hogy ne keletkezzen új regisztráció a régi oldalon az átállás alatt.
6. Restart-teszt migráció után (L-08), egyeztető riport, `implementation-notes.md` bejegyzés.

## 6. Elfogadási feltételek

- Forrás `users` = importált + összekötésre váró + szándékosan kihagyott (okkal), 0 ismeretlen.
- `source_code` szerinti darabszámok egyeznek a forrással (mind a 142 kódra).
- Nincs nyers IP, telefonszám vagy jelszó-hash az `ai2know` sémában (automata teszt: séma- és
  adatszken).
- Importált tesztfiókkal első belépés e-mail kóddal sikeres non-prod környezetben (P-V0-07 alternatívája esetén: bcrypt tesztfiók a régi jelszóval).
- phpass / SHA-256 / közös hash-ű tesztfiók: soha nem lép be régi jelszóval.

# F7 – Adatmigráció futtatása

> Cél: a 04-ben leírt ETL megírása, próbája és egyeztetése non-prod környezetben; az éles futás
> az F8 átállási ablakában történik.
> Routing: CRITICAL (migráció, PII, adatvesztés kockázat). Skillek: `db-migration`,
> `data-import`, `backup-strategy`, `safedata-mode`.

## 1. ETL eszköz (`crates/a2k-legacy-etl`)

- [ ] Bemenet: helyi staging Postgres (a dump betöltve), SQLite fájlok, log könyvtárak. Útvonal
      paraméterként, a backup mappából csak olvas.
- [ ] Lépések, mind idempotens és `--dry-run` képes:
  1. `classify` – aggregált riport (sorok, hash típusok, verified, duplikátumok, kódok) PII nélkül.
  2. `members` – `members` + `legacy_link_candidates` (e-mail csak itt, megőrzési határidővel).
  3. `partners` – Postgres + SQLite `business_data` összefésülése `username` szerint.
  4. `referral_codes` – a 142 kód osztályozva; `referral_events` a coupon/invite logokból (aggregált).
  5. `coupons` – `orders.db.coupons` + discounts modul kódjai.
  6. `share_links`, `qr_codes` (PNG-k MinIO-ba), `coupon_owners`. A tracker előzmény nem migrál (bot zaj).
  7. `skillpass-export` – az import bemenete (külön fájl, titkosítva, csak a skillpass import jobnak).
  8. `skillpass-mapping` – a visszakapott `legacy_user_id → sp_sub` párok betöltése.
  9. `reconcile` – egyeztető riport (forrás vs. cél darabszámok, kódonkénti attribúció).
- [ ] Naplózás: csak darabszámok és azonosítók, e-mail/név soha (L-04).

## 2. Feltöltött fájlok

- [ ] `hu/app/static/uploads/*` (és az `en` megfelelője, ha eltér) → MinIO `a2k-public/static/uploads/`,
      Caddy a régi `/static/uploads/<név>` URL-en szolgálja ki (byte-azonos, ellenőrzőösszeggel).
- [ ] Képek, logók → `apps/web/public` (ami a felülethez kell) vagy aibos média (ami tartalom).

## 3. Próbák

- [ ] 1. próba: a 2026-10-17-es dumppal, helyben → riport a `implementation-notes.md`-be.
- [ ] 2. próba: test környezetben, skillpass test példány importtal, E2E belépés régi jelszóval.
- [ ] 3. próba (főpróba): friss dumppal, időméréssel – ez adja az átállási ablak hosszát.

## Elfogadás

- A 04 / 6. fejezet minden feltétele teljesül.
- Kétszeri futás ugyanazt az állapotot adja (idempotencia teszt).
- A főpróba ideje belefér az átállási ablakba (cél: < 30 perc).

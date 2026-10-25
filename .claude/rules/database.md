# Adatbazis Szabalyok

## PostgreSQL
- **Schema-per-service**: minden modul sajat schema-ban
  - `auth_schema` — felhasznalok, role-ok
  - `product_schema` — termekek
  - `log_schema` — audit trail
- Migraciok idopecsetes fajlokban: `migrations/postgres/YYYYMMDDHHMMSS_nev.sql`
- Minden migracio tranzakcioban (`BEGIN; ... COMMIT;`)
- DOWN migracio kommentben mindig mellekelve

## Indexek
- Minden foreign key-ra automatikusan
- Gyakran szurt oszlopokra (status, created_at, email)
- Egyedi index unique mezokon
- Partial index ha csak aktiv rekordok szamitanak

## Nevezes
- Tabla: snake_case, tobbes szam (users, products)
- Oszlop: snake_case (created_at, user_id)
- Index: `idx_{tabla}_{oszlop}`
- FK: `fk_{tabla}_{cel_tabla}`

## MongoDB
- Strukturalatlan adatokhoz (scraper output, AI valaszok)
- Schema validacio Mongoose-zal
- Migraciok: `migrations/mongodb/`

## Redis
- CSAK cache celra — NEM primer adattarolas
- TTL minden kulcson
- Kulcs nevezes: `{modul}:{entitas}:{id}`

## Biztonsag
- Parameterized query kizarolag
- Connection pool hasznalata (sqlx pool)
- Prod DB torles: L0 BLOCK

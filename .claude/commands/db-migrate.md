# DB Migracio

Uj migracios fajl letrehozasa: $ARGUMENTS

## PostgreSQL migracio

Hozd letre az uj migraciot idopecsetes fajlnevel:

```
migrations/postgres/YYYYMMDDHHMMSS_$ARGUMENTS.sql
```

Sablon:
```sql
-- Migracio: $ARGUMENTS
-- Datum: {{DATUM}}
-- Leiras: {{LEIRAS}}

BEGIN;

-- UP migracio
-- TODO: Sema valtoztatas ide

COMMIT;

-- DOWN migracio (kommentben)
-- BEGIN;
-- TODO: Visszaallitas ide
-- COMMIT;
```

## MongoDB migracio

Ha MongoDB-t is erint:
```
migrations/mongodb/YYYYMMDDHHMMSS_$ARGUMENTS.js
```

## Szabalyok

- Schema-per-service: minden modul sajat schema-ban (`CREATE SCHEMA IF NOT EXISTS`)
- Indexek: minden FK-ra es gyakran lekerdezett oszlopra
- Nem destruktiv: ne torolj oszlopot, elobb deprecald
- Teszteles: futtasd `./scripts/migrate.sh` es ellenorizd

## Futtatas

```bash
./scripts/migrate.sh
```

## L1 APPROVE

Ha a migracio:
- Tablt torol: L1 jovahagyas szukseges
- Prod adatbazist erint: Plan Mode kotelzo
- Nagy tablat modosit (>1M sor): teljesitmeny elemzes elotte

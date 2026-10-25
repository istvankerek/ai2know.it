# ADR-002: Schema-per-service PostgreSQL minta

## Allapot
Elfogadva

## Kontextus
Az adatbazis szervezest kellett meghatarozni a modul-alapu architekturhoz.

## Dontes
Minden modul sajat PostgreSQL schema-t kap (schema-per-service).

## Indoklas
- Modulok logikai elkulonitese az adatbazis szinten
- Egyszerubb jogosultsag kezeles (schema szintu GRANT)
- Elokeszites mikroszolgaltatas iranyba (ha szukseges)
- Egyetlen fizikai adatbazis = egyszerubb mukodestetesul
- Migrciok modulonkent kezelhetok

## Kovetkezmenyek
- Schema letrehozas: `infrastructure/postgres/init/02-schemas.sql`
- Cross-schema query-k: `schema_name.table_name`
- Modul konfig: `source: "schema_name"`
- Minden FK cross-schema eseten explicit

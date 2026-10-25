# Products Modul

## Leiras
Termek kezeles: CRUD muveletek, kategoriak, cimkek.

## Schema
- `product_schema.products` tabla
- FK: `taxonomy_schema.taxonomies` (kategoriak, cimkek)

## Endpoint-ok
- POST /api/v1/products — uj termek
- GET /api/v1/products — lista
- GET /api/v1/products/:id — reszletek
- PUT /api/v1/products/:id — frissites
- DELETE /api/v1/products/:id — torles

## Fuggosegek
- taxonomy-system (kategoriak)
- file-upload (termek kepek)
- activity-log (automatikus logolas)

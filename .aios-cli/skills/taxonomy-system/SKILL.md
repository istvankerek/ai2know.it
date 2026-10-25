---
name: taxonomy-system
description: >
  Egyseges taxonomy rendszer: groups, labels, categories, statuses.
  Polimorf tabla, hierarchia, i18n forditasok, szin/ikon metadata.
  Triggerek: "taxonomy", "kategoria", "cimke", "label", "statusz",
  "csoportositas", "tag".
  NE hasznald: role kezeles (-> roles-permissions), flat enumok.
model: claude-sonnet-4-6
---

# Taxonomy System

## Felelossegek
- Polimorf taxonomies tabla (type, parent_id, metadata JSONB)
- Hierarchia tamogatas (fa struktura)
- i18n forditasok (nev, leiras)
- Szin es ikon metadata
- Admin UI: taxonomy CRUD
- Hasznalat: kategoriak, cimkek, statuszok, csoportok

---
name: data-import
description: >
  Adat import: CSV, XLSX, JSON fajlokbol, mapping, validacio,
  hibakezelés, progress tracking, nagy fajl tamogatas.
  Triggerek: "import", "adat betoltes", "csv import", "excel import".
  NE hasznald: export (-> list-view ExportMenu), seed data.
model: claude-sonnet-4-6
---

# Data Import

## Felelossegek
- CSV / XLSX / JSON fajl olvasas
- Oszlop mapping (forras -> cel)
- Validacio (Zod schema)
- Hibakezekes (sor szintu hibak, atugrás/megallitas)
- Progress tracking (nagy fajloknal)
- Duplikatum kezeles (skip / update / error)
- NATS queue alapu aszinkron feldolgozas

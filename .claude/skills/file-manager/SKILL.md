---
name: file-manager
description: >
  Fajlkezelo: MinIO/S3 bongeszo, feltoltes, letoltes, elonezet,
  mappa struktura, jogosultsagok, meret korlatok.
  Triggerek: "fajlkezelo", "file manager", "fajl bongeszo", "media library",
  "keptar", "dokumentum kezelo".
  NE hasznald: egyedi fajl feltoltes form-ban (-> file-upload), backup.
model: claude-sonnet-4-6
---

# File Manager

## Felelossegek
- MinIO bucket bongeszo (/admin/files)
- Mappa letrehozas/torles/atnevezes
- Fajl feltoltes (drag & drop, multi-file)
- Fajl elonezet (kep, PDF, szoveg)
- Kep elonezet generalas (thumbnail)
- Fajl meret es tipus korlatok (konfiguralhato)
- Fajl jogosultsagok (publikus / privat / role-based)
- Fajl kereses (nev, tipus, meret, datum)
- Bulk letoltes (ZIP)
- Bulk torles
- Hasznalat statisztika (tarhely, fajlok szama)

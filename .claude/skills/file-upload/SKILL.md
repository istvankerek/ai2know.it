---
name: file-upload
description: >
  Fajl feltoltes komponens: drag & drop, multi-file, progress bar,
  presigned URL (MinIO), tipus/meret validacio, kep elonezet, kep crop/resize.
  Triggerek: "fajl feltoltes", "file upload", "kep feltoltes",
  "drag and drop", "upload", "attachment".
  NE hasznald: fajlkezelo oldal (-> file-manager), backup (-> backup-strategy).
model: claude-sonnet-4-6
---

# File Upload

## Felelossegek
- Upload komponens (shadcn/ui + custom)
- Drag & drop zona
- Multi-file feltoltes (parhuzamos)
- Progress bar per fajl
- MinIO presigned URL generalas (backend)
- Tipus validacio (MIME type whitelist)
- Meret validacio (konfiguralhato limit)
- Kep elonezet generalas
- Kep crop (react-image-crop)
- Kep resize (szerver oldalon: image-rs)
- Virus scan (ClamAV ha elerheto)
- Feltoltott fajl metaadatok mentese (DB)

---
name: list-view
description: >
  Admin lista nezet: Simple (shadcn/ui) + Advanced (AG Grid Enterprise),
  kereses, szures, rendezes, lapozas, bulk muveletek, mentett nezetek.
  Triggerek: "lista", "tablazat", "list page", "grid", "bulk", "szures",
  "rendezes", "lapozas", "AG Grid", "data table".
  NE hasznald: dashboard widget, egyedi chart, form, profil.
model: claude-sonnet-4-6
---

# List View

Teljes spec: references/list-spec.md

## Komponensek (12 db)
- ListPage.tsx — Simple/Advanced ful valto
- SimpleList.tsx — shadcn/ui DataTable (konnyu, mobil-barat)
- AdvancedList.tsx — AG Grid Enterprise (pivot, 100K+ sor)
- ListToolbar.tsx — Globalis kereses + szurok
- BulkActions.tsx — Export/Delete/Edit/Download
- BulkEditModal.tsx — Tomeges szerkesztes modal
- BulkDeleteConfirm.tsx — Tomeges torles megerosites
- SelectionBanner.tsx — Gmail-minta haromszintu kijololes
- SavedViewsBar.tsx — Mentett szuro+rendezes nezetek
- ExportMenu.tsx — CSV / XLSX / PDF / MD / JSON export
- PaginationBar.tsx — 50/100/500/1000/all + virtual scroll
- filters/ — 6 szuro widget (Text, Enum, Date, Number, Boolean, Relation)

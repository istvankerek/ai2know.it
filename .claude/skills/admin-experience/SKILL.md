---
name: admin-experience
description: >
  Production-grade shadcn-stílusú DLA admin UX. Fehér felület, relation select,
  create-in-modal, soft delete + kuka, auditált CRUD. Aktiválódik admin UI,
  CRUD UX, DLA menü, shadcn design és relation mezők esetén.
priority: P0
model: claude-sonnet-4-6
related_skills:
  - frontend-design
  - crud-dla-module
  - dla-menu-pattern
  - audit-trail-mandatory
---

# Admin Experience

> **Ökoszisztéma (v8.0):** partner projektben az admin felület az **aibos.space konzolban** épül,
> a projekt csak contract-first admin API-t ad (`aibos-admin-contract`). Ez a skill az aibos
> konzol (és a skillpass Account Center) UI mintáit írja le. Lásd `.aios-cli/core/ecosystem.md`.

## Kötelező elvek

- Fehér shadcn/ui admin alap, semantic Tailwind tokenekkel.
- DLA navigáció minden CRUD modulra: dashboard, list, add, detail, trash.
- Nincs kézzel gépelt idegen kulcs ID: relation combobox kötelező.
- Kapcsolt entitás létrehozása modalból történik.
- Delete csak soft delete, kuka nézettel és restore művelettel.
- Minden create/update/delete/restore auditált, diffel.
- Read-only activity/audit modulokból nem lehet törölni.

## Tiltások

- Placeholder admin oldal.
- Dark gradient AI-slop.
- `/new` route.
- Külön `/view` és `/edit` route ugyanarra az entitásra.
- Manuális ID mező kapcsolatokhoz.
- Mutáció activity/audit nélkül.

# Permission kódok — formátum és szabályok

**Forrás:** `/Users/everengine/Documents/dev/aibos` @ `7e30ba5` (2026-10-06)  
Hivatkozott fájlok: `contracts/authorization/aibos-permissions.json`,
`contracts/authorization/aibos-permissions.schema.json`,
`contracts/authorization/aibos-role-matrix.csv`,
`crates/aibos-contracts/src/`

---

## Permission kód formátum

```
{projekt}.{modul}.{akció}
```

Szabályok:
- Kizárólag kisbetű és alulvonás (`[a-z][a-z0-9_]*`)
- Elválasztó: `.` (pont) — nem kettőspont, nem perjel
- Nincs wildcard (`*`) soha, semmilyen szinten
- `implicit_default: "DENY"` — ami nincs definiálva, az tiltott
- `missing_permission_behavior: "DENY"`

Példák:
```
aibootcamp.courses.list
aibootcamp.courses.view
aibootcamp.courses.create
aibootcamp.courses.edit
aibootcamp.courses.delete
aibootcamp.courses.publish
aibootcamp.courses.history
```

Az `x-permission` az OpenAPI operációkban a projekt prefix nélküli rövidített
formát használja (`courses.list`), de a `permissions.json`-ban a teljes kód él.

---

## `permissions.json` struktúra

A sablon: `templates/admin-contract/contracts/authorization/permissions.json`

```json
{
  "$schema": "./permissions.schema.json",
  "schema_version": "1.0.0",
  "realm": "aibootcamp",
  "prefix": "aibootcamp.",
  "separator": ".",
  "implicit_default": "DENY",
  "wildcards_allowed": false,
  "missing_permission_behavior": "DENY",
  "groups": [
    {
      "key": "courses",
      "name": "Kurzusok",
      "permissions": [
        { "code": "aibootcamp.courses.list",    "description": "Kurzusok listázása" },
        { "code": "aibootcamp.courses.view",    "description": "Kurzus megtekintése" },
        { "code": "aibootcamp.courses.create",  "description": "Kurzus létrehozása" },
        { "code": "aibootcamp.courses.edit",    "description": "Kurzus szerkesztése" },
        { "code": "aibootcamp.courses.delete",  "description": "Kurzus törlése (soft delete)" },
        { "code": "aibootcamp.courses.publish", "description": "Kurzus publikálása" },
        { "code": "aibootcamp.courses.history", "description": "Kurzus auditnapló megtekintése" }
      ]
    }
  ],
  "roles": [
    {
      "code": "superadmin",
      "name": "Szuperadminisztrátor",
      "grant_rule": "ALL"
    },
    {
      "code": "admin",
      "name": "Adminisztrátor",
      "grant_rule": "EXPLICIT"
    },
    {
      "code": "editor",
      "name": "Szerkesztő",
      "grant_rule": "EXPLICIT"
    },
    {
      "code": "viewer",
      "name": "Megfigyelő",
      "grant_rule": "EXPLICIT"
    }
  ]
}
```

---

## Role matrix CSV

```csv
role_code,role_name,permission_code,effect
superadmin,Szuperadminisztrátor,aibootcamp.courses.list,ALLOW
superadmin,Szuperadminisztrátor,aibootcamp.courses.view,ALLOW
...
admin,Adminisztrátor,aibootcamp.courses.list,ALLOW
admin,Adminisztrátor,aibootcamp.courses.view,ALLOW
admin,Adminisztrátor,aibootcamp.courses.create,ALLOW
admin,Adminisztrátor,aibootcamp.courses.edit,ALLOW
admin,Adminisztrátor,aibootcamp.courses.delete,ALLOW
...
viewer,Megfigyelő,aibootcamp.courses.list,ALLOW
viewer,Megfigyelő,aibootcamp.courses.view,ALLOW
```

Szabályok:
- Csak `ALLOW` értékek — DENY explicit megadása felesleges (default)
- A `role_code` és `permission_code` csak ismert értékeket tartalmazhat
- A `superadmin` szerepkörnek minden permission-t tartalmaznia kell

---

## Fordítási időben épül a binárisba

Az aibos `crates/aibos-contracts` crate a `contracts/authorization/`
könyvtárat `build.rs`-sel olvassa és statikus adatstruktúrává fordítja:

```rust
// crates/aibos-contracts/src/lib.rs (leegyszerűsítve)
pub struct PermissionCatalog {
    pub permissions: &'static [Permission],
    pub roles: &'static [Role],
}

pub fn catalog() -> &'static PermissionCatalog {
    // build.rs által generált statikus adat
    &COMPILED_CATALOG
}
```

Futásidőben szerepkör-szerkesztés TILOS — ez architektúrális garancia, nem
konfigurációs döntés.

---

## CRM-stílusú ACL: szűkítés, nem tágítás

Az aibos konzol CRM-stílusú ACL réteget implementál: az aibos szintű
szerepkörök maximumot definiálnak, amelyet a projekt szintű beállítások
csak szűkíteni tudnak, soha nem tágítani.

```
aibos szintű szerepkör  ⊇  projekt szintű hozzáférés
```

Példa: ha az operátor `editor` szerepkörrel rendelkezik aibos szinten,
és az aibootcamp projekthez `viewer` van rendelve, akkor az érvényes
hozzáférés a `viewer` — a szűkebb ér.

Ez az `X-Actor-Assertion` `scp` mezőjében tükröződik: az aibos csak
az effektív, szűkített scope-okat szerepelteti.

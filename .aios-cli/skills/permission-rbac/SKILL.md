---
name: permission-rbac
description: >
  Minden endpoint require_permission() dekoratorral / makroval. Frontend-only
  permission check sosem eleg. {module}.{action} formatum (pont szeparator),
  PERMISSION_GROUPS + BUILTIN_ROLES (admin/editor/viewer/superadmin) frissitese.
  Triggerek: "uj endpoint", "permission", "role", "jogosultsag", "rbac",
  "require_permission", "szerepkor", "kinek szabad", "guard", "auth".
license: Everengine v7.0
priority: P0
model: claude-sonnet-4-6
related_skills:
  - roles-permissions
  - skillpass-auth
  - security-audit
related_rules:
  - .claude/rules/security.md
  - .claude/rules/module-implementation.md
---

# Permission RBAC — minden endpointon kotelezo

## Vasszabaly
> **Minden endpointnak `require_permission()` dekoratoron kell mennie.**
> Frontend permission check csak UI hint, a backend check kotelezo.
> Permission formatum: `{module}.{action}` (pont szeparator, NEM kettospont).

## Permission formatum

```
{module}.{action}              — egyszeru modul: tickets.list, users.create
{module}.{resource}.{action}   — nested: crm.contacts.list, crm.deals.assign
```

## Kotelezo CRUD permission set

Minden uj modulhoz minimum ezek:

```python
# permissions.py — uj modul kategoria
"{module}.list":   "{Entity}-ek listazasa",
"{module}.view":   "{Entity} megtekintese",
"{module}.create": "{Entity} letrehozasa",
"{module}.edit":   "{Entity} szerkesztese",
"{module}.delete": "{Entity} torlese",
```

Domain action-ok igeny szerint:
```python
"{module}.assign":   "{Entity} hozzarendelese",
"{module}.approve":  "{Entity} jovahagyasa",
"{module}.reject":   "{Entity} elutasitasa",
"{module}.export":   "{Entity}-ek exportalasa",
"{module}.upload":   "Fajl feltoltese",
"{module}.cancel":   "{Entity} visszavonasa",
```

## Implementacio

### Python (FastAPI)
```python
from ..rbac import require_permission, require_any_permission

# AND: minden permission kell
@router.get("")
async def list_users(
    user=require_permission("users.list"),
    session=Depends(get_pg_session),
):
    ...

# OR: barmelyik eleg
@router.get("/{id}")
async def view_user(
    id: str,
    user=require_any_permission("users.view", "users.edit"),
    session=Depends(get_pg_session),
):
    ...
```

**FONTOS:** `require_permission()` BELUL tartalmazza a `Depends()` hivast.
NEM kell `Depends(require_permission(...))`.

### Rust (Axum) — middleware extract
```rust
use crate::auth::{require_permission, AuthUser};

async fn list_tickets(
    user: AuthUser,                                        // JWT validalva
    _: require_permission!("tickets.list"),                // permission check makro
    State(pool): State<PgPool>,
) -> impl IntoResponse {
    // ...
}
```

A `require_permission!` makro bedobja a 403-at ha a user nem rendelkezik.

## Szerepkor (BUILTIN_ROLES)

```python
BUILTIN_ROLES = {
    "superadmin": list(PERMISSIONS.keys()),    # MINDIG mindent kap
    "admin": [
        # majdnem minden, kiveve user/role management?
        ...
    ],
    "editor": [
        "{module}.list", "{module}.view",
        "{module}.create", "{module}.edit",
        # NINCS .delete
    ],
    "viewer": [
        "{module}.list", "{module}.view",
        # csak olvasas
    ],
}
```

### Vasszabaly: superadmin permission-ok SOHA NEM szukulnek
```python
# ❌ TILOS
BUILTIN_ROLES["superadmin"] = [...subset...]

# ✅ Helyesen
BUILTIN_ROLES["superadmin"] = list(PERMISSIONS.keys())
```

## PERMISSION_GROUPS frissitese

```python
PERMISSION_GROUPS["Tickets"] = [
    p for p in PERMISSIONS if p.startswith("tickets.")
]
```

A frontend `roles-permissions` modul ezeket csoportokba szedve mutatja.

## Frontend permission check (csak UI hint)

```tsx
import { usePermissions } from "@/lib/auth";

function TicketActions({ ticket }) {
  const { hasPermission } = usePermissions();

  return (
    <div>
      {hasPermission("tickets.edit") && <Button>Szerkeszt</Button>}
      {hasPermission("tickets.delete") && <Button>Torlés</Button>}
    </div>
  );
}
```

⚠️ A frontend check CSAK UI elrejtes. A backend MINDEN endpointon ujraellenorzi.

## Audit & roles-permissions UI

A `roles-permissions` skill biztositja:
- Vizualis matrix (role × permission)
- Drag-drop role konfigracio
- Permission keszlet importalas/exportalas
- Audit log: ki valtoztatta a role-okat (audit-trail-mandatory!)

## Tiltasok

❌ Backend endpoint `require_permission()` nelkul
❌ Frontend-only permission check (backend nelkul)
❌ Hardkodolt user.id ellenorzes (`if user.id == 1:`) — RBAC matrix-ban kell
❌ `superadmin` szukitese
❌ Permission string `:` szeparatorral (`tickets:list` rossz, `tickets.list` jo)
❌ Permission letrehozas `permissions.py`-on kivul (single source of truth)

## Hivatkozott
- Sister skill: `roles-permissions` (vizualis editor + matrix)
- Sister skill: `skillpass-auth` (JWT validacio middleware)
- Rules: `.claude/rules/security.md` (RBAC, parameterized query)
- Master skill: `crud-dla-module` (5. szekcio: Permissions)

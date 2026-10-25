---
name: roles-permissions
description: >
  Szerepkor kezeles, permission matrix, vizualis roles editor,
  require_permission makro, CRUD permission guard.
  Triggerek: "role", "permission", "jogosultsag", "szerepkor", "hozzaferes",
  "roles editor".
  NE hasznald: auth implementacio (-> skillpass-auth), session kezeles.
model: claude-sonnet-4-6
---

# Roles & Permissions

## Felelossegek
- DB: roles, permissions, role_permissions, user_roles tablak
- Vizualis permission matrix editor (/admin/settings/roles)
- require_permission! Rust makro
- Permission format: {module}:{action}
- System role-ok (super_admin, admin, editor, viewer)
- Super Admin jogai SOHA nem modosithatok (L0 guardrail)
- Role forditasok (i18n)

## Helyes output pelda

```rust
// apps/backend/src/middleware/permission.rs
use axum::extract::Extension;
use axum::http::StatusCode;

use crate::middleware::auth::SkillpassClaims;

/// Ellenorzi hogy a felhasznalo rendelkezik-e a megadott permission-nal.
/// Format: "{module}:{action}" — pl. "users:create", "products:delete"
#[macro_export]
macro_rules! require_permission {
    ($claims:expr, $permission:expr) => {{
        let has_perm = $claims.roles.iter().any(|role| {
            crate::permissions::has_permission(role, $permission)
        });
        if !has_perm {
            return Err(StatusCode::FORBIDDEN);
        }
    }};
}

// Hasznalat endpoint-ban:
// apps/backend/src/modules/users/create_user/endpoint.rs
pub async fn create_user_endpoint(
    Extension(claims): Extension<SkillpassClaims>,
    Json(input): Json<CreateUserInput>,
) -> Result<Json<UserDto>, StatusCode> {
    require_permission!(claims, "users:create");
    // ... tovabbi logika
}
```

```typescript
// apps/admin/src/lib/permissions.ts — Frontend permission guard
import { useAuth } from '@/lib/auth/skillpass-client';

export function usePermission(permission: string): boolean {
  const { user } = useAuth();
  if (!user) return false;
  return user.permissions.includes(permission);
}

// Hasznalat komponensben:
export function UserListActions() {
  const canCreate = usePermission('users:create');
  const canDelete = usePermission('users:delete');

  return (
    <div>
      {canCreate && <Button onClick={handleCreate}>Uj felhasznalo</Button>}
      {canDelete && <Button variant="destructive">Torles</Button>}
    </div>
  );
}
```

## Helytelen output pelda (NE csinald igy)

```rust
// ❌ String szintu role check (use permissions, not roles!)
if claims.roles.contains(&"admin".to_string()) {
    // ...
}

// ❌ Super admin-t modositani probal (L0 BLOCK!)
UPDATE roles SET permissions = '[]' WHERE name = 'super_admin';

// ❌ Permission format helytelen
require_permission!(claims, "create_user");  // -> "users:create"

// ❌ Nincs permission check
pub async fn delete_user_endpoint(...) { /* boom */ }
```

## Szabalyok
1. Permission format KOTELEZO: `{module}:{action}` (pl. `users:create`)
2. `require_permission!` makro MINDEN vedett endpoint-on
3. Frontend permission check CSAK UI hint — a valodi check backend-en
4. `super_admin` jogait SOHA nem lehet modositani (L0 guardrail)
5. System role-ok: `super_admin`, `admin`, `editor`, `viewer`
6. Role nev forditasok `roles.{name}` i18n kulcsban
7. Permission matrix editor CSAK super_admin jogosultsaggal erheto el

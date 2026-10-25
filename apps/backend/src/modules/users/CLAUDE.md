# Users Modul

## Leiras
Felhasznalo kezeles: CRUD muveletek, profil, jogosultsagok.

## Schema
- `auth_schema.users` tabla
- FK: `auth_schema.user_roles`

## Endpoint-ok
- POST /api/v1/users — uj felhasznalo (CreateUserEndpoint)
- GET /api/v1/users — lista (GetUsersEndpoint)
- GET /api/v1/users/:id — reszletek
- PUT /api/v1/users/:id — frissites (UpdateUserEndpoint)
- DELETE /api/v1/users/:id — torles (DeleteUserEndpoint)

## Fuggosegek
- skillpass-auth (JWT validacio, SkillPass.ID JWKS)
- roles-permissions (require_permission!)
- activity-log (automatikus CRUD logolas)

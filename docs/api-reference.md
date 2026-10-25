# API Referencia

## Alap URL
```
Lokalis:    http://localhost:8080/api/v1
Teszt:      https://test.{{DOMAIN}}/api/v1
Produkcio:  https://api.{{DOMAIN}}/api/v1
```

## Autentikacio
- Bearer token (JWT) az `Authorization` headerben
- Token beszerzes: SkillPass.ID OAuth2/OIDC flow (BFF) vagy M2M client_credentials

```
Authorization: Bearer <jwt_token>
```

## Valasz formatum

### Sikeres valasz
```json
{
  "data": { ... },
  "pagination": {
    "cursor": "abc123",
    "hasMore": true,
    "total": 150
  }
}
```

### Hiba valasz (RFC 7807)
```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validacios hiba",
  "status": 400,
  "detail": "Az email cim formatum ervenytelen",
  "instance": "/api/v1/users",
  "errors": [
    { "field": "email", "message": "Ervenytelen email formatum" }
  ]
}
```

## Endpoint-ok

### Users
| Method | Endpoint | Leiras |
|--------|----------|--------|
| GET | /api/v1/users | Felhasznalok listazasa |
| GET | /api/v1/users/:id | Felhasznalo reszletei |
| POST | /api/v1/users | Uj felhasznalo |
| PUT | /api/v1/users/:id | Felhasznalo frissitese |
| DELETE | /api/v1/users/:id | Felhasznalo torlese |

<!-- Tovabbi modulok endpoint-jai itt -->

## Lapozas
Cursor-based lapozas:
```
GET /api/v1/users?cursor=abc123&limit=50
```

## Rate Limiting
- 100 request/perc/IP (alapertelmezett)
- 429 Too Many Requests valasz tullepes eseten

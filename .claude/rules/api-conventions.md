# API Konvenciok

## REST szabalyok
- GET: lekerdezesek (lista, reszletek)
- POST: letrehozas
- PUT: teljes frissites
- PATCH: reszleges frissites
- DELETE: torles

## HTTP statusz kodok
- 200: sikeres muvelet
- 201: sikeresen letrehozva
- 204: sikeres torles (no content)
- 400: hibas input (validacios hiba)
- 401: nincs autentikacios (unauthorized)
- 403: nincs jogosultsag (forbidden)
- 404: nem talalhato
- 409: konfliktus (duplikatum)
- 423: zarolva (SafeData mod)
- 429: rate limit
- 500: szerver hiba
- 503: karbantartas

## Hiba formatum (RFC 7807)
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

## Verziozas
- URL path: `/api/v1/`, `/api/v2/`
- Uj verzio csak breaking change eseten

## Lapozas (cursor-based)
```json
{
  "data": [...],
  "pagination": {
    "cursor": "abc123",
    "hasMore": true,
    "total": 1500
  }
}
```

## Validacio
- Zod schema minden endpoint input-ra
- Validacio a handler elso lepese

# AIOS – Kódolási Konvenciók

> Minden CLI adapterben érvényes. Az egyedi adapter-specifikus kiegészítések
> az `adapters/{cli}/` sablonokban találhatók.

## TypeScript

- **strict** mód kötelező (`"strict": true` tsconfig-ban)
- **SOHA** `any` type – használj `unknown`-t és type guard-ot
- **SOHA** `as` type assertion kerülő megoldásként
- **Zod** validáció minden endpoint input/output-on
- Prefer `interface` over `type` publikus API-hoz

## Feature-based struktúra

```
src/modules/{feature}/{action}/
  CreateUserEndpoint.ts
  CreateUserService.ts
  CreateUserDto.ts
  CreateUser.test.ts
```

Fájlnév = funkció. NEM generikus: `controller.ts`, `service.ts`, `utils.ts`.

## Import sorrend

1. React / React Router
2. Külső könyvtárak (zod, axios, stb.)
3. Belső modulok (lib/, components/)
4. Típusok (type imports)

Üres sor a csoportok között.

## JSDoc – magyarul

```typescript
/**
 * Létrehozza a felhasználót a megadott adatokkal.
 * @param dto - A felhasználó adatait tartalmazó DTO
 * @returns A létrehozott felhasználó ID-ja
 * @throws ValidationError ha az email formátum érvénytelen
 */
```

## API Konvenciók

- Hiba formátum: RFC 7807
- Lapozás: cursor-based
- Verziózás: URL path (`/api/v1/`)
- HTTP státusz kódok: 200/201/204/400/401/403/404/409/429/500

RFC 7807 példa:
```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validációs hiba",
  "status": 400,
  "detail": "Az email cím formátum érvénytelen",
  "instance": "/api/v1/users"
}
```

## Egyéb szabályok

- Logger modul használata – SOHA `console.log`
- Nincs hardcoded URL – környezeti változó
- Nincs magic number – nevesített konstans
- Parameterized query kizárólag (SQL injection védelem)
- CORS: explicit whitelist, SOHA `*`

## Elnevezési konvenciók

- PascalCase: komponensek, interfészek, type-ok
- camelCase: függvények, változók, property-k
- UPPER_SNAKE_CASE: konstansok
- kebab-case: fájlnevek (kivéve: `{Action}{Entity}` minták)

## Tiltások

- `.env` commitálás
- `any` type
- `console.log`
- TODO/FIXME/HACK/placeholder kód
- Hardcoded URL
- Saját kriptográfia
- Docker nélküli futtatás

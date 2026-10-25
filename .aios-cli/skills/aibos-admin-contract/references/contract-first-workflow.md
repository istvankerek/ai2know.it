# Contract-First Workflow

**Forrás:** `/Users/everengine/Documents/dev/aibos` @ `7e30ba5` (2026-10-06)  
Hivatkozott fájlok: `contracts/external/aibootcamp-admin.yaml`,
`crates/aibos-aibootcamp-client/`, `console/lib/menu-config.ts`,
`specification/plan-v25/`, `specification/plan-v26/00_terv.md`

---

## Az alapelv

> A partner projekt `contracts/admin/` könyvtárában lévő OpenAPI fájl az
> egyetlen igazságforrás. Sem az aibos konzol, sem a typed client crate nem
> kerülhet szinkronba azzal addig, amíg az OpenAPI nincs lezárva (frozen).

---

## Lépések sorrendben

### 1. OpenAPI szerződés a partner repóban

Hozd létre a `contracts/admin/{projekt}-admin.yaml` fájlt. Kötelező elemek:

- `openapi: "3.1.0"`
- `info.title`, `info.version`, `info.description`
- Minden operáción: `x-permission: {modul}.{akció}` (rövidített, a realm prefix
  nélkül — a teljes kód a `permissions.json`-ban él)
- Cursor-alapú lapozás minden lista végponton
- RFC 7807 hibaszema hivatkozás minden nem-2xx választ adó endpointon
- Security scheme: `workloadJwt` Bearer + `actorAssertion` JWS header

Mintafájl: `templates/admin-contract/contracts/admin/example-admin.yaml`

### 2. Validáció

```bash
# stdlib validator a partner repóban (vagy a skeleton templateból másolva):
python3 scripts/validate-contract.py contracts/
```

Ellenőrzi:
- Minden operációnak van `x-permission`
- Az `x-permission` kód szerepel a `permissions.json`-ban
- Minden nem-2xx válasz hivatkozza a problem schema-t
- Nincs wildcard a permission kódokban

### 3. Mock szerver (aibos oldalán)

Az aibos csapat az OpenAPI-ból mock szervert épít (pl. `prism` vagy egyedi
Rust mock handler). A konzol fejlesztése a mock ellen indul, függetlenül a
partner implementációtól.

```bash
# példa prism-mel:
npx @stoplight/prism-cli mock contracts/admin/{projekt}-admin.yaml
```

### 4. Typed client crate az aibos repóban

Az aibos `crates/aibos-{projekt}-client` crate az OpenAPI-ból generált,
erősen típusos Rust kliens:

```
crates/aibos-{projekt}-client/
  Cargo.toml
  src/
    lib.rs          ← generált API trait + Reqwest implementáció
    models.rs       ← generált DTO struct-ok (serde)
    error.rs        ← RFC 7807 problem típusok
```

Generálás: `openapi-generator-cli` + `rust` generator, utólag
kézzel igazított `error.rs`.

A kliens minden kérésnél automatikusan csatolja:
- `Authorization: Bearer <workload_jwt>`
- `X-Actor-Assertion: <jws>` (az aibos actor assertion middleware állítja elő)
- `X-Operator-Id` + `X-Operator-Roles` (az aibos session kontextusból)

### 5. Konzol menüpont hozzáadása

`console/lib/menu-config.ts` bővítése a MenuCategory/MenuApp/MenuSub
hierarchia szerint (részletek: `references/menu.md`):

```typescript
// console/lib/menu-config.ts
{
  id: "aibootcamp",
  labelKey: "app.aibootcamp",
  color: "#10b981",
  href: "/aibootcamp",
  icon: "GraduationCap",
  subs: [
    {
      id: "overview",
      labelKey: "sub.overview",
      href: "/aibootcamp",
      permission: "aibos.aibootcamp.view",
      icon: "Grid2x2",
    },
    {
      id: "courses",
      labelKey: "sub.courses",
      href: "/aibootcamp/courses",
      permission: "aibos.aibootcamp.courses.list",
      icon: "BookOpen",
    },
  ],
}
```

**Kötelező teszt:** `tests/menu-config.test.ts` ellenőrzi, hogy minden
`href` létező route-ra mutat (részletek: `references/menu.md`).

### 6. DLA oldalak az aibos konzolban

Az aibos konzolban a szokásos DLA minta szerint (részletek: `dla-menu-pattern`
skill):

```
/aibootcamp/courses                → lista (TablePage)
/aibootcamp/courses/add            → létrehozás
/aibootcamp/courses/[id]           → részlet + inline szerkesztés
```

Minden oldal a typed client crate-et használja, soha nem hív közvetlenül
`fetch`-et.

### 7. Partner implementáció

A partner projektben kötelező elemek:

```
src/
  admin/
    middleware/
      auth.rs         ← workload JWT + actor assertion validáció
    handlers/
      {modul}.rs      ← CRUD handler-ek
    audit.rs          ← append-only audit log writer
```

Middleware ellenőrzési sorrend:
1. Workload JWT aláírás, `iss`, `aud`, `client_id`, `scope`, `exp`
2. `X-Actor-Assertion` JWS — részletek: `references/actor-assertion.md`
3. Permission check: assertion `scp` tartalmazza az endpoint `x-permission`-jét
4. Handler meghívás
5. Audit log bejegyzés (minden mutációra)

---

## Változáskezelés

| Változástípus | Teendő |
|---------------|--------|
| Nem breaking (új opcionális mező) | Partner frissíti YAML-t + validáció, aibos frissíti a typed client-et |
| Breaking (endpoint megszüntetése, kötelező mező hozzáadása) | Verzióváltás: `/api/admin/v2/...`, mindkét verzió él ≥3 hónapig |
| Permission kód hozzáadása | `permissions.json` + `role-matrix.csv` frissítése mindkét oldalon, bináris újraépítés |
| Permission kód eltávolítása | TILOS megszüntetés előtt. Deprecated jelölés, majd következő főverzióban eltávolítás |

---

## Ellenőrzőlista új partner admin API-hoz

```
[ ] contracts/admin/{projekt}-admin.yaml elkészült és frozen
[ ] validate-contract.py átment
[ ] permissions.json + role-matrix.csv frissítve (partner oldal)
[ ] aibos-permissions.json bővítve az aibos oldali permission kódokkal
[ ] Mock szerver elérhető
[ ] aibos-{projekt}-client crate generálva és tesztelt
[ ] console/lib/menu-config.ts bővítve
[ ] tests/menu-config.test.ts zöld (nincs 404-es href)
[ ] DLA oldalak implementálva az aibos konzolban
[ ] Partner middleware: workload JWT + actor assertion
[ ] Partner: append-only audit log
[ ] E2E teszt: mock → typed client → DLA oldalak
```

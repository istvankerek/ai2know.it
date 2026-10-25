# Admin Contract Sablon

Ez a könyvtár kiindulópontot ad egy új partner projekt aibos admin API
szerződéséhez. Másold be a partner repódba, cseréld ki az `example` / `aibootcamp`
hivatkozásokat a valódi projekt nevére, majd töltsd ki a tényleges endpointokat.

---

## Könyvtárszerkezet

```
templates/admin-contract/
├── contracts/
│   ├── admin/
│   │   ├── example-admin.yaml        ← ember-olvasható OpenAPI 3.1
│   │   └── example-admin.json        ← gépi formátum (validator inputja)
│   └── authorization/
│       ├── permissions.json          ← permission katalógus
│       ├── permissions.schema.json   ← JSON Schema a permissions.json-hoz
│       └── role-matrix.csv           ← szerepkör → permission kiosztás
└── scripts/
    ├── validate-contract.py          ← stdlib validator (Python 3, függőség nélkül)
    └── test_validate_contract.py     ← unittest tesztek a validátorhoz
```

---

## Gyors kezdés

### 1. Másold be a partner repóba

```bash
cp -r templates/admin-contract/contracts /path/to/partner-repo/
cp -r templates/admin-contract/scripts  /path/to/partner-repo/
```

### 2. Nevezd át az `aibootcamp` hivatkozásokat

```bash
# Linux/macOS
grep -rl "aibootcamp" contracts/ scripts/ | xargs sed -i 's/aibootcamp/PROJEKTNEV/g'
```

### 3. Töltsd ki az endpointokat

Szerkeszd a `contracts/admin/PROJEKTNEV-admin.yaml` fájlt. Kötelező elemek:
- Minden operáción: `x-permission: {modul}.{akció}` (pl. `courses.list`)
- Minden nem-2xx választ adó endpointon: `$ref: "#/components/responses/Problem"`
- Cursor-alapú lapozás minden lista végponton
- Security scheme: `workloadJwt` + `actorAssertion`

### 4. Definiáld a permission kódokat

Szerkeszd a `contracts/authorization/permissions.json` fájlt az operáció kódokkal:
- Formátum: `{projekt}.{modul}.{akció}` (pl. `aibootcamp.courses.list`)
- DENY by default — csak felsorolt kódok engedélyezhetők
- Nincs wildcard

Töltsd ki a `role-matrix.csv`-t: ki kap milyen jogot.

### 5. Generáld a JSON verziót

```bash
python3 scripts/yaml_to_json.py contracts/admin/PROJEKTNEV-admin.yaml \
  > contracts/admin/PROJEKTNEV-admin.json
```

Vagy kézzel tartsd szinkronban a YAML és JSON fájlokat.

### 6. Validáld

```bash
# A skeleton gyökeréből:
python3 templates/admin-contract/scripts/validate-contract.py templates/admin-contract

# A partner repó gyökeréből:
python3 scripts/validate-contract.py contracts/
```

---

## YAML és JSON — döntés

Az OpenAPI szerződés két formában él:

| Fájl | Célja |
|------|-------|
| `example-admin.yaml` | Ember-olvasható, diff-barát, kézikönyv |
| `example-admin.json` | Gépi feldolgozás, validator input, typegen |

**Miért nem csak YAML?** A Python stdlib-nek nincs YAML parsere. A validator
`.json` fájlokat dolgoz fel, mert ez a legegyszerűbb, legtransparensebb megközelítés.

A YAML és JSON tartalmát szinkronban kell tartani. CI pipeline-ban ez automatizálható
`yq` vagy hasonló eszközzel:

```bash
yq e -o=json contracts/admin/PROJEKTNEV-admin.yaml \
  > contracts/admin/PROJEKTNEV-admin.json
```

---

## Validátor szabályok

A `validate-contract.py` ellenőrzi:

1. **Permission formátum:** minden kód illeszkedik a `^[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*$` regex-re
2. **Nincs wildcard:** egyetlen kódban sem szerepel `*`
3. **Kódok egyediek:** nincs duplikátum a `permissions.json`-ban
4. **Role matrix konzisztencia:** csak ismert permission kódok, csak `ALLOW` effect
5. **OpenAPI `x-permission`:** minden operáción megvan (GET, POST, PUT, PATCH, DELETE)
6. **`x-permission` létezik:** a hivatkozott kód szerepel a `permissions.json`-ban
7. **Nem-2xx válasz hivatkozza a problem sémát:** `$ref: "#/components/responses/Problem"` (vagy inline equivalent)

---

## aibos bekötés

Miután a szerződés kész, az aibos csapatnak:

1. A `permissions.json` alapján bővíteni kell az `aibos-permissions.json`-t
   (prefix: `aibos.{projekt}.`)
2. Generálni kell az `aibos-{projekt}-client` typed crate-et
3. Bővíteni kell a `console/lib/menu-config.ts`-t
4. Implementálni kell a DLA oldalakat az aibos konzolban

Részletek: `.aios-cli/skills/aibos-admin-contract/references/contract-first-workflow.md`

---

## Hivatkozások

- Skill: `.aios-cli/skills/aibos-admin-contract/SKILL.md`
- Actor assertion: `.aios-cli/skills/aibos-admin-contract/references/actor-assertion.md`
- Permission szabályok: `.aios-cli/skills/aibos-admin-contract/references/permissions.md`
- Menü modell: `.aios-cli/skills/aibos-admin-contract/references/menu.md`
- Workflow: `.aios-cli/skills/aibos-admin-contract/references/contract-first-workflow.md`

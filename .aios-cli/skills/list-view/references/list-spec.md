# Lista Nézet Specifikáció v2.2

## 1. Layout struktúra

```
┌──────────────────────────────────────────────────────────────────────┐
│ Mentett nézetek: [Összes ▼] [Aktív adminok] [Mai regisztrációk] [+] │
├──────────────────────────────────────────────────────────────────────┤
│ 🔍 [_________________________] [Oszlop: Összes ▼]                   │
│                                                                      │
│ Szűrők: [Státusz ▼] [Szerepkör ▼] [Dátum: -tól ─ -ig] [+ szűrő]   │
│ Aktív: [Státusz: Aktív ✕] [Szerepkör: Admin ✕]      [Szűrők törlés]│
│                                                                      │
│ [Simple] [Advanced]                    234 találat / 1,247 összesen  │
├──────────────────────────────────────────────────────────────────────┤
│ ☐ │ Név ↕         │ Email ↕        │ Szerepkör ↕ │ Státusz ↕ │ ··· │
│───┼────────────────┼────────────────┼─────────────┼───────────┼─────│
│ ☐ │ Kiss Anna      │ anna@mail.hu   │ Admin       │ 🟢 Aktív  │ ··· │
│ ☑ │ Nagy Péter     │ peter@mail.hu  │ Editor      │ 🟢 Aktív  │ ··· │
│ ☑ │ Szabó János    │ janos@mail.hu  │ Viewer      │ 🔴 Inaktív│ ··· │
│   │                │                │             │           │     │
│   │ ... (virtuális scrolling ha "all" kiválasztva)           │     │
├──────────────────────────────────────────────────────────────────────┤
│ ☑ 2 kijelölve  [▸ Mind a 234 szűrt kijelölése]                     │
│                                                                      │
│ Műveletek: [📥 Export ▼] [✏️ Szerkesztés] [🗑️ Törlés] [📦 Letöltés]│
├──────────────────────────────────────────────────────────────────────┤
│ Lapozás: [◀ Előző] 1 2 3 ··· 5 [Következő ▶]   [50▼] elem/oldal   │
└──────────────────────────────────────────────────────────────────────┘
```

## 2. Keresés & Szűrés

### 2.1 Globális keresés
- Egy keresőmező az összes kereshető oszlopon
- **Fuzzy search** támogatás (typo-toleráns)
- **Debounce**: 300ms (ne indítson API hívást minden billentyűleütésnél)
- **Oszlop-specifikus keresés**: legördülő menüvel kiválasztható melyik oszlopra szűrjön
- Keresés eredmény kiemelése (highlight) a táblázatban

### 2.2 Szűrő típusok oszloponként

| Oszlop típus | Szűrő widget | Viselkedés |
|---|---|---|
| **Text** (név, email) | Fuzzy search input | Részleges egyezés, case-insensitive |
| **Enum/Select** (státusz, role) | Multi-select dropdown | Több érték kijelölhető (OR logika) |
| **Date** (létrehozás, módosítás) | Date range picker | -tól/-ig, preset-ek: ma, héten, hónapban |
| **Number** (ár, mennyiség) | Min-max range slider + input | Párhuzamos slider + szám bevitel |
| **Boolean** (aktív, verifikált) | Toggle switch | Igen/Nem/Mind |
| **Relation** (kategória, címke) | Autocomplete search + chips | Keresés a kapcsolt táblában |
| **Taxonomy** (group, label, status) | Multi-select a taxonomy-ból | Taxonomy rendszerből (Section 24) |

### 2.3 Aktív szűrők megjelenítése
- Chip-ek sorban, mindegyiken ✕ gomb az egyedi törléshez
- "Összes szűrő törlése" gomb
- Szűrő állapot URL-ben is tükröződik (megosztható link)
- Szűrő állapot elmenthető "Mentett nézetként"

### 2.4 Server-side szűrés
- Minden szűrő API query paraméterként megy
- Nem a frontend szűri az adatot (kivéve: AG Grid client-side mód kis adatnál)
- API formátum: `GET /api/v1/{module}?filter[status]=active&filter[role]=admin&search=kiss&sort=-created_at&page=1&limit=50`

## 3. Rendezés

### 3.1 Egyoszlopos rendezés
- Klikk az oszlop fejlécre: nincs → asc (↑) → desc (↓) → nincs
- Vizuális jelzés: nyíl ikon a fejlécben

### 3.2 Többoszlopos rendezés
- **Shift+klikk**: másodlagos, harmadlagos rendezés hozzáadása
- Vizuális jelzés: szám badge az oszlop fejlécben (①②③)
- Alapértelmezett: `created_at desc` (legújabb elől)

### 3.3 Rendezés API-ban
```
?sort=-created_at,+name    # created_at DESC, name ASC
```

## 4. Lapozás

### 4.1 Elemek oldalanként
- Opciók: **50** (default) | 100 | 500 | 1000 | All
- "All" figyelmeztetéssel ha > 5,000 sor: "Ez lassíthatja a böngészőt. Folytatod?"
- Kiválasztás legördülő menüvel a tábla alján

### 4.2 Navigáció
- Előző/Következő gombok
- Oldal számok: 1 2 3 ··· 47 48 49 (collapse a közepén)
- Közvetlen ugrás: "Ugrás oldalra: [__]"

### 4.3 Virtual Scrolling (AG Grid Advanced)
- "All" kiválasztásakor virtual scrolling – csak a DOM-ban látható sorok renderelve
- AG Grid Server-Side Row Model: lazy loading 100-as blokkonként
- Nem fagyasztja le a böngészőt 100K+ sornál sem

### 4.4 Összesítő
- Mindig látható: **"234 találat a szűrésből / 1,247 összesen"**
- Ha nincs szűrő: "1,247 elem összesen"

## 5. Bulk Kijelölés – Háromszintű

### 5.1 Kijelölési szintek

| Szint | Trigger | Hatás | Vizuális |
|---|---|---|---|
| **Egyedi** | Checkbox soronként | 1 sor kijelölve | ☑ az adott soron |
| **Oldal** | Fejléc checkbox | Aktuális oldal összes sora | ☑ fejlécben + összes soron |
| **Szűrt** | Banner gomb megnyomása | Mind a N szűrt eredmény | Banner: "234 szűrt kijelölve" |
| **Teljes DB** | Banner gomb megnyomása | Teljes adatbázis | Banner: "1,247 kijelölve (teljes)" |

### 5.2 Banner viselkedés (Gmail minta)
```
Amikor a fejléc checkbox-ra kattintasz:
  → Banner: "Mind az 50 elem kijelölve ezen az oldalon."
  → Link: "Mind a 234 szűrt eredmény kijelölése"
  → Link: "Mind az 1,247 elem kijelölése a teljes adatbázisból"

Amikor "szűrt eredmény kijelölése":
  → Banner: "Mind a 234 szűrt elem kijelölve."
  → Link: "Kijelölés megszüntetése"
  → A bulk műveletek az ÖSSZES szűrt elemre vonatkoznak (nem csak az aktuális oldal)
  → A backend kapja: { selectionMode: 'filtered', filters: {...} }

Amikor "teljes adatbázis kijelölése":
  → Banner: "Mind az 1,247 elem kijelölve a teljes adatbázisból."
  → A backend kapja: { selectionMode: 'all' }
```

### 5.3 Backend implementáció

```typescript
// A frontend SOHA nem küld 10,000 ID-t – ehelyett mode-ot küld
interface BulkRequest {
  action: 'delete' | 'edit' | 'export' | 'download';
  selection:
    | { mode: 'individual'; ids: string[] }           // Max ~1000 ID
    | { mode: 'filtered'; filters: FilterParams }      // Backend szűri
    | { mode: 'all' }                                  // Teljes tábla
  ;
  // Bulk edit esetén:
  changes?: Record<string, unknown>;
  // Export esetén:
  format?: 'csv' | 'xlsx' | 'pdf' | 'md' | 'json';
}
```

## 6. Bulk Műveletek

### 6.1 Bulk Export

```
📥 Export ▼
├── CSV (.csv)        – UTF-8 BOM, Excel kompatibilis
├── Excel (.xlsx)     – Formázott fejlécek, auto-width, szűrők
├── PDF (.pdf)        – Táblázat + logó + dátum + oldalszám
├── Markdown (.md)    – Markdown tábla (Slack/Teams/docs)
└── JSON (.json)      – Nyers adat (fejlesztőknek)
```

Viselkedés:
- Kijelölt sorok exportálása (ha van kijelölés)
- Ha nincs kijelölés → aktuális szűrt eredmény exportálása
- Nagy export (> 10,000) → háttérben generálás, notification ha kész
- Export tartalmazza az összes oszlopot (nem csak a láthatókat)

### 6.2 Bulk Delete

```
🗑️ Törlés gomb → Megerősítő modal:
┌─────────────────────────────────────────────┐
│ ⚠️ Biztosan törlöd?                        │
│                                             │
│ 23 elem kerül törlésre.                     │
│ Ez a művelet NEM vonható vissza.            │
│                                             │
│ Írd be "TÖRLÉS" a megerősítéshez:           │
│ [________________]                          │
│                                             │
│              [Mégse]  [Törlés]              │
└─────────────────────────────────────────────┘
```

- Soft delete (is_deleted flag, nem fizikai törlés)
- Activity log bejegyzés minden törölt elemről
- Ha > 100 elem → háttérben, notification ha kész
- Megerősítés: szöveg beírás ("TÖRLÉS") > 10 elemnél

### 6.3 Bulk Edit

```
✏️ Szerkesztés → Modal:
┌─────────────────────────────────────────────┐
│ Tömeges szerkesztés (23 kijelölt elem)      │
│                                             │
│ ☑ Státusz:     [Aktív ▼]                    │
│ ☐ Szerepkör:   [— Nem módosít —]           │
│ ☐ Kategória:   [— Nem módosít —]           │
│ ☐ Címkék:      [— Nem módosít —]           │
│                                             │
│ ℹ️ Csak a bejelölt mezők módosulnak.        │
│                                             │
│    [Mégse]  [Előnézet (23 elem)]  [Alkalmaz]│
└─────────────────────────────────────────────┘
```

- Checkbox-szal jelöli melyik mezőt módosítja
- "Előnézet": megmutatja mit fog változtatni mielőtt alkalmazza
- Activity log: minden módosított elem, régi→új érték
- Enum/Select/Taxonomy mezők: batch-ben módosíthatók
- Text mezők: "Csere" mód (keresés→csere) vagy "Felülírás" mód

### 6.4 Bulk Download

- Csak ha a modulnak van fájl mezője (avatar, dokumentum, kép)
- ZIP-be csomagolva (háttérben)
- Notification ha kész + letöltési link
- Fájlnév konvenció: `{module}_{id}_{field}.{ext}`

## 7. Simple nézet (shadcn/ui DataTable)

### 7.1 Mikor használd
- Alapértelmezett nézet minden modulnál
- < 10,000 sor esetén tökéletesen elég
- Mobil-barát, gyors betöltés (~50KB vs AG Grid ~3MB)

### 7.2 Funkciók
- Keresés, szűrés, rendezés, lapozás, bulk műveletek – mind működik
- Oszlop szűrés: popup filterek (nem inline)
- Rendezés: klikk a fejlécre
- Responsive: mobil nézetben kártyás megjelenítés

### 7.3 Implementáció
```typescript
import { DataTable } from "@/components/ui/data-table";
import { columns } from "./columns";

// A DataTable wrappeli a shadcn/ui Table + filtering + sorting + pagination
<DataTable
  columns={columns}
  data={data}
  pagination={config.list.pagination}
  filters={config.list.filters}
  bulkActions={config.list.bulk}
  onBulkAction={handleBulk}
/>
```

## 8. Advanced nézet (AG Grid Enterprise)

### 8.1 Mikor használd
- Power usereknek (a TF.js intelligence ajánlja nagy adatnál)
- > 10,000 sor
- Pivot/csoportosítás/aggregáció szükséges
- Inline szerkesztés kell

### 8.2 AG Grid Enterprise Features – Tier rendszer

#### Tier 1 – Alapértelmezetten bekapcsolva

| Feature | Konfig kulcs | Leírás |
|---|---|---|
| Server-Side Row Model | `serverSideRowModel: true` | Lazy loading 100-as blokkonként, 100K+ sor |
| Column Filters | (beépített) | Oszloponkénti szűrés (text, number, date, set) |
| Multi-Column Sort | `multiSort: true` | Shift+klikk többszintű rendezés |
| Column Reorder & Resize | (beépített) | Drag & drop oszlop sorrend + szélesség |
| Column Pinning | `columnPinning: true` | Bal/jobb rögzítés (ID, név fix) |
| Row Selection | `rowSelection: 'multiple'` | Checkbox + Shift+klikk range |
| Row Grouping | `rowGrouping: true` | Csoportosítás bármely oszlop szerint |
| Clipboard | `clipboard: true` | Ctrl+C másolás cellákból/sorokból |
| Excel Export | (beépített) | Natív .xlsx export formázással |
| Quick Filter | (beépített) | Globális keresés minden oszlopon |
| Status Bar | `statusBar: true` | Összeg/átlag/darabszám kijelölt cellákon |

#### Tier 2 – Modulonként bekapcsolható

| Feature | Konfig kulcs | Mikor |
|---|---|---|
| Pivot Mode | `pivotMode: true` | Analitika, pénzügy modulok |
| Aggregation | `aggregation: true` | Összeg/átlag csoportonként |
| Master/Detail | `masterDetail: true` | Rendelés → tételek, szülő → gyerek |
| Tree Data | `treeData: true` | Kategóriák, szervezeti fa, hierarchia |
| Charts Integration | `chartsIntegration: true` | Kijelölésből grafikon generálás |
| Sparklines | `sparklines: true` | Mini trend-grafikonok cellákban |

### 8.3 Inline Edit (AG Grid)

| Mező típus | Szerkesztés mód | Trigger |
|---|---|---|
| Text, Number | Inline – dupla kattintás a cellára | Direkt szerkesztés |
| Boolean | Toggle switch | Egy kattintás |
| Select/Enum | Dropdown megnyitás | Egy kattintás |
| Date | Date picker popup | Klikk |
| Relation | Autocomplete modal | Klikk → modal |
| File | Upload modal | Klikk → modal |

- Enter: mentés + következő sorra lépés
- Escape: mégse
- Tab: mentés + következő cellára
- Változás → API PATCH → Activity log

### 8.4 AG Grid konfigurációs példa

```typescript
const gridOptions: GridOptions = {
  // Server-Side Row Model (lazy loading)
  rowModelType: 'serverSide',
  serverSideDatasource: createServerSideDatasource(moduleConfig),
  cacheBlockSize: 100,

  // Kijelölés
  rowSelection: 'multiple',
  suppressRowClickSelection: true,  // Csak checkbox-szal

  // Rendezés
  multiSortKey: 'shift',

  // Csoportosítás
  rowGroupPanelShow: 'always',      // Drag & drop csoportosítás

  // Status Bar
  statusBar: {
    statusPanels: [
      { statusPanel: 'agTotalAndFilteredRowCountComponent' },
      { statusPanel: 'agSelectedRowCountComponent' },
      { statusPanel: 'agAggregationComponent' },
    ],
  },

  // Oszlop rögzítés
  defaultColDef: {
    sortable: true,
    filter: true,
    resizable: true,
    floatingFilter: true,           // Szűrő sor a fejléc alatt
  },

  // Lokalizáció
  localeText: AG_GRID_LOCALE_HU,    // Magyar felület!
};
```

## 9. Mentett nézetek (Saved Views)

### 9.1 Adatbázis struktúra
```sql
CREATE TABLE saved_views (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module      VARCHAR(100) NOT NULL,      -- 'users', 'products'
    user_id     UUID REFERENCES users(id),  -- NULL = globális/megosztott
    name        VARCHAR(255) NOT NULL,
    is_default  BOOLEAN DEFAULT FALSE,
    is_shared   BOOLEAN DEFAULT FALSE,      -- Csapattal megosztott
    config      JSONB NOT NULL,             -- Teljes nézet konfiguráció
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### 9.2 Config JSONB tartalom
```json
{
  "filters": { "status": ["active"], "role": ["admin"] },
  "sort": [{ "field": "created_at", "direction": "desc" }],
  "columns": {
    "visible": ["name", "email", "role", "status", "created_at"],
    "order": ["name", "email", "role", "status", "created_at"],
    "widths": { "name": 200, "email": 250 },
    "pinned": { "left": ["name"], "right": [] }
  },
  "pageSize": 100,
  "viewMode": "simple",
  "groupBy": null
}
```

### 9.3 UI
```
Mentett nézetek: [Összes ▼] [Aktív adminok] [Mai regisztrációk] [📌 Alapért.] [+ Nézet mentés]
                                                                     ↑
                                                            Csillag ikon: alapértelmezetté teszi
```

## 10. Keyboard Shortcut-ok

| Billentyű | Művelet |
|---|---|
| `/` | Keresőbe ugrás (focus) |
| `Escape` | Keresőből kilépés / kijelölés törlés / modal bezárás |
| `Ctrl+A` | Összes kijelölése az aktuális oldalon |
| `Ctrl+Shift+A` | Összes kijelölése a szűrt eredményből |
| `Delete` | Kijelöltek törlése (megerősítő modal) |
| `Ctrl+E` | Export menü megnyitása |
| `Ctrl+Enter` | Inline edit mentése |
| `←` / `→` | Lapozás előre/hátra |
| `Ctrl+G` | Ugrás oldalra (Go to page) |
| `Shift+klikk` (fejléc) | Multi-sort hozzáadás |
| `Shift+klikk` (sor) | Range kijelölés (A-tól B-ig) |
| `Tab` | Következő szerkeszthető cella (inline edit) |

## 11. Mobil nézet

- < 768px: tábla helyett **kártyás nézet**
- Kártyán: elsődleges mezők megjelenítése + "Részletek" gomb
- Swipe jobb: gyors szerkesztés
- Swipe bal: törlés (megerősítéssel)
- Bulk kijelölés: long press → checkbox mód
- Szűrők: bottom sheet modal

## 12. Permission integráció

- Lista megtekintés: `{module}:list` permission
- Bulk export: `{module}:export` permission
- Bulk delete: `{module}:delete` + `{module}:bulk` permission
- Bulk edit: `{module}:update` + `{module}:bulk` permission
- Advanced nézet: `{module}:list` + `system:advanced-grid` permission
- Mentett nézet megosztás: `{module}:list` + `system:share-views` permission

Ha nincs jogosultsága → a gomb/fül nem jelenik meg (nem disabled, hanem hidden).
```

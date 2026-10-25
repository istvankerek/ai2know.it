# Menü modell — MenuCategory → MenuApp → MenuSub

**Forrás:** `/Users/everengine/Documents/dev/aibos` @ `7e30ba5` (2026-10-06)  
Hivatkozott fájlok: `console/lib/menu-config.ts`, `tests/menu-config.test.ts`

---

## Háromszintű hierarchia

```
MenuCategory
  id, labelKey, icon
  └── MenuApp[]
        id, labelKey, color, href, icon
        └── MenuSub[]
              id, labelKey, href, permission, icon, group?
```

| Szint | Felelőssége |
|-------|-------------|
| `MenuCategory` | Tematikus csoportosítás (értékesítés, tartalom, rendszer…) |
| `MenuApp` | Egy partner modul vagy aibos modul belépési pontja |
| `MenuSub` | Konkrét oldal (lista, részlet, beállítás) |

---

## TypeScript típusok (console/lib/menu-config.ts)

```typescript
export interface MenuSub {
  readonly id: string;
  readonly labelKey: MessageKey;
  readonly href: string;
  readonly permission: string;   // kötelező!
  readonly icon: IconName;
  readonly group?: MessageKey;   // opcionális csoportfejléc
}

export interface MenuApp {
  readonly id: string;
  readonly labelKey: MessageKey;
  readonly color: string;        // hex, bal sáv szín
  readonly href: string;         // alapértelmezett route
  readonly icon: IconName;
  readonly subs: readonly MenuSub[];
}

export interface MenuCategory {
  readonly id: string;
  readonly labelKey: MessageKey;
  readonly icon: IconName;
  readonly apps: readonly MenuApp[];
}
```

---

## Szabályok

### Minden menüpontnak kötelező a jogosultsága

```typescript
// ❌ TILOS
{ id: "courses", href: "/aibootcamp/courses" }

// ✅ Helyes
{ id: "courses", href: "/aibootcamp/courses", permission: "aibos.aibootcamp.courses.list" }
```

### Szerver oldali szűrés

A menükonfiguráció szerver oldalon szűrődik az operátor effektív permission
készlete alapján. A kliensre csak azok a menüpontok kerülnek, amelyekhez az
operátornak valóban joga van.

Ez **felületi elrejtés** — a backend minden API hívásnál újra ellenőriz.
A frontend menüszűrés csak UX, nem biztonsági garancia.

### "Menüpont soha nem 404"

Minden `href` létező route-ra kell mutatnia. A mintarendszerben 33 menüpont
404-re vitt — ezt nálunk teszt akadályozza meg.

```typescript
// tests/menu-config.test.ts (részlet)
it("minden MenuSub href létező route-ra mutat", () => {
  const allSubs = MENU
    .flatMap(cat => cat.apps)
    .flatMap(app => app.subs);

  for (const sub of allSubs) {
    expect(existingRoutes.has(sub.href), `Nem létező route: ${sub.href}`).toBe(true);
  }
});
```

---

## Példa: partner modul hozzáadása

```typescript
// console/lib/menu-config.ts bővítése
{
  id: "partners",      // MenuCategory (meglévő)
  labelKey: "cat.partners",
  icon: "Network",
  apps: [
    // ... meglévő appok ...
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
          group: "sub.group.content",
        },
        {
          id: "students",
          labelKey: "sub.students",
          href: "/aibootcamp/students",
          permission: "aibos.aibootcamp.students.list",
          icon: "Users",
          group: "sub.group.content",
        },
      ],
    },
  ],
}
```

---

## Aibos oldali permission kódok vs partner kódok

A menükonfiguráció az aibos `permissions.json`-ban definiált kódokat
hivatkozza (prefix: `aibos.`), nem a partner projekt kódjait.

Az aibos szintű kódok leképezik a partner projekteket:

```
aibos.aibootcamp.view               ← az aiBootcamp app megjelenik a menüben
aibos.aibootcamp.courses.list       ← kurzusok lista oldal látható
aibos.aibootcamp.students.list      ← diákok lista oldal látható
```

A partner `permissions.json` a partner domainen él (`aibootcamp.courses.list`),
az aibos `aibos-permissions.json` az aibos domainen (`aibos.aibootcamp.courses.list`).
Az aibos middleware leképezi a kettőt az actor assertion `scp` mezőn keresztül.

---

## i18n kulcsok

Minden `labelKey` az aibos konzol lokalizációs fájljaiban (`console/lib/i18n/`)
kell szerepeljen. Hiányzó kulcs TypeScript fordítási hibát okoz (strict `MessageKey` típus).

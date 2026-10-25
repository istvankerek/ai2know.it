---
name: skillpass-app-launcher
description: >
  Partner portal regisztracio a SkillPass.ID 9-pontos launcherben es a
  workspace shell app-listajaban. Hydra kliens metadata.launcher mezok
  (app_id, name, tagline, launch_url, accent, icon, nav, category,
  required_entitlements, data_scope_note), consent-api /portals, shell-context
  GET /api/v1/partner/shell-context, kedvencek (favourites). Validaciós
  szabályok és default-deny policy.
  Triggerek: "launcher", "9-pontos menu", "app launcher", "app regisztracio",
  "metadata.launcher", "shell context", "portals api", "kedvenc app",
  "favourites", "app-switcher", "connected app".
  NE hasznald: auth implementacio (-> skillpass-auth),
  shell UI beagyazas (-> skillpass-portal).
priority: P1
model: claude-sonnet-5-5
related_skills:
  - skillpass-auth
  - skillpass-portal
---

# SkillPass.ID App Launcher – Regisztrációs útmutató

A 9-pontos launcher csempéje és a workspace shell app-listája a Hydra kliens
`metadata.launcher` mezőjéből épül fel. Az adatokat a SkillPass team tárolja
— a partner kéréssel regisztráltatja.

---

## 1. metadata.launcher mezők

A teljes validációs referencia: `skillpass-auth` skill `references/client-registration.md`.

```json
"metadata": {
  "launcher": {
    "app_id": "aibootcamp",
    "name": "AI Bootcamp",
    "tagline": "Mesterséges intelligencia képzések",
    "launch_url": "https://aibootcamp.hu",
    "category": "oktatás",
    "accent": "#F0731D",
    "icon": {
      "svg": "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'>…</svg>"
    },
    "nav": [
      {
        "label": { "hu": "Főmenü", "en": "Main" },
        "items": [
          {
            "id": "home",
            "label": { "hu": "Kezdőlap", "en": "Home" },
            "href": "/",
            "icon": "Home"
          },
          {
            "id": "trainings",
            "label": { "hu": "Képzések", "en": "Trainings" },
            "href": "/trainings",
            "icon": "GraduationCap"
          }
        ]
      }
    ],
    "required_entitlements": ["aibootcamp-access"],
    "data_scope_note": {
      "hu": "Képzési adatok az AI Bootcamp rendszeréből.",
      "en": "Training data from AI Bootcamp."
    }
  }
}
```

### Kötelező mezők

| Mező | Szabály |
|------|---------|
| `name` | max 200 kar., `<` és `>` tilos — hiba esetén az app **kiesik** a launcherből |
| `launch_url` | csak `https://`, userinfo (`user@host`) tilos — hiba esetén az app **kiesik** |

### Opcionális mezők

| Mező | Hiba esetén |
|------|-------------|
| `app_id` | hiányában `client_id` |
| `icon.svg` | max 8 KiB, `<svg`-vel kezdődik; tilos: `<script`, `on…=`, `javascript:`, `<foreignObject`, `<iframe`, `<embed`, `<use`, `<animate`, `<set` |
| `icon.url` | csak `https://` |
| `accent` | csak `#rgb`/`#rrggbb`/`#rrggbbaa`; hiba → `#1D6FE0` |
| `nav.items[].href` | `https://` abszolút VAGY `/`-kezdetű relatív VAGY `#`; tilos: `javascript:`, `data:`, `//host` |

**Validálás default-deny:** minden eldobott mező `tracing::warn!` naplót kap.

---

## 2. Többnyelvi klienspár (hu/en)

Ha a portal két Hydra kliensben van regisztrálva (magyar és angol scope-okkal):

```json
// Magyar kliens
"metadata.launcher": {
  "app_id": "aibootcamp",   // UGYANAZ az érték a két kliensben
  "locale": "hu",
  "name": "AI Bootcamp",
  "launch_url": "https://aibootcamp.hu/hu"
}

// Angol kliens
"metadata.launcher": {
  "app_id": "aibootcamp",   // UGYANAZ az érték!
  "locale": "en",
  "name": "AI Bootcamp",
  "launch_url": "https://aibootcamp.hu/en"
}
```

Azonos `app_id`-val érkező manifestekből **egy** csempe marad a launcherben:
a kérés `?locale=` értékéhez illő (alapértelmezés: `hu`).

---

## 3. Shell-context végpont

A workspace shell a BFF-en keresztül hívja a SkillPass shell-context
végpontot. A partner BFF a `shell:read` scope-os access tokennel kéri le:

```
GET https://skillpass.id/api/v1/partner/shell-context?locale=hu
Authorization: Bearer <shell:read access_token>
```

Válasz: `ShellContext` objektum (→ `skillpass-portal` skill `references/shell-contract.md`).

A partner BFF-je **változtatás nélkül** adja tovább a `WorkspaceShell`-nek —
a kontraktus szerint a csomag maga nem hív hálózatot.

Gyorsítótárazás: 60 s sikeresnél, 10 s sikertelennél (negatív cache).
Időkorlát: max 4 000 ms.

---

## 4. /portals végpont (consent-api)

A felhasználó által engedélyezett appokat a consent-api tartja nyilván. A
shell-context `apps` listája ennek entitlement-szűrt változata.

A partner közvetlen hozzáférést ehhez a végponthoz nem igényelhet — a shell-
context végpont aggregálja a szükséges adatokat.

---

## 5. Kedvencek (favourites)

A shell AppSwitcherben a felhasználó csillagozhatja kedvenc appjait. A
kedvencek sorrendje a SkillPass Account Centerben (`/account/access`) kezelhető.

A partner nem befolyásolhatja a kedvencek sorrendjét — a felhasználó dönt.
A `required_entitlements` mezővel korlátozhatja, hogy az app kiknek jelenik meg.

---

## 6. Checklist (launcher regisztrációhoz)

```
[ ] app_id meghatározva (egyedi, stabil)
[ ] name max 200 kar., nincs < vagy > karakter
[ ] launch_url https://, nincs userinfo
[ ] accent hex szín (#rrggbb vagy #rgb)
[ ] icon svg: max 8 KiB, script/event handler nélkül
[ ] nav minden href biztonságos (https:// vagy /)
[ ] scope tartalmazza shell:read (ha shell integráció kell)
[ ] Többnyelvi kliensnél az app_id mindkét kliensben azonos
[ ] SkillPass team regisztrálta a Hydra admin API-n
```

---
name: aibos-admin-contract
description: >
  Admin API contract-first minta: OpenAPI `contracts/admin/*.yaml` a partner
  projektben, permission kódok (`{projekt}.{modul}.{akció}`, DENY default,
  nincs wildcard), role-matrix CSV, actor assertion, M2M kliens crate,
  append-only audit, RFC 7807 `https://aibos.space/errors/<slug>`, "menüpont
  soha nem 404". Az aibos.space konzol admin/management UI-ját fogyasztja,
  partner projekt NEM épít saját admin felületet.
  Triggerek: "admin API", "contract-first", "aibos admin", "partner admin",
  "OpenAPI contract", "M2M admin", "actor assertion", "aibos console",
  "admin endpoint", "management API", "operator API".
  NE hasznald: ügyfélportál (-> skillpass-portal), autentikáció (-> skillpass-auth),
  normál CRUD fejlesztés (-> crud-dla-module), saját admin UI építése (TILOS).
priority: P0
model: claude-sonnet-5-5
related_skills:
  - admin-experience
  - crud-dla-module
  - dla-menu-pattern
  - permission-rbac
  - audit-trail-mandatory
  - skillpass-auth
---

# aibos-admin-contract

> **Aranyszabály:** Partner projekt NEM épít saját admin/management felületet.
> Az összes admin UI az **aibos.space konzolban** él. A partner projekt kizárólag
> egy contract-first admin API-t tesz ki, amelyet az aibos konzol fogyaszt
> M2M + actor assertion hitelesítéssel.

## 1. Mikor aktiválódik ez a skill

- Új admin endpoint hozzáadásakor partner projektben
- `contracts/admin/` könyvtár létrehozásakor
- M2M hitelesítés implementálásakor (aibos → partner)
- Permission kódok definiálásakor partner projektben
- Actor assertion middleware írásakor

## 2. Architektúra

```
┌─────────────────────────────────────────────────────────────┐
│  aibos.space konzol (Next.js)                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ MenuCategory → MenuApp → MenuSub (jogosultság-szűrve) │   │
│  └──────────────────────────────────────────────────────┘   │
│               ↓ M2M Bearer + X-Actor-Assertion              │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Partner projekt (pl. aibootcamp.hu)                        │
│  contracts/admin/example-admin.yaml  ← SINGLE SOURCE        │
│  contracts/authorization/permissions.json                   │
│  contracts/authorization/role-matrix.csv                    │
│                                                             │
│  → typed client crate generálva az OpenAPI-ból              │
│  → middleware: workload JWT + actor assertion validáció     │
│  → append-only audit log minden mutációra                   │
└─────────────────────────────────────────────────────────────┘
```

## 3. Workflow (lépések sorrendben)

Részletek: `references/contract-first-workflow.md`

1. **OpenAPI először** — `contracts/admin/{projekt}-admin.yaml` a partner repóban
2. **Mock szerver** — az aibos csapat mock szerver ellen fejleszt, amíg a partner implementál
3. **Typed client crate** — aibos generál: `crates/aibos-{projekt}-client`
4. **Konzol menüpont** — `console/lib/menu-config.ts` bővítése
5. **DLA oldalak** — aibos konzolban, a típusos kliensre támaszkodva
6. **Partner implementáció** — middleware, handler-ek, audit log

## 4. Permission kódok

Részletek: `references/permissions.md`

**Formátum:** `{projekt}.{modul}.{akció}` (pont szeparátor, kisbetű, alulvonás megengedett)

```
aibootcamp.courses.list
aibootcamp.courses.view
aibootcamp.courses.create
aibootcamp.courses.edit
aibootcamp.courses.delete
```

**Szabályok:**
- DENY by default — ami nincs definiálva, az tiltott
- Nincs wildcard (`*`) — soha, semmilyen szinten
- Forráskód a `contracts/authorization/permissions.json`
- Fordítási időben épül a binárisba (`aibos-contracts` crate olvassa)

## 5. Actor assertion

Részletek: `references/actor-assertion.md`

- Header neve: `X-Actor-Assertion`
- JWS kompakt formátum, `EdDSA` (Ed25519) vagy `ES256`
- Élettartam: max 120 másodperc
- Request binding: `req.m`, `req.p`, `req.h` (SHA-256 body hash)
- Replay védelme: `jti` store

## 6. Audit

Részletek: `references/audit.md`

- Minden mutációra kötelező: create, update, delete, archive
- Append-only: adatbázis szinten tiltott a módosítás és törlés
- RFC 7807 hiba típus prefix: `https://aibos.space/errors/<slug>`
- Manuális override esetén kötelező a `reason` mező

## 7. Menüpont

Részletek: `references/menu.md`

- `MenuCategory → MenuApp → MenuSub` hierarchia
- Minden `MenuSub`-nak van `permission` mezője
- Szerver oldali szűrés: jogosultság nélküli pont nem kerül a kliensre
- "Menüpont soha nem 404" — teszt védi: `tests/menu-config.test.ts`

## 8. Adatminimalizálás

Részletek: `references/data-minimisation.md`

- aibos NEM tárol ügyféladat-példányokat
- A partner forrásrendszer állapotgépe az autoritatív
- aibos csak kivételkezelési akciókat végez (override, manuális beavatkozás)

## 9. Sablon

`templates/admin-contract/` — másolható kiindulópont:
- `contracts/admin/example-admin.yaml` + `.json` (validator inputja)
- `contracts/authorization/permissions.json` + `role-matrix.csv` + séma
- `scripts/validate-contract.py` — stdlib validator
- `README.md` — magyar útmutató

Validáció futtatása a skeleton gyökeréből:
```bash
python3 templates/admin-contract/scripts/validate-contract.py templates/admin-contract
```

## 10. Tiltások

- Partner projekt NEM épít saját admin UI-t (ez az aibos.space feladata)
- Wildcard permission soha (`*`)
- Futásidejű szerepkör-szerkesztés (fordítási időben rögzített)
- Admin endpoint authorization nélkül
- `console.log` / `print` logginghoz (strukturált logger kötelező)
- Megszűnt IdP neve bármilyen kontextusban (visszavont rendszer, lásd `.aios-cli/removed-paths.txt`)

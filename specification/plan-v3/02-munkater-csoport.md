# 02 – Munkatér és csoport

## 1. Miért kell saját modell

- A skillpass.id-ben a „workspace" az alkalmazás-keret (shell), nem bérlő; a szervezeteket
  (Organizations) partner **nem tudja olvasni** (nincs M2M vagy partner scope hozzá).
- A superskiller `tenants` és `organization_groups` B2B képzési egységek (ülőhely-limit, riport),
  közösségi csoport még nincs.
- Ezért a munkatér és a csoport az **ai2know saját objektuma**; a skillpass szervezethez és a
  superskiller bérlőhöz opcionálisan **összeköthető** (hivatkozás, nem másolat).

## 2. Munkatér (`workspace`)

| Mező | Leírás |
|------|--------|
| `handle` | `@handle`, globálisan egyedi az ai2know-ban, `[a-z0-9-]{3,40}`; a személyes munkatérnél a skillpass `preferred_username`, ha van (Q-V3-06) |
| `kind` | `personal` (mindenkinek automatikusan, belépéskor) \| `organization` (cég, képző, közösség) |
| `display_name`, `bio`, `avatar`, `cover`, `website` | |
| `skillpass_org_ref` | opcionális, ellenőrzött kapcsolat egy skillpass szervezettel (06/6) |
| `superskiller_tenant_ref` | opcionális, a superskiller bérlő slugja (05/2) |
| `aibos_club_partner_ref` | ha a tulajdonos ellenőrzött aibos.club partner (F11) |
| `access_policy` | 01 – a munkatér oldalának és tagságának szintje |

- Szerepek: `owner` > `admin` > `editor` > `member`. Az `owner` mindig egy személy (átadható,
  auditálva). Szervezeti munkateret bármely tag létrehozhat (D-V3-01 szellemében), limit:
  5 munkatér / fő az első 30 napban (spam ellen, 04/5).
- Oldal: `/@handle` – bemutatkozás, nyilvános curve-ök, feltöltött elemek, csoportok
  (a láthatóság szerint), tagok száma.

## 3. Csoport (`group`)

| Mező | Leírás |
|------|--------|
| `workspace_id` | minden csoport egy munkatérben él |
| `slug` | munkatéren belül egyedi: `/@handle/csoport/{slug}` |
| `kind` | `cohort` (képzés, workshop – kezdés/vég dátum) \| `team` \| `community` |
| `access_policy` | 01 – ki csatlakozhat (zárt: csak meghívás adminnal; meghívásos; nyilvános: bárki csatlakozik; fizetős) |
| `origin_ref` | pl. aibos esemény, aibootcamp tréning, superskiller kohorsz |

- Szerepek: `manager` > `moderator` > `member`.
- Funkciók a csoportban: hozzárendelt curve-ök (sorrenddel, határidővel), csoport-haladás a
  managernek, csoport-hírfolyam (komment szál a csoport oldalán, 04 szabályai szerint).
- Kohorsz egy lépésben: a v2 „Új curve az eseményből" sablon **csoportot + curve-öt** hoz létre,
  meghívó kóddal/QR-ral.

## 4. Adatmodell (`ai2know` séma)

```text
workspaces         id, handle, kind, display_name, bio, avatar, cover, website,
                   skillpass_org_ref, superskiller_tenant_ref, aibos_club_partner_ref,
                   status (active|suspended|deleted), created_by, created_at, is_deleted
workspace_members  workspace_id, member_sub, role, status (invited|active|left|removed),
                   invited_by, joined_at
groups             id, workspace_id, slug, kind, title, summary, starts_at, ends_at,
                   origin_kind, origin_ref, created_by, is_deleted
group_members      group_id, member_sub, role, status, joined_at, left_at, source
                   (invite:{grant_id} | purchase:{entitlement_id} | self)
group_curves       group_id, curve_id, position, due_at
handles            handle, owner_type (workspace|curve), owner_id, retired_at
                   – közös névtér-őr: a `@` és a `+` foglalások egy táblában (03/3)
```

Minden curve és elem kap egy `workspace_id`-t (a v2 `owner_sub` mellé); a személyes munkatér
automatikus, így a meglévő tervek nem törnek.

## 5. Admin (aibos.space)

A munkatér- és csoportkezelés (felfüggesztés, átadás, handle-felszabadítás) az ai2know admin
contracton keresztül az aibos.space konzolban (L-15); permission kódok:
`ai2know.workspaces.{list,view,suspend,transfer}`, `ai2know.groups.{list,view,suspend}`.

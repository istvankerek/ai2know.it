# 01 – Hozzáférési modell (egy motor: munkatér, csoport, curve, elem)

## 1. Négy szint

| Szint (`access_level`) | Ki látja / éri el | Listázás, keresés | Indexelés (SEO) | Ki állíthatja be |
|------------------------|-------------------|-------------------|-----------------|------------------|
| `private` – **zárt** | csak a tulajdonos és a társszerkesztők | nem | nem | bárki |
| `invite` – **meghívásos** | aki teljesít egy meghívási módot (2. fejezet) | csak a jogosultaknak | nem | bárki |
| `public` – **nyilvános** | bárki; belépés nélkül a teaser, belépve a teljes tartalom (3. fejezet) | igen | igen (minőségi küszöb felett, 04/6) | bárki |
| `paid` – **fizetős** (F11) | aki megvásárolta (entitlement); belépés nélkül a teaser és az ár | igen | igen (teaser) | **csak ellenőrzött aibos.club partner** (D-V3-03) |

Az alapértelmezett szint **`private`**: semmi nem lesz véletlenül nyilvános.

## 2. Meghívási módok (`invite` szint)

A v2 hat szabálya (P-V2-08) itt a meghívásos szint **módjai** lettek. Több mód is beállítható, ilyenkor
VAGY kapcsolat érvényes. Alapból minden tiltva (DENY).

| Mód (`invite_kind`) | Érték | Lejárat / limit | Tipikus használat |
|---------------------|-------|-----------------|-------------------|
| `link` | titkos token a linkben (`/+slug?k=…`) | lejárat, visszavonható | gyors megosztás |
| `code` | kód / QR (`K7Q-29F`) | lejárat, max létszám | workshop résztvevők |
| `member` | név szerint (skillpass `sub` vagy e-mail meghívó) | – | mentorálás |
| `email_domain` | `@ceg.hu` (ellenőrzött e-mail cím a skillpass-ból) | – | céges képzés |
| `workspace` | egy munkatér tagjai (`@ceg`) | – | szervezeti tartalom |
| `group` | egy csoport tagjai | – | kohorsz, csapat |

## 3. Elemek: a v2 négy láthatósága ebbe a modellbe illesztve

| v2 láthatóság | v3 megfelelője |
|---------------|----------------|
| `public` (teljes, nyilvános minta) | `public` + `open_sample = true` (szerkesztő jelöli, típusonként 10–15% marad) |
| `teaser` (alapértelmezett szerkesztői elemnél) | `public` + `open_sample = false` – belépés nélkül teaser, belépve teljes |
| `members` | `public` + `display = list_only` (belépés nélkül csak a cím a listában) |
| `restricted` | `invite` (pl. `group` vagy `workspace` mód) vagy `paid` |

A v2 SEO szabályai (fizetőfal strukturált adat, zárt rész soha nincs a HTML-ben) változatlanok.

## 4. Az objektumok és a konténerek

```text
munkatér (@handle)            access_level + meghívási módok + (F11) ár
 ├─ csoport                    access_level + meghívási módok + (F11) ár
 │   └─ curve / elem           access_level + meghívási módok + (F11) ár
 └─ curve / elem (közvetlenül a munkatérben)
```

Szabályok:

1. **Minden objektumnak saját szintje van.** A konténer szintje a konténer oldalára, tagságára és
   listájára vonatkozik, nem korlátozza automatikusan a tartalmat. (Mindenkinek van **személyes
   munkatere**, ami zárt, mégis lehet benne nyilvános curve.)
2. **Felfedezés a konténert követi.** Egy zárt munkatér csoportjai és tartalmai a munkatér
   listájában csak a tagoknak látszanak; a nyilvános tartalom a globális keresőben ettől még
   megjelenik a készítő nevével.
3. **Csoporthoz kötött tartalom.** Ha egy curve „csak a csoportnak" készül, a meghívási módja `group`.
   Ez nem külön szabály, hanem egy mód: a csoporttagság adja a hozzáférést.
4. **Fizetős öröklés (F11).** A fizetős munkatér vagy csoport tagsága (előfizetés) hozzáférést ad
   minden olyan tartalomhoz, amelynek meghívási módja az adott munkatér vagy csoport. Egy curve
   külön is lehet fizetős (egyszeri vásárlás).
5. **Curve kontextus.** A curve hozzáférése a curve-ön belül feloldja a lépés-elemeket (v2 03/3
   szabály megmarad): egy `invite` elem a curve-ön keresztül látható a curve jogosultjának.
   Ez csak akkor engedett, ha a curve készítője az elemhez maga is hozzáfér, **szerkesztő**
   jogosultsággal (nem lehet idegen zárt tartalmat curve-be csempészve „kinyitni").
6. **Szint váltása.** Nyitottabb szintre váltás azonnali; zártabbra váltáskor a már felvett
   résztvevők megtartják a hozzáférést (a készítő kérésre visszavonhatja, auditálva). Fizetősből
   kilépés: a vásárlók hozzáférése megmarad a vásárolt időszak végéig.

## 5. Adatmodell (`ai2know` séma, a v2 03/2 `curve_access` helyett)

```text
access_policies    id, object_type (workspace|group|curve|item), object_id,
                   access_level (private|invite|public|paid), open_sample bool,
                   display (full|list_only), price_ref (F11), updated_by, updated_at
invite_grants      id, policy_id, invite_kind (link|code|member|email_domain|workspace|group),
                   value (token hash | kód hash | sub | domain | workspace_id | group_id),
                   valid_from, valid_until, max_uses, used_count, revoked_at, created_by
access_grants      id, object_type, object_id, member_sub, source
                   (invite:{grant_id} | purchase:{entitlement_id} | owner | editor),
                   granted_at, revoked_at        – materializált hozzáférés (gyors ellenőrzés)
```

- A link-token és a kód **hash-elve** tárolódik (kiszivárgott DB nem ad belépőt).
- Kiértékelés egy helyen: `a2k-access::can(subject, action, object)` crate. Minden végpont ezen
  megy át; a frontend csak UI-tippet kap (ecosystem TILOS: frontend-only ellenőrzés).
- Akciók: `view_teaser`, `view`, `enroll`, `edit`, `manage_access`, `view_stats`, `moderate`.
- Minden szint- és meghívás-módosítás `log_activity()` (audit-trail-mandatory).

## 6. Fizetős kapu (F11 – előkészítve, kikapcsolva)

- A `paid` érték az enumban már F1-től szerepel, de a `feature.paid_access` flag kikapcsolva tartja.
- Beállíthatja: aki **ellenőrzött aibos.club eladó partner** (`seller_status = active`; az aibos.club
  oldali igény és az indoklás: `08-dontesek-indoklassal.md` P-V3-15).
- Vásárlás: pay.aibos.space checkout → az ai2know a hozzáférés forrásrendszere → skillpass
  `entitlements:write` tükrözés (`kind = course | subscription`, `product_ref = ai2know:{type}:{code}`).
- Bevételmegosztás és partner-kifizetés: az aibos.club meglévő jutalék-főkönyvének mintája szerint,
  a részletek jogi/adó döntést igényelnek (Q-V3-01).

# 05 – superskiller ↔ ai2know partner API

> Közös contract: `contracts/partner/ai2know-superskiller.v1.yaml` mindkét repóban (azonos fájl).
> A superskiller oldalon **extension overlay**-ként (`contracts/http/extensions/`,
> `x-extension: plan-vN`), mert az 1.0.0-rc1 snapshot változtathatatlan (superskiller plan-v14 D-5).
> Megvalósítás: az ai2know oldal ebben a planben (F5), a superskiller oldal a superskiller saját
> plan-jében. Elv (P-V2-16): mindkét rendszer a saját objektumainak gazdája, nincs tartalommásolás.

## 1. Kiinduló állapot (felderítve 2026-10-20)

| superskiller | Állapot |
|--------------|---------|
| Stack | Rust/Axum + Next.js BFF, PostgreSQL, skillpass OIDC, M2M a skillpass felé (`learning:write`) |
| Objektumok | `courses` → `course_versions` → `modules` → `chapters` → `lessons`; `quests` (az „Út" küldetései); `skills` (kompetencia-fa); `organization_groups` (B2B); mind uuid + slug, bérlőhöz (`tenant_id`) kötve |
| Hozzáférés | entitlement-alapú (`entitlements`, `course_enrollments`); a skillpass lesz az entitlement gazdája (plan-v14 D-1) |
| Események | `outbox_events`, 100+ esemény séma (`course_lesson.*`, `certificate.issued`, `xp.awarded.v1` …) |
| Hiányzik | partner API, kimenő partner webhook, oEmbed, közösségi poszt/csoport (plan-v15 után) |

## 2. Azonosítók

- Objektum hivatkozás (mindkét irányban): `superskiller:{type}:{tenant_slug}/{slug}` és mellette
  a stabil `id` (uuid). Típusok: `course`, `lesson`, `quest`, `skill` (kompetencia), később `post`,
  `community_group`.
- ai2know hivatkozás: `ai2know:item:{code}`, `ai2know:curve:{code}` (`+slug` csak megjelenítésre).
- Felhasználó: a skillpass `sub` (mindkét rendszer ezt köti a belső azonosítóhoz).

## 3. Hitelesítés

| Hívás | Mód |
|-------|-----|
| Szerver–szerver | skillpass Hydra `client_credentials`; tokenek `audience`-szel: `https://superskiller.com/api` ill. `https://ai2know.it/api`. Kliensek: `ai2know-to-superskiller-m2m`, `superskiller-to-ai2know-m2m` (06/1) |
| Felhasználó nevében (hozzáférés-állapot) | M2M token + `X-Subject-Sub: {sub}` fejléc. A scope csak metaadatra és hozzáférés-állapotra jogosít, tartalomra nem; minden hívás auditált |
| Webhook | HMAC-SHA256: `X-A2K-Signature: t={unix},v1={hex}` (és `X-SS-Signature` a másik irányban), 5 perces időablak, `event_id` idempotencia |

Scope-ok:

- superskiller oldalon: `superskiller.partner:objects.read`, `superskiller.partner:subscriptions.write`.
- ai2know oldalon: `ai2know.partner:items.read`, `ai2know.partner:curves.read`,
  `ai2know.partner:subscriptions.write`.

Mindenhol a legszűkebb jogosultság, wildcard nincs.

## 4. superskiller → szolgáltatja (ai2know hívja)

| Végpont | Cél | Válasz (lényeg) |
|---------|-----|-----------------|
| `POST /v1/partner/ai2know/objects:resolve` | curve lépések feloldása (batch, max 50) | `[{ref, id, type, title, summary, image_url, est_minutes, locale, tenant {slug, name}, deep_link, status (available\|archived\|not_found), access (granted\|enrollment_required\|entitlement_required\|unknown), access_url, etag}]` |
| `GET /v1/partner/ai2know/objects/search?q=&type=&tenant=&cursor=` | a curve-szerkesztő oldalpanele („superskiller lecke hozzáadása") | csak a `X-Subject-Sub` által látható objektumok; cursor lapozás |
| `PUT /v1/partner/ai2know/subscriptions/{subscription_id}` | feliratkozás elvégzés-eseményre: `{subject_sub, object_ref, curve_code, enrollment_id}` | 201/200; `DELETE` leiratkozás, amikor a curve kész vagy a résztvevő kilép |
| `GET /v1/partner/ai2know/progress?subject_sub=&refs=` | utólagos szinkron (pl. webhook kiesés után) | `[{ref, state (not_started\|in_progress\|completed), completed_at}]` |

**Adatminimalizálás:** a superskiller csak arról küld elvégzés-eseményt, amire az ai2know
feliratkozott (az adott felhasználó egy curve-jében lépés). Nincs általános felhasználói
aktivitás-feed.

## 5. ai2know → szolgáltatja (superskiller hívja)

| Végpont | Cél |
|---------|-----|
| `GET /api/v1/partner/items/{code}` | elem metaadat + (`X-Subject-Sub` jogosultsága szerint) tartalom a leckébe ágyazáshoz |
| `GET /api/v1/partner/items/search?q=&type=&cursor=` | a superskiller `/tudastar` és a lecke-szerkesztő elemkeresője |
| `GET /api/v1/partner/curves/{code}` és `GET /api/v1/resolve/plus/{slug}` | curve kártya (cím, lépésszám, elvégzők, átlag) a superskiller posztban/leckében |
| `GET /oembed?url=…` és `/embed/{code}`, `/embed/curve/{code}` | beágyazás (nyilvános, partnertől függetlenül) |
| `PUT /api/v1/partner/subscriptions/{id}` | feliratkozás elem-változásra (a superskiller leckében beágyazott elem frissült / archiválódott) |

## 6. Események (webhook)

| Esemény | Irány | Payload (lényeg) | Fogyasztó hatása |
|---------|-------|------------------|------------------|
| `superskiller.lesson.completed.v1` | ss → a2k | `subscription_id, subject_sub, object_ref, completed_at` | `step_progress.signal = external_webhook` |
| `superskiller.course.completed.v1` | ss → a2k | ugyanaz | kurzus-lépés kész |
| `superskiller.quest.completed.v1` | ss → a2k | ugyanaz | Út-küldetés lépés kész |
| `superskiller.object.changed.v1` | ss → a2k | `object_ref, change (updated\|archived\|access_changed)` | lépés pillanatkép frissítése, „nem elérhető" jelzés |
| `ai2know.item.changed.v1` | a2k → ss | `code, version, change (updated\|archived)` | a beágyazás frissítése |
| `ai2know.curve.completed.v1` | a2k → ss | `subject_sub, curve_code, steps_from_superskiller[]` | opcionális: superskiller XP (a superskiller döntése) |

Kézbesítés: outbox (mindkét oldalon van `outbox_events`), újrapróbálás exponenciális visszalépéssel
24 óráig, utána holtlevél és konzol riasztás; `GET /progress` utólagos egyeztetés naponta.
A superskiller oldalon a **kimenő partner webhook kézbesítő új komponens** (ma nincs).

## 7. Hibák és limitek

- RFC 7807 mindkét oldalon (`https://ai2know.it/errors/<slug>`, superskiller `problem-codes.json`).
- Rate limit: 600 kérés/perc/kliens; `objects:resolve` batch max 50; cache: metaadat 10 perc, ETag.
- `X-Subject-Sub` ismeretlen felhasználónál: `access = unknown` (nem 404), hogy ne szivárogjon,
  ki tagja a másik rendszernek.

## 8. UI összehangolás (változatlan a v2-ből, kiegészítve)

- „AI skill" (ai2know) vs. „Kompetencia" (superskiller); „Learning curve" vs. „Út".
- A curve megjelölhet cél-kompetenciákat superskiller kóddal (`superskiller:skill:{code}`).
- A superskiller `/tudastar` az ai2know keresőjét mutatja (beágyazás vagy partner API).
- A `+slug` linkesítés a superskiller szövegeiben (03/5).

## 9. Átadandó a superskiller csapatnak

1. A közös contract fájl (F0).
2. Új komponensek listája: partner API végpontok (4. fejezet), kimenő webhook kézbesítő,
   feliratkozás-tábla, Hydra M2M kliens és scope-ok, `+` Caddy szabály.
3. Elfogadási teszt: a superskiller mock szerver (ai2know F5) és a valódi superskiller test példány
   ugyanazon a contract-teszten fut.

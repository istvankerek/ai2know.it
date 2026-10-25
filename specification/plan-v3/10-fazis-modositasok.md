# 10 – Fázisok: változások a plan-v2-höz képest

A v2 fázisfájljai (`../plan-v2/10-…` – `22-…`) érvényesek; az alábbi tételek **kiegészítik vagy
felülírják** őket. Minden fázis: failing teszt → implementáció → `implementation-notes.md` →
validáció → git save point → non-prod deploy + smoke. Prod csak „mehet" után (L-03).

## F0 – Alapozás és biztonság

- [ ] `contracts/partner/ai2know-superskiller.v1.yaml` (05) – review a superskiller csapattal.
- [ ] `contracts/partner/ai2know-public.v1.yaml`: feloldó (`/resolve/plus`), elem, curve, oEmbed.
- [ ] Skillpass igénylista átadása (06), az aibos.club eladói státusz igény (P-V3-15).
- [ ] Adatkezelési alap tisztázása a skillpass-szal (06/10) – éles M2M előfeltétel.

## F1 – Tudásmag backend

- [ ] `a2k-access` crate: négy szint, hat meghívási mód, akciók, materializált `access_grants`;
      jogosultság-mátrix teszt **elsőként** (TDD).
- [ ] Munkatér, csoport, tagság, szerepek (02); automatikus személyes munkatér belépéskor.
- [ ] `handles` névtér-őr (`@` és `+`), foglalt szavak, átnevezés-előzmény (03/3).
- [ ] Közösségi feltöltés: forrás-jelölés, moderációs állapot, titok-detektálás, licenc, ClamAV,
      duplikátum-figyelmeztetés (04/2).
- [ ] Értékelés (Bayes-rangsor, „használtam"), komment, reakció, bejelentés, bizalmi szint (04/3–8).
- [ ] `paid` enum és `price_ref` mező a `feature.paid_access` flag mögött (kikapcsolva).

## F2 – Web váz és belépés

- [ ] aibootcamp tokenek (07/2) Tailwind témába kötve, light + dark, Manrope önhosztolva.
- [ ] Middleware: `/+{slug}[/{n}]`, `%2B` normalizálás, `/lc/{slug}` → 301, `/@handle` oldalak.
- [ ] Fejléc, mobil `<dialog>` menü, alsó navigáció; skillpass belépés gomb (`skillpass` változat).
- [ ] Workspace shell a tagi oldalakon; vizuális regresszió light/dark × 3 szélesség.

## F3 – Katalógusok

- [ ] Feltöltés varázsló típusonként (a titok-detektálás eredménye inline), szint-választó (07/5).
- [ ] Értékelés + komment blokk, bejelentés gomb, „közösségi / szerkesztői" jelölés, `noindex` szabály.
- [ ] Elemtípus-színkód és ikonok (07/4).

## F4 – Learning curve

- [ ] Curve-öt bárki készít és tesz közzé (P-V2-07 törölve); szint-választó a négy kártyával.
- [ ] Meghívási módok UI: link, kód/QR, név, domain, munkatér, csoport; lejárat, létszám.
- [ ] „Új curve az eseményből" → csoport + curve + kód egy lépésben.
- [ ] Lejátszó „narancs útvonal" lépéssávval; `+slug/{n}` lépés-URL.
- [ ] Csoporthoz rendelt curve-ök, határidő, csoport-haladás a managernek.

## F5 – Integrációk

- [ ] superskiller (ai2know oldal): resolve/search kliens, feliratkozás-kezelés, webhook fogadó (HMAC,
      idempotencia), napi `progress` egyeztetés, mock szerver a contractból.
- [ ] ai2know partner végpontok a superskillernek (05/5), `ai2know.item.changed.v1` kimenő esemény.
- [ ] skillpass: `trainings:write` + xAPI; `contributions:write` és `reviews.entities:write`, amint a
      skillpass oldalon elkészül (a skillpass plan ütemezése szerint, addig feature flag mögött).
- [ ] skillpass `user.deleted` / `consent.revoked` fogadó és törlési folyamat.
- [ ] `plus-linkify` közös függvény csomagként (npm + Rust crate) a partnereknek.

## F6 – aibos admin és moderáció

- [ ] Admin contract bővítés: munkaterek, csoportok, moderációs sor, bejelentések, bizalmi küszöbök,
      handle-kezelés; permission kódok `ai2know.{workspaces|groups|moderation|reports|trust}.{akció}`.
- [ ] DSA: indoklás a szerzőnek, fellebbezés, átláthatósági összesítő (jogi szöveg tervezet, L-09).

## F7 – Élesítés (I. felvonás)

- [ ] Caddy `+` szabály minden ökoszisztéma-domainen (Q-V3-05 jóváhagyás után), smoke script:
      domainenként `/+teszt-curve` → 302 → 200.
- [ ] Linkfelismerő-smoke (03/4 lista), eredmény a `implementation-notes.md`-be.

## F11 – Fizetős szint (új, az I. felvonás élesítése után, CRITICAL)

> Előfeltétel: Q-V3-01 és Q-V3-02 lezárva, aibos.club eladói státusz végpont kész.

- [ ] Eladói státusz ellenőrzése (aibos.club s2s, cache, visszavonás-webhook).
- [ ] Ár és termék a munkatéren / csoporton / curve-ön; pay.aibos.space checkout, idempotencia kulcs,
      aláírt callback.
- [ ] Vásárlás → `access_grants` + skillpass `entitlements:write`; visszatérítés → visszavonás.
- [ ] Jutalék és kifizetés az aibos.club főkönyv mintájával; fogyasztóvédelmi tájékoztatás.
- [ ] Tesztek: nem-partner 403 API-n is; dupla callback egyszer számít; visszatérítés után nincs hozzáférés.

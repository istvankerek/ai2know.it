# F5 – Tartalom feltöltés és admin (aibos konzol)

> Routing: STANDARD. Skillek: `aibos-admin-contract`, `data-import`, `crud-dla-module`
> (az aibos repóban), `brand-auditor`.

## Feladatok

- [ ] Régi ai2know seed ETL (03/1) → aibos import `review` állapotban; szerkesztői átnézés.
- [ ] aiagentek elemek portál-átadása (03/2), statisztikák és értékelések megőrzése.
- [ ] Konzol (aibos repó): „ai2know.it / Tudásbázis" menü – DLA lista típus-szűrővel, típus-specifikus
      űrlapok (`/add`, sosem `/new`), előnézet, publikálás, archiválás, tömeges címkézés,
      kérések kezelése, kommentek moderálása, kérdés-válasz moderálás. Menüpont soha nem 404.
- [ ] Minőségkapuk publikáláskor: kötelező mezők, alt szöveg, élő kimenő link, kategória a
      taxonómiából, duplikátum-figyelés (cím/URL hasonlóság).
- [ ] Heti link-ellenőrző és „elavult" (> 6 hónap ellenőrizetlen) riport.
- [ ] Tartalombővítés az indulási célokig (03/4) – szerkesztői munka, owner ütemezéssel.
- [ ] Keresési „nincs találat" riport a konzolban (tartalomhiány-lista).

## Elfogadás

- Az indulási tartalmi célok (03/4) teljesülnek, minden elem átnézett.
- Minden konzol-mutáció auditált (append-only), jogosultság `ai2know.kb.{list,view,create,edit,publish,archive}`.

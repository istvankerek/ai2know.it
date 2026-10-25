# F1 – Tudásmag backend

> Routing: STANDARD (+ CRITICAL review az aibos adatköltöztetésre). Skillek: `db-migration`,
> `data-import`, `integration-test`, `tdd-enforcer`, `permission-rbac`.

## Feladatok

- [ ] Rust workspace (v0 F1 váz: config, RFC 7807, health, tracing, JWT/JWKS, outbox).
- [ ] Séma: `items`, `item_versions`, `item_relations` (szerepkör-tagság, kapcsolódók), `taxonomy`,
      `item_stats`, `item_ratings`, `item_comments`, `item_requests`, `favorites`; a curve táblák F4-ben.
- [ ] Típus-specifikus `attributes` validáció (serde + JSON Schema, a contractban publikálva).
- [ ] Láthatósági szűrő egy helyen (`a2k-visibility`): anonim / tag / curve-kontextus / partner;
      a `members`/`restricted` törzs soha nem kerül anonim válaszba – tulajdonság-alapú teszttel.
- [ ] Keresés (v1/02/3): FTS, trigram, facetták, rangsor, autocomplete, keresési napló.
- [ ] API: publikus olvasó, tagi (kedvenc, értékelés, komment, kérés), partner (M2M), oEmbed,
      `embed` kártya adat.
- [ ] **Átköltöztetés az aibos-ból:** a 461 könyvtárelem, ~300 szócikk, statisztika, értékelés,
      komment, kérés – kód és azonosítók változatlanok; egyeztető riport (forrás = cél darabszám).
- [ ] Régi ai2know seed import (v1/03/1): eszközök, linkek, videók, segédanyagok `review` állapotban.

## Tesztek

- Láthatóság mátrix: 4 szint × 4 néző × lista/részlet/keresés/API – a zárt törzs soha nem szivárog.
- Szerepkör: körkörös tagság tiltva; archivált tag jelzése.
- Átköltöztetés: idempotens, darabszám- és mintatartalom-egyezés.
- Keresés golden-lista (magyar ragozás, ékezet nélkül, elírás).

# F1 – Katalógus backend (aibos bővítés + ai2know keresés)

> Routing: STANDARD; az aibos séma-migráció CRITICAL review. Skillek: `db-migration`,
> `vector-search` (csak a 2. körhöz), `integration-test`, `tdd-enforcer`.

## 1. Döntés az F1 elején (Q-V1-01)

A tartalom helye: **A)** aibos `knowledge_item` (javasolt, P-V1-02) vagy **B)** ai2know saját séma +
aibos admin contract. Az alábbi lépések A-ra szólnak; B esetén az 1.1 pont az ai2know repóba kerül,
és a v0 F5 admin contract mintája lép be.

### 1.1 aibos oldal (az aibos repóban, saját plan alatt)

- [ ] `prompt_library_item` → `knowledge_item` általánosítás: `item_type` bővítés (02/1), `portal_id`,
      `attributes jsonb`, `status`, `locale`, `cover`, `external_url`, `reviewed_at`; a meglévő
      sorok és a `_stat/_rating/_comment/_request` táblák megmaradnak.
- [ ] A 461 aiagentek elem portál-tulajdona `ai2know-it`; a könyv továbbra is látja (megosztás).
- [ ] aibos-public: `GET /public/v1/portal/ai2know-it/catalog?since=…` (változásfolyam, ETag),
      `GET …/catalog/{code}`, írás: stat/rating/comment/request (szolgáltatás-token + olvasó-session).
- [ ] Aláírt webhook „elem változott" eseményre (revalidálás + szinkron).
- [ ] Konzol: DLA szerkesztő típus-specifikus űrlappal (F5).

### 1.2 ai2know backend

- [ ] `a2k-catalog` crate: szinkron worker (teljes + inkrementális), idempotens upsert a
      `kb_items` olvasó-modellbe; hibánál riasztás, nem csendes elavulás (L-07).
- [ ] Keresési séma: `search_vector` (súlyozott, `hungarian` + `unaccent`), `pg_trgm` index a
      címre és címkékre, facetta-mezők normalizált oszlopokban, szinonimatábla.
- [ ] Rangsor-függvény konfigurálható súlyokkal; népszerűség napi aggregátumból.
- [ ] Végpontok a 02/4 szerint, cursor lapozás, RFC 7807, rate limit a mérő végpontokra.
- [ ] Tagi táblák: `favorites`, `collections`, `collection_items` (skillpass `sub` alapján).
- [ ] Keresési napló (kifejezés normalizálva, PII-szűrő: e-mail/telefon minták eldobva).

## Tesztek

- Szinkron: törölt/archivált elem eltűnik a keresőből; ismételt futás idempotens.
- Keresés golden-lista (02/7), facetta-számláló egyezés, teljesítmény 10 000 elemen.
- Contract teszt az aibos mock ellen és a valódi aibos test példány ellen.

## Kimenet

- Az aiagentek 461 eleme + a régi ai2know seed kereshető a helyi és test környezetben.

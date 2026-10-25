# F4 – Learning curve

> Specifikáció: `03-learning-curve.md`. Routing: STANDARD. Skillek: `tdd-enforcer`,
> `frontend-design`, `e2e-test`, `audit-trail-mandatory`.

## Lépések

1. [ ] Séma (03/2) + migrációk, jogosultság-kiértékelő (`a2k-curves::access`) DENY alapból.
2. [ ] Backend: curve CRUD, szerkesztők, lépések, közzététel (verzió pillanatkép), archiválás, fork.
3. [ ] Hozzáférési szabályok: nyilvános, link-token, kohorsz-kód (lejárat, létszám), skillpass
       entitlement (`entitlements:read`), név szerinti, e-mail domain.
4. [ ] Felvétel és haladás: `enrollments`, `step_progress`, automatikus jelek (megnyitás, másolás,
       letöltés), elvégzési szabály, igazolás oldal.
5. [ ] Visszajelzés, moderációs állapot, statisztika (napi aggregátum, lépésenkénti lemorzsolódás).
6. [ ] Web: curve böngésző, curve oldal, lejátszó nézet (mobil lapozás), szerkesztő (drag & drop,
       elemkereső oldalpanel, „miért nézd meg" jegyzet), csatlakozás kóddal/QR-ral, statisztika,
       „Curve-jeim".
7. [ ] „Új curve az eseményből" sablon (esemény neve, dátuma, résztvevő-kohorsz egy lépésben).
8. [ ] Outbox események: `curve.published`, `enrollment.created`, `enrollment.completed`,
       `feedback.created` (F5 integrációk fogyasztják).

## Tesztek

- Jogosultság-mátrix: 6 szabály × (anonim, tag, jogosult, szerkesztő) × (curve, lépés-elem,
  restricted elem a curve-ön belül és kívül).
- Verzió: v1-en felvett résztvevő a v2 közzététel után is a v1-et látja; frissítés működik.
- Kohorsz-kód: lejárt kód / betelt létszám → érthető hiba (RFC 7807), nem csendes elutasítás.
- Visszajelzés: elvégzés nélkül 403; < 5 értékelésnél nincs átlag a nyilvános összesítőben.
- E2E mobil: QR → belépés → felvétel → 3 lépés kész → elvégzés → visszajelzés.

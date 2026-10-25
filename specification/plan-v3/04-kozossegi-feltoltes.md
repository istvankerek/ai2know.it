# 04 – Közösségi feltöltés, értékelés, komment, moderáció

## 1. Ki mit tölthet fel

- Minden belépett tag feltölthet bármely elemtípust (v2 02/1: prompt, skill, MCP, guardrail, eval,
  compliance guide, szerepkör, tutorial, videó, link).
- A feltöltés a saját (vagy egy szerkesztett) munkatérbe kerül; az alapértelmezett szint
  `private`, a feltöltő választ: zárt / meghívásos / nyilvános.
- **Compliance guide** nyilvánosan csak „közösségi, nem jogi tanács" jelöléssel és a felülvizsgálat
  dátumával jelenhet meg; szerkesztői „ellenőrzött" jelölést csak az aibos konzol adhat (L-09).
- Forrás jelölése: `source = editorial | community | partner`. A UI mindig mutatja, ki a szerző,
  és hogy szerkesztői vagy közösségi elem.

## 2. Feltöltési folyamat és automatikus ellenőrzések

```text
vázlat → automatikus ellenőrzés → (bizalmi szinttől függően) moderációs sor → közzétett
```

| Ellenőrzés | Mikor blokkol | Megjegyzés |
|------------|---------------|------------|
| **Titok-detektálás** (API kulcs, token, jelszó, DB connection string a promptban/skillben/MCP konfigban) | mindig | a feltöltő látja, mit kell kitakarnia; a titok nem kerül logba (L-04) |
| Licenc mező | skill, MCP, szerepkör: kötelező; nem újraterjeszthető forrásnál csak link (v2 Q-V2-06) | |
| Fájlok vírusellenőrzése (ClamAV), méret- és típuskorlát | mindig | MinIO karantén bucket, átvizsgálás után mozgatás |
| Link- és videó-elérhetőség, oEmbed | közzétételkor és hetente | v2 04/5 |
| Duplikátum (FTS + vektor hasonlóság) | nem blokkol, figyelmeztet | „Hasonló már van: …, inkább kommenteld vagy forkold" |
| Tartalom-osztályozás (spam, sértő, kártékony utasítás) | magas pontszámnál moderációs sorba | **helyi modell** (MLX), az adat nem hagyja el a gépet |

## 3. Értékelés

- **1–5 csillag**, tagonként és elemenként egy, módosítható.
- **„Használtam" jelölés:** ha a tag ténylegesen másolta, letöltötte vagy curve-ben elvégezte, az
  értékelés „ellenőrzött használat" jelet kap, és nagyobb súllyal számít.
- Saját elemre nem lehet értékelni; új fiók (< 3 nap) értékelése nem számít a rangsorba.
- Rangsor: **Bayes-átlag** (kevés értékelésnél a globális átlag felé húz), plusz frissesség és
  használat. Kis számnál (< 5) nincs nyilvános átlag, csak „3 értékelés" (v2 P-V2-11 mintája).
- Curve-öknél a v2 szabály marad: értékelés csak elvégzés (vagy ≥ 50% haladás) után.

## 4. Komment

- Elemen, curve-ön és csoportban; egyszintű válasz (szál), markdown-részhalmaz, `@említés` és
  `+curve` linkesítés (03).
- Szerző válasza kiemelve; a szerző egy kommentet kitűzhet.
- „Hasznos" reakció (nincs lefelé szavazás – a negatív visszajelzés értékelésben vagy bejelentésben
  menjen).
- Szerkesztés 15 percig nyomtalanul, utána „szerkesztve" jelöléssel; törlés soft delete.

## 5. Bizalmi szintek (spam és visszaélés ellen)

| Szint | Hogyan éri el | Mit tud |
|-------|---------------|---------|
| T0 új | belépés | feltöltés, de az első **3 nyilvános** feltöltés előmoderációs sorba megy; max 5 feltöltés / nap; link a kommentben nem kattintható |
| T1 tag | 3 jóváhagyott nyilvános tartalom vagy 14 nap aktivitás bejelentés nélkül | utólagos moderáció; 20 feltöltés / nap |
| T2 megbízható | 10 jól értékelt tartalom (Bayes ≥ 3,8) | a kommentjeit nem kell átnézni; bejelentései gyorsabban kerülnek elő |
| Szerkesztő | aibos konzolban kiosztva | ajánlás, nyilvános minta jelölés, „ellenőrzött" jelölés |

A pontos küszöbök az aibos konzolban állíthatók (Q-V3-03).

## 6. Keresőoptimalizálás közösségi tartalomnál

- Közösségi nyilvános elem `noindex` marad, amíg el nem éri a minőségi küszöböt (≥ 3 értékelés és
  Bayes ≥ 3,5, vagy szerkesztői ajánlás). Így a spam nem rontja a domain hírnevét.
- A külső linkek közösségi tartalomban `rel="ugc nofollow"`.

## 7. Bejelentés és moderáció (DSA)

Az ai2know tárhelyszolgáltató a felhasználói tartalmakra, ezért az EU DSA szerinti minimum kell:

- **Bejelentés gomb** minden elemen, kommenten, curve-ön, munkatéren, csoporton: ok kiválasztása,
  indoklás, bejelentő e-mail (nem kötelező belépés).
- **Moderációs sor** az aibos konzolban: elem, előzmények, a szerző bizalmi szintje, automatikus
  osztályozás eredménye; döntés: marad / elrejtve / eltávolítva / fiók korlátozása.
- **Indoklás a szerzőnek** (statement of reasons) minden korlátozó döntésnél, **fellebbezés**
  lehetőséggel; minden döntés auditált (L-11).
- Éves átláthatósági összesítő az ai2know oldalán (darabszámok, döntéstípusok).
- A jogi szöveg (ÁSZF, közösségi irányelvek) tervezet marad az owner jóváhagyásáig (L-09).

## 8. Adatmodell (`ai2know` séma)

```text
items (+ mezők)    workspace_id, source (editorial|community|partner), author_sub,
                   moderation_state (pending|approved|hidden|removed), quality_score
item_ratings       item_id, member_sub, stars 1–5, used_verified bool, created_at, updated_at
comments           id, target_type (item|curve|group), target_id, parent_id, author_sub,
                   body, pinned, state (visible|hidden|removed), edited_at, is_deleted
comment_reactions  comment_id, member_sub, kind (helpful)
reports            id, target_type, target_id, reporter_sub | reporter_email_hash, reason,
                   text, status (open|actioned|dismissed), decided_by, decision, reason_text,
                   appeal_state, created_at
member_trust       member_sub, level (t0|t1|t2|editor), counters jsonb, updated_at
```

## 9. Elismerés a skillpass-on

A közösségi alkotó a skillpass profilján megjelenhet („Készítette: 12 prompt, 3 curve, átlag 4,6")
– a felhasználó beállításával, a `06-skillpass-igenyek.md` 3. pont szerint.

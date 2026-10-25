# 03 – Learning curve

## 1. Fogalom

A **learning curve** egy sorba rendezett, szakaszokra bontható lista tudáselemekből és külső
tartalmakból, egy céllal („Workshop után: AI marketing alapok 2 hét alatt"), készítővel,
jogosultsággal, haladáskövetéssel és visszajelzéssel. Mint egy YouTube playlist, de bármilyen
tudáselemmel, és igazolható elvégzéssel.

## 2. Adatmodell (`ai2know` séma)

```text
curves             id, code (pl. LC-2026-0042), slug, title, summary, cover, locale, level,
                   est_minutes, tags[], status (draft|published|archived),
                   origin_kind (event|workshop|training|self|fork), origin_ref
                   (pl. aibos esemény ID, superskiller edition kód), forked_from_curve_id,
                   owner_sub, created_at
curve_editors      curve_id, member_sub, role (owner|editor|viewer_stats)
curve_versions     curve_id, version, published_at, snapshot (jsonb: szakaszok + lépések),
                   completion_rule (all_required | n_of_m | with_check)
curve_steps        (a munkapéldány) curve_id, section, position, kind, ref, required,
                   note („miért nézd meg"), est_minutes
                   kind = item (ai2know code+verzió) | external (provider + ref) | task (szöveges feladat)
curve_access       curve_id, rule_kind, rule_value, valid_from, valid_until
                   rule_kind = public | unlisted_link | cohort_code | skillpass_entitlement |
                               named_member | email_domain
enrollments        id, curve_id, version, member_sub, source (link|code|entitlement|invite|self),
                   status (enrolled|in_progress|completed|dropped), started_at, completed_at
step_progress      enrollment_id, step_key, state (open|done|skipped), done_at, signal
                   (manual|viewed|copied|external_webhook)
curve_feedback     enrollment_id, rating 1–5, text, verified (elvégzés után), moderation
curve_stats_daily  curve_id, day, views, enrollments, completions, avg_rating
```

## 3. Jogosultság

- **Szerkesztés:** tulajdonos + társszerkesztők. Curve-öt létrehozni minden tag tud (privát);
  **közzétenni nyilvánosan** a `curve_author` képességgel rendelkező tag (oktató, partner) –
  ezt az aibos konzolban kapja (P-V2-07).
- **Hozzáférés (a résztvevők felé), DENY alapból, több szabály VAGY kapcsolattal:**

| Szabály | Példa | Tipikus használat |
|---------|-------|-------------------|
| `public` | bárki, kereshető | marketing curve |
| `unlisted_link` | aki ismeri a linket (token az URL-ben) | gyors megosztás |
| `cohort_code` | meghívó kód / QR (`LC-2026-0042-K7Q`), lejárattal, max létszámmal | workshop résztvevők |
| `skillpass_entitlement` | aki megvette a képzést (skillpass entitlement kód) | fizetős tréning |
| `named_member` | név szerint meghívott tagok | mentorálás |
| `email_domain` | `@ceg.hu` címmel belépők | céges képzés |

- A curve hozzáférés **felülírja az elemek láthatóságát a curve kontextusán belül**: egy
  `restricted` elem a curve-ön keresztül látható a jogosultnak (pl. képzési anyag), a curve-ön kívül nem.
- Külső lépés (superskiller) hozzáférését a forrásrendszer dönti el; ha nincs hozzáférés, a lépés
  „hozzáférés kell" állapotot mutat a forrás belépési/vásárlási linkjével.

## 4. Életciklus

`draft` → `published` (vN pillanatkép) → szerkesztés új vázlaton → `published` (vN+1) → `archived`.
A felvett résztvevők a saját verziójukon maradnak; új verziónál választhatnak („frissítés a v3-ra").
Archivált curve-ön az elvégzések és visszajelzések megmaradnak (a skillpass bejegyzés érvényes).

## 5. Haladás és elvégzés

- Lépés teljesítése: kézi „kész" jelölés (alap), automatikus jelzés: megnyitás (link, tutorial),
  másolás (prompt), letöltés (skill/szerepkör), **külső webhook** (superskiller lecke elvégezve).
- Videó: „megnéztem" jelölés; a lejátszási idő mérése nem cél (adatvédelem, forrásfüggetlenség).
- Elvégzés: a `completion_rule` teljesül → `completed` → visszajelzés kérés → skillpass push (04/1).
- Opcionális ellenőrzés (`with_check`): rövid kvíz vagy feladat-link (2. kör).
- Igazolás oldal: `https://ai2know.it/igazolas/{token}` (név, curve, dátum, készítő) – ez a
  skillpass `certificate_url`.

## 6. Visszajelzés és statisztika

- Visszajelzés: 1–5 csillag + szöveg, csak elvégzés (vagy ≥ 50% haladás) után; „ellenőrzött" jelölés
  elvégzés esetén. Szöveg moderálva (aibos konzol).
- Készítőnek: felvettek, aktívak, elvégzők, lemorzsolódás lépésenként (melyik lépésnél akadnak el),
  átlagos idő, értékelés-eloszlás, szöveges visszajelzések. Résztvevőnként csak a haladás látszik
  (név a résztvevő hozzájárulásával – kohorsz-megosztás beállítás).
- Nyilvános összesítő (a curve oldalán és a skillpass-on): elvégzők száma, átlagértékelés, legutóbbi
  visszajelzések – kis számoknál (< 5) nem mutatunk átlagot (azonosíthatóság).

## 7. Megosztás

Link, QR (a QR-generátor újrahasznosítva), rövid link `ai2know.it/lc/{code}`, beágyazás (oEmbed),
naptár-emlékeztető (opcionális e-mail emlékeztető a résztvevőnek, hozzájárulással), másolás
(„fork") a készítő megnevezésével, ha a készítő engedi.

## 8. Felületek

| Oldal | URL |
|-------|-----|
| Curve böngésző (nyilvánosak) | `/lc` |
| Curve oldal (áttekintés, lépések, belépés/felvétel) | `/lc/{slug}` |
| Lejátszó nézet (lépésről lépésre, mobilon lapozható) | `/lc/{slug}/lepes/{n}` |
| Saját curve-ök (felvett, készített) | `/curve-jaim` (workspace shell) |
| Szerkesztő (drag & drop, kereső oldalpanel, elem-előnézet) | `/lc/{slug}/szerkesztes` |
| Statisztika | `/lc/{slug}/statisztika` |
| Csatlakozás kóddal | `/csatlakozas` (QR célja) |

A szerkesztő mobilon is használható (lista-átrendezés fel/le gombokkal), de desktopra optimalizált.

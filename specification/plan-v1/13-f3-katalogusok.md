# F3 – Katalógusok (a profi keresők)

> Routing: STANDARD. Skillek: `frontend-design`, `e2e-test`, `i18n-required`.
> Minden szekció ugyanazt a katalógus-motort használja (02/5); egy szekció = konfiguráció
> (típusok, facetták, kártya-variáns, alapértelmezett rendezés) + szekció-fejléc tartalom.

## 1. Közös motor (első lépés)

- [ ] `components/catalog/*` (02/5) + `lib/catalog/section-config.ts` (szekció-regiszter, mint az
      aiagentek `library-types.ts`, de facettákkal és rendezéssel).
- [ ] URL-állapot, SSR első render, „Továbbiak", görgetés-visszaállítás, skeleton, üres állapot
      kérés-gombbal.
- [ ] Részletoldal sablon + típus-specifikus blokkok, strukturált adat, OG kép.

## 2. Szekciók (sorrend: forgalom és érték szerint)

| # | Szekció | Facetták | Kártya / részlet különlegesség |
|---|---------|----------|-------------------------------|
| 1 | Eszközök (`/eszkozok`, régi `/appok`, `/bovitmenyek`) | kategória, árazás, platform, magyar támogatás | logó, platform-ikonok, „Letöltés" platformonként, QR (mobilon gomb), alternatívák |
| 2 | Promptok, Skillek, MCP-k, Guardrailek, Evalok | típus, kategória, szint, üzleti funkció, iparág, cél-LLM | másolás egy kattintással, másolásszám, értékelés, komment, „javítást kérek" |
| 3 | Eszköztár (`/eszkoztar`) | – | 7 pillér + pilléren belüli könyvtár-keresés (F4) |
| 4 | Szótár (`/szotar`) | betű, kategória | A–Z ugrás, „lásd még", angol megfelelő |
| 5 | Linkek (`/linkek`) | forrás típusa, nyelv, kategória | domain-ikon, kimenő kattintás mérés, „utoljára ellenőrizve" |
| 6 | Videók (`/videok`) | előadó, téma, hossz | bélyegkép, lite YouTube beágyazás (kattintásra tölt, adatvédelmi mód), fejezetek |
| 7 | Segédanyagok (`/segedanyagok`) | téma, formátum | előnézet, letöltés (régi URL), belépve letöltésszám |
| 8 | Kedvezmények (`/kedvezmenyek`) | partner, kategória, érvényes | kuponkód felfedése belépve, „másolva" mérés, lejárt elrejtve |
| 9 | Kérdések (`/kerdesek`, régi `/ai-kerdesek-es-valaszok`) | téma, megválaszolt | publikus kérdés-válasz oldalak (`QAPage` séma); kérdezés belépve, moderálás aibos-ban |

## 3. Régi URL-ek ebben a fázisban

`/appok` → `/eszkozok`, `/bovitmenyek` → `/eszkozok?tipus=bovitmeny`, `/aitools` → `/eszkozok`,
`/ai-kerdesek-es-valaszok` → `/kerdesek`; a többi szekció a régi címén él.

## Tesztek

- Szekciónként: szűrés, rendezés, URL-megosztás, vissza gomb, másolás/kattintás mérés.
- Mobil E2E: szűrő lap nyitás–választás–„Mutasd" folyamat; kártya akciók.
- Kedvezmény: kijelentkezve a kód nem szerepel a HTML-ben sem.
- XSS: komment és kérdés szövege escape-elve (a régi aiqna hiba ellen).

## Kimenet

- Mind a 9 szekció működik test környezetben a seed + aiagentek tartalommal.

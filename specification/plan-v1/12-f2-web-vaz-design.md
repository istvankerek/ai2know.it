# F2 – Web váz, design rendszer, mobil navigáció

> Routing: STANDARD. Skillek: `frontend-design`, `skeleton-loading`, `i18n-required`,
> `skillpass-auth`, `webapp-testing`.

## Feladatok

- [ ] Képernyőtervek (04/2) → owner jóváhagyás.
- [ ] `apps/web` (Next.js 16, React 19, Tailwind v4, zod, vitest) a testvérprojektek mintájára;
      design tokenek, világos/sötét mód, típus-színek és ikonok.
- [ ] Layout: desktop felső navigáció, mobil alsó tab sáv, teljes képernyős menü, lábléc (jogi
      linkek, cégadatok, közösségi linkek).
- [ ] Kezdőlap (01/4) – a `/` már nem irányít a belépésre.
- [ ] Globális kereső: `Cmd/Ctrl+K` paletta, mobil teljes képernyős kereső, `/kereses` oldal.
- [ ] Könnyű skillpass belépés (BFF: `/auth/login|callback|refresh|logout`, v0 F2/1) – csak a
      személyes funkciókhoz; tag-összekötés és régi fiókok kezelése a II. felvonásban.
- [ ] Nyelv: skillpass `locale` → hint süti → `Accept-Language` → `hu` (v0 02/5).
- [ ] Consent: egy banner, Consent Mode v2, GA4 csak hozzájárulás után.
- [ ] Hibaoldalak (404 kereséssel, 500 kérésazonosítóval), `robots.txt`, dinamikus `sitemap.xml`.

## Tesztek

- E2E mobil és desktop viewporton: navigáció minden pontja 200, kereső paletta billentyűzettel.
- Lighthouse CI mobil profil ≥ 90; axe 0 kritikus.
- Belépés/kilépés skillpass test példánnyal; token nincs JS által olvasható helyen.

## Kimenet

- Navigálható, mobilon is gyors váz kezdőlappal és működő globális keresővel (mock adaton is).

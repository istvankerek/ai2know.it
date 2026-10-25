# F3 – Nyilvános frontend és tartalom

> Cél: az `apps/web` nyilvános része a régi tartalommal, az aibos-public API-ból, a régi
> URL-eken; SEO, hozzájárulás-kezelés, hibaoldalak.
> Routing: STANDARD. Skillek: `frontend-design`, `i18n-required`, `skeleton-loading`,
> `webapp-testing`, `brand-auditor`.

## 1. Váz és arculat

- [ ] Layout: fejléc (logó, fő menü), oldalsáv helyett kategória-navigáció, lábléc (jogi linkek,
      közösségi linkek, cégadatok: felnőttképzési nyilvántartási szám, D-U-N-S).
- [ ] Menü a régi `header.html` / `sidebar.html` / `footer.html` alapján (01 / 2): csak élő céloldal
      kerülhet menübe – teszt: minden menüpont 200 (L-06). A régi „#" menüpontok (Hírek,
      CustomGPT-k, Cheat sheets, E-books) kimaradnak, amíg nincs tartalmuk.
- [ ] Arculat: a régi ai2know.it logó és színek, Tailwind tokenek, világos/sötét mód, reszponzív,
      WCAG 2.1 AA. A design előbb képernyőtervként (owner jóváhagyás), aztán kód.
- [ ] Új nyitóoldal a `/`-en (ma `/belepes`-re irányít): mi az ai2know.it, belépés/regisztráció
      skillpass-szal, kiemelt tartalmak, partnerek.

## 2. Tartalom az aibos-public API-ból

- [ ] Kliens: `GET /public/v1/portal/ai2know-it/{bundle|pages|pages/{path}|links|offers|faq|glossary}`,
      zod validáció, ISR (300 s) + címkézett revalidálás aláírt webhookkal.
- [ ] Oldaltípusok: jogi szöveg, link-gyűjtemény (Telegram/Discord/…, Linkek, Bővítmények, Appok),
      erőforrás-könyvtár (Segédanyagok, cheat sheetek letöltéssel), csomag (Pro, Business csomag),
      eseménylista, szótár.
- [ ] **Tartalom seed** (egyszeri, F3 része): a `hu/app/modules/*/templates` és
      `pages/templates/pages/*.html` szövegeinek kinyerése (HTML → Markdown), az aibos-ba töltés.
      Jogi szövegek változtatás nélkül; bármilyen módosítás tervezet, amíg az owner nem hagyja
      jóvá (L-09). A 2024-es elavult események archívumba, nem a főlistára.
- [ ] Angol tartalom: nincs forrás (01). Első körben a UI szövegek angolul, a tartalom
      angol változata az owner döntése szerint (Q-03); hiányzó angol tartalomnál a magyar jelenik
      meg „csak magyarul érhető el" jelzéssel – nem üres oldal.

## 3. Fájlok és képek

- [ ] `/static/uploads/*` kiszolgálása MinIO-ból a régi útvonalon (Caddy), helyes `Content-Type`,
      hosszú cache.
- [ ] Favicon készlet, `apple-touch-icon*.png` (ma ~8 k 404), `manifest.json`.

## 4. SEO

- [ ] Oldalankénti metadata, kanonikus URL `https://ai2know.it/...`, OG/Twitter kártyák.
- [ ] `sitemap.xml` dinamikusan (statikus route-ok + aibos oldalak), `robots.txt`.
- [ ] Strukturált adat: Organization (Everengine Kft.), BreadcrumbList.
- [ ] `Content-Language`, `Vary` (02 / 5); nincs hreflang (egy URL, a nyelvet a kérés dönti el).

## 5. Hozzájárulás és mérés

- [ ] Egyetlen süti banner (a régi kettő helyett), Google Consent Mode v2; GA4 (`G-DSGDV4EG3E`
      vagy új property – Q-14) csak hozzájárulás után.
- [ ] OneSignal web push: megtartás vagy kivezetés (Q-14); ha marad, csak hozzájárulás után tölt,
      és a régi service worker útvonalai (`/OneSignalSDKWorker.js`, `/OneSignalSDK.sw.js`) élnek.

## 6. Hibaoldalak

- [ ] 404: kereső + népszerű oldalak; 500: őszinte hibaüzenet, kérésazonosítóval (L-07).
- [ ] `/feed` és megszűnt végpontok 410-et adnak (03 / 3.4).

## Tesztek

- Unit: tartalom-kliens zod sémák, hiányzó mező → látható hiba, nem csendes üres oldal.
- E2E: minden 3.1-es tartalomoldal 200, a menü minden pontja 200, sitemap minden URL-je 200.
- Lighthouse ≥ 90 (perf, a11y, SEO, best practices) a nyitóoldalon és 3 tartalomoldalon; axe 0 kritikus.
- Hozzájárulás nélkül nincs GA / OneSignal hálózati kérés (Playwright hálózati napló).

## Kimenet

- A nyilvános oldal teljes egészében fut test környezetben, a régi tartalommal.

# 07 – Design: aibootcamp.hu stílus

> Forrás: az élő aibootcamp.hu (`aibootcamp.hu/apps/web/src/app/globals.css`, Next 16, kézi CSS,
> lucide-react) és az AIBootcamp brand skill (`anthropic-skills:aibootcamp`, infografika-irányelvek).
> A mobil minták (alsó navigáció, lapozós lejátszó) a `../plan-v1/04-design-mobil.md` szerint maradnak.

## 1. Melyik az irányadó

A **weboldal az élő aibootcamp.hu-t követi** (szerkesztőségi hangulat: Georgia címek, Manrope
szöveg, éles 4–6 px sarkok). A brand skill (Montserrat, 18–28 px kártyasarok) az infografikákra
és nyomdai anyagokra vonatkozik; a két forrás tipográfiája eltér → P-V3-17, Q-V3-08.

## 2. Tokenek (azonos értékek, Tailwind-be kötve)

A repo szabálya Tailwind + shadcn/ui (`.claude/rules/frontend.md`), az aibootcamp kézi CSS-t
használ. Megoldás: **ugyanazok a CSS változók** a `:root`-on, és a Tailwind téma ezekre mutat
(`colors.brand = 'var(--brand)'` …). Így a két oldal tokenjei egyeznek, a mi kódunk mégis a repo
szabályait követi.

| Token | Light | Dark | Használat |
|-------|-------|------|-----------|
| `--bg` | `#fffbf5` | `#171817` | oldal háttér |
| `--surface` | `#ffffff` | `#20221f` | kártya, panel |
| `--ink` | `#171714` | `#f6f3eb` | szöveg |
| `--muted` | `#645f57` | `#bbb8ae` | másodlagos szöveg |
| `--brand` | `#f6a41d` | `#f6a41d` | elsődleges gomb háttér (**sötét szöveggel**) |
| `--orange` | `#f67300` | `#f67300` | kiemelés, aktív lépés |
| `--accent-text` | `#a34d00` | `#ffb35c` | kis kiemelt szöveg (amber szövegszínként tilos) |
| `--soft` | `#fff0d9` | `#3c2c19` | badge, kiemelt sáv háttér |
| `--line` | `#ddd8cf` | `#454640` | 1 px keret |
| `--blue` / `--blue-soft` | `#0668c9` / `#eef5ff` | `#80baff` / `#152a40` | skillpass gomb, linkek |
| `--error` | `#a91c20` | `#ff9d9d` | hiba |

Sötét mód: `:root[data-theme="dark"]` + `prefers-color-scheme`, a kapcsoló a fejlécben.
(A `--accent-text` sötét értéke saját javaslat, kontrasztra ellenőrizve F2-ben.)

## 3. Tipográfia, forma, mozgás

- Címek: Georgia 500, `letter-spacing: -0.035em`, h1 `clamp(2.75rem,5.1vw,4.55rem)`, h2
  `clamp(1.8rem,3vw,2.65rem)`, `text-wrap: balance`; h3 és UI: **Manrope** 600 (önhosztolt, `next/font/local`,
  hogy ne legyen harmadik féltől származó betöltés).
- Szöveg: 16 px / 1,65. Kód (prompt, skill, MCP konfig): JetBrains Mono / SFMono.
- Sarok: gomb 4 px, badge 3 px, kártya 6 px, dialógus 6 px; kör/pill csak avatarnál és chipnél.
- Árnyék: `0 12px 40px #0002` (kártya hover), `0 20px 70px #0002` (dialógus).
- Gomb: min. 48 px magas, 13×22 padding, 600-as súly; hover `translateY(-1px)`;
  változatok: `primary` (amber, sötét szöveg), `dark`, `outline`, `skillpass` (kék, „Belépés skillpass.id-vel").
- Fejléc: sticky, 90 px (mobilon 64 px), középre zárt menü 14 px, aktív elem aláhúzással;
  mobilon natív `<dialog>` menü elmosott háttérrel (aibootcamp minta), plusz a v1 alsó navigáció.
- `prefers-reduced-motion` tisztelete; töréspontok: 1250 / 1000 / 767 / 420 px.

## 4. Elemtípus-színkód (a funkcionális színekből, < 10% vizuális tömeg)

| Típus | Szín (ikon + badge szegély) | Lucide ikon |
|-------|-----------------------------|-------------|
| prompt | `--orange` | `message-square-text` |
| skill (AI skill) | lila `#7c3aed` | `sparkles` |
| MCP | türkiz `#0d9488` | `plug` |
| guardrail | zöld `#16a34a` | `shield-check` |
| eval | kék `#2563eb` | `gauge` |
| compliance guide | `--ink` | `scale` |
| szerepkör | `--orange` + keret | `users-round` |
| tutorial | `--muted` | `list-checks` |
| videó | `--error` árnyalat | `play` |
| link | `--blue` | `link` |

A szín mellett mindig ott az ikon és a felirat (nem csak színnel kódolunk – akadálymentesség).

## 5. Saját komponensek az aibootcamp nyelvén

- **Curve kártya:** borító, cím (Georgia), `+slug` mono betűvel, lépésszám, idő, készítő (avatar +
  `@handle`), elvégzők, átlag (≥ 5 értékelésnél), szint-badge (Zárt / Meghívásos / Nyilvános / Fizetős).
- **Curve lejátszó – „narancs útvonal":** a brand skill útvonal-mintája a lépéssávra: az aktuális lépés
  kitöltött amber gradiens, a kész lépés `--orange` keret, a jövőbeli `--line`; mobilon vízszintesen
  görgethető, lapozás húzással.
- **Szint-választó:** négy rádiókártya ikonnal (`lock`, `mail`, `globe`, `badge-euro`); a fizetős kártya
  csak aibos.club partnernek aktív, másnak „aibos.club partnereknek" magyarázó szöveggel, letiltva.
- **Értékelés + komment blokk:** csillagok `--brand` színnel (sötét körvonallal a kontrasztért),
  „Használtam" jel, szerző válasza `--soft` háttérrel.
- **Dekoráció:** halvány pontmátrix vagy koncentrikus ív a hero mögött, max. 5–10% fedés; a logó-ív
  ferde vágás oldalanként egyszer.

## 6. Belépett felület

A tagi oldalak (Curve-jeim, Feltöltéseim, Munkatereim) a `@skillpass/workspace-shell` keretben futnak
(ecosystem kánon), a tartalom-területen az ai2know tokenekkel. A shell `sp-` CSS-e és a mi tokenjeink
ütközését F2-ben vizuális regresszió-teszt őrzi.

## 7. Minőségkapu

Lighthouse ≥ 90 mobilon, axe 0 kritikus, kontraszt 4,5:1 szövegre, vizuális regresszió (Playwright
screenshot) light + dark módban, 360 / 768 / 1280 px szélességen.

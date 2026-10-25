# 03 – Tartalomforrások és átvétel

## 1. Régi ai2know.it (seed)

| Régi oldal | Tartalom | Cél típus | Teendő |
|-----------|----------|-----------|--------|
| `/appok` | ~50 hivatkozás, főleg a ChatGPT elérési pontjai (web, Android, iOS, macOS, Windows, Chrome) QR kódokkal + további AI szolgáltatók (Claude, Gemini, Copilot, Perplexity, Midjourney, Leonardo, DeepL, Notion…) | `tool` | szolgáltatónként egy elem, platform-linkek és QR az `attributes`-ben; leírás bővítése |
| `/bovitmenyek` | 1 bővítmény (Image Prompt Helper) | `extension` | átvétel + bővítés |
| `/linkek` | 42 link, 5 kategória (eszközök és technológiák, oktatás, kutatás, közösségek, hazai és nemzetközi oldalak) | `link` | átvétel, link-ellenőrzés, kategóriák a közös taxonómiába |
| `/videok` | 11 YouTube videó (podcastok, előadások Kerek Istvánnal) | `video` | átvétel, hossz, előadók, fejezetek |
| `/segedanyagok`, `/aitools` | ~20 cheat sheet (PDF + PNG), fogalomtár, tokenizer link | `resource` (+ `tool`) | fájlok változatlan URL-en (MinIO), előnézet |
| `/kedvezmenyek` | 2 kupon (ELTE Books -15%, Sikerkalauz könyv -1000 Ft) | `discount` | érvényesség ellenőrzése (owner), új partnerkuponok |
| `/promptok` | üres | – | az aiagentek prompt könyvtár tölti meg |
| `/ai-kerdesek-es-valaszok` | tagi kérdések JSON fájlokban (privát), XSS hibával | `question` | csak az owner által kiválasztott, publikálásra jóváhagyott kérdések kerülnek át (hozzájárulás) |
| `/ai-erettsegi-szint-felmeres` | 25 kérdéses kérdőív | interaktív eszköz | átvétel, pontozás javítása (v0 P-V0-14) |
| `/qrcode` | QR generátor | interaktív eszköz | új, kliens oldali generálás; mentés belépve |

Az átvétel egy ETL szkript (`tools/content-import/legacy-ai2know`), amely a Jinja sablonokból
strukturált elemeket készít, és az aibos import végpontján tölti be `status = review` állapotban
– élesítés szerkesztői átnézés után.

## 2. aiagentekagyakorlatban.hu „Eszközök" (átköltözik)

| Elem | Darab / jelleg | Adat helye ma | Átvétel |
|------|----------------|---------------|---------|
| Prompt könyvtár | 30 | aibos `prompt_library_item` (book scope) | portál-tulajdon átadás ai2know-it-re (P-V1-02), kód változatlan |
| Skillek | ~339 (30 üzleti + ~309 GitHub skill) | ua. | ua.; a GitHub skillek forrásmegjelöléssel |
| MCP-k, guardrailek, evalok | 32 / 30 / 30 | ua. | ua. |
| Statisztika, értékelés, komment, kérések | meglévő sorok | aibos | megmaradnak (a kulcs `code`) |
| Szótár | ~300 szócikk | aibos glossary | portálhoz rendelés; aiagentek oldalon redirect |
| Eszköztár 7 pillér | statikus TS (`lib/eszkoztar-content.ts`) | kód | `pillar` típusú elemként az aibos-ba (L-12: tartalom nem kódban) |
| LLM működése (`/llm-mukodes`), Doodle AI (`/doodle-ai`) | interaktív komponensek | kód | komponens átvétele az `apps/web`-be (licenc/forrás ellenőrzés: moebio Mind) |
| Önteszt, Felmérő, Infografika, Agentek, Aktiválás | könyvspecifikus | – | **marad az aiagentek oldalon** (a könyv olvasói élménye), az ai2know-ra csak link |

Az aiagentek oldalon maradó menü az „Eszközök" alatt az ai2know.it-re mutat („Az eszköztár mostantól
az ai2know.it-en"); a könyv-olvasói belépés ugyanaz a skillpass.id fiók, ezért SSO-val folytonos.

### 2.1 Örök átirányítások az aiagentekagyakorlatban.hu hoston (P-V1-08)

| Régi | Új |
|------|----|
| `/eszkoztar` | `https://ai2know.it/eszkoztar` |
| `/eszkoztar/{slug}` | `https://ai2know.it/eszkoztar/{slug}` |
| `/promptok`, `/skillek`, `/mcp-k`, `/guardrailek`, `/evalok` | azonos útvonal az ai2know.it-en |
| `/promptok-es-skillek` | `https://ai2know.it/promptok` |
| `/promptok-es-skillek/{code}` | `https://ai2know.it/elem/{code}` |
| `/szotar`, `/szotar/{slug}` | azonos útvonal az ai2know.it-en |
| `/llm-mukodes`, `/doodle-ai` | `https://ai2know.it/interaktiv/{slug}` |

- Megvalósítás az aiagentek repóban (`next.config` redirects vagy Caddy), követéssel
  (`redirect_hits` mintára), saját plan alatt; a `qrcd.click/3/eszkoztar` sor átírása opcionális
  (a 301 lánc 2 ugrás – elfogadható, de a közvetlen cél jobb).
- Regressziós lista: a könyv minden nyomtatott URL-je, amely tools címre mutat → 100% 200 a végén.
- A váltás sorrendje: előbb az ai2know.it-en élesedik az elem (200), **utána** kapcsol a redirect.

## 3. superskiller.com

- Nincs tools rész (az „Eszközök" 2026-08-29-én költözött az aiagentek repóba).
- Ami átfedhet: üres `/tudastar` (cikklista), skill-katalógus (`/v1/public/skills`), könyvlista.
  Javaslat: a superskiller `/tudastar` az ai2know.it-re mutasson vagy annak tartalmát jelenítse
  meg (aibos portál-szinten megosztva) – Q-V1-02.

## 4. Tartalombővítés (hogy valódi tudásbázis legyen)

- Indulási cél: ≥ 120 eszköz/app, ≥ 150 kurált link, ≥ 40 videó, 461 könyvtárelem, 300 szócikk,
  ≥ 30 segédanyag, ≥ 10 aktív kedvezmény.
- Szerkesztői folyamat az aibos konzolban: `draft → review → published`, kötelező mezők
  típusonként, „utoljára ellenőrizve" ≤ 6 hónap (különben figyelmeztetés), link-ellenőrző robot
  hetente (törött kimenő link → konzol feladat).
- AI-asszisztált előkészítés (opcionális): eszköz-adatlap vázlat generálása nyilvános forrásból,
  **mindig emberi jóváhagyással** – az elem `source` mezője jelzi.
- Felhasználói kérések (`request`) a konzolban, státusszal; a kérő értesítést kap, ha elkészült.

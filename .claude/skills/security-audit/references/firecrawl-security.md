# Firecrawl MCP — Biztonsagi megjegyzes

> **Kapcsolodo skill:** `security-audit`
> **Forras:** `specification/everengine-v2.3.4-patch-mcp-observability.md` §2

## Mi a Firecrawl?

A Firecrawl egy **cloud-alapu** web scraping szolgaltatas, ami MCP szerveren keresztul elerheto a Claude Code-bol. Gyors ad-hoc scraping-re ideális (dokumentacio importalas, versenytars elemzes, egyetlen oldal kinyerese).

A skeleton `.mcp.json` tartalmazza a `firecrawl` szervert P2 prioritassal (opt-in).

## Figyelmeztetes — Cloud szolgaltatas

A Firecrawl **cloud szolgaltatas**, ami azt jelenti: a scraping cel URL es a valasz adatok atmennek a Firecrawl szerverein.

### Mit jelent ez a gyakorlatban?

| Helyzet | Kockazat |
|---------|----------|
| Publikus, nyilt dokumentacio scraping (pl. MDN, Rust docs) | ✅ Biztonsagos |
| Versenytars nyilvanos landing page | ✅ Biztonsagos |
| **Belso admin portal, bejelentkezes mogotti oldal** | ❌ NE hasznald |
| **Sajat ugyfel-portal** | ❌ NE hasznald |
| **Hitelesitett API** mogotti tartalom | ❌ NE hasznald |
| **GDPR/szemelyes adatokat tartalmazo oldal** | ❌ NE hasznald |

## Szabalyok

### 1. Soha ne scraplj belso/autentikalt oldalt Firecrawl-lal

Ha a cel URL bejelentkezes mogotti, vagy a sajat rendszered belso resze, hasznald a projekt sajat `scraper` skill-jet (Rust-nativ, self-hosted, proxy pool).

### 2. API kulcs kezeles

A `FIRECRAWL_API_KEY`:
- **NEM** kerulhet kodba (semmilyen `.ts`, `.rs`, `.js` fajlba)
- **NEM** kerulhet git-be (`.env.local` gitignored)
- **NEM** commitolhato PR-ba
- A `.env.local`-ban legyen, es a `.mcp.json`-ban csak `${FIRECRAWL_API_KEY}` valtozo hivatkozas

A v3.0 CLAUDE.md `Tiltasok` szekcio mar lefedi ezt a szabalyt.

### 3. robots.txt tiszteletben tartasa

A Firecrawl automatikusan tiszteletben tartja a cel oldal `robots.txt`-jet. Ez **nem kapcsolhato ki**, ami jo dolog — a skeleton sajat `scraper` skill-je is kotelzi ezt.

### 4. Rate limit es etika

Ad-hoc scraping:
- Max 10 oldal per session (etika + koltseg)
- NE scraplj versenytarsi rendszeres frissites celjabol (az a `scraper`/`spider` skill dolga, proxy pool-lal es rate limit-tel)

### 5. GDPR / szemelyes adatok

Ha a scraping eredmenye szemelyes adatot tartalmaz (email, nev, telefonszam), NE tarolod el hosszu tavra a projekt DB-jeben a jogalap megallapitasa nelkul.

## Biztonsagi audit checklist

A `security-audit` skill futtasa soran ellenoriznod kell:

- [ ] `FIRECRAWL_API_KEY` nincs hardcoded sehol
- [ ] A `firecrawl` MCP nem vonatkozik belso/auth-olt URL-re
- [ ] A scraping logok nem tartalmaznak szemelyes adatot
- [ ] A `.env.local` gitignored es nem push-olt

## Mikor hasznald a sajat scraper skill-t?

| Feladat | Firecrawl MCP | Sajat scraper skill |
|---------|:-:|:-:|
| Egy publikus oldal gyors kinyerese | ✅ | ⚠️ Tul nehez |
| Rendszeres napi/heti gyujtes | ❌ | ✅ |
| Anti-bot vedett oldal | ❌ | ✅ (residential proxy) |
| Belso/auth-olt oldal | ❌ NE! | ✅ (izolalt, self-hosted) |
| GDPR erzekeny oldal | ❌ NE! | ✅ (sajat jogalap) |
| 100+ oldal crawling | ❌ tul draga | ✅ spider skill |

## Kapcsolodo

- `scraper` skill — sajat Rust-nativ scraper, proxy pool, rate limit
- `spider` skill — teljes weboldal feltérképezés
- v2.3.4 spec §2
- CLAUDE.md Tiltasok szekcio — secret commit tilos

# 02 – Célarchitektúra és refaktor

## 1. Célkép

Egyetlen domain (`ai2know.it`), egyetlen nyelvfüggetlen URL-készlet, két alkalmazás:

- **`apps/web`** – Next.js App Router: nyilvános oldalak (SSR/ISR), tagi felület a skillpass
  workspace shell-ben, és az auth **BFF** (a token soha nem jut a böngészőbe).
- **`apps/backend`** – Rust/Axum API: tagok, referral, partnerek, kuponok, megosztás, QR,
  követés, admin API az aibos.space felé, régi URL-ek átirányítása.

Ami **nem** épül újra: belépés, regisztráció, jelszó, profil, e-mail-ellenőrzés (skillpass.id);
admin felület (aibos.space konzol); tartalomszerkesztés (aibos → `aibos-public` portál-tartalom
API); fizetés és számla (`pay.aibos.space`, `invoice.aibos.space`).

## 2. Rendszerkontextus

```text
                     ┌──────────────── skillpass.id ────────────────┐
                     │ OIDC (Code+PKCE), Account Center, shell ctx  │
                     └───────▲───────────────────────▲──────────────┘
                 OIDC + BFF  │                       │ M2M (entitlements:write, …)
                             │                       │
Látogató ─▶ Cloudflare ─▶ Caddy ─┬─▶ apps/web (Next.js :3000) ──▶ apps/backend (Axum :8080)
                                 │        │  SSR tartalom                 │
       hu.ai2know.it ─┐          │        ▼                               ├─▶ PostgreSQL (schema ai2know)
       en.ai2know.it ─┼─ 301 ────┤   aibos-public API                     ├─▶ Redis (csak cache)
       t./auth./… ────┘ (követve)│   (portál-tartalom)                    ├─▶ NATS JetStream (outbox)
                                 └─▶ /_legacy redirector (backend) ◀──────┤─▶ MinIO (feltöltések, QR)
                                                                          │
                      aibos.space konzol ── M2M + X-Actor-Assertion ──▶ /admin/v1/* (contract)
                      pay / invoice.aibos.space ◀── API kulcs, idempotencia ── backend
```

## 3. Repo-szerkezet (a skeleton 8.0.0-ra építve)

```text
ai2know.it/
├── apps/
│   ├── web/                    Next.js 16 App Router, React 19, Tailwind 4, zod, vitest,
│   │                           @skillpass/workspace-shell (vendored tgz, a testvérprojektek mintája)
│   └── backend/                Axum bináris (a crate-eket köti össze)
├── crates/
│   ├── a2k-common/             config, hibák (RFC 7807), id (UUID v7), idő, ip_hash
│   ├── a2k-db/                 sqlx pool, migrációk futtatása, repository trait-ek
│   ├── a2k-auth/               skillpass JWKS (RS256) validáció, BFF→backend service token,
│   │                           aibos workload JWT + actor assertion
│   ├── a2k-members/            tagok, összekötés, handle
│   ├── a2k-referrals/          referral kódok, csatornák, meghívók, kuponok, partnerek
│   ├── a2k-engagement/         kedvencek, megosztás, QR, AI felmérés, AI kérdés-válasz, support
│   ├── a2k-tracking/           redirect_hits (régi host átirányítások követése)
│   ├── a2k-admin-api/          /admin/v1/* a contracts/admin/ai2know-admin.yaml szerint
│   └── a2k-legacy-etl/         egyszeri migrációs bináris (F7), csak helyben fut
├── contracts/
│   ├── admin/ai2know-admin.yaml (+ .json)       aibos ⇄ backend
│   ├── authorization/permissions.json, role-matrix.csv
│   └── public/ai2know-public.yaml               web ⇄ backend (typed kliens generálás)
├── migrations/postgres/        sqlx migrációk (up + down)
├── infrastructure/caddy/       Caddyfile: ai2know.it + régi hostok
├── docker/                     compose: local / test / prod
└── specification/plan-v0/      ez a terv
```

A skeleton `apps/frontend` (Vite), `apps/admin` (Vite) és `apps/ai-chat` nem kell: a frontend
Next.js, az admin az aibos.space-ben él. Eltávolításuk owner jóváhagyást kér (P-V0-03, 3. aranyszabály).

Verziók: a testvérprojektek (aibootcamp.hu, aiagentekagyakorlatban.hu) mintája – Next 16.2.x,
React 19.2.x, Node 24, pnpm; Axum 0.8, sqlx 0.8, tower-http 0.6, utoipa 5, jsonwebtoken 9.
F0-ban a pontos verziókat a lockfile-ok rögzítik.

## 4. Refaktor: 50 modulból 7 kontextus

A régi rendszer 50 FastAPI modulja egy generátorból (`create_module.py`) készült; a modulok
többsége üres sablon. A célrendszer üzleti kontextusok szerint szerveződik, a régi URL-ek
viszont mind megmaradnak (lásd 03). A modulonkénti döntés (megtart / tartalomba / elhagy +
átirányít) a `01-legacy-audit.md` táblázatában van.

| # | Kontextus | Régi modulok | Új helye |
|---|-----------|--------------|----------|
| K1 | Identitás és tagság | auth, users, settings, roles, profil | skillpass.id + `a2k-members` |
| K2 | Referral és partnerek | channel (`/@handle`), invite, affiliate, business, business_partners, myteam, discounts, qrcode, share | `a2k-referrals`, `a2k-engagement` |
| K3 | Tartalom | pages, csr, dictionary, resources, links, videos, plugins, apps, aitools, prompts, events, instructors, experts, mastermind, meetup(s), sundayprompts, news, blogs, newsletter, pro, communities | aibos-public portál-tartalom API → `apps/web` |
| K4 | Részvétel | favorites, aiqna, ai_maturity_assessment, support, gamification | `a2k-engagement` (amit az owner megtart) |
| K5 | Követés és átirányítás | tracker (t.ai2know.it), új: régi host redirect | `a2k-tracking` + Caddy |
| K6 | Admin | users-admin, business export/import, fetch-orders, orders-report, newsletter_users, labels, aiqna answer, share/list, list_qrcodes | `contracts/admin` → aibos.space konzol |
| K7 | Platform | seo (robots, sitemap, favicon), errors (404/500), statikus fájlok | `apps/web` + Caddy |

Elhagyott (soha nem működött, üres táblák): posts/feed, comments, follows, friendships, groups,
forums, messages, notifications, files, categories, labels-UI. A régi URL-jük nem 404-re fut,
hanem a legközelebbi élő oldalra irányít (lásd 03, L-06).

## 5. Nyelv (D-V0-05)

- Nincs nyelvváltó és nincs nyelvi URL-előtag: egy URL = egy oldal, a nyelvet a kérés dönti el.
- **Bejelentkezett tag:** a skillpass.id `locale` trait (a Kratos sémában megvan; claimként a
  `profile` scope-ban vagy a shell-context `locale` mezőjéből olvassuk – Q-02).
- **Vendég:** sorrend: `a2k_locale_hint` süti (a régi `en.ai2know.it`-ről érkezőknél a redirector
  állítja `Domain=ai2know.it`-re) → `Accept-Language` → alapértelmezett `hu`.
- Válasz: `Content-Language` + `Vary: Cookie, Accept-Language`; CDN cache kulcs ugyanerre.
- SEO következmény: az angol változat nem kap külön indexelt URL-t, a kanonikus tartalom a magyar.
  Ezt az owner döntése tudatosan vállalja; a kockázat a `91-kockazatok.md`-ben.
- Fontos tény az átvizsgálásból: az `en.ai2know.it` **nem fordítás**, hanem a hu régebbi,
  magyar nyelvű másolata (magyar URL-ek, magyar szöveg, `.mo` fájl sehol). Angol tartalom tehát
  nincs – az angol UI-szövegek és az angol tartalomváltozatok új munka (F3, Q-03).
- Szövegek: `next-intl` „prefix nélküli" módban, `hu.json` + `en.json` azonos kulcskészlettel
  (`i18n-required`); a tartalom nyelvi változatait az aibos-public adja (`locale` paraméter).

## 6. Auth folyamat (skillpass-auth minta)

- BFF route-ok a `apps/web`-ben: `/auth/login`, `/auth/callback`, `/auth/refresh`, `/auth/logout`
  (Hydra + Kratos session zárás, L-13). Sütik: `a2k_session` (HMAC-aláírt, httpOnly, Secure, Lax),
  `a2k_csrf` (double-submit).
- A régi auth URL-ek megmaradnak, de a skillpass felé visznek: `/belepes` → `/auth/login`,
  `/jelentkezes` → `/auth/login?flow=registration`, `/profil` → Account Center deep link stb.
  (teljes lista: 03).
- A backend minden tagi kérésnél RS256 JWT-t validál a skillpass JWKS-sel (iss, aud, exp), a
  `sub` alapján tölti a `members` sort; első belépéskor összeköt (04 / 3.2).
- Jogosultság: a `cohort` (régi role 4/5/6) csak tartalmi kedvezményt nyit, jogosultságot nem ad;
  semmilyen admin funkció nincs a web felületen.

## 7. Admin (aibos.space)

- Contract-first: `contracts/admin/ai2know-admin.yaml`, permission kódok `ai2know.{modul}.{akció}`,
  DENY alapértelmezés, nincs wildcard; lista végpontok cursor lapozással; hibák RFC 7807.
- Hitelesítés: aibos workload JWT (M2M) + `X-Actor-Assertion` (EdDSA, ≤120 s, `jti` replay védelem).
- Modulok (első kör): `members`, `partners`, `referral_codes`, `coupons`, `share_links`,
  `qr_codes`, `redirects` (riport), `assessments`, `support_tickets`, `newsletter`
  (export a kiküldő rendszer felé), `audit` (olvasás).
- Az aibos csapat a contractból typed klienst generál, a DLA oldalak az aibos konzolban épülnek.

## 8. Tartalom

- Portál slug: `ai2know-it` az aibos-public API-ban (`/public/v1/portal/ai2know-it/...`).
- Leképezés: jogi oldalak, CSR, közösségi csatorna oldalak → `pages`; szótár → `glossary`;
  hírek/blog → `posts`; linkek → `links`; csomagok (business-csomag, pro) → `offers`; GYIK → `faq`.
- `apps/web` ISR-rel (pl. 300 s) és címkézett revalidálással (aibos webhook → `/api/revalidate`,
  aláírt) tölti; aibos kiesésnél az utolsó jó állapotot szolgálja ki.
- A régi Jinja sablonokból kinyert szöveg egyszeri seed az aibos-ba (F3), utána a tartalom
  forrása az aibos (L-12).

## 9. Nem funkcionális követelmények

| Terület | Követelmény |
|---------|-------------|
| Biztonság | CSP nonce, HSTS, sütik a skillpass-auth szerint, CORS explicit whitelist, secretek csak env-ből, `cargo audit` + `pnpm audit` CI-ban |
| Adatvédelem | IP csak kulcsolt hash, PII minimalizálás, audit append-only, megőrzési idők dokumentálva |
| Hibák | RFC 7807 mindenhol, nincs csendes fallback (L-07), 404/500 oldalak magyar/angol |
| Megfigyelhetőség | tracing (JSON log), Prometheus metrikák, health/readiness végpontok |
| Teljesítmény | nyilvános oldalak TTFB < 300 ms cache-ből, redirect < 50 ms Caddy szinten |
| Tesztek | TDD; unit + integráció (sqlx teszt DB) + Playwright E2E (kritikus utak) + redirect regresszió a teljes URL-listán |
| Üzemeltetés | Docker Compose, non-prod először, smoke automata, prod csak „mehet" után (L-03) |

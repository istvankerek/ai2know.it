# 01 – A régi rendszer átvizsgálása (hu.ai2know.it)

> Forrás: `backup/hu.ai2know.it` (git: `github.com/istvankerek/ai2know.it`, 9 commit, utolsó
> 2025-12-26). Fókusz: `hu/` (fő alkalmazás); a többi szolgáltatás kiegészítő.
> Az itt említett titkok értéke szándékosan nincs leírva – csak a helyük.

## 1. Architektúra (ma)

```text
Caddy (80/443) ─┬─ hu.ai2know.it  → hu  (FastAPI :8001, Jinja2 + Bootstrap 5, jQuery)
                ├─ en.ai2know.it  → en  (FastAPI :8002 – a hu régebbi, MAGYAR másolata)
                ├─ auth.ai2know.it → auth (FastAPI :8000 – a route-ok kikommentezve, gyakorlatilag üres)
                ├─ t.ai2know.it   → tracker (Rust/Axum :8900 – 308 redirect + nyílt redirect hiba)
                ├─ o.aitoknow.it  → orders (WooCommerce proxy, Basic auth)
                ├─ api./app./cdn./portal./sync./test./forum./support. + live.aibootcamp.space
                │                 → „Coming soon" statikus oldal
                └─ pgadmin./c./p./b.aitoknow.it → pgAdmin, cAdvisor, Portainer, backup_server
PostgreSQL 16 · Redis (konfigurálva, nem használt) · óránkénti pg_dump (90 nap) · ~10 SQLite fájl
```

- 50 modul a `create_module.py` generátorból; a modulok többsége üres sablon.
- Auth: saját JWT süti (`access_token`, HS256, **10 év** élettartam „emlékezz rám"-mal), a
  szerepkör csak a tokenben él, nincs visszavonás, nincs CSRF védelem.
- i18n: Babel be van kötve, de `.mo` fájl sehol – minden felület beégetett magyar szöveg. A nyelvet
  a domain döntötte el (hu/en), de az `en` oldal is magyarul szólt.
- Külső kapcsolatok, amik ténylegesen futnak: Mailgun EU (csak auth e-mailek), Számlázz.hu
  (díjbekérő, UI-ból nem elérhető), Trello (support), WooCommerce az aibootcamp.hu shopból
  (affiliate), OneSignal web push, Google Analytics `G-DSGDV4EG3E` (hozzájárulás nélkül tölt).
  Az OpenAI, Groq, Stripe, GeoIP2 csak a `requirements.txt`-ben és az `.env`-ben szerepel.

## 2. Modulonkénti döntés (refaktor alap)

Jelölés: **MEGTART** = újraépül; **TARTALOM** = aibos-public tartalom lesz; **ELHAGY** = nem épül
újra, az URL átirányít (03); **ADMIN** = aibos.space konzolba kerül.

| Régi modul / útvonal | Állapot ma | Döntés | Megjegyzés |
|----------------------|-----------|--------|-----------|
| auth: `/belepes`, `/jelentkezes`, `/elfelejtett-jelszo`, `/jelszo-modositas`, `/profil`, `/verify` | működik, súlyos hibákkal | skillpass.id | URL-ek megmaradnak, skillpass felé visznek (F2) |
| auth: `/jelentkezes/{code}` | működik | MEGTART | referral belépési pont, `a2k_ref` süti |
| auth: `POST /api/create-user` (Basic auth, külső hívó) | működik | MEGTART más formában | M2M végpont, a hívó azonosítandó (Q-06) |
| channel: `/@{handle}` | működik (ismeretlen handle → 500) | MEGTART | partner / tag / csatlakozás változat, adószám NEM publikus |
| myteam: `/csapatom` | működik | MEGTART | rekurzív csapatfa `source_code` alapján |
| invite: `/meghivas` | oldal működik, API törött | MEGTART | meghívó link + másolás esemény |
| affiliate: `/affiliate` + kupon/rendelés | működik, nyitott végpontokkal | MEGTART | WooCommerce olvasás a backendből, kupon-tulajdon explicit tábla |
| discounts: `/kedvezmenyek` | beégetett kuponok + napló | MEGTART | kuponok az admin felől, napló `coupon_redemptions` |
| business: `/business`, `/business-csomag` | működik, IDOR + nyitott import/export | MEGTART | partner profil; vásárlás pay/invoice.aibos.space (P-V0-11) |
| business: export/import/sold_packages/generate_invoice/proforma | nyitott vagy törött | ADMIN | `/business/sold_packages` sok hívást kap (Q-09) |
| business_partners: `/partnereink` | működik (adószámot mutat) | MEGTART | adatok a `partners` táblából, PII nélkül |
| qrcode: `/qrcode`, `/data/qrcodes/{user}/{file}` | működik, IDOR | MEGTART | a QR képek URL-je megmarad (nyomtatott lehet, L-12) |
| share: `/share/{uuid}` | törött (500), nyílt redirect | MEGTART javítva | csak saját domainre irányít |
| aiqna: `/ai-kerdesek-es-valaszok` | működik, stored XSS | MEGTART (Q-10) | válaszolás az aibos-ból |
| ai_maturity_assessment: `/ai-erettsegi-szint-felmeres` | kérdőív megy, mentés törött | MEGTART (Q-10) | 25 kérdés tartalom; pontozás javítása (P-V0-14) |
| support: `/support` | Trello, minden kártyát kiad bárkinek | MEGTART (Q-10) | saját jegy tábla + aibos admin (P-V0-13) |
| users: `/users`, `/api/users` | admin, `password_hash`-t is kiad | ADMIN | aibos `members` modul |
| affiliate: `/newsletter_users`, `/orders-report`, `/fetch-*` | nyitott | ADMIN | aibos `newsletter`, `orders_report` |
| aitools, resources, apps, videos, links, plugins, prompts, sundayprompts, events, meetups, mastermind, pro, csr, gamification (`/pontok`) | statikus tartalom | TARTALOM | aibos-public `pages` / `links` / `offers` |
| pages: jogi oldalak, közösségi link oldalak | statikus tartalom | TARTALOM | ÁSZF, BLÁSZF, adatkezelés, etikai kódex, impresszum, FB/Telegram/Discord/WhatsApp/Viber |
| experts (`/szakertok`), dictionary (`/szotar`) | „feltöltés alatt" | TARTALOM | szótár → aibos `glossary` |
| favorites (`/kedvencek`) | „fejlesztés alatt" | ELHAGY vagy új funkció (Q-10) | menüben szerepel, ezért nem lehet 404 |
| posts/feed, comments, follows, friendships, groups, forums, messages, notifications, files, categories, labels, blogs, news, newsletter, settings, communities, instructors, meetup | üres sablon, többnek hitelesítés nélküli API-ja van | ELHAGY | URL → legközelebbi élő oldal; API → 410 |
| seo: `/robots.txt`, `/sitemap.xml`, `/favicon.ico`, `/` | sitemap generálás törött, `/` → `/belepes` | MEGTART újraírva | `/` valódi nyitóoldal lesz |
| errors: 404/500 | működik, de minden anonim kérést 500-ként naplóz | MEGTART újraírva | RFC 7807 + szép hibaoldalak |
| tracker (t.ai2know.it) | nincs valódi rövid link, 91% bot | ELHAGY | host → 301 a főoldalra |
| orders (o.aitoknow.it) | WooCommerce proxy | ELHAGY | a backend olvas közvetlenül |
| auth szolgáltatás (auth.ai2know.it) | üres | ELHAGY | host → 301 (03) |

## 3. Biztonsági megállapítások

### 3.1 Az ÉLŐ rendszert most is érintik (F0 / 4, owner döntés kell)

| # | Megállapítás | Hely |
|---|--------------|------|
| S1 | `backup_server` valószínűleg üres felhasználónévvel és jelszóval is enged (a `.env` nem jut a konténerbe), a 7000-es porton és a `b.aitoknow.it`-n kint van → az óránkénti DB dumpok letölthetők lehetnek. Kódból következtetve, nem tesztelve. | `backup_server/main.go:55`, compose |
| S2 | pgAdmin `SERVER_MODE=False`, a 15432-es host porton kint; a Docker-publikált portok megkerülik az iptables szabályokat. Ugyanez: cAdvisor 8081, Portainer 9000 (docker.sock!). | `docker-compose.yml` |
| S3 | Teljes DB dump (users e-mail + jelszó-hash) és számos `.env` (Mailgun, OpenAI, Számlázz, Stripe, Trello, WooCommerce, JWT, DB) **commitolva** a GitHub repóba. Ha a repo valaha nyilvános volt: minden titok kompromittált. | git, Q-12 |
| S4 | Jelszavak nyílt szövegben a readme-ben és az install.sh-ban (Portainer, Django, Postgres). | `readme.md`, `install.sh` |
| S5 | A `/verify/{token}` URL-ek 10 éves, e-mailt tartalmazó JWT-ket írnak a 500-as logba. | `hu/app/logs/500` |

### 3.2 Alkalmazás hibák (az újraírás megszünteti, a régiben élnek)

- Jogosultság-emelés: `POST /profil` bármely `User` mezőt átír, a `role_id`-t is.
- Tetszőleges fájlírás hitelesítés nélkül: `POST /files/`, `/fetch-coupons`, `/fetch-orders`.
- Hitelesítés nélküli admin funkciók: `/business/import`, `/business/export`, `/orders-report`,
  `/business/sold_packages`, `/api/posts|categories|tags|ratings`, `/api/favorites`, `/labels`.
- Adatszivárgás bármely bejelentkezettnek: `/newsletter_users` (minden e-mail), `/support/cards`
  (minden Trello jegy), díjbekérő PDF IDOR + path traversal, QR fájlok IDOR.
- Fióklopás: az „elfelejtett jelszó" azonnal felülírja bárki jelszavát és e-mailben küldi; a
  jelszavak nyílt szövegben mennek e-mailben és a logba.
- Nyílt redirect és XSS: login `next` (javascript: URL is), share, aiqna stored XSS.
- Nincs CSRF; GA és OneSignal hozzájárulás előtt tölt; két egymással versengő süti banner.

## 4. Ami ma is el van romolva (nem portoljuk „működőként")

`?x@felhasznalo` referral (a middleware nincs regisztrálva), `/@ismeretlen` → 500, share modul,
invite API, AI felmérés mentése, sitemap újragenerálás (4 386 hiba, ma is), `/feed` → `/login`
(nem létezik), labels törlés rekurzió, `/business/export` NameError, `POST /profil` mindig 500,
pontrendszer csak kijelzés, `approved` soha nem érvényesül.

## 5. Forgalom (a redirect térkép alapja)

A Caddy access logok üresek a mentésben (root jogosultság miatt nem másolódtak – Q-15). Helyettük
a hu alkalmazás minden anonim kérést „Token not found" 500-ként naplózott (3,4 M sor,
2024-08 → 2026-10); ebből, bot mintákat kiszűrve:

- hu: `/belepes` 1,31 M és `/` 1,27 M (a `/` → `/belepes` páros), `/check-username` 23 k,
  `/aiqna/all-questions` 16 k, `/jelentkezes` 9 k, `/aitools` 7,7 k, `/vasarnapestipromptolas` 5 k,
  `/jelentkezes/vasarnapestipromptolas` 3,1 k, `/jelentkezes/mkik` 2,7 k, `/business/sold_packages`
  2,3 k, … `/csr` 905, `/@ranita` 293 … (teljes lista a 03-ban).
- en: 63,8 k kérés, 306 különböző útvonal, ugyanazok a magyar URL-ek.
- 404 de érdemes kezelni: `/feed/` 206 k (régi RSS olvasók), `/login` 731, `/promtpok` 610,
  `/register` 453, `/read-document` 645, `/en/` 232, `apple-touch-icon*.png` ~8 k, OneSignal SW ~1 k.

## 6. Mi értékes és viendő tovább

1. **5 083 tag és a 142 forrás-kód szerinti attribúció** (partner riportok alapja).
2. **Referral belépési pontok**: `/jelentkezes/{kód}` (több tucat partnerkód élő forgalommal) és `/@{handle}`.
3. **Tartalom**: jogi oldalak (Everengine Kft. adatai), 25 kérdéses AI felmérés, ~78 cheat sheet
   PDF/PNG (`/static/uploads`), közösségi linkek, partner- és csomagoldalak.
4. **Partner cégadatok** (5–6 sor) és a csapatfa logika.
5. **Az URL-készlet** – nyomtatott anyagokban, közösségi csoportokban, e-mailekben él.

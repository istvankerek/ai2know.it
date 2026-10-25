# F6 – Átirányítás és követés

> Cél: a 03 térkép megvalósítása – régi hostok és útvonalak követett 301-gyel, 100%-os
> regressziós lefedettséggel, kiesésbiztosan.
> Routing: STANDARD (+ CRITICAL review a Caddy éles konfigra). Skillek: `caddy-gateway`,
> `cloudflare-cdn`, `integration-test`, `e2e-test`.

## 1. Caddy (`infrastructure/caddy/Caddyfile`)

- [ ] `ai2know.it`: `web` (Next.js) alapértelmezés; `/static/uploads/*` és `/data/qrcodes/*`
      MinIO-ból; `/api/*` a backend felé csak belső használatra (a böngésző a BFF-en át jön);
      security headerek, `encode zstd gzip`.
- [ ] `www.ai2know.it` → apex.
- [ ] Régi hostok blokkja (`hu.`, `en.`, `auth.`, `t.`, `support.`, `api.`, `app.`, `cdn.`,
      `portal.`, `sync.`, `test.`, `forum.`): `reverse_proxy backend:8080/_legacy` 200 ms
      timeouttal, `handle_errors` ágban statikus `redir` ugyanarra a célra.
- [ ] TLS: Cloudflare proxy mögött origin tanúsítvány vagy ACME DNS challenge (a régi hostoknak
      is kell érvényes tanúsítvány a redirecthez).
- [ ] Rate limit a `/_legacy` útvonalra (bot áradat: a régi forgalom 90%-a bot).

## 2. Redirector (`a2k-tracking`, backend)

- [ ] `GET|HEAD|POST… /_legacy`: a `Host` és az eredeti URI alapján célt számol (03 / 2 tábla,
      konfigurációból, nem kódba égetve), `redirect_hits` sort ír aszinkron (csatorna → batch insert,
      a válasz nem vár a DB-re), 301/308-at ad.
- [ ] `en.ai2know.it` esetén `Set-Cookie: a2k_locale_hint=en; Domain=ai2know.it; Path=/; Max-Age=15552000; Secure; SameSite=Lax`.
- [ ] Bot jelzés (UA lista + viselkedés: `.env`, `wp-admin`, `.git` minták) – a bot találat külön
      számlálóba megy, nem a riportba.
- [ ] Metrikák: `a2k_legacy_redirect_total{host,kind,bot}`, `a2k_legacy_redirect_fallback_total`.

## 3. Útvonal szintű átirányítások (apps/web)

- [ ] `next.config` `redirects()` a 03 / 3.3 táblából generálva (egy forrás: `config/legacy-redirects.json`,
      ezt használja a backend és a teszt is).
- [ ] 410 válaszok a 03 / 3.4 listára (route handler, RFC 7807).
- [ ] Ezek is `redirect_hits`-be kerülnek (`kind = path`) a backend esemény végpontján át.

## 4. Riport

- [ ] Admin API `redirects.stats` (F5): régi host / útvonal / hivatkozó szerinti bontás, napi trend,
      „átirányítás után 404" lista (a térkép hiányai), bot arány.

## 5. Regresszió

- [ ] `tests/redirects/legacy-urls.csv` összeállítása (03 / 5) – a forgalmi lista a backup logokból
      helyben aggregálva, PII nélkül.
- [ ] Tesztfuttató: minden sorra `curl -sI` a megadott hosttal (`--resolve`), státusz + `Location`
      ellenőrzés; CI-ban helyi stacken, smoke-ként test és prod környezetben.

## Tesztek

- Unit: célszámítás minden host típusra; query megmarad; `next` paraméter külső domainre → eldobva.
- Integráció: backend leállítva → Caddy fallback ugyanazt a `Location`-t adja.
- Terhelés: 500 kérés/s a `/_legacy`-n, p99 < 50 ms, nincs elveszett hit a batch írásban normál
  terhelésnél.

## Kimenet

- A teljes régi URL-készlet 100%-ban a 03 szerint viselkedik test környezetben, követéssel.

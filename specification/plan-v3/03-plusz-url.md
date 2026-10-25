# 03 – A `+` jelölés: `+curve-neve` mindenhol

## 1. Mit tud

| Hol | Mit ír a felhasználó | Mi történik |
|-----|----------------------|-------------|
| Böngésző címsor | `ai2know.it/+ai-marketing-alapok` | megnyílik a curve |
| Ökoszisztéma bármely oldala | `aibootcamp.hu/+ai-marketing-alapok`, `superskiller.com/+…`, `skillpass.id/+…`, `aibos.club/+…`, `aiagentekagyakorlatban.hu/+…` | 302 → `https://ai2know.it/+ai-marketing-alapok` |
| Szöveg (komment, poszt, curve jegyzet, superskiller lecke) | `nézd meg: +ai-marketing-alapok` | automatikusan link lesz (mint az `@említés`) |
| ai2know kereső | `+ai-mar…` | azonnali ugrás / curve-javaslat |
| Lépés | `ai2know.it/+ai-marketing-alapok/3` | a lejátszó a 3. lépésen nyílik |
| Nyomtatás, QR | `ai2know.it/+ai-marketing-alapok` | rövid, olvasható, mondható |

A `/lc/{slug}` örök 301-alias marad (meglévő hivatkozásokra és olyan helyekre, ahol a `+` gondot
okoz, 4. fejezet). Párja: `@handle` = munkatér vagy személy (`ai2know.it/@aibootcamp`).

## 2. Szabványosság

- RFC 3986: a `+` a path-ban megengedett „sub-delim" karakter, nem kell kódolni. Csak a
  **query stringben** jelent szóközt (`application/x-www-form-urlencoded`) – ezért a slug soha nem
  kerül query-be; a meghívó token (`?k=`) nem tartalmaz `+`-t (base32).
- Előzmény: a Google+ ugyanígy használta (`plus.google.com/+Nev`).
- Ha egy kliens `%2B`-re kódolja (`/%2Bai-marketing`), a szerver 301-gyel a `/+…` alakra normalizál.

## 3. Slug szabályok

- Formátum: `[a-z0-9]+(-[a-z0-9]+)*`, 3–60 karakter, ékezet nélkül (a címből automatikusan:
  „AI marketing alapok" → `ai-marketing-alapok`).
- **Globálisan egyedi** a `handles` táblában (02/4), ugyanabban a névtérben ellenőrizve a `@` handle-ökkel
  az összetévesztés elkerülésére.
- Foglalt szavak: rendszerútvonalak (`admin`, `api`, `lc`, `login`, `csatlakozas` …), márkanevek
  (`aibootcamp`, `skillpass`, `superskiller`, `aibos`, `ai2know` …), sértő szólista.
- **Átnevezés:** a régi slug örökre átirányít (301) és nem adható ki újra (`retired_at`), így a
  kinyomtatott QR-ok nem törnek (L-12).
- **Zárt vagy meghívásos curve:** jogosulatlan látogató **404**-et kap, nem 403-at, így a létezés nem
  szivárog. A meghívó linkkel érkező a belépés után bejut.
- **Squatting ellen:** új fióknál a rövid (≤ 5 karakteres) slug szerkesztői jóváhagyáshoz kötött;
  kihasználatlan, nyilvános tartalom nélküli slug 180 nap után felszabadítható (bejelentéssel).

## 4. Ismert kockázatok és teszt

| Kockázat | Kezelés |
|----------|---------|
| Egyes linkfelismerők a `+`-nál megszakíthatják a linket | smoke lista: Gmail, Outlook, WhatsApp, Messenger, Viber, Slack, Teams, LinkedIn, Facebook, X, iOS/Android SMS; ahol tör, ott a megosztó gomb a `/lc/{slug}` alakot adja |
| Proxy / WAF a `+`-t szóközzé alakítja | Caddy + Cloudflare szabályteszt F2-ben; a backend a szóközt is a `+` alakra normalizálja |
| A szöveges `+szó` véletlen egyezés (pl. „+3 pont") | csak létező, nyilvános vagy a néző számára elérhető slug lesz link; számmal kezdődő nem |

## 5. Megvalósítás

- **ai2know web (Next.js):** a middleware a `/+{slug}[/{n}]` alakot belső útvonalra írja át
  (`/_curve/{slug}`); a kanonikus URL a `/+{slug}`.
- **Feloldó API:** `GET /api/v1/resolve/plus/{slug}` → `{type: "curve", code, canonical_url}` vagy
  404 (a hívó jogosultsága szerint). Ezt használja a többi oldal szöveges linkesítője is.
- **Ökoszisztéma (Caddy / aio.broker):** egyetlen közös szabály minden domainen:

  ```caddyfile
  @plus path_regexp plus ^/\+([a-z0-9][a-z0-9-]{1,58}[a-z0-9])(/[0-9]{1,3})?/?$
  redir @plus https://ai2know.it/+{re.plus.1}{re.plus.2} 302
  ```

  302 (nem 301), mert a cél később változhat (pl. más típusok is kaphatnak `+` nevet). Ütközés-ellenőrzés:
  a superskiller és a skillpass útvonalai között nincs `+` kezdetű (felderítve 2026-10-20). Minden
  domain gazdája jóváhagyja (Q-V3-05).
- **Szöveges linkesítő:** kis közös JS/Rust függvény (`plus-linkify`), regex
  `(?<![\w/])\+([a-z][a-z0-9-]{2,59})`, batch feloldás a feloldó API-n, cache 10 perc.
  A superskiller, az aibos.club cikkek és a skillpass bio is használhatja.

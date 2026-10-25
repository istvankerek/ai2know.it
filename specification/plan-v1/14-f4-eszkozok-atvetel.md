# F4 – Eszközök átvétele és interaktív modulok

> Routing: STANDARD. Skillek: `frontend-design`, `e2e-test`, `caddy-gateway`.

## 1. Agent eszköztár (aiagentek → ai2know)

- [ ] 7 pillér `pillar` elemként (03/2), pilléroldal: összefoglaló, szakaszok, ellenőrzőlista,
      buktatók, a pillérhez tartozó könyvtárelemek beágyazott keresője.
- [ ] Teaser helyett (aiagentek `TeaserGate`) nyilvános tartalom; a könyv-olvasói előny belépve:
      kedvencek, gyűjtemények, értékelés, kérés (P-V1-04).

## 2. Interaktív modulok (`/interaktiv/{slug}`)

- [ ] LLM működése (`/interaktiv/llm-mukodes`) – komponens átvétel, licencellenőrzés.
- [ ] Doodle AI (`/interaktiv/doodle-ai`) – böngészőben futó neurális háló.
- [ ] QR generátor (`/qr-generator`, régi `/qrcode`) – kliens oldali generálás (PNG/SVG/PDF),
      belépve mentés és lista; a régi `/data/qrcodes/{user}/{fájl}` képek változatlan URL-en
      maradnak (nyomtatott lehet).
- [ ] AI érettségi felmérés (`/felmeres`, régi `/ai-erettsegi-szint-felmeres`) – 25 kérdés,
      javított pontozás, eredmény + ajánlott tudáselemek (pl. kezdőknek promptolási alapok);
      belépve mentés.

## 3. Átirányítások az aiagentek hostról (03/2.1)

- [ ] Redirect-tábla és regressziós lista a könyv nyomtatott URL-jeiből.
- [ ] Az aiagentek repóban végrehajtott változtatás (saját plan, owner jóváhagyás): `next.config`
      redirects + követés; az ott maradó „Eszközök" menü az ai2know.it-re mutat.
- [ ] Sorrend: ai2know.it cél él (200) → redirect bekapcsol → regresszió 100%.

## Tesztek

- Minden aiagentek tools URL → 301 → 200 a helyes elemre (`code` egyezés).
- QR: generált kód dekódolva visszaadja a bemeneti URL-t; nem http(s) → hiba.
- Felmérés: pontozási táblázat golden-tesztje mind a 25 kérdésre.

## Kimenet

- Az eszköztár és az interaktív modulok az ai2know.it-en élnek; az aiagentek redirectek test
  környezetben bizonyítottak.

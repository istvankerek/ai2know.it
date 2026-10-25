# F5 – Integrációk

> Specifikáció: `04-integraciok.md`. Routing: STANDARD (+ CRITICAL review az M2M és webhook
> biztonságra). Skillek: `skillpass-auth`, `skillpass-portal`, `skillpass-app-launcher`,
> `webhook-manager`, `ai-agent-reliability`.

## 1. skillpass.id

- [ ] `trainings:write` push az outbox eseményekből (enrolled / in_progress / completed),
      idempotencia `external_id`-n, újrapróbálás backoff-fal, 409/403 kezelés (m2m referencia).
- [ ] Igazolás oldal mint `certificate_url`.
- [ ] Shell `status_line` / `progress` (aktív curve-ök száma, átlagos haladás).
- [ ] Publikus összesítő végpont curve-önként; „Készítette" megjelenítés a skillpass-on a skillpass
      plan szerint (Q-V2-01).

## 2. superskiller.com

- [ ] Közös contract (`contracts/partner/ai2know-superskiller.yaml`) mindkét repóban.
- [ ] ai2know oldalon: `external` lépés-szolgáltató `superskiller` (objektum-feloldás, hozzáférés-állapot,
      mélylink, pillanatkép-frissítés), aláírt webhook fogadás (lecke elvégezve).
- [ ] superskiller oldalon (az ő plan-jükben): oEmbed/kártya beágyazás, `/tudastar` → ai2know
      tartalom, partner API és webhook.
- [ ] Fogalmi összehangolás a UI-ban („AI skill" / „Kompetencia", „Learning curve" / „Út").

## 3. aiagentek és aibootcamp

- [ ] aiagentek: a könyvtár listák és elemek az ai2know API-ból vagy 301 (nyomtatott URL regresszió).
- [ ] „A könyv eszköztára" curve a könyvaktivációs entitlementtel.
- [ ] aibootcamp: tréning végén curve-vázlat M2M-mel (Q-V2-04).

## 4. Beágyazás mindenhová

- [ ] oEmbed szolgáltató (`/oembed?url=…`), `embed.js` kártya, CSP és `frame-ancestors` szabályok.

## Tesztek

- skillpass mock és test példány: elvégzés → profil-bejegyzés; ismételt push → nincs duplikátum.
- Webhook: hamis aláírás → 401; ismételt esemény → egyszer számít.
- superskiller mock: hozzáférés nélküli lépés „hozzáférés kell" állapotot mutat.

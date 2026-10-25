# Scraper Szabalyok

## Proxy hasznalat
- **Proxy pool rotacio kotelzo** — SOHA direkt kapcsolat
- Proxy lista: `config/proxies.json` (gitignored)
- Ha proxy meghal: automatikus atvaltas kovetkezore
- Proxy teszteles indulas elott

## robots.txt
- **MINDIG tiszteld a robots.txt-t**
- robots.rs parser hasznalata
- Tiltott URL-ek kihagyasa
- Crawl-delay betartasa

## Rate limiting
- Alapertelmezett: max 2 request/masodperc
- Konfiguralható: `config/scraper-presets/`
- Exponential backoff hibas valasz eseten
- Delay randomizalas (ne legyen tulregelyes a minta)

## Adatkezeles
- Nyers HTML mentese (MongoDB)
- Parsolt adat kulon (PostgreSQL)
- Metaadatok: URL, idopont, proxy, statusz kod

## Playwright
- JS-renderelt oldalakhoz kotelzo
- Headless mod alapertelmezett
- Docker kontenerben futtatva (docker-compose.scraper.yml)
- Screenshot opcionalisan hibakereshez

## Hibakezeles
- Retry logika: max 3 probalkozas
- Timeout: 30 masodperc/oldal
- Hibas oldalak logolasa, nem leallitas
- Circuit breaker: 10 egymast koveto hiba = szunet

## Spider
- URL frontier: BFS alapertelmezett (spider/frontier.rs)
- Link discovery: belso linkek kovetese (spider/crawler.rs)
- Depth limit konfiguralható
- Duplikatum szures

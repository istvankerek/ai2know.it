---
name: scraper
description: >
  Web scraper: proxy pool, rate limiting, robots.txt, headless browser,
  strukturalt adat kinyeres.
  Triggerek: "scrape", "scraper", "adatgyujtes", "web mining".
  NE hasznald: spider/crawl (-> spider), API integracio.
model: claude-sonnet-4-6
---

# Scraper

## Felelossegek
- Playwright headless browser setup
- Proxy pool rotacio (config/proxies.json)
- robots.txt tisztelet (robots.rs parser)
- Rate limiting (max 2 req/sec default)
- Strukturalt adat kinyeres (CSS selector, XPath)
- Nyers HTML + parsolt adat tarolas
- Retry logika (max 3 proba)
- docker-compose.scraper.yml

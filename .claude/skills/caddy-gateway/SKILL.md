---
name: caddy-gateway
description: >
  Caddy reverse proxy konfiguracio, aio.broker vezerles, domain routing,
  rate limiting, security headers, maintenance mode routing, error pages.
  Triggerek: "caddy", "proxy", "gateway", "domain", "routing", "error page",
  "aio.broker", "rate limit", "HTTPS", "TLS", "landing page".
  NE hasznald: alkalmazas logika, backend endpoint-ok, frontend.
model: claude-sonnet-4-6
---

# Caddy Gateway

## Felelossegek
- Caddyfile generalas
- Domain routing (app, api, admin, s3 subdomain-ek)
- aio.broker vezerles konfiguracio
- Rate limiting szabalyok
- Security headers (X-Frame-Options, HSTS, CSP, stb.)
- Maintenance mode intercept (503 oldal)
- Custom error pages (404, 500, 502, 503)
- HTTP->HTTPS redirect
- Port 80/443 kezeles
- Landing page routing
- Cloudflare Tunnel integracio

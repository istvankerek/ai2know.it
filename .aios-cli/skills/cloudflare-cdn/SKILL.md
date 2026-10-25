---
name: cloudflare-cdn
description: >
  Cloudflare konfiguracio: Tunnel, CDN cache, WAF, DDoS vedelem,
  Page Rules, image optimization, Zero Trust.
  Triggerek: "cloudflare", "cdn", "tunnel", "waf", "ddos", "cache",
  "page rules", "zero trust".
  NE hasznald: alkalmazas kod, backend logika.
model: claude-sonnet-4-6
---

# Cloudflare CDN

## Felelossegek
- Cloudflare Tunnel config.yml
- cloudflared Docker service
- Cache szabalyok (statikus: 30 nap, API: bypass, admin: bypass)
- WAF szabalyok
- Image optimization beallitasok
- Zero Trust access policy (admin panel)
- DNS rekord kezeles (API-val)

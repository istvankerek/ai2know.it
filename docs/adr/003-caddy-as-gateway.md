# ADR-003: Caddy mint egyetlen gateway

## Allapot
Elfogadva

## Kontextus
Reverse proxy / API gateway megoldast kellett valasztani.

## Dontes
Caddy 2 az egyetlen publikus belepesi pont (gateway).

## Indoklas
- Automatikus HTTPS (ACME/Let's Encrypt)
- Egyszeru konfig (Caddyfile)
- Beepitett rate limiting
- Egyszeru error page kezeles
- Cloudflare Tunnel integracio
- Alacsony memoria es CPU hasznalat
- JSON logging

## Kovetkezmenyek
- Minden kulso forgalom Caddy-n megy keresztul
- Konfig: `infrastructure/caddy/Caddyfile`
- Error pages: `infrastructure/caddy/error-pages/`
- Rate limit, CORS, header-ok: Caddyfile-ban
- Belso szolgaltatasok NEM erhetok el kozvetlenul

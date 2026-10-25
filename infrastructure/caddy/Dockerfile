# Caddy egyedi build (ha extra plugin-ek kellenek)
FROM caddy:2-builder AS builder
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM caddy:2-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY error-pages /srv/error-pages
EXPOSE 80 443

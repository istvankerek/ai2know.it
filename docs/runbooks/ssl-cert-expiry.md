# SSL Tanusitvany Lejarat – Runbook

## Tunet
SSL tanusitvany < 3 napon belul lejar. Alert ertesites erkezett.

## Sulyossag
🟡 Magas (🔴 Kritikus ha mar lejart)

## Azonnali teendok (elso 5 perc)
1. Ellenorizd a tanusitvany lejaratat: `echo | openssl s_client -connect domain:443 2>/dev/null | openssl x509 -noout -dates`
2. Ha Cloudflare: ellenorizd a Cloudflare dashboardot
3. Ha Caddy: ellenorizd a Caddy ACME allapotat

## Diagnozis
- Cloudflare dashboard: SSL/TLS szekció
- Caddy logok: `docker compose logs caddy | grep -i "cert\|tls\|acme"`
- DNS beallitasok: `dig +short domain`

## Megoldas

### Cloudflare kezeli az SSL-t
```bash
# Cloudflare dashboard -> SSL/TLS -> Edge Certificates
# Ha Universal SSL: automatikus megujitas
# Ha Custom: toltsd fel az uj tanusitvanyt
```

### Caddy kezeli az SSL-t (ACME/Let's Encrypt)
```bash
# Caddy ujrainditas (ujra megprobalja az ACME challenge-t)
docker compose restart caddy

# Caddy log ellenorzes
docker compose logs caddy --tail=50

# Ha ACME hiba: ellenorizd a DNS-t es a port 80/443 eleretoseget
```

### Manualis tanusitvany csere
```bash
# 1. Uj tanusitvany generalas/beszerzes
# 2. Tanusitvany fajlok frissitese
# 3. Caddy/Cloudflare ujrainditas
```

## Megelozes
- Alert 14 nappal lejarat elott (alerts/backup-ssl.yml)
- Automatikus megujitas (Cloudflare/Caddy ACME)
- Rendszeres tanusitvany allapot ellenorzes

## Eszkalacio
Ha mar lejart es nem sikerul megujitani: tech lead + DevOps azonnali ertesitese

# Everengine Okoszisztema

## Adatreteg definiciok

> Szerepkor kanon (v8.0): `.aios-cli/core/ecosystem.md`

### SkillPass.ID (skillpass.id)
- **Rol:** Egyetlen OAuth2/OIDC identity provider (Ory Kratos + Hydra), profil es ugyfelportal
- **Kapcsolat:** Minden partner alkalmazas SkillPass.ID-n keresztul hitelesit (BFF, httpOnly cookie)
- **Fontos:** NE implementalj sajat autentikaciot, profil oldalt!
- **Protokoll:** OAuth2 Authorization Code Flow + PKCE, M2M client_credentials
- **Skill:** `skillpass-auth`, `skillpass-portal`

### aibos.space
- **Rol:** Egyetlen admin/management konzol + kozos szolgaltatasok (pay/invoice/delivery)
- **Auth:** sajat operatori auth (aibos-auth, TOTP) – az egyetlen kivetel
- **Kapcsolat:** partner projekt contract-first admin API-t ad (skill: `aibos-admin-contract`)

### aio.broker
- **Rol:** Caddy reverse proxy konfiguracio
- **Funkcio:** Domain routing, rate limiting, error pages
- **Konfig:** infrastructure/caddy/Caddyfile

### Hetzner S3
- **Rol:** Offsite backup tarolas (WORM)
- **Fontos:** Write-only! NINCS delete method a kodban!
- **Szabaly:** 3-2-1 backup strategia

### MinIO
- **Rol:** Lokalis S3-kompatibilis fajl tarolas
- **Hasznalat:** Feltoltott fajlok, kepek, dokumentumok
- **Hozzaferes:** Presigned URL-ek

### Qdrant
- **Rol:** Vektor adatbazis szemantikus kerseshez
- **Hasznalat:** RAG, AI chat kontextus, intelligens kereses

### NATS JetStream
- **Rol:** Uzenet sor a worker-ekhez
- **Worker tipusok:** email, notification, scraper, spider, backup, analytics

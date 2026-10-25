# Rendszer Architektura

## Attekintes

```
                    ┌─────────────┐
                    │ Cloudflare  │
                    │ Tunnel+WAF  │
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │    Caddy    │
                    │  (Gateway)  │
                    └──┬───┬───┬──┘
                       │   │   │
              ┌────────┘   │   └────────┐
              │            │            │
        ┌─────┴─────┐ ┌───┴───┐ ┌──────┴──────┐
        │ Frontend  │ │ Admin │ │   Backend   │
        │ Vite+RR7  │ │ Vite  │ │  Rust/Axum  │
        └───────────┘ └───────┘ └──┬───┬───┬──┘
                                   │   │   │
                    ┌──────────────┘   │   └──────────────┐
                    │                  │                   │
              ┌─────┴─────┐    ┌──────┴──────┐    ┌──────┴──────┐
              │ PostgreSQL │    │   MongoDB   │    │    Redis    │
              │ (schema/  │    │(unstructured)│    │   (cache)   │
              │  service) │    └─────────────┘    └─────────────┘
              └───────────┘
                                   │
                            ┌──────┴──────┐
                            │    NATS     │
                            │ JetStream   │
                            └──────┬──────┘
                                   │
                            ┌──────┴──────┐
                            │   Workers   │
                            │  (6 tipus)  │
                            └─────────────┘
```

## Szolgaltatasok

| Szolgaltatas | Technologia | Port | Leiras |
|-------------|-------------|------|--------|
| Frontend | Vite + React Router v7 | 3000 | Publikus weboldal |
| Admin | Vite + React Router v7 | 3001 | Admin panel |
| Backend | Rust/Axum | 8080 | REST API |
| AI Chat | - | 8081 | AI chat szolgaltatas |
| PostgreSQL | PostgreSQL 16 | 5432 | Fo adatbazis |
| MongoDB | MongoDB 7 | 27017 | Dokumentum tarolas |
| Redis | Redis 7 | 6379 | Cache |
| NATS | NATS JetStream | 4222 | Uzenet sor |
| MinIO | MinIO | 9000 | Fajl tarolas |
| Qdrant | Qdrant | 6333 | Vektor adatbazis |
| Caddy | Caddy 2 | 80/443 | Reverse proxy |

## Feature-based Szervezes

```
apps/backend/src/modules/
├── users/
│   ├── CLAUDE.md              # Modul kontextus
│   ├── create_user/
│   │   ├── endpoint.rs        # CreateUserEndpoint
│   │   ├── dto.rs             # CreateUserDto
│   │   └── service.rs         # CreateUserService
│   ├── get_users/
│   ├── update_user/
│   └── delete_user/
└── products/
    └── ...
```

## Adatbazis Schema

Schema-per-service minta:
- `auth_schema` — felhasznalok, role-ok, session-ok
- `product_schema` — termekek, kategoriak
- `log_schema` — audit trail, activity log
- `notification_schema` — ertesitesek, email naplo

## Dontesek

Lasd: [ADR-ek](adr/) az architekturalis dontesekrol.

---
name: docker-setup
description: >
  Docker Compose konfiguracio, multi-service setup, environment override-ok.
  Triggerek: "docker", "compose", "container", "service", "kornyezet inditas".
  NE hasznald: alkalmazas kod iras, frontend komponensek, tesztek.
model: claude-sonnet-4-6
---

# Docker Setup

## Felelossegek
- docker-compose.yml (base) generalas
- Environment override-ok (local/test/prod)
- Dockerfile-ok minden service-hez
- Makefile parancsok
- Health check konfiguracio
- Volume es network elnevezes (PROJECT_PREFIX)
- docker-compose.workers.yml szetvalasztas
- docker-compose.monitoring.yml szetvalasztas
- docker-compose.scraper.yml szetvalasztas

## Helyes output pelda

```yaml
# docker/docker-compose.yml
version: "3.9"

services:
  postgres:
    image: postgres:16-alpine
    container_name: ${PROJECT_PREFIX:-ee}_postgres
    restart: unless-stopped
    env_file:
      - ../environments/.env.example
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ../infrastructure/postgres/init:/docker-entrypoint-initdb.d:ro
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app_network

  backend:
    build:
      context: ../apps/backend
      dockerfile: Dockerfile
    container_name: ${PROJECT_PREFIX:-ee}_backend
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    env_file:
      - ../environments/.env.example
    networks:
      - app_network

volumes:
  postgres_data:
    name: ${PROJECT_PREFIX:-ee}_postgres_data

networks:
  app_network:
    name: ${PROJECT_PREFIX:-ee}_network
    driver: bridge
```

```yaml
# docker/docker-compose.local.yml — dev override
services:
  backend:
    build:
      target: dev  # multi-stage: dev/prod
    volumes:
      - ../apps/backend/src:/app/src:ro
    command: cargo watch -x run
    ports:
      - "3000:3000"
      - "9229:9229"  # debug port
```

## Helytelen output pelda (NE csinald igy)

```yaml
# ❌ Inline credential a compose YAML-ben (secret .env-bol kell!)
environment:
  POSTGRES_PASSWORD: <plain-text-here>

# ❌ Nincs healthcheck
postgres:
  image: postgres

# ❌ Nincs PROJECT_PREFIX — ugyanazon a gepen ket projekt utkozne
container_name: postgres

# ❌ :latest tag (nem reprodukalhato build)
image: postgres:latest

# ❌ depends_on csak nevvel, health nelkul
depends_on:
  - postgres
```

## Szabalyok
1. Minden service `PROJECT_PREFIX` env valtozot hasznal (nev utkozes ellen)
2. Minden secret `.env` fajlbol (`env_file:` direktiva), SOHA inline a compose-ban
3. Minden image pin-elt verzioval (`postgres:16-alpine`, NEM `:latest`)
4. Healthcheck KOTELEZO minden stateful service-hez (DB, cache, queue)
5. `depends_on` mindig `condition: service_healthy` hasznalattal
6. Volume nev + network nev prefixelve (PROJECT_PREFIX)
7. Dev/prod szetvalasztas: base + override (docker-compose.local.yml)

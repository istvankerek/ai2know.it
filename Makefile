# Everengine Projekt Makefile
# Hasznalat: make <target>

.PHONY: local prod test deploy backup clean monitoring scraper

# --- FEJLESZTES ---

local:
	cd docker && docker compose -f docker-compose.yml -f docker-compose.local.yml up -d

local-down:
	cd docker && docker compose -f docker-compose.yml -f docker-compose.local.yml down

local-logs:
	cd docker && docker compose -f docker-compose.yml -f docker-compose.local.yml logs -f

# --- TESZT ---

test:
	cd docker && docker compose -f docker-compose.yml -f docker-compose.test.yml up -d
	./scripts/test.sh

test-down:
	cd docker && docker compose -f docker-compose.yml -f docker-compose.test.yml down

# --- PRODUKCIO ---

prod:
	cd docker && docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

prod-down:
	cd docker && docker compose -f docker-compose.yml -f docker-compose.prod.yml down

# --- MONITORING ---

monitoring:
	cd docker && docker compose -f docker-compose.monitoring.yml up -d

monitoring-down:
	cd docker && docker compose -f docker-compose.monitoring.yml down

# --- WORKERS ---

workers:
	cd docker && docker compose -f docker-compose.workers.yml up -d

workers-down:
	cd docker && docker compose -f docker-compose.workers.yml down

# --- SCRAPER ---

scraper:
	cd docker && docker compose -f docker-compose.scraper.yml up -d

scraper-down:
	cd docker && docker compose -f docker-compose.scraper.yml down

# --- DEPLOY ---

deploy:
	./scripts/deploy.sh $(ENV)

# --- DB ---

migrate:
	./scripts/migrate.sh

seed:
	./scripts/seed-db.sh

# --- BACKUP ---

backup:
	./scripts/backup-manual.sh

# --- MAINTENANCE ---

maintenance-on:
	@echo "Maintenance mode ON"
	# TODO: Caddy + backend maintenance intercept bekapcsolasa

maintenance-off:
	@echo "Maintenance mode OFF"
	# TODO: Caddy + backend maintenance intercept kikapcsolasa

# --- EGYEB ---

build:
	./scripts/build.sh

lint:
	./scripts/lint.sh

clean:
	cd docker && docker compose down -v --remove-orphans
	@echo "Minden kontenner es volume torolve"

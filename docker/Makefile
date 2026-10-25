# Docker-specifikus make parancsok
.PHONY: up down logs ps

up:
	docker compose -f docker-compose.yml -f docker-compose.local.yml up -d

down:
	docker compose -f docker-compose.yml -f docker-compose.local.yml down

logs:
	docker compose -f docker-compose.yml -f docker-compose.local.yml logs -f

ps:
	docker compose ps

build:
	docker compose build --no-cache

prune:
	docker system prune -f

# Deploy Rollback – Runbook

## Tunet
Friss deploy utan hibas mukodes, 500-as hibak, teljesitmeny romlás.

## Sulyossag
🔴 Kritikus

## Azonnali teendok (elso 5 perc)
1. Ellenorizd a hibat: `docker compose logs --tail=100`
2. Donts: rollback vagy hotfix?
3. Ha rollback: kozvetlen vegrehajtás

## Diagnozis
- Melyik deploy okozta? `git log --oneline -10`
- Grafana: API latency, error rate dashboard
- Loki: alkalmazas logok

## Megoldas

### Rollback az elozo verziora
```bash
# Elozo commit-ra visszaallas
git log --oneline -5
git revert HEAD

# Ujra deploy
make deploy ENV=prod
```

### Docker image rollback
```bash
# Elozo image hasznalata
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --no-build
```

### Adatbazis migracio rollback
```bash
# Ha a migracio okozta
./scripts/migrate.sh rollback
```

## Megelozes
- Canary deploy bevezetes
- Staging kornyezet teszteles prod elott
- Automatikus health check deploy utan

## Eszkalacio
Ha a rollback sem segit: maintenance mode bekapcsolása, tech lead ertesitése

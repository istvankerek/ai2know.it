# Magas CPU – Runbook

## Tunet
CPU hasznalat > 90% tobb mint 5 percig. Alertmanager ertesitest kuld.

## Sulyossag
🟡 Magas

## Azonnali teendok (elso 5 perc)
1. Melyik kontener fogyasztja? `docker stats`
2. Grafana: CPU dashboard ellenorzese
3. Van-e egyideju forgalom novekedes?

## Diagnozis
- `docker stats` — kontenerenkenti CPU
- `docker compose top` — processz lista
- Grafana: System metrikai dashboard
- Ha backend: `docker compose exec backend top`

## Megoldas

### Egyetlen kontener magas CPU
```bash
# Kontener ujrainditas
docker compose restart <service_name>
```

### Worker tulterheltseg
```bash
# Worker szam noveles
docker compose -f docker-compose.workers.yml up --scale worker=4 -d
```

### Adatbazis lassu query
```bash
# Aktualis lekerdezesek
docker compose exec postgres psql -c "SELECT * FROM pg_stat_activity WHERE state = 'active';"
# Lassu query-k
docker compose exec postgres psql -c "SELECT * FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"
```

### Scraper/Spider tulterhelts
```bash
# Rate limit csokkentese
# Kontener leallitas ha szukseges
docker compose -f docker-compose.scraper.yml stop
```

## Megelozes
- Auto-scale szabalyok: infrastructure/autoscale/rules.yml
- Alert kuszob finomhangolasa: alerts/cpu-memory.yml
- Query optimalizalas rendszeresen

## Eszkalacio
Ha 30 percen belul nem normalizalodik: tech lead ertesitese

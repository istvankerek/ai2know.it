# Adatbazis Helyreallitas – Runbook

## Tunet
PostgreSQL vagy MongoDB nem elerheto, alkalmazas 500-as hibakat ad.

## Sulyossag
🔴 Kritikus

## Azonnali teendok (elso 5 perc)
1. Ellenorizd a kontener allapotat: `docker compose ps`
2. Nezd meg a DB logokat: `docker compose logs postgres` / `docker compose logs mongodb`
3. Ellenorizd a disk helyet: `df -h`

## Diagnozis
- Grafana dashboard: Database metrikai
- Loki: `{container="postgres"} |= "error"`
- Kapcsolat teszt: `docker compose exec postgres pg_isready`

## Megoldas

### PostgreSQL nem indul
```bash
# Kontener ujrainditasa
docker compose restart postgres

# Ha korrupt: backup-bol visszaallitas
./scripts/backup-manual.sh restore latest
```

### MongoDB nem indul
```bash
docker compose restart mongodb

# Repair
docker compose exec mongodb mongod --repair
```

### Disk tele
```bash
# Regi logok torlese
docker system prune -f
# Archivalas
./scripts/backup-manual.sh
```

## Megelozes
- Disk alert: 80%-nal figyelmeztetés (alerts/disk.yml)
- Automatikus backup: naponta
- Connection pool monitoring

## Eszkalacio
Ha 15 percen belul nem sikerul: ertesitsd a tech lead-et

# Backup Hiba – Runbook

## Tunet
Utolso sikeres backup > 24 oraja. Alert ertesites erkezett.

## Sulyossag
🟡 Magas

## Azonnali teendok (elso 5 perc)
1. Manualis backup inditas: `./scripts/backup-manual.sh`
2. Ellenorizd a backup logokat
3. Ellenorizd a Hetzner S3 kapcsolatot

## Diagnozis
- Backup log ellenorzes
- Hetzner S3 elerheto? `curl -I $HETZNER_S3_ENDPOINT`
- Disk hely: `df -h`
- Docker kontener allapot: `docker compose ps`

## Megoldas

### Hetzner S3 nem elerheto
```bash
# Halozat ellenorzes
ping $HETZNER_S3_ENDPOINT
# Credentials ellenorzes
# Ha szukseges: lokalis backup MinIO-ba
```

### Disk tele
```bash
# Regi lokalis backup-ok torlese
# Docker cleanup
docker system prune -f
```

### Manualis backup
```bash
./scripts/backup-manual.sh
```

## Megelozes
- Napi automatikus backup
- Heti backup teszt (restore teszteles)
- Disk hasznalat monitoring (alerts/backup-ssl.yml)
- 3-2-1 szabaly: 3 masolat, 2 mediumon, 1 offsite

## Eszkalacio
Ha 48 oran belul nem sikerul backup: tech lead ertesitese

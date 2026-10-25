# Worker Queue Elakadas – Runbook

## Tunet
NATS JetStream queue > 10K pending uzenet. Worker-ek nem dolgozzak fel.

## Sulyossag
🟡 Magas

## Azonnali teendok (elso 5 perc)
1. Queue allapot: `docker compose exec nats nats stream ls`
2. Worker kontener allapot: `docker compose -f docker-compose.workers.yml ps`
3. Worker logok: `docker compose -f docker-compose.workers.yml logs --tail=50`

## Diagnozis
- Grafana: Workers dashboard (queue depth, processing time)
- Melyik queue telitodott?
- Worker hiba logok (Loki)
- Memory/CPU a worker kontenereken

## Megoldas

### Worker leall
```bash
# Worker ujrainditas
docker compose -f docker-compose.workers.yml restart

# Tobb worker inditas
docker compose -f docker-compose.workers.yml up --scale worker=6 -d
```

### Queue tul nagy
```bash
# Dead letter queue ellenorzes
docker compose exec nats nats stream info <stream_name>

# Ha szukseges: regi uzenetek torlese (ovatosan!)
# docker compose exec nats nats stream purge <stream_name> --keep=1000
```

### Specialis worker tipus hiba
```bash
# Specialis worker ujrainditas
docker compose -f docker-compose.workers.yml restart <worker_type>
```

## Megelozes
- Auto-scale szabalyok a worker-ekre (infrastructure/autoscale/rules.yml)
- Queue depth alert: alerts/queue.yml
- Dead letter queue monitoring
- Worker health check endpoint

## Eszkalacio
Ha 1 oran belul nem csokkenn a queue: tech lead ertesitese

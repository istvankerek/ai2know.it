# Chaos Drill – Runbook

## Mikor fut
- Staging: napi 03:00 UTC (random scenario)
- Prod: pentek 09:00 UTC (monitoring aktiv idoszakban)

## Pre-check (5 perc ELOTTE)
1. Slack #ops csatornan: "Chaos drill starting in 5 min"
2. On-call engineer ebren es elerheto
3. Rollback kill-switch elerheto: `make chaos-abort`

## Scenario futtatas
1. Chaos-mesh pod injekcio (infrastructure/chaos/scenarios/)
2. 5-10 perc megfigyeles Grafana-n
3. Automatikus recovery VAGY manualis beavatkozas
4. Post-drill: SLI/SLO erintett? → postmortem

## Scenario lista
| Scenario | Target | Elvaras |
|----------|--------|---------|
| database-down | PG primary | Standby failover < 30s |
| network-partition | Worker ↔ NATS | Ujracsatlakozas < 10s |
| pod-kill-random | Worker | Restart < 15s |
| latency-injection | API → DB +500ms | P95 < 1s |
| cpu-stress | Backend 95% | Graceful degradation |
| disk-fill | MinIO 90% | Alert + cleanup |
| dns-failure | Cloudflare DNS | Cached response |
| memory-leak-sim | Backend +100MB/h | OOM kill + restart |

## Post-drill
- Minden drill utan → `docs/postmortems/chaos-YYYYMMDD.md`
- Ha recovery > RTO (4 ora) → runbook frissites
- Tanulsagok → `tasks/lessons.md`

## Eszkalacios lancok
1. On-call engineer (5 perc)
2. Tech lead (15 perc)
3. CTO (30 perc, prod incident eseten)

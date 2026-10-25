---
name: monitoring-setup
description: >
  Prometheus, Grafana, Loki, Jaeger, Alertmanager konfiguracio.
  Node-exporter, cAdvisor, DB exporterek, alert szabalyok.
  Triggerek: "monitoring", "prometheus", "grafana", "alert", "dashboard",
  "metrika", "log", "trace", "exporter".
  NE hasznald: alkalmazas kod, business logika, frontend.
model: claude-sonnet-4-6
---

# Monitoring Setup

## Felelossegek
- Prometheus scrape config (minden service-re)
- Grafana dashboard JSON-ok (10 dashboard)
- Alertmanager routing (Telegram critical, Slack warning)
- Alert szabalyok (CPU, RAM, disk, DB, queue, AI cost, backup, SSL)
- Node-exporter, cAdvisor, pg-exporter, redis-exporter, mongo-exporter, nats-exporter
- Loki log aggregacio
- Jaeger trace gyujtes
- docker-compose.monitoring.yml

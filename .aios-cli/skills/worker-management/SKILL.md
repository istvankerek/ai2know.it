---
name: worker-management
description: >
  NATS JetStream worker queue-k, worker tipusok, auto-scale szabalyok,
  concurrency kezeles, koltseg limitek.
  Triggerek: "worker", "queue", "job", "background task", "auto-scale",
  "concurrency", "nats".
  NE hasznald: szinkron API endpoint-ok, frontend, UI komponensek.
model: claude-sonnet-4-6
---

# Worker Management

## Felelossegek
- Worker tipusok (default, ai-tasks, backup, email, scraper, spider)
- NATS JetStream queue konfiguracio
- Auto-scale szabalyok (queue depth alapu)
- Concurrency beallitasok worker tipusonkent
- AI worker koltseg limit ($50/ora)
- Worker health metrikak (Prometheus)
- docker-compose.workers.yml
- Dockerfile.worker

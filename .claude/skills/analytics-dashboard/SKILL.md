---
name: analytics-dashboard
description: >
  Szerver es worker analitika dashboard: CPU, RAM, disk, halozat,
  container stats, queue melyseg, API latency, AI koltseg.
  Triggerek: "analytics", "analitika", "szerver statisztika",
  "worker dashboard", "rendszer attekintes".
  NE hasznald: uzleti KPI (-> dashboard-widgets), monitoring alertek.
model: claude-sonnet-4-6
---

# Analytics Dashboard

## Felelossegek
- /admin/analytics/system – szerver metrikak (Prometheus lekerdezes)
- /admin/analytics/workers – queue depth, processing time, failures
- /admin/analytics/api – endpoint latency, error rate, throughput
- /admin/analytics/ai-cost – AI hivasok, token hasznalat, koltseg
- Chart-ok: recharts (Simple), AG Grid Charts (Advanced)
- Idoszak szuro: 1h, 24h, 7d, 30d, custom range
- Auto-refresh: 30 masodpercenkent

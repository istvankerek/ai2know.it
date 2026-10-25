# AI Agent Observability — OpenLogs integracio

> **Kapcsolodo skill:** `monitoring-setup`
> **Forras:** `specification/everengine-v2.3.4-patch-mcp-observability.md` §4

## Jelenlegi megoldasunk

A skeleton-ben mar megvannak az alap AI monitoring eszkozok:

| Eszkoz | Fajl | Cel |
|--------|------|-----|
| Prompt log | `.claude/prompt-log/` | Git verzionalt session naplok |
| `/cost` command | Claude Code built-in | Session koltseg monitorozas |
| Grafana AI cost dashboard | `infrastructure/monitoring/grafana/dashboards/ai-cost.json` | Havi koltseg trend |
| AI cost alert | `infrastructure/monitoring/alerts/ai-cost.yml` | Budget tullepes figyelmeztetes |

## Hatar: mit nem latunk

- **Tool call szintu trace** — melyik tool-t hivta, mennyi ideig tartott
- **Prompt → response chain** — a teljes interakcio lancolata
- **Anomalia detektalas** — szokatlanul draga session
- **Modell donteshoz adatot** — miert Opus-t valasztotta (vagy nem)

## OpenLogs (openlogs.dev) — kiegeszito platform

Az OpenLogs egy observability platform kimondottan AI agentekhez:

- Strukturalt AI agent trace-ek (OpenTelemetry kompatibilis)
- Tool call vizualizacio (timeline, duration, cost per tool)
- Prompt → response chain nyomkovetes
- Koltseg breakdown tool call szinten
- Anomalia detektalas (szokatlanul draga session-ok)

## Integracio a SessionEnd hook-ba

Ha bevezetjuk, a `.claude/hooks/save-prompt-log.sh` kiegeszul:

```bash
# save-prompt-log.sh vegere:

# OpenLogs export (opcionalis)
if [ -n "${OPENLOGS_API_KEY:-}" ]; then
  SESSION_ID=$(echo "$json" | jq -r '.session_id // empty')
  curl -sS -X POST "https://api.openlogs.dev/v1/sessions" \
    -H "Authorization: Bearer ${OPENLOGS_API_KEY}" \
    -H "Content-Type: application/json" \
    -d @.claude/prompt-log/session_${SESSION_ID}.json \
    || echo "OpenLogs export failed (nem blokkol)"
fi
```

## Mikor erdemes bevezetni

| Feltetel | Bevezetes? |
|----------|------------|
| AI Chat admin production-ben fut | ✅ Igen |
| AI koltseg > $500/ho | ✅ Igen |
| autodream skill nem eleg a minta-felismereshez | ✅ Igen |
| Hobby projekt, 1 fejleszto | ❌ Tulzas |
| Egyszeru CRUD app, minimalis AI | ❌ Tulzas |
| Lokalis dev only | ❌ Tulzas |

## Alternativa: saját dashboard

Ha nem akarsz kulso szolgaltatast:
- A `prompt-log/*.json` fajlokat egy cron job parsolja
- Prometheus exporter kesziti a metrikakat
- Grafana dashboard mutatja (AI cost dashboard bovithető)

Ez 1-2 nap munka, de teljesen self-hosted es nincs 3rd party adatszivargas.

## Biztonsagi megjegyzes

Az OpenLogs CLOUD szolgaltatas — a prompt-jaid es a kod kontextusod az OpenLogs szerverein megy at. Ha **erzekeny kodon** dolgozol (pl. belso rendszerek, uzletileg erzekeny logika), hasznald a self-hosted alternativat.

## Kapcsolodo

- `autodream` skill — projekt memoria rendrakas (az AI observability data-ja feldolgozhato)
- `ai-chat-admin` skill — AI Chat admin (ott nagy szerepe lehet)
- v2.3.4 spec §4

# CTO Guide

## Attekintes
- Tech stack: Vite + React Router v7 + Rust/Axum + PostgreSQL
- Architektura: Feature-based, Docker, mikroszolgaltatas-keszito
- Biztonsag: 4 szintu guardrails (L0-L3)
- Koltseg: ~$6/fejleszto/nap Claude Code hasznalat

## Fontos metrikai
- Grafana dashboard: infrastructure/monitoring/grafana/dashboards/
- AI koltseg: analytics/ai-cost oldal az admin panelen
- Alert-ek: infrastructure/monitoring/alerts/

## Strategiai dontesek
- ADR-ek: docs/adr/ — minden nagy dontes dokumentalva
- Okoszisztema: docs/ECOSYSTEM.md
- Architektura: docs/architecture.md

## Koltseg optimalizalas
| Modell | Hasznalat | Koltseg |
|--------|-----------|---------|
| Haiku | Mechanikus (subagent) | ~$1.25/Mt |
| Sonnet | Fejlesztes (default) | ~$15/Mt |
| Opus | Architektura (jovahagyas) | ~$75/Mt |

## Biztonsag
- L0 BLOCK: secret vedelem, prod DB vedelem
- L1 APPROVE: deploy, migracio, Opus
- Runbooks: docs/runbooks/ (7 incident forgatokonyv)

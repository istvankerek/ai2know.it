# Sentry Kritikus Hiba — Runbook

> **Alert:** `SentryCriticalError`
> **Forras:** [infrastructure/monitoring/alerts/sentry.yml](../../infrastructure/monitoring/alerts/sentry.yml)

## Tunet

Sentry alert: kritikus (`fatal`/`critical`) szintu hiba jelentve prod-bol. A Sentry dashboard mutat legalabb 1 unresolved critical issue-t.

## Sulyossag

🔴 **Kritikus** — azonnali beavatkozas szukseges.

Kiserleti jellemzok:
- Felhasznaloi flow megszakad
- Adat integritas veszelyben lehet
- Lancreakció lehetseges (cascading failure)

## Azonnali teendok

1. **Sentry dashboard megnyitasa:** `https://sentry.io/{ORG}/{PROJECT}/issues/`
2. **Hiba azonositas:**
   - Mi a hiba tipusa (TypeError, ValueError, TimeoutError, stb.)?
   - Mennyi felhasznalot erint (affected users)?
   - Mikor kezdodott (first seen)?
   - Milyen gyakran fordul elo (events/min)?
3. **Impakt becsles:**
   - Ha >100 felhasznalot erint → maintenance mode bekapcsolasa (`make maintenance-on`)
   - Ha <100 felhasznalot → direkt javitas
4. **Notify:**
   - Alertmanager → Telegram/Slack csatorna automatikusan
   - Ha 10 percen belul nem intezkedsz → on-call eszkalacio

## Diagnozis Claude Code-dal

```bash
claude "Nezd meg a Sentry-ben a legutobbi kritikus hibat,
        olvasd el a stack trace-t es javasolj javitast.
        Hasznald a sentry MCP szervert."
```

A Sentry MCP automatikusan lekerdezi az `list_issues`, `get_issue_details` tool-okat.

## Megoldasi lepesek

1. **Reprodukalas lokalban** (ha lehetseges):
   ```bash
   # A stack trace alapjan:
   ./scripts/test.sh unit -- --grep "<fuggveny-nev>"
   ```
2. **Hotfix commit** a feature branch-re:
   ```bash
   git checkout -b hotfix/sentry-<issue-id>
   # javitas
   ./scripts/test.sh
   git commit -m "fix: <leiras> (Sentry #<issue-id>)"
   ```
3. **Deploy prod-ba** (dupla jovahagyas!):
   ```bash
   ./scripts/deploy.sh prod --hotfix
   ```
4. **Sentry resolve:**
   ```bash
   claude "Jeloltsd fel a Sentry #<issue-id>-t resolved-kent a sentry MCP-vel"
   ```

## Megelozes

- Minden kritikus endpoint-ban explicit null check (`unit-test-writer` skill)
- Error boundary-k minden React route-nal (`skeleton-loading` skill)
- Integration teszt a kritikus user flow-ra (`integration-test` skill)
- Security audit negyedevente (`security-audit` skill)
- Pre-deploy checklist futtatasa (CLAUDE.md §Commit elotti checklist)

## Eszkalacio

Ha a hiba 30 percen belul nem megszuntetett:
1. Rollback az utolso stabil deploy-ra (`./scripts/deploy.sh rollback`)
2. CTO / tech lead ertesitese
3. Incident report kezdese a `docs/runbooks/security-incident.md` minta alapjan

## Kapcsolodo dokumentumok

- [deployment-rollback.md](./deployment-rollback.md) — gyors visszaallitas
- [security-incident.md](./security-incident.md) — ha a hiba biztonsagi szivargasra utal
- [../for-roles/for-tech-leads.md](../for-roles/for-tech-leads.md)

# SOC2 Audit Trail

> Minden "kritikus" muvelet naplozva, 7 ev retention.

## Naplozott muveletek
| Muvelet | Trigger | Tarolas |
|---------|---------|---------|
| Admin login / logout | Auth middleware | ClickHouse + S3 WORM |
| Permission change | RBAC middleware | ClickHouse + S3 WORM |
| Secret rotation | API key service | ClickHouse + S3 WORM |
| Prod deploy | CI/CD pipeline | ClickHouse + S3 WORM |
| DB migration | Migration runner | ClickHouse + S3 WORM |
| User data access | Activity log middleware | ClickHouse + S3 WORM |
| API key create / revoke | API key service | ClickHouse + S3 WORM |
| Backup restore | Backup service | ClickHouse + S3 WORM |
| AI dontes (prompt + response) | AI chat middleware | ClickHouse + S3 WORM |

## Tarolas
- **Real-time:** ClickHouse (AI audit log schema)
- **Long-term:** Hetzner S3 WORM (7 ev retention)
- **Search:** Qdrant vector embedding (semantic search)

## Hozzaferes
- RBAC: compliance officer only
- Dashboard: Grafana SOC2 panel
- Export: CSV/JSON a compliance officer kerelmere

## Retention
- 7 ev (Object Lock compliance mode)
- Torlodhetetlen (WORM – Write Once Read Many)
- Lifecycle: 90 nap utan → Glacier Deep Archive

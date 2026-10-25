---
name: audit-trail-mandatory
description: >
  Minden create/update/delete muvelet utan log_activity() hivas KOTELEZO.
  Ki, mit, mikor, miert, milyen mezok valtoztak old->new. Auto-write
  PostgreSQL particionalt tablaba (activity_log) + S3 WORM archive 90 nap utan.
  Triggerek: "uj endpoint", "POST", "PUT", "DELETE", "create endpoint",
  "update endpoint", "delete endpoint", "mutacio", "audit trail", "ki valtoztatta".
license: Everengine v7.0
priority: P0
model: claude-haiku-4-5-20251001
related_skills:
  - activity-log
  - logger
  - backup-strategy
related_rules:
  - .claude/rules/module-implementation.md
---

# Audit Trail Mandatory — minden mutacio nyomon kovetese

## Vasszabaly
> **Egyetlen mutacio sem mehet ki audit log nelkul.**
> Create/update/delete utan AZONNAL `log_activity()` (Python) vagy
> `log_activity_fire_and_forget()` (Rust). A logok evekig megorizve.

## Mit nyomon kovetunk

| Mezo | Tartalom |
|------|----------|
| `user_id` | A muveletet vegrehajto felhasznalo (JWT-bol) |
| `action` | `{module}_{verb}` formatum (pl. `tickets_created`) |
| `entity_type` | A modul / table neve |
| `entity_id` | Az erintett rekord ID-ja |
| `details` | Olvashato magyar leiras |
| `data` (opcionalis) | Strukturalt extra (changed fields old/new) |
| `ip_address` | Request IP (header-bol) |
| `user_agent` | Browser / API client |
| `timestamp` | Server-side `NOW()` |

## Implementacio

### Python (FastAPI)
```python
from ..routes.auth import log_activity

@router.post("")
async def create_ticket(
    data: TicketCreate,
    user=require_permission("tickets.create"),
    session=Depends(get_pg_session),
):
    # ... insert logic ...
    new_ticket = await create_in_db(session, data)

    await log_activity(
        user_id=str(user["_id"]),
        action="tickets_created",
        details=f"Ticket letrehozva: #{new_ticket.id} ({new_ticket.title})",
        entity_type="tickets",
        entity_id=str(new_ticket.id),
        data={"title": data.title, "priority": data.priority},
    )

    return new_ticket
```

### Rust (Axum) — fire-and-forget
```rust
async fn create_ticket(...) -> impl IntoResponse {
    let new_ticket = sqlx::query_as!(...).fetch_one(&pool).await?;

    // Fire-and-forget: hiba nem blokkol
    log_activity_fire_and_forget(
        &user_id,
        "tickets_created",
        &format!("Ticket letrehozva: #{} ({})", new_ticket.id, new_ticket.title),
        "tickets",
        &new_ticket.id.to_string(),
    ).await;

    Json(new_ticket)
}
```

### Update — diff tracking
A masodlagos `data` mezobe RAKD a valtozott mezoket old → new formatumban:
```python
changed_fields = {}
if data.priority and data.priority != old.priority:
    changed_fields["priority"] = {"old": old.priority, "new": data.priority}
if data.status and data.status != old.status:
    changed_fields["status"] = {"old": old.status, "new": data.status}

await log_activity(
    user_id=str(user["_id"]),
    action="tickets_updated",
    details=f"Ticket #{id} frissitve: {len(changed_fields)} mezo valtozott",
    entity_type="tickets",
    entity_id=str(id),
    data={"changes": changed_fields},
)
```

### Delete — soft delete
```python
await log_activity(
    user_id=str(user["_id"]),
    action="tickets_deleted",
    details=f"Ticket torolve (soft): #{id}",
    entity_type="tickets",
    entity_id=str(id),
)
```

## Action elnevezesi konvencio

```
{module}_{verb}
```

| Muvelet | Action |
|---------|--------|
| Create | `{module}_created` |
| Update | `{module}_updated` |
| Delete | `{module}_deleted` |
| Assign | `{module}_assigned` |
| Approve | `{module}_approved` |
| Reject | `{module}_rejected` |
| Cancel | `{module}_cancelled` |
| Status change | `{module}_status_changed` |
| File upload | `{module}_attachment_uploaded` |
| Export | `{module}_exported` |

## Adattarolas

### Elsodleges: PostgreSQL particionalt tabla
```sql
CREATE TABLE activity_log (
    id BIGSERIAL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID NOT NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT,
    details TEXT,
    data JSONB,
    ip_address INET,
    user_agent TEXT,
    PRIMARY KEY (id, timestamp)
) PARTITION BY RANGE (timestamp);

-- Havi particiok automatikusan
CREATE INDEX idx_activity_user_id ON activity_log (user_id, timestamp DESC);
CREATE INDEX idx_activity_entity ON activity_log (entity_type, entity_id, timestamp DESC);
CREATE INDEX idx_activity_action ON activity_log (action, timestamp DESC);
```

### Masodlagos: MongoDB collection (Python backend kettos iras)
A `log_activity()` egyszerre ir PostgreSQL-be ES MongoDB `activity_log`
collection-be — redundancia + flexibilitas.

### Hosszu tavu: S3 WORM
90 nap utan automatikus archive Hetzner S3 WORM bucket-be (90 nap retention,
tamper-proof). Lasd: `backup-strategy` skill.

## Olvasas (UI)

### Felhasznaloi profil → activity history
```python
@router.get("/api/admin/users/{id}/activity")
async def user_activity(
    id: str,
    user=require_permission("users.view"),
    session=Depends(get_pg_session),
):
    return await session.execute(text("""
        SELECT * FROM activity_log
        WHERE user_id = :id
        ORDER BY timestamp DESC
        LIMIT 100
    """), {"id": id})
```

### Entity history
```python
@router.get("/api/admin/{module}/{id}/history")
async def entity_history(
    id: str,
    user=require_permission("{module}.view"),
):
    return await session.execute(text("""
        SELECT * FROM activity_log
        WHERE entity_type = :type AND entity_id = :id
        ORDER BY timestamp DESC
    """), {"type": module, "id": id})
```

## Tiltasok

❌ Mutacio audit log nelkul (CRUD endpoint anelkul hogy `log_activity()` hivnank)
❌ User context kihagyasa (mindig kell `user_id`)
❌ Hardkodolt action string (mindig `{module}_{verb}` minta)
❌ Sensitive data (`password`, `api_key`) `data` mezobe (auto-redactalas javasolt)
❌ Activity log torles (csak archive S3-ra, soha nem fizikai delete)

## Hivatkozott
- Sister skill: `activity-log` (technikai middleware impl)
- Sister skill: `backup-strategy` (S3 WORM archive 90 nap utan)
- Rules: `.claude/rules/module-implementation.md` (3. elv: audit trail)
- Tabla schema: `migrations/postgres/*_activity_log.sql`

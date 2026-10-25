---
name: activity-log
description: >
  CRUD tevekenyseg naplo: automatikus middleware, change tracking (old->new),
  particionalt tabla, felhasznalo/IP/user agent, S3 archivalas.
  Triggerek: "activity log", "audit trail", "tevekenyseg naplo",
  "valtozas kovetes", "audit".
  NE hasznald: monitoring (-> monitoring-setup), error log.
model: claude-sonnet-4-6
---

# Activity Log

## Felelossegek
- activity_logs tabla (havi particiok)
- Middleware: automatikus logolas minden CRUD muveletrol
- Change tracking: { field: { old: X, new: Y } } JSONB
- Felhasznalo azonositas (user_id, IP, user agent)
- Hetzner S3 archivalas (write-only, no edit, no delete!)
- Admin UI: /admin/activity-log (szures, kereses, export)
- Retention policy (online: 90 nap, S3: korlatlan)

## Helyes output pelda

```sql
-- migrations/postgres/20260412_create_activity_logs.sql
BEGIN;

CREATE TABLE log_schema.activity_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL,
    module      TEXT NOT NULL,      -- pl. "users"
    action      TEXT NOT NULL,      -- "create" | "update" | "delete" | "view"
    entity_id   UUID,
    changes     JSONB,              -- { "email": { "old": "a@b.hu", "new": "c@d.hu" } }
    ip_address  INET NOT NULL,
    user_agent  TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
) PARTITION BY RANGE (created_at);

-- Havi particiok (a cron job-ok automatikusan hoznak letre uj particiokat)
CREATE TABLE log_schema.activity_logs_2026_04
    PARTITION OF log_schema.activity_logs
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');

CREATE INDEX idx_activity_logs_user_id ON log_schema.activity_logs(user_id);
CREATE INDEX idx_activity_logs_module_action ON log_schema.activity_logs(module, action);
CREATE INDEX idx_activity_logs_created_at ON log_schema.activity_logs(created_at DESC);

COMMIT;
```

```rust
// apps/backend/src/middleware/activity_log.rs
use axum::{
    extract::{Extension, State},
    http::Request,
    middleware::Next,
    response::Response,
};
use serde_json::Value;

use crate::middleware::auth::SkillpassClaims;

/// Automatikus CRUD muvelet log middleware.
/// Minden vedett endpoint utan elmenti a muveletet a log_schema.activity_logs tablaba.
pub async fn log_activity<B>(
    State(state): State<AppState>,
    Extension(claims): Extension<SkillpassClaims>,
    req: Request<B>,
    next: Next<B>,
) -> Response {
    let method = req.method().clone();
    let path = req.uri().path().to_string();
    let ip = extract_ip(&req);
    let user_agent = extract_user_agent(&req);

    let response = next.run(req).await;

    // Csak sikeres mutacioknal logolunk (2xx, es nem GET)
    if response.status().is_success() && method != http::Method::GET {
        let (module, action) = parse_route(&path);
        let _ = sqlx::query!(
            r#"
            INSERT INTO log_schema.activity_logs
                (user_id, module, action, ip_address, user_agent)
            VALUES ($1, $2, $3, $4, $5)
            "#,
            claims.sub.parse::<uuid::Uuid>().ok(),
            module,
            action,
            ip,
            user_agent,
        )
        .execute(&state.db_pool)
        .await;
    }

    response
}

/// Change tracking helper — osszehasonlitja a regi es uj entitast,
/// es csak a valtozott mezoket adja vissza JSONB formatumban.
pub fn diff_changes<T: serde::Serialize>(old: &T, new: &T) -> Value {
    let old_json = serde_json::to_value(old).unwrap_or(Value::Null);
    let new_json = serde_json::to_value(new).unwrap_or(Value::Null);
    // ... mezo-szintu osszehasonlitas
    build_diff(&old_json, &new_json)
}
```

## Helytelen output pelda (NE csinald igy)

```rust
// ❌ Kezi logolas minden endpoint-ban (felejtes kockazata)
pub async fn create_user_endpoint(...) {
    create_user_service(...).await?;
    log::info!("User created by {}", user.id);  // nem a log tablaba megy!
}

// ❌ DELETE permission-nel GDPR miatt torolni akarja a log-okat
DELETE FROM activity_logs WHERE user_id = $1;  -- TILOS!

// ❌ Teljes entitas mentese change-kent (nagy JSONB, lassu)
changes: full_user_object  // csak a mezo-szintu diff legyen

// ❌ Nincs particionalas (nehany hirtelen meger 100GB+)
CREATE TABLE activity_logs (...);  -- partition nelkul
```

## Szabalyok
1. Activity log CSAK middleware-bol, SOHA kezi logolas endpoint-ban
2. Csak sikeres mutaciok (2xx status, nem GET kerest)
3. Havi particiok KOTELEZO (automatikus cron letrehozas)
4. Change tracking: `{ field: { old, new } }` diff, NEM teljes entitas
5. S3 archivalas: WORM bucket (write-once, no delete, no update)
6. Retention: 90 nap online, korlatlan S3-ban
7. Log sorok SOHA nem modosithatok vagy torolhetok (L0 BLOCK)

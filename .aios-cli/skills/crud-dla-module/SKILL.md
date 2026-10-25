---
name: crud-dla-module
description: >
  Kotelezo CRUD + DLA modul minta. Aktivalodik minden uj admin feature,
  backend resource, endpoint, list page, dashboard page, add form, role,
  permission, vagy CRUD viselkedes hozzaadasakor. Tamogatott backend:
  Rust (Axum) es Python (FastAPI). Triggerek: "uj modul", "uj feature",
  "scaffold", "crud", "dla", "admin oldal", "list page", "dashboard",
  "add form", /bootstrap, /project:bootstrap.
license: Everengine v7.0 (skeleton master)
priority: P0
model: claude-sonnet-4-6
advisor: claude-opus-4-7
advisor_max_uses: 3
related_skills:
  - i18n-required
  - audit-trail-mandatory
  - permission-rbac
  - dla-menu-pattern
  - backup-strategy
  - activity-log
  - crud-generator
related_rules:
  - .claude/rules/module-implementation.md
---

# CRUD + DLA Module — Teljes implementációs útmutató

> **Ökoszisztéma (v8.0):** partner projektben a backend oldal (CRUD endpoint, permission,
> audit) itt marad, de a DLA admin UI az **aibos.space konzolban** készül, a projekt
> `contracts/admin/*.yaml` szerződése alapján (`aibos-admin-contract`). Saját admin app
> csak az aibos repóban épül. Lásd `.aios-cli/core/ecosystem.md`.

Minden admin funkció egy permissioned CRUD modul DLA navigációval.
Ez a skill pontosan leírja, hogy mit hol kell megcsinálni és milyen
sorrendben, hogy minden modul egységes legyen.

A backend lehet **Rust (Axum)** vagy **Python (FastAPI)** — mindkettőre
teljes mintát ad ez a skill. A legtöbb új modul Rust, de létező
Python modulok is vannak.

---

## 1. Implementációs sorrend (kötelező)

Új modul hozzáadásakor ez a kötelező sorrend. Egyetlen lépés sem
hagyható ki.

```
 1. Backend: Adatmodellek (Rust: serde struktok / Python: Pydantic)
 2. Backend: CRUD endpointok (list, stats, detail, create, update, soft-delete)
 3. Backend: Permission definíciók (permissions.py — közös mindkét backendhez)
 4. Backend: Auth/permission middleware (Rust: header extract / Python: RBAC dekorátor)
 5. Backend: Activity logging minden mutáción
 6. Backend: Route/service regisztráció (Rust: main.rs Router / Python: main.py include_router)
 7. Backend: Dockerfile + docker-compose.yml service entry (Rust microservice esetén)
 8. Frontend: API helper függvények (api.ts)
 9. Frontend: i18n kulcsok (hu.ts + en.ts párhuzamosan)
10. Frontend: menuConfig.ts — app + category regisztráció
11. Frontend: DLA oldalak (dashboard, list, add, [id])
12. Frontend: Loading skeleton minden oldalhoz
13. Frontend: resolveActiveApp kiegészítése
14. Ellenőrzés: tsc, i18n szinkron, dark mode, permission-ök, cargo build
```

---

## 2. Backend választás — Rust vs Python

### Mikor melyiket

| Szempont | Rust (Axum) | Python (FastAPI) |
|----------|-------------|------------------|
| Új önálló modul | Alapértelmezett választás | Ha sok meglévő Python kóddal integrálódik |
| Teljesítményigényes | Mindig Rust | — |
| Meglévő Python route bővítés | — | Mindig Python |
| DB driver | SQLx (PG) vagy mongodb crate | SQLAlchemy async (PG) vagy Motor (MongoDB) |
| Deploy | Külön container (port 3100+) | Közös backend container (port 8000) |

### Architektúra

```
Rust microservice:  docker/{module}/src/main.rs  → saját container, saját port
Python route:       docker/backend/app/routes/{module}.py → közös backend container
```

Rust service-ek a FastAPI backend-en keresztül is proxy-zhatók
(`docker/backend/app/routes/{module}_proxy.py`), hogy a console
egységes `/api/admin/{module}` prefix-en érje el.

---

## 3. Backend — Rust (Axum) implementáció

### 3.1 Projekt struktúra

```
docker/{module}/
  Cargo.toml
  src/
    main.rs          → minden egy fájlban (kis-közepes modulnál)
  migrations/
    001_{module}_tables.sql    → PostgreSQL séma (ha PG)
  Dockerfile
```

### 3.2 Cargo.toml sablon

```toml
[package]
name = "{module}-service"
version = "0.1.0"
edition = "2021"

[dependencies]
axum = { version = "0.8", features = ["macros"] }
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
chrono = { version = "0.4", features = ["serde"] }
uuid = { version = "1", features = ["v4", "serde"] }
tower-http = { version = "0.6", features = ["cors", "trace"] }
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }

# PostgreSQL:
sqlx = { version = "0.8", features = ["runtime-tokio", "tls-rustls", "postgres", "uuid", "chrono"] }

# VAGY MongoDB:
# mongodb = "3"
```

### 3.3 Adatmodellek (serde struktok)

Minden entitáshoz kell egy teljes, egy Create és egy Update strukt:

```rust
use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use uuid::Uuid;

// Teljes entitás (DB-ből jön)
#[derive(Debug, Serialize, Deserialize, Clone, sqlx::FromRow)]
pub struct {Entity} {
    pub id: Uuid,
    pub name: String,
    pub description: String,
    pub status: String,
    pub is_deleted: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

// Létrehozás request
#[derive(Debug, Deserialize)]
pub struct Create{Entity} {
    pub name: String,
    pub description: Option<String>,
    pub status: Option<String>,
    // ... kötelező és opcionális mezők
}

// Frissítés request (minden Optional)
#[derive(Debug, Deserialize)]
pub struct Update{Entity} {
    pub name: Option<String>,
    pub description: Option<String>,
    pub status: Option<String>,
    // ... minden mező Optional
}
```

MongoDB esetén ObjectId kezelés:

```rust
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct {Entity} {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<mongodb::bson::oid::ObjectId>,
    pub {module}_id: String,    // slug: "{module}-abc12345"
    pub name: String,
    pub is_deleted: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}
```

### 3.4 Router és lapozás struktúrák

```rust
use axum::{
    extract::{Path, Query, State, Json},
    http::StatusCode,
    response::IntoResponse,
    routing::{get, post, put, delete},
    Router,
};

#[derive(Debug, Deserialize)]
pub struct ListParams {
    pub page: Option<i64>,
    pub limit: Option<i64>,
    pub search: Option<String>,
    pub status: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct PaginatedResponse<T: Serialize> {
    pub items: Vec<T>,
    pub total: i64,
    pub page: i64,
    pub pages: i64,   // FONTOS: a frontend `data.pages`-t olvassa, NEM `data.limit`-et
}
```

### 3.5 Kötelező endpointok — Router setup

```rust
let app = Router::new()
    .route("/health", get(health))
    .route("/api/{module}/stats", get(get_stats))
    .route("/api/{module}", get(list_{entities}))
    .route("/api/{module}", post(create_{entity}))
    .route("/api/{module}/{id}", get(get_{entity}))
    .route("/api/{module}/{id}", put(update_{entity}))
    .route("/api/{module}/{id}", delete(delete_{entity}))
    .layer(cors)
    .with_state(pool);    // PgPool vagy Arc<AppState>
```

FONTOS: a `/stats` route a lista route ELÉ kerül, különben az
Axum `/{id}` path paramként matcheli a "stats" stringet.

### 3.6 Lista endpoint — PostgreSQL (SQLx)

```rust
async fn list_{entities}(
    State(pool): State<PgPool>,
    Query(params): Query<ListParams>,
) -> impl IntoResponse {
    let page = params.page.unwrap_or(1).max(1);
    let limit = params.limit.unwrap_or(25).min(100);
    let offset = (page - 1) * limit;
    let search = params.search.unwrap_or_default();
    let status = params.status.unwrap_or_default();

    let total: i64 = sqlx::query_scalar(
        r#"SELECT COUNT(*) FROM {table}
           WHERE is_deleted = false
           AND ($1 = '' OR name ILIKE '%' || $1 || '%')
           AND ($2 = '' OR status = $2)"#
    )
    .bind(&search)
    .bind(&status)
    .fetch_one(&pool)
    .await
    .unwrap_or(0);

    let items = sqlx::query_as::<_, {Entity}>(
        r#"SELECT * FROM {table}
           WHERE is_deleted = false
           AND ($1 = '' OR name ILIKE '%' || $1 || '%')
           AND ($2 = '' OR status = $2)
           ORDER BY created_at DESC
           LIMIT $3 OFFSET $4"#
    )
    .bind(&search)
    .bind(&status)
    .bind(limit)
    .bind(offset)
    .fetch_all(&pool)
    .await
    .unwrap_or_default();

    let pages = (total as f64 / limit as f64).ceil() as i64;

    Json(PaginatedResponse {
        items,
        total,
        page,
        pages: pages.max(1),
    })
}
```

### 3.7 Lista endpoint — MongoDB

```rust
async fn list_{entities}(
    State(state): State<Arc<AppState>>,
    Query(params): Query<ListParams>,
) -> Json<serde_json::Value> {
    let coll = state.db.collection::<{Entity}>("{collection}");
    let page = params.page.unwrap_or(1).max(1);
    let limit = params.limit.unwrap_or(25).min(100);
    let skip = ((page - 1) * limit) as u64;

    let mut filter = doc! {"is_deleted": {"$ne": true}};
    if let Some(ref s) = params.search {
        if !s.is_empty() {
            filter.insert("name", doc! {"$regex": s, "$options": "i"});
        }
    }
    if let Some(ref status) = params.status {
        if !status.is_empty() {
            filter.insert("status", status.as_str());
        }
    }

    let total = coll.count_documents(filter.clone()).await.unwrap_or(0) as i64;

    let opts = mongodb::options::FindOptions::builder()
        .sort(doc! {"updated_at": -1})
        .skip(Some(skip))
        .limit(Some(limit))
        .build();

    let mut cursor = coll.find(filter).with_options(opts).await.unwrap();
    let mut items = Vec::new();
    while cursor.advance().await.unwrap_or(false) {
        if let Ok(doc) = cursor.deserialize_current() {
            items.push(doc);
        }
    }

    let pages = ((total as f64) / (limit as f64)).ceil() as i64;

    Json(serde_json::json!({
        "items": items,
        "total": total,
        "page": page,
        "pages": pages.max(1),
    }))
}
```

### 3.8 Stats endpoint

PostgreSQL:

```rust
async fn get_stats(
    State(pool): State<PgPool>,
) -> impl IntoResponse {
    let row = sqlx::query_as::<_, (i64, i64, i64, i64)>(
        r#"SELECT
            COUNT(*) FILTER (WHERE status = 'active'),
            COUNT(*) FILTER (WHERE status = 'draft'),
            COUNT(*) FILTER (WHERE status = 'archived'),
            COUNT(*)
           FROM {table} WHERE is_deleted = false"#
    )
    .fetch_one(&pool)
    .await
    .unwrap_or((0, 0, 0, 0));

    Json(serde_json::json!({
        "active_count": row.0,
        "draft_count": row.1,
        "archived_count": row.2,
        "total": row.3,
    }))
}
```

MongoDB:

```rust
async fn get_stats(
    State(state): State<Arc<AppState>>,
) -> Json<serde_json::Value> {
    let coll = state.db.collection::<mongodb::bson::Document>("{collection}");
    let active = coll.count_documents(doc! {"status": "active", "is_deleted": {"$ne": true}}).await.unwrap_or(0);
    let draft = coll.count_documents(doc! {"status": "draft", "is_deleted": {"$ne": true}}).await.unwrap_or(0);
    let total = coll.count_documents(doc! {"is_deleted": {"$ne": true}}).await.unwrap_or(0);

    Json(serde_json::json!({
        "active_count": active,
        "draft_count": draft,
        "total": total,
    }))
}
```

### 3.9 Create endpoint

```rust
async fn create_{entity}(
    State(pool): State<PgPool>,
    Json(data): Json<Create{Entity}>,
) -> impl IntoResponse {
    let result = sqlx::query_as::<_, {Entity}>(
        r#"INSERT INTO {table} (name, description, status, created_at, updated_at)
           VALUES ($1, $2, $3, NOW(), NOW())
           RETURNING *"#
    )
    .bind(&data.name)
    .bind(data.description.as_deref().unwrap_or(""))
    .bind(data.status.as_deref().unwrap_or("draft"))
    .fetch_one(&pool)
    .await;

    match result {
        Ok(entity) => (StatusCode::CREATED, Json(serde_json::json!(entity))),
        Err(e) => {
            tracing::error!("Create failed: {}", e);
            (StatusCode::INTERNAL_SERVER_ERROR,
             Json(serde_json::json!({"error": e.to_string()})))
        }
    }
}
```

### 3.10 Update endpoint

```rust
async fn update_{entity}(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
    Json(data): Json<Update{Entity}>,
) -> impl IntoResponse {
    // Partial merge: csak a küldött mezőket frissítjük
    let result = sqlx::query(
        r#"UPDATE {table} SET
            name = COALESCE($1, name),
            description = COALESCE($2, description),
            status = COALESCE($3, status),
            updated_at = NOW()
           WHERE id = $4 AND is_deleted = false"#
    )
    .bind(data.name.as_deref())
    .bind(data.description.as_deref())
    .bind(data.status.as_deref())
    .bind(id)
    .execute(&pool)
    .await;

    match result {
        Ok(r) if r.rows_affected() > 0 => Json(serde_json::json!({"ok": true})),
        Ok(_) => return (StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Nem található"}))).into_response(),
        Err(e) => return (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))).into_response(),
    }.into_response()
}
```

MongoDB partial merge:

```rust
let mut update_doc = doc! {
    "updated_at": mongodb::bson::DateTime::from_millis(Utc::now().timestamp_millis()),
};
if let Some(v) = data.name { update_doc.insert("name", v); }
if let Some(v) = data.description { update_doc.insert("description", v); }
if let Some(v) = data.status { update_doc.insert("status", v); }

coll.update_one(
    entity_filter(&id),
    doc! {"$set": update_doc},
).await;
```

### 3.11 Soft delete — SOHA NEM fizikai törlés

```rust
async fn delete_{entity}(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
) -> impl IntoResponse {
    let result = sqlx::query(
        "UPDATE {table} SET is_deleted = true, updated_at = NOW() WHERE id = $1 AND is_deleted = false"
    )
    .bind(id)
    .execute(&pool)
    .await;

    match result {
        Ok(r) if r.rows_affected() > 0 =>
            (StatusCode::OK, Json(serde_json::json!({"ok": true}))),
        Ok(_) =>
            (StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "Nem található"}))),
        Err(e) =>
            (StatusCode::INTERNAL_SERVER_ERROR, Json(serde_json::json!({"error": e.to_string()}))),
    }
}
```

MongoDB:

```rust
coll.update_one(
    entity_filter(&id),
    doc! {"$set": {"is_deleted": true, "updated_at": bson::DateTime::from_millis(Utc::now().timestamp_millis())}},
).await;
```

### 3.12 MongoDB szűrő helper (ha MongoDB-t használ)

Flexibilis ID lookup — ObjectId VAGY slug alapján:

```rust
fn entity_filter(id: &str) -> mongodb::bson::Document {
    if let Ok(oid) = mongodb::bson::oid::ObjectId::parse_str(id) {
        doc! {"$or": [{"{module}_id": id}, {"_id": oid}], "is_deleted": {"$ne": true}}
    } else {
        doc! {"{module}_id": id, "is_deleted": {"$ne": true}}
    }
}
```

### 3.13 CORS és middleware

```rust
use tower_http::cors::{CorsLayer, Any};
use axum::http::Method;

let cors = CorsLayer::new()
    .allow_origin(Any)
    .allow_methods([Method::GET, Method::POST, Method::PUT, Method::DELETE, Method::PATCH, Method::OPTIONS])
    .allow_headers(Any);
```

### 3.14 Main entry és DB init

PostgreSQL:

```rust
#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "info".into()),
        )
        .init();

    let database_url = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgresql://deapp:changeme@postgres:5432/digitalisebreszto".into());

    let pool = sqlx::PgPool::connect(&database_url).await
        .expect("Failed to connect to PostgreSQL");

    // Migrációk futtatása
    sqlx::migrate!("./migrations").run(&pool).await
        .expect("Failed to run migrations");

    let port: u16 = std::env::var("PORT")
        .ok().and_then(|p| p.parse().ok()).unwrap_or(3100);

    let app = Router::new()
        // ... route-ok ...
        .layer(cors)
        .with_state(pool);

    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{}", port)).await.unwrap();
    tracing::info!("{module}-service listening on port {}", port);
    axum::serve(listener, app).await.unwrap();
}
```

MongoDB:

```rust
struct AppState {
    db: mongodb::Database,
}

#[tokio::main]
async fn main() {
    // ... tracing init ...

    let mongo_uri = std::env::var("MONGO_URI")
        .unwrap_or_else(|_| "mongodb://admin:changeme@mongo:27017/digitalisebreszto?authSource=admin".into());

    let client = mongodb::Client::with_options(
        mongodb::options::ClientOptions::parse(&mongo_uri).await.unwrap()
    ).unwrap();
    let db = client.database("digitalisebreszto");

    let state = std::sync::Arc::new(AppState { db });

    let app = Router::new()
        // ... route-ok ...
        .layer(cors)
        .with_state(state);

    // ... serve ...
}
```

### 3.15 Dockerfile

```dockerfile
FROM rust:slim-bookworm AS builder
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
COPY src/ src/
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates libssl3 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/{module}-service /usr/local/bin/
COPY --from=builder /app/migrations /app/migrations
EXPOSE {port}
CMD ["/usr/local/bin/{module}-service"]
```

### 3.16 docker-compose service entry

```yaml
{module}:
  build: ./{module}
  restart: always
  depends_on:
    postgres:                    # vagy: mongo:
      condition: service_healthy #       condition: service_started
  environment:
    DATABASE_URL: postgresql://${PG_USER}:${PG_PASSWORD}@postgres:5432/${PG_DB}
    # VAGY: MONGO_URI: mongodb://${MONGO_ROOT_USER}:${MONGO_ROOT_PASSWORD}@mongo:27017/${MONGO_DB}?authSource=admin
    PORT: "{port}"
    RUST_LOG: info
  networks: [data, internal, mnitr]
```

### 3.17 Activity logging (Rust service-ből)

Rust service-ek HTTP POST-tal küldik a logot az activity-logger-nek
(fire-and-forget):

```rust
async fn log_activity_fire_and_forget(
    user_id: &str, action: &str, details: &str,
    entity_type: &str, entity_id: &str,
) {
    let client = reqwest::Client::new();
    let _ = client.post("http://activity-logger:3100/api/activities")
        .json(&serde_json::json!({
            "user_id": user_id,
            "action": action,
            "details": details,
            "entity_type": entity_type,
            "entity_id": entity_id,
        }))
        .send()
        .await;
}
```

Vagy, ha a Python backend proxy-n megy keresztül, a Python oldali
`log_activity()` kezeli automatikusan.

---

## 4. Backend — Python (FastAPI) implementáció

### 4.1 Fájl helye

```
docker/backend/app/routes/{module}.py
```

### 4.2 Router prefix

```python
router = APIRouter(prefix="/api/admin/{module}", tags=["{module}"])
```

FONTOS: `@router.get("")` — NEM `@router.get("/")` (elkerüli a 307
redirect-et).

### 4.3 Pydantic modellek

Minden modulnak kell egy `Create` és egy `Update` modell:

```python
from pydantic import BaseModel
from typing import Optional

class {Entity}Create(BaseModel):
    name: str
    description: str = ""
    # ... kötelező és opcionális mezők

class {Entity}Update(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    # ... minden mező Optional
```

### 4.4 Kötelező endpointok

| Végpont | Metódus | Cél | Permission |
|---------|---------|-----|------------|
| `""` | GET | Lista, lapozás, szűrés, keresés | `{module}.list` |
| `"/stats"` | GET | Dashboard KPI adatok | `{module}.list` |
| `"/{id}"` | GET | Részletes nézet | `{module}.view` |
| `""` | POST | Létrehozás | `{module}.create` |
| `"/{id}"` | PUT | Frissítés (partial merge) | `{module}.edit` |
| `"/{id}"` | DELETE | Soft delete | `{module}.delete` |

Domain-specifikus action endpointok igény szerint:
`assign`, `upload`, `approve`, `reject`, `cancel`, `export`, `reprocess`.

### 4.5 Lista endpoint — PostgreSQL

```python
@router.get("")
async def list_{entities}(
    user=require_permission("{module}.list"),
    session=Depends(get_pg_session),
    page: int = Query(1, ge=1),
    limit: int = Query(25, ge=1, le=100),
    search: str = Query("", max_length=200),
    status: Optional[str] = None,
):
    conditions = ["{table}.is_deleted = FALSE"]
    params: dict = {"limit": limit, "offset": (page - 1) * limit}

    if search:
        conditions.append(
            "({table}.name ILIKE :search OR {table}.description ILIKE :search)"
        )
        params["search"] = f"%{search}%"
    if status:
        conditions.append("{table}.status = :status")
        params["status"] = status

    where = " AND ".join(conditions)

    count_result = await session.execute(
        text(f"SELECT COUNT(*) FROM {table} WHERE {where}"), params
    )
    total = count_result.scalar()

    result = await session.execute(text(f"""
        SELECT * FROM {table}
        WHERE {where}
        ORDER BY created_at DESC
        LIMIT :limit OFFSET :offset
    """), params)
    rows = result.fetchall()

    return {
        "items": [dict(r._mapping) for r in rows],
        "total": total,
        "page": page,
        "pages": max(1, (total + limit - 1) // limit),
    }
```

### 4.6 Stats endpoint

```python
@router.get("/stats")
async def {module}_stats(
    user=require_permission("{module}.list"),
    session=Depends(get_pg_session),
):
    result = await session.execute(text("""
        SELECT
            COUNT(*) FILTER (WHERE status = 'active') AS active_count,
            COUNT(*) FILTER (WHERE status = 'draft') AS draft_count,
            COUNT(*) FILTER (WHERE status = 'archived') AS archived_count,
            COUNT(*) AS total
        FROM {table} WHERE is_deleted = FALSE
    """))
    row = result.fetchone()
    return dict(row._mapping) if row else {}
```

### 4.7 Soft delete — SOHA NEM fizikai törlés

```python
@router.delete("/{id}")
async def delete_{entity}(
    id: str,
    user=require_permission("{module}.delete"),
    session=Depends(get_pg_session),
):
    result = await session.execute(text("""
        UPDATE {table} SET is_deleted = TRUE, updated_at = NOW()
        WHERE id = CAST(:id AS uuid) AND is_deleted = FALSE
    """), {"id": id})
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="Nem található")
    await session.commit()

    await log_activity(
        str(user["_id"]), "{module}_deleted",
        f"{Entity} törölve: {id}",
        entity_type="{module}", entity_id=id,
    )

    return {"ok": True}
```

MongoDB esetén:

```python
await collection.update_one(
    {"_id": ObjectId(id)},
    {"$set": {"is_deleted": True, "updated_at": datetime.utcnow()}}
)
```

### 4.8 Route regisztráció

`docker/backend/app/main.py` — hozzáadás:

```python
from .routes.{module} import router as {module}_router
app.include_router({module}_router)
```

### 4.9 Proxy route (Rust service elérése Python-on keresztül)

Ha a Rust service-t a console `/api/admin/` prefixen keresztül kell
elérni:

```python
# docker/backend/app/routes/{module}_proxy.py
import httpx
from fastapi import APIRouter, Request, Response

router = APIRouter(prefix="/api/admin/{module}", tags=["{module}"])

UPSTREAM = "http://{module}:{port}"

@router.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def proxy(request: Request, path: str = ""):
    async with httpx.AsyncClient() as client:
        url = f"{UPSTREAM}/api/{module}/{path}"
        resp = await client.request(
            request.method, url,
            headers=dict(request.headers),
            content=await request.body(),
            params=dict(request.query_params),
        )
    return Response(content=resp.content, status_code=resp.status_code,
                    headers=dict(resp.headers))
```

---

## 5. Backend — Permissions (közös)

### 5.1 Fájl helye

```
docker/backend/app/permissions.py
```

A permission rendszer MINDIG a Python backend-ben él, függetlenül
attól, hogy a tényleges CRUD Rust-ban van-e.

### 5.2 Permission formátum

```
{module}.{action}              — egyszerű modul
{module}.{resource}.{action}   — nested resource (pl. crm.contacts.list)
```

Pont (`.`) szeparátor, NEM kettőspont.

### 5.3 Kötelező CRUD permission-ök

Minden új modulhoz minimum ezek kellenek:

```python
# {Module neve}
"{module}.list": "{Entity}ek listázása",
"{module}.view": "{Entity} megtekintése",
"{module}.create": "{Entity} létrehozása",
"{module}.edit": "{Entity} szerkesztése",
"{module}.delete": "{Entity} törlése",
```

Domain action-ök igény szerint:

```python
"{module}.assign": "{Entity} hozzárendelése",
"{module}.upload": "Fájl feltöltése",
"{module}.approve": "{Entity} jóváhagyása",
"{module}.reject": "{Entity} elutasítása",
"{module}.export": "{Entity}ek exportálása",
"{module}.cancel": "{Entity} visszavonása",
```

### 5.4 PERMISSION_GROUPS kiegészítése

```python
PERMISSION_GROUPS["Új modul neve"] = [
    p for p in PERMISSIONS if p.startswith("{module}.")
]
```

### 5.5 BUILTIN_ROLES frissítése

Ellenőrizd, hogy az `admin`, `editor`, `viewer` role-ok tartalmazzák-e
az új permission-öket a domain logikának megfelelően. A `superadmin`
automatikusan megkapja (mert `list(PERMISSIONS.keys())`).

FONTOS: `superadmin` permission-ök SOHA nem szűkíthetők.

### 5.6 RBAC dekorátor használata (Python)

`require_permission()` BELÜL tartalmazza a `Depends()` hívást —
NEM kell külön `Depends()`-be csomagolni.

```python
from ..rbac import require_permission, require_any_permission

@router.get("")
async def list_items(
    user=require_permission("{module}.list"),   # NEM Depends(require_permission(...))
    session=Depends(get_pg_session),
):
    ...
```

AND logika: `require_permission("a", "b")` — mindkettő kell.
OR logika: `require_any_permission("a", "b")` — bármelyik elég.

Frontend permission check csak UI hint — a backend check kötelező
minden endpointon.

---

## 6. Backend — Activity Logging

### 6.1 Python backend-ből

```python
from ..routes.auth import get_current_user, log_activity

await log_activity(
    user_id=str(user["_id"]),
    action="{module}_created",       # vagy _updated, _deleted
    details=f"Leírás: {entity.name}",
    entity_type="{module}",
    entity_id=str(entity_id),
    data={"field": "value"},         # opcionális extra adat
)
```

### 6.2 Rust service-ből

HTTP POST az activity-logger felé (fire-and-forget, a hiba nem
blokkol):

```rust
// Hívás minden CREATE, UPDATE, DELETE után
log_activity_fire_and_forget(
    &user_id, "{module}_created",
    &format!("{Entity} létrehozva: {}", entity_id),
    "{module}", &entity_id,
).await;
```

### 6.3 Elnevezési konvenció

| Művelet | Action string |
|---------|--------------|
| Létrehozás | `{module}_created` |
| Frissítés | `{module}_updated` |
| Törlés | `{module}_deleted` |
| Hozzárendelés | `{module}_assigned` |
| Fájl feltöltés | `{module}_attachment_uploaded` |
| Üzenet | `{module}_message_added` |
| Státuszváltás | `{module}_status_changed` |

A Python log MongoDB-be (`activity_log` collection) ÉS a Rust
activity-logger microservice-be (PostgreSQL) is elmegy automatikusan.

---

## 7. Frontend — API helper függvények

### 7.1 Fájl helye

```
docker/console/src/lib/api.ts
```

### 7.2 Kötelező helper-ek

Minden új modulhoz ezek a függvények kellenek (az endpoint azonos,
akár Rust, akár Python a backend — a proxy egységesíti):

```typescript
// ── {Module} ──
export async function get{Entities}(params?: string) {
  return apiFetch(`/api/admin/{module}${params ? `?${params}` : ""}`);
}
export async function get{Entity}(id: string) {
  return apiFetch(`/api/admin/{module}/${id}`);
}
export async function get{Entity}Stats() {
  return apiFetch("/api/admin/{module}/stats");
}
export async function create{Entity}(data: any) {
  return apiFetch("/api/admin/{module}", {
    method: "POST",
    body: JSON.stringify(data),
  });
}
export async function update{Entity}(id: string, data: any) {
  return apiFetch(`/api/admin/{module}/${id}`, {
    method: "PUT",
    body: JSON.stringify(data),
  });
}
export async function delete{Entity}(id: string) {
  return apiFetch(`/api/admin/{module}/${id}`, { method: "DELETE" });
}
```

---

## 8. Frontend — i18n (Fordítások)

### 8.1 Fájlok

```
docker/console/src/lib/translations/hu.ts
docker/console/src/lib/translations/en.ts
```

MINDIG EGYSZERRE FRISSÍTSD MINDKETTŐT. Soha ne maradjon kulcs az
egyikből ki.

### 8.2 Használat

```tsx
const { t } = useI18n();  // from "@/lib/i18n"
```

Soha ne hardkódolj szöveget. Minden user-visible text `t("key")`.

### 8.3 Kötelező kulcsok új modulhoz

```typescript
// Navigáció (menuConfig labelKey-ek)
"app.{module}": "Modul neve",
"sub.overview": "Áttekintés",           // már létezik, közös
"sub.{module}.list": "Lista oldal neve",
"sub.{module}.add": "Új {entity}",

// Dashboard
"{module}.dashboard_title": "Modul Dashboard",
"{module}.stat_{status1}": "Státusz 1",
"{module}.stat_{status2}": "Státusz 2",
"{module}.recent_items": "Legutóbbi elemek",
"{module}.view_all": "Összes",
"{module}.no_items": "Nincs még {entity}.",

// List
"{module}.title": "Lista cím",
"{module}.search_placeholder": "Keresés...",
"{module}.all_statuses": "Minden státusz",
"{module}.no_results": "Nincs találat.",
"{module}.total_items": "Össz: {count} elem",
"{module}.confirm_delete": "Biztosan törlöd?",

// Táblázat oszlopok
"{module}.col_name": "Név",
"{module}.col_status": "Státusz",
"{module}.col_created": "Létrehozva",
"{module}.col_updated": "Frissítve",

// Státuszok
"{module}.status_{value}": "Megjelenítendő szöveg",

// Add / Edit form
"{module}.add_title": "Új {entity}",
"{module}.edit_title": "{Entity} szerkesztése",
"{module}.name_label": "Név",
"{module}.name_placeholder": "Adj meg egy nevet...",
"{module}.create_button": "{Entity} létrehozása",
"{module}.save_button": "Mentés",
"{module}.name_required": "A név megadása kötelező",

// Detail nézet
"{module}.detail_title": "{Entity} részletei",
"{module}.back_to_list": "Vissza a listához",
```

---

## 9. Frontend — menuConfig.ts

### 9.1 Fájl helye

```
docker/console/src/lib/menuConfig.ts
```

### 9.2 App regisztráció

Új entry az `APPS` Record-ba:

```typescript
{module}: {
  id: "{module}",
  labelKey: "app.{module}",
  icon: {LucideIcon},       // lucide-react ONLY
  color: "#{hex}",
  href: "/{module}/dashboard",
  // superadminOnly: true,   // ha kell
  subs: [
    { id: "overview", labelKey: "sub.overview", href: "/{module}/dashboard", icon: LayoutDashboard },
    { id: "list", labelKey: "sub.{module}.list", href: "/{module}/list", icon: {ListIcon} },
    { id: "add", labelKey: "sub.{module}.add", href: "/{module}/add", icon: FilePlus2 },
  ],
},
```

### 9.3 Category regisztráció

Az `CATEGORIES` tömbbe a megfelelő kategóriához:

```typescript
{ id: "kategória_id", labelKey: "cat.kategória", icon: Icon, color: "#hex",
  apps: [..., APPS.{module}] },
```

### 9.4 resolveActiveApp kiegészítése

Új sor a `resolveActiveApp` függvénybe:

```typescript
if (pathname.startsWith("/{module}")) return "{module}";
```

---

## 10. Frontend — DLA oldalak

### 10.1 Kötelező mappastruktúra

```
src/app/(app)/{module}/
  page.tsx              → redirect /{module}/dashboard
  dashboard/
    page.tsx            → KPI stat-ok + legutóbbi 5-10 elem
    loading.tsx         → StatGridSkeleton + TableSkeleton
  list/
    page.tsx            → kereshető, szűrhető, lapozott táblázat
    loading.tsx         → PageHeaderSkeleton + TableSkeleton
  add/
    page.tsx            → létrehozó form
    loading.tsx         → FormSkeleton
  [{id}]/
    page.tsx            → részletes nézet + inline szerkesztés
    loading.tsx         → DetailSkeleton
```

FONTOS: Az add oldal MINDIG `/add`, NEM `/new`.

### 10.2 Redirect oldal (page.tsx a modul gyökerében)

```tsx
"use client";
import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function {Module}Page() {
  const router = useRouter();
  useEffect(() => { router.replace("/{module}/dashboard"); }, [router]);
  return null;
}
```

### 10.3 Dashboard oldal minta

Kötelező elemek:
- `"use client"` direktíva
- `useI18n()` hook — minden szöveg `t("key")`
- Stats grid: 2×2 vagy 4×1, `StatCard` komponensek
- Recent items: első 5-10 rekord táblázatban
- Refresh gomb
- Link az `/add` oldalra (ha van `create` permission)
- Link a `/list` oldalra ("Összes megtekintése")
- Loading állapot: `StatGridSkeleton` + `TableSkeleton`
- Error állapot kezelés

Dark mode osztályok:

| Elem | Classes |
|------|---------|
| Kártya háttér | `bg-white dark:bg-[#1a1b23]` |
| Keret | `border-gray-200 dark:border-[#2a2b36]` |
| Fejléc szöveg | `text-gray-900 dark:text-gray-100` |
| Halvány szöveg | `text-gray-500 dark:text-gray-400` |
| Táblázat fejléc bg | `bg-gray-50 dark:bg-[#13141a]` |
| Hover sor | `hover:bg-gray-50 dark:hover:bg-[#13141a]` |
| Elválasztó | `divide-gray-100 dark:divide-[#2a2b36]` |
| Árnyék | `shadow-sm dark:shadow-none` |

### 10.4 List oldal minta

Kötelező elemek:
- Keresés: `<Search />` ikon + input, `search` state → API paraméter
- Szűrők: status dropdown, egyéb szűrők igény szerint
- Lapozás: `page`, `pages`, `total` kezelése
- Táblázat: fejléc `text-xs uppercase tracking-wider`
- Sorok: kattintható link a `/{module}/{id}` detail oldalra
- Törlés: confirm dialog → `delete{Entity}(id)` → újratöltés
- Empty state: ikon + szöveg ha nincs találat
- Loading: `<TableSkeleton />`

### 10.5 Add oldal minta

Kötelező elemek:
- `"use client"` + form state-ek `useState`-tel
- Vissza gomb: `<ArrowLeft />` → `/{module}/list`
- Form: `onSubmit` → `create{Entity}(data)` → `router.push("/{module}/{result.id}")`
- Validáció: kliens oldali (required mezők) + szerver oldali (Pydantic / Rust)
- Error megjelenítés: piros sáv a form tetején
- Loading gomb: `disabled={saving}`, szöveg: `t("common.loading")`
- A form VALÓDI backend endpoint-ra submitol — SOHA ne hozzon létre
  hard-coded mintaadatot

### 10.6 Detail / Edit oldal ([{id}]/page.tsx)

Egyetlen oldalon kezeljük a view és edit funkciót (inline szerkesztés).
NINCS külön `/:id/view` és `/:id/edit` route.

Kötelező elemek:
- Adatlekérés: `get{Entity}(id)` a mount-on
- Inline edit: dropdown / input mezők azonnal PATCH-elnek
- Törlés gomb: confirm → soft delete → redirect listára
- Loading: `<DetailSkeleton />`

---

## 11. Frontend — Loading Skeleton-ok

### 11.1 Elérhető skeletonok

```tsx
import {
  StatGridSkeleton,
  TableSkeleton,
  PageHeaderSkeleton,
  FormSkeleton,
  DetailSkeleton,
  SearchBarSkeleton,
  ChartSkeleton,
  TimelineSkeleton,
  KanbanSkeleton,
} from "@/components/Skeleton";
```

### 11.2 Melyik oldalhoz melyik skeleton

| Oldal | loading.tsx tartalma |
|-------|---------------------|
| dashboard | `<StatGridSkeleton />` + `<TableSkeleton />` |
| list | `<PageHeaderSkeleton />` + `<TableSkeleton />` |
| add | `<FormSkeleton />` |
| [{id}] | `<DetailSkeleton />` |

### 11.3 Loading.tsx sablon

```tsx
import { StatGridSkeleton, TableSkeleton } from "@/components/Skeleton";

export default function Loading() {
  return (
    <div className="space-y-6">
      <StatGridSkeleton />
      <TableSkeleton cols={5} rows={8} />
    </div>
  );
}
```

---

## 12. Frontend — Dark mode

MINDEN komponensen kötelező a light + dark variáns.

### 12.1 Referencia táblázat

| Elem | Light | Dark |
|------|-------|------|
| Oldal háttér | `bg-gray-50` | `dark:bg-[#13141a]` |
| Kártya háttér | `bg-white` | `dark:bg-[#1a1b23]` |
| Keret | `border-gray-200` | `dark:border-[#2a2b36]` |
| Szöveg | `text-gray-900` | `dark:text-gray-100` |
| Halvány szöveg | `text-gray-500` | `dark:text-gray-400` |
| Másodlagos szöveg | `text-gray-600` | `dark:text-gray-400` |
| Táblázat fejléc | `bg-gray-50` | `dark:bg-[#13141a]` |
| Hover | `hover:bg-gray-100` | `dark:hover:bg-[#2a2b36]` |
| Hover sor | `hover:bg-gray-50` | `dark:hover:bg-[#13141a]` |
| Input bg | `bg-white` | `dark:bg-[#13141a]` |
| Elválasztó | `divide-gray-100` | `dark:divide-[#2a2b36]` |
| Árnyék | `shadow-sm` | `dark:shadow-none` |
| Error háttér | `bg-red-50` | `dark:bg-red-900/20` |
| Státusz badge | `bg-{color}-100 text-{color}-700` | `dark:bg-{color}-900/30 dark:text-{color}-300` |

### 12.2 Input mezők sablon

```tsx
className="w-full px-3 py-2 rounded-lg border border-gray-200
  dark:border-[#2a2b36] bg-white dark:bg-[#13141a]
  focus:ring-2 focus:ring-{moduleColor}-500 outline-none"
```

---

## 13. Ellenőrző checklist

Egy modul CSAK AKKOR tekinthető késznek, ha MINDEN pont teljesül.

### 13.1 Backend checklist — Rust (Axum)

```
[ ] Cargo.toml dependencies helyes (axum 0.8, sqlx 0.8 / mongodb 3)
[ ] serde struktok: Entity, Create{Entity}, Update{Entity}
[ ] PaginatedResponse<T> strukt
[ ] GET /api/{module} — list (lapozás, szűrés, keresés, is_deleted=false)
[ ] GET /api/{module}/stats — dashboard KPI-k (A LISTA ROUTE ELÉ!)
[ ] GET /api/{module}/{id} — detail
[ ] POST /api/{module} — create
[ ] PUT /api/{module}/{id} — update (partial merge, updated_at)
[ ] DELETE /api/{module}/{id} — soft delete (is_deleted=true, NEM fizikai)
[ ] return formátum: { items, total, page, pages } a list-nél
[ ] CORS layer beállítva
[ ] Tracing/logging inicializálva
[ ] Health check endpoint: GET /health
[ ] Activity log küldés HTTP POST-tal (fire-and-forget)
[ ] Dockerfile kész (multi-stage build)
[ ] docker-compose service entry kész
[ ] Migráció fájl kész (PostgreSQL) vagy séma ellenőrizve (MongoDB)
```

### 13.2 Backend checklist — Python (FastAPI)

```
[ ] Pydantic Create + Update modell definiálva
[ ] GET "" — list endpoint (lapozás, szűrés, keresés, is_deleted=FALSE)
[ ] GET "/stats" — dashboard KPI-k
[ ] GET "/{id}" — detail (joinolt adatokkal)
[ ] POST "" — create (Pydantic validáció)
[ ] PUT "/{id}" — update (partial merge, updated_at beállítás)
[ ] DELETE "/{id}" — soft delete (is_deleted=TRUE, NEM fizikai törlés)
[ ] return formátum: { items, total, page, pages } a list-nél
[ ] require_permission dekorátor MINDEN endpointon
[ ] log_activity hívás MINDEN mutáción (create, update, delete, assign...)
[ ] Route regisztrálva main.py-ban (app.include_router)
[ ] Router prefix: @router.get("") NEM @router.get("/")
```

### 13.3 Permission checklist (közös)

```
[ ] Permission definíciók hozzáadva (permissions.py)
[ ] PERMISSION_GROUPS kiegészítve
[ ] BUILTIN_ROLES ellenőrizve (admin, editor, viewer szintek)
[ ] superadmin automatikusan kap minden permission-t
```

### 13.4 Frontend checklist

```
[ ] API helper függvények hozzáadva (api.ts): get, getOne, getStats, create, update, delete
[ ] i18n kulcsok hozzáadva hu.ts-ben ÉS en.ts-ben (minden szöveg)
[ ] menuConfig.ts: APPS entry hozzáadva
[ ] menuConfig.ts: CATEGORIES-be besorolva
[ ] menuConfig.ts: resolveActiveApp kiegészítve
[ ] /{module}/page.tsx — redirect a /dashboard-ra
[ ] /{module}/dashboard/page.tsx — KPI grid + recent items + refresh
[ ] /{module}/dashboard/loading.tsx — StatGridSkeleton + TableSkeleton
[ ] /{module}/list/page.tsx — keresés + szűrők + lapozás + törlés
[ ] /{module}/list/loading.tsx — PageHeaderSkeleton + TableSkeleton
[ ] /{module}/add/page.tsx — form → backend POST → redirect detail-ra
[ ] /{module}/add/loading.tsx — FormSkeleton
[ ] /{module}/[{id}]/page.tsx — detail + inline edit
[ ] /{module}/[{id}]/loading.tsx — DetailSkeleton
[ ] MINDEN oldal "use client"
[ ] MINDEN szöveg t("key") — NINCS hardcoded szöveg
[ ] MINDEN kártya/input/tábla dark mode osztályokkal
[ ] Form valódi endpointra submitol
[ ] Error kezelés minden fetch-nél
[ ] Loading state skeleton-nal
[ ] Empty state ikon + szöveggel
```

### 13.5 Konzisztencia checklist

```
[ ] tsc hiba nélkül lefut (TypeScript compile)
[ ] cargo build --release hiba nélkül (Rust backend esetén)
[ ] hu.ts és en.ts kulcsok szinkronban (azonos kulcskészlet)
[ ] Permission nevek konzisztensek: {module}.{action} formátum
[ ] Activity log action nevek: {module}_{action} formátum
[ ] API helper nevek: get{Entities}, get{Entity}, create{Entity}, update{Entity}, delete{Entity}
[ ] Dark mode: MINDEN elem tartalmaz light ÉS dark osztályt
[ ] superadmin permission-ök nem szűkültek
[ ] Soft delete: NINCS fizikai törlés üzleti adaton
[ ] Loading skeleton MINDEN oldal mellé készült
[ ] menuConfig sub id="add" (NEM "new") és href="/{module}/add"
[ ] Docker networks: data + internal + mnitr (Rust service)
```

---

## 14. Ami NEM megengedett

- Fizikai DELETE üzleti adaton (mindig soft delete).
- Hardcoded szöveg a console/portal felületen (mindig i18n).
- Frontend-only permission check backend nélkül.
- `@router.get("/")` — trailing slash Python-ban (307 redirect veszély).
- `/new` route az add oldalhoz — mindig `/add`.
- Különálló `/view` és `/edit` route — egyetlen `[{id}]` oldal.
- `superadmin` jogok szűkítése.
- Modul regisztráció nélkül (`main.py`/`main.rs`, `menuConfig.ts`, `permissions.py`).
- Loading skeleton nélküli oldal.
- Dark mode nélküli komponens.
- Activity log nélküli mutáció.
- Rust service Docker network-ök nélkül (`data`, `internal`, `mnitr`).
- Axum-ban `/stats` route a `/{id}` route UTÁN (match conflict).

---

## 15. Referencia fájlok

### Python backend

| Mit keresek | Hol találom |
|-------------|-------------|
| Permission definíciók | `docker/backend/app/permissions.py` |
| RBAC dekorátorok | `docker/backend/app/rbac.py` |
| Activity logging | `docker/backend/app/routes/auth.py` → `log_activity()` |
| Route regisztráció | `docker/backend/app/main.py` |
| DB — PostgreSQL | `docker/backend/app/pg_database.py` → `get_pg_session` |
| DB — MongoDB | `docker/backend/app/database.py` → `db` |
| S3 / MinIO | `docker/backend/app/s3_client.py` |
| Minta modul (tickets) | `docker/backend/app/routes/tickets.py` |
| Minta modul (forms) | `docker/backend/app/routes/forms.py` |
| Proxy minta (affiliate) | `docker/backend/app/routes/affiliate.py` |
| Proxy minta (projects) | `docker/backend/app/routes/projects_proxy.py` |

### Rust backend

| Mit keresek | Hol találom |
|-------------|-------------|
| Activity logger (PG minta) | `docker/activity-logger/src/main.rs` |
| Affiliate CRUD (PG minta) | `docker/affiliate/src/main.rs` |
| Projects CRUD (MongoDB minta) | `docker/projects-service/src/main.rs` |
| DB migráció minta | `docker/activity-logger/migrations/001_activity_tables.sql` |
| Dockerfile minta | `docker/affiliate/Dockerfile` |
| Docker compose | `docker/docker-compose.yml` |

### Frontend

| Mit keresek | Hol találom |
|-------------|-------------|
| API helper-ek | `docker/console/src/lib/api.ts` |
| i18n — magyar | `docker/console/src/lib/translations/hu.ts` |
| i18n — angol | `docker/console/src/lib/translations/en.ts` |
| Sidebar konfig | `docker/console/src/lib/menuConfig.ts` |
| Skeleton komponensek | `docker/console/src/components/Skeleton.tsx` |
| i18n hook | `docker/console/src/lib/i18n.tsx` |
| Dark mode referencia | `docker/console/CLAUDE.md` → Dark Mode Classes |
| Minta modul (tickets) | `docker/console/src/app/(app)/tickets/` |
| Minta modul (forms) | `docker/console/src/app/(app)/forms/` |
| Minta modul (projects) | `docker/console/src/app/(app)/projects/` |
# Audit napló — append-only, reason required

**Forrás:** `/Users/everengine/Documents/dev/aibos` @ `7e30ba5` (2026-10-06)  
Hivatkozott fájlok: `crates/aibos-audit/src/`, `contracts/external/actor-assertion.md`

---

## Alapelv

> Az audit napló csak bővülhet. Adatbázis szintű kényszer tiltja a módosítást
> és a törlést — a séma tulajdonosának sincsen erre lehetősége.

Ez nem konfigurációs döntés, hanem az aibos biztonsági modell fundamentuma.

---

## Mikor kötelező audit bejegyzés

| Művelet típusa | Kötelező? |
|----------------|-----------|
| `GET`, `HEAD`, lista lekérdezés | Nem (teljesítmény) |
| `POST` (létrehozás) | **Igen** |
| `PATCH`, `PUT` (módosítás) | **Igen** |
| `DELETE`, soft delete, archivál | **Igen** |
| Publish, activate, deactivate | **Igen** |
| Manuális override | **Igen + `reason` kötelező** |

---

## Bejegyzés tartalma

```rust
pub struct AuditEntry {
    pub id: Uuid,                    // UUIDv7 (rendezett)
    pub ts: DateTime<Utc>,           // szerver oldali NOW()
    pub operator_id: String,         // assertion sub claim
    pub operator_sub_iss: String,    // assertion sub_iss claim
    pub tenant: Option<Uuid>,        // assertion tenant claim
    pub correlation_id: Option<Uuid>, // assertion corr claim
    pub permission: String,          // érintett permission kód
    pub http_method: String,         // "PATCH", "DELETE", …
    pub path: String,                // normalizált URL path
    pub entity_type: String,         // pl. "courses"
    pub entity_id: String,           // rekord UUID
    pub payload_hash: String,        // "sha256:<hex>" (nem a payload maga)
    pub reason: Option<String>,      // max 500 karakter
    pub ticket: Option<String>,      // support ticket ID
    pub outcome: AuditOutcome,       // Success | Denied | Error
    pub error_slug: Option<String>,  // RFC 7807 slug hibánál
}
```

**Fontos:** a napló NEM tartalmazza a kérés payloadját — csak hash-t.
PII adatok soha nem kerülnek a naplóba.

---

## Manuális override

Ha egy operátor alapértelmezésen kívüli műveletet hajt végre (pl. kényszer
soft delete, adatjavítás ügyfélkérésre), a `reason` mező kötelező.

Az assertion `reason` és `ticket` claim-jeit az aibos middleware automatikusan
propagálja az audit bejegyzésbe.

Ha `reason` hiányzik manuális override esetén → 422 Unprocessable Entity:

```json
{
  "type": "https://aibos.space/errors/reason-required",
  "title": "Kötelező indoklás hiányzik",
  "status": 422,
  "detail": "Ez a művelet indoklást igényel. Add meg az X-Actor-Assertion reason mezőjét.",
  "instance": "/api/admin/v1/courses/uuid"
}
```

---

## RFC 7807 hibatípus prefix

Minden hiba `type` URI-ja az aibos domainen él:

```
https://aibos.space/errors/<slug>
```

Slugok: kötőjellel elválasztott kisbetűs szavak (pl. `assertion-expired`,
`tenant-mismatch`, `reason-required`). Nincs szóköz, nincs nagybetű,
nincs speciális karakter.

---

## Adatbázis szintű garancia (PostgreSQL)

```sql
-- Az audit tábla sorait nem lehet módosítani vagy törölni
CREATE RULE audit_no_update AS ON UPDATE TO audit_schema.entries
    DO INSTEAD NOTHING;
CREATE RULE audit_no_delete AS ON DELETE TO audit_schema.entries
    DO INSTEAD NOTHING;

-- Alternatíva (erősebb): Row Security Policy
ALTER TABLE audit_schema.entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY audit_insert_only ON audit_schema.entries
    FOR INSERT WITH CHECK (true);
-- SELECT engedélyezett, UPDATE és DELETE nem
```

---

## Megőrzési idő és archiválás

- Aktív tábla: 90 nap (PostgreSQL particionálva, havi partíciók)
- 90 nap után: automatikus archiválás Hetzner Object Storage-ba (Object Lock)
- Export: CSV, az aibos konzolból indítható, `aibos.audit.export` jogosultság
- Törlés: TILOS — Object Lock garantálja az archiválás után is

---

## Partner oldali audit log

A partner projektben az aibos middleware által hívott audit writert kell
implementálni:

```rust
// src/admin/audit.rs
pub async fn write_audit(
    pool: &PgPool,
    entry: AuditEntry,
) -> Result<(), AuditError> {
    sqlx::query!(
        "INSERT INTO admin_audit (id, ts, operator_id, ...) VALUES ($1, $2, $3, ...)",
        entry.id, entry.ts, entry.operator_id, ...
    )
    .execute(pool)
    .await?;
    Ok(())
}
```

A partner tábla csak INSERT-et fogad; a partner sem módosíthat.

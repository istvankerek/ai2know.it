# Modul implementacios szabalyok

Minden uj backend resource / admin feature epitesenel a 6 alap-elv egyideju
betartasa kotelezo. A `crud-dla-module` skill ezeket az elveket egyutt
hasznalja, de barmelyik onmagaban is aktivalodhat tobb kontextusban.

---

## 1. i18n discipline (minden szoveg t() hook-on at)

**Skill:** `i18n-required`

- Minden user-facing string `t("key")` hivason at megy
- `hu.ts` + `en.ts` PARHUZAMOSAN frissitve (kulcskeszlet azonos)
- Hardcoded szoveg TILOS UI/email/notification kontextusban
- Datum/penz/szam formazas locale-fuggo (`formatDate`, `formatCurrency`)

```tsx
// ❌ TILOS
<button>Mentes</button>
<input placeholder="Add meg az email cimet" />
toast.error("Sikertelen mentes")

// ✅ Helyesen
<button>{t("common.save")}</button>
<input placeholder={t("user.email_placeholder")} />
toast.error(t("common.save_failed"))
```

Ellenorzes:
```bash
diff <(grep -oE '"[a-z._]+":' hu.ts | sort -u) \
     <(grep -oE '"[a-z._]+":' en.ts | sort -u)
```

---

## 2. Logger (NE console.log)

**Skill:** lasd `.claude/rules/code-style.md`

- **Logger modul** hasznalata (Rust: `tracing`, Python: `logging` strukturalt)
- `console.log` TILOS production kodban
- Strukturalt log: trace_id, level, ts, context (felhasznalo, modul)
- Minden hibanal `tracing::error!` / `logger.error()` (NEM `print!`)

```rust
// ❌ TILOS
println!("ticket created: {:?}", ticket);
eprintln!("error: {}", e);

// ✅ Helyesen
tracing::info!(ticket_id = %ticket.id, user_id = %user.id, "ticket created");
tracing::error!(error = %e, "ticket creation failed");
```

```python
# ❌ TILOS
print(f"User logged in: {user.id}")

# ✅ Helyesen
logger.info("user logged in", extra={"user_id": user.id, "ip": ip})
```

Production observability:
- Loki: structured log aggregation
- Jaeger: distributed tracing (`traceparent` header)
- Sentry: runtime error capture

---

## 3. Audit trail (minden mutacio nyomon kovetese)

**Skill:** `audit-trail-mandatory` (P0)

- **Minden** create/update/delete utan `log_activity()` hivas
- Format: `user_id`, `action={module}_{verb}`, `entity_type`, `entity_id`,
  `details`, `data` (changed fields old→new), `ip`, `user_agent`, `ts`
- PostgreSQL particionalt tabla (havi particiok) + MongoDB collection
- 90 nap utan auto-archive Hetzner S3 WORM bucket-be

```python
await log_activity(
    user_id=str(user["_id"]),
    action="tickets_updated",
    details=f"Ticket #{id} frissitve: {len(changes)} mezo valtozott",
    entity_type="tickets",
    entity_id=str(id),
    data={"changes": {"priority": {"old": "low", "new": "high"}}},
)
```

Sensitive mezok (`password`, `api_key`, `token`) auto-redactalas.

---

## 4. Backup (Hetzner WORM + 90 nap retention)

**Skill:** `backup-strategy`

- **PostgreSQL:** orankenti `pg_dump` → MinIO local + Hetzner S3 mirror
- **MongoDB:** napi `mongodump` → MinIO local + Hetzner S3 mirror
- **MinIO objects:** real-time replication Hetzner S3-ra
- **Hetzner S3 WORM:** Object Lock 90 napos retention (immutable)
- **Restore teszt:** napi `daily-backup-verify.yml` routine random restore-ral
- **Activity log archive:** 90 nap utan auto S3 (audit-trail-mandatory)

Modul-specifikus:
- Uj tabla → migration fajl tartalmazza a backup metaadatot (PII-flag, retention)
- Sensitive PII → kulon retention class (GDPR right-to-be-forgotten kompatibilis)

---

## 5. CRUD + Permission + Role (RBAC kotelezo)

**Skill:** `permission-rbac` (P0)

- **CRUD:** minimum 5 endpoint per modul (list, view, create, edit, delete)
- **Soft delete:** `is_deleted = true`, SOHA fizikai DELETE uzleti adaton
- **Permission:** `{module}.{action}` formatum (pont szeparator, NEM kettospont)
- **Endpoint guard:** minden endpointon `require_permission()`
- **Role:** admin/editor/viewer/superadmin (BUILTIN_ROLES)
- **Frontend permission check:** csak UI hint, backend MINDIG ujraellenorzi
- **superadmin SOHA NEM szukul** (`list(PERMISSIONS.keys())`)

```python
@router.get("")
async def list_tickets(
    user=require_permission("tickets.list"),    # NEM Depends(require_permission(...))
    session=Depends(get_pg_session),
):
    ...
```

Permission hozzadasakor frissits:
1. `permissions.py` `PERMISSIONS` dict
2. `PERMISSION_GROUPS` array
3. `BUILTIN_ROLES` (admin/editor/viewer szintek)

---

## 6. DLA menu struktura (Dashboard / List / Add + [id])

**Skill:** `dla-menu-pattern`

Minden admin modul **4 oldal** (kulon URL):

```
/{module}/                  → 301 redirect → /{module}/dashboard
/{module}/dashboard         → KPI grid + recent items
/{module}/list              → kereses + szures + lapozas + tablazat
/{module}/add               → letrehozo form (NEM /new!)
/{module}/[{id}]            → detail + inline edit (NEM /:id/view + /:id/edit!)
```

Mindegyikhez:
- `loading.tsx` (StatGridSkeleton / TableSkeleton / FormSkeleton / DetailSkeleton)
- Dark mode kotelezo (`dark:` variantok)
- `menuConfig.ts` regisztracio (APPS + CATEGORIES + resolveActiveApp)
- shadcn/ui + Tailwind (NEM MUI / NEM Bootstrap)
- `lucide-react` ikonok (NEM custom icon library)

---

## Egyutt: minimum checklist uj modulhoz

```
[ ] i18n: hu.ts + en.ts kulcsok parhuzamosan, hardcoded szoveg nincs
[ ] Logger: tracing/logging hasznalat, console.log/print nincs
[ ] Audit trail: log_activity() minden CRUD mutacional
[ ] Backup: tabla migration + retention metaadat
[ ] Permission: 5+ permission, require_permission minden endpointon
[ ] Role: BUILTIN_ROLES frissitve (admin/editor/viewer/superadmin)
[ ] DLA: 4 oldal (dashboard/list/add/[id]) + loading.tsx + dark mode
[ ] menuConfig: APPS + CATEGORIES + resolveActiveApp frissitve
[ ] API helper: get/getOne/getStats/create/update/delete minden modulnal
[ ] Test: TDD Iron Law (failing test ELOSZOR — 5. Aranyszabaly)
[ ] Activity log UI: /{module}/[{id}]/history endpoint elerheto
```

A teljes 14-szekcios checklist: `crud-dla-module` skill 13. szekcio.

---

## Hivatkozott

- Master skill: `crud-dla-module` (1448 sor reszletes pattern)
- Cross-cutting skills: `i18n-required`, `audit-trail-mandatory`, `permission-rbac`, `dla-menu-pattern`
- Sister skills: `crud-generator`, `roles-permissions`, `activity-log`, `backup-strategy`, `frontend-design`
- Kapcsolodo rules: `code-style.md`, `security.md`, `testing.md`, `frontend.md`, `database.md`, `api-conventions.md`
- Forras: `specification/skills/crud-dla/crud-dla.md` (eredeti spec)

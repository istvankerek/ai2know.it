---
name: agent-teams-coordinator
description: >
  Agent Teams technikai koordinacio: Redis pub/sub mailbox setup, shared task
  list management, atomic locking, conflict resolution. Multi-agent
  parhuzamositashoz a v5.2 architektura szerint.
  Triggerek: "agent teams setup", "teammate communication", "shared task list",
  "redis pub/sub mailbox", "team lock"
  NE hasznald: egyszeru subagent feladat (akkor Task tool eleg), single-agent workflow.
priority: P2
model: claude-sonnet-4-7
advisor:
  model: claude-opus-4-7
  max_uses: 3
---

# Agent Teams Coordinator

## Cel

A v5.2-ben bevezetett Teammate Mailboxes (Redis pub/sub) technikai
koordinaciojara optimalizalt skill. Akkor aktivalodik, amikor az Agent Teams
infrastrukturalis szempontjait kell kezelni.

## Architektura

```
Team Lead (orchestrator)
    │
    ├── Spawns + assigns tasks
    ▼
Shared Task List (atomic, Redis lock-kal)
    │
Teammate A    Teammate B    Teammate C
    │             │             │
    └─────────────┼─────────────┘
                  ▼
        Redis Pub/Sub channels:
        - team-{id}.broadcast       (one → all)
        - team-{id}.{teammate-x}    (direct mailbox)
        - team-{id}.lead            (report-back)
        - team-{id}.atomic-lock     (mutex)
```

## Channel tipusok

| Channel | Direction | Use case |
|---------|-----------|----------|
| broadcast | One → All | Team-wide announcement |
| {teammate} | One → One | Direct message |
| lead | All → Lead | Status report, completion |
| atomic-lock | Mutex | Shared task list lock |

## Implementacio referencia

A tenyleges Rust kod a backend-ben:
- `apps/backend/src/modules/agent_teams/messaging.rs`
- `apps/backend/src/modules/agent_teams/shared_state.rs`

A skeleton-ben CSAK a konfiguracios template-ek vannak. A tenyleges kodot
a fejleszto irja a projekt-specifikus apps/backend/-ben.

## Settings.json env vars

```json
"AGENT_TEAMS_REDIS_URL": "${REDIS_URL}",
"AGENT_TEAMS_MAILBOX_TTL_SECONDS": "3600",
"AGENT_TEAMS_LOCK_TIMEOUT_SECONDS": "5"
```

## Anti-patterns

- ❌ NEM hasznaljuk single-agent feladatra (overkill)
- ❌ NEM keverjuk a mailbox-ot a tasks/todo.md-vel
- ❌ NEM > 3 teammate (token cost robban)
- ✅ Context-based split (NE role-based)
- ✅ Atomic Redis lock minden shared write-nal
- ✅ /project:plan ELOTTE

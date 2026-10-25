# Parhuzamos Agent-ek Izolalasa — dmux integracio

> **Kapcsolodo skill:** `docker-setup`
> **Forras:** `specification/everengine-v2.3.4-patch-mcp-observability.md` §5
> **Kulso:** [github.com/standardagents/dmux](https://github.com/standardagents/dmux)

## Manualis modszer (alapertelmezett)

Ha 1-2 parhuzamos agent-et futtatsz kulonbozo feladatokra:

```bash
# Agent 1: users modul
git worktree add ../project-agent-users -b feature/users-module
cd ../project-agent-users
claude "Implementald a users modul CRUD endpoint-jait"

# Agent 2: products modul (masik terminalban)
git worktree add ../project-agent-products -b feature/products-module
cd ../project-agent-products
claude "Implementald a products modul CRUD endpoint-jait"

# Merge utan:
git worktree remove ../project-agent-users
git worktree remove ../project-agent-products
```

Elonye: egyszeru, Git-nativ, atlathato.

Hatranya: kezzel kell manage-elni a worktree-ket, a merge-et, a branch cleanup-ot.

## Automatizalt: dmux

A dmux egy Git worktree multiplexer, ami automatizalja a fenti workflowt:

```bash
# Telepites
npm i -g dmux

# Parhuzamos agent-ek inditasa
dmux spawn --agents 3 --task "Implement users, products, orders modules"

# Minden agent sajat worktree-t kap automatikusan:
#   .dmux/agent-1/ (feature/agent-1)
#   .dmux/agent-2/ (feature/agent-2)
#   .dmux/agent-3/ (feature/agent-3)

# Merge:
dmux merge --strategy rebase

# Cleanup:
dmux cleanup
```

## Mikor hasznald dmux-ot

| Szituacio | dmux? |
|-----------|-------|
| 3+ parhuzamos agent ugyanazon projektben | ✅ Igen |
| Nem trivialis merge (atfedo fajlok varhatoak) | ✅ Igen |
| CI/CD pipeline-ban automatizalt multi-agent munka | ✅ Igen |
| 1-2 egyszeru parhuzamos feladat | ❌ Manualis worktree eleg |
| Egymastol fuggo feladatok | ❌ Szekvencialis jobb |
| Fejlesztoi gep, 8GB RAM alatt | ❌ Eroforras igenyes |

## Kockazatok

- **Token koltseg szorzodik** — 3 agent = 3x token hasznalat
- **Merge konfliktus** — ha az agent-ek ugyanazon fajlokat erintik, a rebase fejfajas lehet
- **Context sharing** — az agent-ek nem latjak egymas munkajat, ami duplikacióhoz vezethet

## Kapcsolodo

- `auto-iterate` skill — iterativ javitasi loop (nem parhuzamos)
- `worker-management` skill — backend worker processing (mas ugy)
- v2.3.4 spec §5

---
name: worktree-agent
description: >
  Git worktree izolalt fejlesztes agent [v2.3]. Parhuzamos fejlesztes
  kulon worktree branch-ekben. Hasznald: tobb feature parhuzamos
  implementacioja, izolalt kiserletezes.
model: claude-sonnet-4-6
---

# Worktree Agent

## Cel
Parhuzamos Claude Code instance-ok izolalt Git worktree-kben,
hogy tobb feature egyidejuleg fejlesztheto legyen anelkul,
hogy zavarnk egymast.

## Hasznalat

### Worktree letrehozas
```bash
git worktree add ../project-agent-1 -b feature/agent-1
git worktree add ../project-agent-2 -b feature/agent-2
```

### Parhuzamos fejlesztes
```bash
# Agent 1: users modul
cd ../project-agent-1 && claude "Implementald a users modult"

# Agent 2: products modul (parhuzamosan!)
cd ../project-agent-2 && claude "Implementald a products modult"
```

### Merge
```bash
git checkout main
git merge feature/agent-1
git merge feature/agent-2
git worktree remove ../project-agent-1
git worktree remove ../project-agent-2
```

## Szabalyok
- Minden worktree sajat branch-en dolgozik
- Merge elott: tesztek futtatasa mindket branch-en
- Konfliktus eseten: manualis feloldas szukseges
- Worktree torlese merge utan

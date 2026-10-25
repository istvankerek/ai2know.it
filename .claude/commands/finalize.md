---
description: WIP branch finalizalas – squash merge a feature branch-re
---

# Session finalizalas

A Claude Code minden Edit/Write utan commitol egy WIP branch-re (`wip/claude-*`), hogy "ne veszitsd el egyetlen sort sem". Ez a command segit lezarni a WIP branch-et.

## Aktualis allapot

!`git branch --show-current`

## Legutobbi commitok

!`git log --oneline -10`

## Mi volt az alap branch?

!`cat .git/claude-base-branch 2>/dev/null || echo "main"`

## Lepesek

1. Kerdezd meg a felhasznalot melyik opciot valassza:

   **a) Squash merge** (ajanlott) — egy commit, tiszta history
   ```bash
   git checkout <alap-branch>
   git merge --squash <wip-branch>
   git commit -m "feat(<modul>): <leiras>"
   git branch -D <wip-branch>
   ```

   **b) Rebase** — minden WIP commit megmarad
   ```bash
   git checkout <alap-branch>
   git rebase <wip-branch>
   git branch -D <wip-branch>
   ```

   **c) Elvetes** — rossz iranyba mentunk
   ```bash
   git checkout <alap-branch>
   git branch -D <wip-branch>
   ```

2. A valasztott opciot hajtsd vegre **csak expliciten jovahagyott parancsokkal**.
   - Az `L1 APPROVE` guardrail: delete/reset muvelet csak jovahagyas utan.
3. A WIP branch cleanup utan a `.git/claude-base-branch` fajlt toroljed:
   ```bash
   rm -f .git/claude-base-branch
   ```

## Worktree lezaras (v8.1)

Ha a munka worktree-ben folyt (`worktrees/<slug>/`), beolvasztas utan:
```bash
./scripts/close-worktree.sh worktrees/<slug>    # tiszta + beolvasztott → eltavolitja
./scripts/close-worktree.sh --stale             # minden lezarhato (agent-worktree-k is)
```

## Fontos szabalyok

- **SOHA ne pushold a WIP branch-et** — ezek lokalis mentesek
- **SOHA ne commitolj main-re** (L0 aranyszabaly #4)
- A squash merge commit uzenete pontos es beszédes legyen (konvencionalis commit: `feat(scope): leiras`)
- Ha nem vagy biztos, kerdezd meg a fejlesztot mielott destruktiv muveletet vegzel

## Kapcsolodo

- `.claude/hooks/auto-commit.sh` — amely a WIP commitokat letrehozza
- CLAUDE.md § Aranyszabalyok

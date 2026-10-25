---
name: workflow-runner
description: |
  YAML workflow futtatas, allapotkövetes es folytatasi kepesseg hiba utan.
  Triggerek: "futtasd a workflow-t", "workflow run", "folytasd a workflow-t",
  "workflow status", "workflow resume", "/project:workflow run".
license: Everengine v6.5
priority: P1
model: claude-sonnet-4-6
---

# Workflow Runner Skill

## Cel
`.claude/workflows/*.yml` fajlok vegrehajtasa, allapotkovetes es resume kepesseg.

## Mukodes

### Workflow betoltese
```bash
cat .claude/workflows/{workflow_name}.yml
```

### State fajl
Minden workflow futashoz state fajl keletkezik:
`.claude/workflows/state/{workflow_name}-{timestamp}.json`

```json
{
  "workflow": "aibos-feature-dev",
  "started_at": "2026-04-27T10:00:00Z",
  "status": "running",
  "current_step": "impl",
  "completed_steps": ["brainstorm", "plan", "tdd"],
  "failed_steps": [],
  "outputs": {}
}
```

### Lepesek vegrehajtasa
1. Olvasd be a YAML-t
2. Kovesd a `depends_on` sorrendet
3. Minden lepesnel frissitsd a state fajlt
4. Hiba eseten: rogzitsd a hibat, ne all meg

### Resume
Ha a state fajl letezik es `status != "completed"`:
- Ugorj a `current_step`-re
- Ugord at a mar elvegzett lepeseket

## Subcommands

| Parancs | Leiras |
|---------|--------|
| `list` | Elerheto workflow-k listazasa |
| `run <nev>` | Workflow futtatasa |
| `status [nev]` | Futasban levo vagy utolso workflow statusza |
| `resume <state-file>` | Megszakitott workflow folytatalsa |

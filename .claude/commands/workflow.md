# /project:workflow – Workflow Kezelese

> Everengine v6.5 Workflow Layer

## Hasznalat

```
/project:workflow <subcommand> [argumentumok]
```

## Subcommands

### list
```
/project:workflow list
```
Elerheto workflow-k listazasa.

```bash
ls .claude/workflows/*.yml | xargs -I{} basename {} .yml
```

### run
```
/project:workflow run <workflow-nev>
```
Workflow futtatasa a YAML definicio alapjan.

```bash
# Workflow letezik-e?
test -f ".claude/workflows/$1.yml" || { echo "Workflow nem talalhato: $1"; exit 1; }
echo "Workflow inditasa: $1"
cat ".claude/workflows/$1.yml"
```

Hasznald a `workflow-runner` skill-t a teljes vegrehajtashoz.

### status
```
/project:workflow status [workflow-nev]
```
Futasban levo vagy utolso workflow allapota.

```bash
ls -t .claude/workflows/state/*.json 2>/dev/null | head -5 | xargs -I{} cat {}
```

### resume
```
/project:workflow resume <state-fajl>
```
Megszakitott workflow folytatalsa a state fajl alapjan.

```bash
test -f "$1" || { echo "State fajl nem talalhato: $1"; exit 1; }
cat "$1"
echo "Resume a fenti state alapjan..."
```

Hasznald a `workflow-runner` skill-t a folytatashoz.

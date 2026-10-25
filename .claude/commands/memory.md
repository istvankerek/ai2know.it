# /project:memory – Memory v2 Kezelese

> Everengine v6.5 Memory v2 (RAD – Retrieval Augmented Distillation)

## Hasznalat

```
/project:memory <subcommand> [argumentumok]
```

## Subcommands

### search
```
/project:memory search <kulcsszo>
```
Keresi a relevanc tapasztalatokat az observations adatbazisban.

```bash
sqlite3 .claude/memory/observations.db \
  "SELECT type, title, content, tags FROM observations WHERE tags LIKE '%$1%' OR title LIKE '%$1%' OR content LIKE '%$1%' LIMIT 10;"
```

### save
```
/project:memory save <tipus> "<cim>" "<tartalom>" [tagek]
```
Uj observation mentese.

Tipusok: `bugfix`, `discovery`, `decision`, `gotcha`, `pattern`, `trade-off`, `how-it-works`

```bash
sqlite3 .claude/memory/observations.db \
  "INSERT INTO observations (session_id, type, title, content, tags) VALUES ('$(date +%Y%m%d-%H%M%S)', '$2', '$3', '$4', '$5');"
```

### promote
```
/project:memory promote
```
3+ alkalommal elofordulo tag-u observationokat promotalja `patterns.md`-be.

```bash
bash .claude/hooks/memory/memory-promote-patterns.sh
```

### cleanup
```
/project:memory cleanup [napok]
```
Regi (alapertelmezett: 90 napnal regebbi) nem-kritkius observationok torlese.

```bash
sqlite3 .claude/memory/observations.db \
  "DELETE FROM observations WHERE timestamp < datetime('now', '-${1:-90} days') AND type NOT IN ('pattern', 'decision', 'gotcha');"
echo "Cleanup kesz."
```

### review
```
/project:memory review
```
Megmutatja a global.md, patterns.md es mistakes.md tartalmat.

```bash
echo "=== global.md ===" && cat .claude/memory/global.md
echo "=== patterns.md ===" && cat .claude/memory/patterns.md
echo "=== mistakes.md ===" && cat .claude/memory/mistakes.md
```

### stats
```
/project:memory stats
```
Adatbazis statisztika: observation szamok tipusonkent.

```bash
sqlite3 .claude/memory/observations.db \
  "SELECT type, COUNT(*) as db FROM observations GROUP BY type ORDER BY db DESC;"
```

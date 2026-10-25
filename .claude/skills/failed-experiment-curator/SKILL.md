---
name: failed-experiment-curator
description: |
  Kudarcba fulladt kiserletezesek dokumentalasa es archiválása.
  Megelozi az ismételt kudarcokat es a "ne menjunk le ujra arra az utcara" tudast rogziti.
  Triggerek: "ez nem mukodik, lezarom", "nem erte meg", "lock decision",
  "dead end", "kiserlet kudarcba fulladt", "nem folytatjuk".
license: Everengine v6.5
priority: P2
model: claude-sonnet-4-6
---

# Failed Experiment Curator Skill

## Cel
`experiments/failed-ideas/` mappa strukturalt kezeleseert felel.
Megakadalyozza, hogy ugyanazt a zsak utcat ketsezet belefussuk.

## Fajl formatum
`experiments/failed-ideas/YYYY-MM-DD-{nev}.md`

```markdown
# [Kiserlet neve]

**Datum:** YYYY-MM-DD
**Dontes:** Lezarva
**Koveto:** [issue/ADR, ha van]

## Mit probaltunk
...

## Miert nem mukodott
...

## Amit tanultunk
1. ...

## Alternativa
...
```

## Folyamat

1. Azonositsd a kiserlet nevet es datumat
2. Hozd letre a fajlt a fennt formatum szerint
3. Toltsd ki az osszes szekciot valodi tartalommal
4. Mentsd az observation adatbazisba is (tipus: `decision`)
5. Frissitsd `mistakes.md`-t ha van altalanos tanulsag

## Keresesek
```bash
ls experiments/failed-ideas/*.md
sqlite3 .claude/memory/observations.db \
  "SELECT title, content FROM observations WHERE type = 'decision' LIMIT 10;"
```

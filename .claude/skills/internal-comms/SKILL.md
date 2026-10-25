---
name: internal-comms
description: |
  Belso csapat kommunikacio: Slack, email, Telegram ertesitesek.
  3P format (Progress/Plans/Problems) es magyar voice hasznalata.
  Triggerek: "ertesitsd a csapatot", "kuldd el az updateet", "heti riport",
  "notify team", "progress update", "3P format".
license: Everengine v6.5
priority: P2
model: claude-sonnet-4-6
---

# Internal Comms Skill

## Cel
Belso csapat ertesitesek generalasa a 3P format es Everengine voice alapjan.
Adapter wrapper a `notification-system` skill fole.

## 3P Format

```
## Progress (Haladas)
- Mit csinalunk elkeszult

## Plans (Tervek)
- Kovetkezo lepesek

## Problems (Problemak)
- Mi blokkal, mi a kockazat
```

## Magyar Voice Szabalyok
- Baratsagos, de professzionalis
- Konkret, nem vague
- Nem tulzott ("fantasztikus eredmenyek" helyett: "X kesz, Y folyamatban")
- Anti-style: nincs em-dash, nincs AI fluff

## Csatornazas

| Esemenye | Csatorna | Urgencia |
|---------|----------|---------|
| Feature kesz | Slack #dev | Normal |
| Bug hotfix | Slack #incidents | Magas |
| Heti riport | Email | Normal |
| Prod incident | Slack #alerts + Email | Azonnali |

## Hasznalat

Ertesites generalasahoz add meg:
1. Mi tortent (esemeny tipusa)
2. Kinek szol (csapat/szemely)
3. Milyen urgencia

A skill megirja a szoveget a 3P format es voice alapjan.

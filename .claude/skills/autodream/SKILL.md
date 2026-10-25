---
name: autodream
description: >
  Projekt memoria rendrakas es tanulsag-kinyeres. Session history elemzes,
  ismetlodo mintak felismerese, CLAUDE.md/rules/ADR frissitesi javaslatok.
  Triggerek: "autodream", "projekt rendrakas", "mit tanultunk",
  "session review", "memoria frissites", "tanulsagok".
  NE hasznald: aktiv fejlesztes kozben, debug, kod review, feature munka.
  Ez session-ok KOZOTT futtatando, nem session kozben.
allowed-tools: Read, Grep, Glob, Bash
model: claude-sonnet-4-6
---

# Autodream – Projekt Memoria Rendrakas

## Mikor futtasd
- Sprint vegen (ketheti ciklus)
- Nagyobb milestone utan
- Ha ugy erzed "mindig ugyanazt javitjuk"
- Heti egyszer utemezetten (opcionalis)

## Bemenet (ezeket elemzi)

### 1. Prompt Log (`.claude/prompt-log/`)
- Utolso N session osszefoglaloi
- Milyen feladatokat kertunk
- Milyen hibakat javitottunk
- Mennyit koltottunk (token, $)

### 2. COORDINATION.md
- Nyitott kerdesek (megvalaszoltak-e?)
- Ismetlodo "kovetkezo lepes"-ek (soha nem csinaloednak meg?)

### 3. Git History
```bash
git log --oneline --since="2 weeks ago" --format="%s"
```
- Commit uzenetek mintai
- Milyen fajlokat modositottunk leggyakrabban (hotspot-ok)

### 4. Meglevo CLAUDE.md + rules/
- Elavult instrukciok (a kod mar nem igy mukodik)
- Hianyzo instrukciok (ismetlodo hibak, amiket rule-lal meg lehetne elozni)

## Elemzesi szempontok (tematikus, NEM kronologikus)

### A. Ismetlodo hibamintak
- Milyen tipusu hibakat javitottunk tobbszor?
- Van-e kozos gyokerok? (hianyzo teszt, rossz konvencio, elavult docs)
- Javaslat: uj rule vagy CLAUDE.md kiegeszites ami megelozi

### B. Koltseg-anomaliak
- Mely session-ok voltak dragak? Miert?
- Volt-e felesleges Opus hasznalat?
- Javithato-e a prompt specifikussabba tetelevel?

### C. Skill hasznalati mintak
- Melyik skill-eket aktivaltuk gyakran? (ezek jol mukodnek)
- Melyik skill-eket NEM aktivaltuk soha? (lehet feleslegesek vagy rossz a trigger)
- Hianyzik-e skill egy ismetlodo feladatra?

### D. Architekturalis dontesek
- Szulettek-e implicit dontesek (kodban igen, ADR-ben nem)?
- Javaslat: ADR letrehozas a felismert dontesekhez

### E. CLAUDE.md elavulas
- A CLAUDE.md-ben emlitett parancsok/strukturak leteznek-e meg?
- A tech stack leiras egyezik-e a package.json/Cargo.toml-lal?
- A konvenciok tukrozik-e a valodi kodot?

## Kimenet formatum

### 1. Osszefoglalo riport
```markdown
# Autodream Riport – {{DATUM}}

## Fo megallapitasok
1. [Legfontosabb minta/tanulsag]
2. [Masodik legfontosabb]
3. [Harmadik]

## Ismetlodo hibamintak
- [Minta]: [N] alkalommal fordult elo -> Javasolt megelozes: [...]

## Koltseg elemzes
- Atlag session koltseg: $X.XX
- Legdragabb feladat tipus: [...]
- Javaslat: [...]

## Skill audit
- Legaktivabb: [skill neve] (N alkalommal)
- Soha nem aktivalodott: [skill neve] -> Javaslat: trigger modositas vagy eltavolitas
- Hianyzo skill: [feladat leiras]
```

### 2. Konkret modositasi javaslatok
- CLAUDE.md modositasi javaslatok
- Javasolt uj rules/ fajl
- Javasolt ADR

### 3. Akciopontok (emberi jovahagyasra var!)

> Az autodream SOHA nem modosit fajlt automatikusan.
> Csak javaslatokat tesz, amiket a fejleszto jovahagyd vagy elvet.
> Ez L1 guardrail szintu – CLAUDE.md modositas emberi jovahagyas kell.

## Futtatas

### Manualis
```
claude "Futtass autodream-et az elmult 2 het session-jein"
```

### Sprint vegen (ajanlott)
```
claude "/project:autodream"
```

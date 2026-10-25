---
name: brand-interview
description: 90 perces strukturalt interju a brand identity feltarasara. Aktivalodik ha "brand interview", "brand workshop", "identity feltaras", "ki vagyunk" kerdes johet.
license: Everengine v6.1
priority: P2
model: claude-opus-4-7
effort: xhigh
advisor_max_uses: 0
---

# Brand Interview

## Cel
90 perces moderalt interju a fejlesztovel/csapattal a brand identity 14 fajl
(`.claude/identity/`) kitoltesere. Strukturalt, nem rohan, jol kerdez, jol jegyzetel.

## Mikor aktivalodik
Trigger: "brand interview", "brand workshop", "identity feltaras", "kik vagyunk
kerdes", "uj brand letrehozasa", "brand audit a 0-rol".

## Munkafolyamat (7 fazis, ~13 perc fazisonkent)

### Fazis 1: WHO (kik vagyunk) – 13 perc
- Mi a ceg neve, alapitas eve?
- Hany ember, hany orszagban?
- Mi a "rovid pitch" (1 mondatos)?
- Mit hagytunk magunk mogott / mibol nottunk ki?
- → `about-us.md` kitoltese

### Fazis 2: WHAT (mit csinalunk) – 13 perc
- Top 3 termek, mindegyikrol 2 mondat
- Melyik termek a legnagyobb bevetel?
- Melyiket szeretjuk legjobban (szubjektive)?
- Mit NEM csinalunk (kategoria-szukites)?
- → `mission.md` kitoltese

### Fazis 3: REJECT (mit utalunk) – 13 perc ⭐ KRITIKUS
- Mutass 3 versenytars copy-jat → mit utalsz benne?
- Melyik AI-frazist hallottad mar 100x?
- Mire mondod: "ezt aztan SOHA"?
- Em-dash, "Let's dive", "innovativ" konkret pelda → utalod?
- → `anti-style.md` finomitas (alap 10 kategoria + sajat tilalmak)

### Fazis 4: WHY (miert csinaljuk) – 13 perc
- Miert pont ezt a problémat?
- Mit valtozott a piacon ami miatt most kell ez?
- Hol leszel 5 ev mulva ha minden jol megy?
- Hol leszel 5 ev mulva ha minden rosszul megy?
- → `vision.md` kitoltese

### Fazis 5: HOW (hogyan beszelunk) – 13 perc
- Tegezol vagy magazol a vegfelhasznaloval?
- Komoly vagy laza a hangnem?
- Mutass egy peldat egy "tipikus" copy-dra
- Mit csak/csak tegezol (developer), mit magazol (CFO)?
- → `voice.md` kitoltese

### Fazis 6: AUDIENCE (kinek beszelunk) – 13 perc
- 4 audience reszletes profil:
  - Developer
  - Decision-maker
  - End-user
  - Support-agent
- Mindegyikrol: pain point, mit ertekel, mit utal, hogyan kommunikalsz vele?
- → `audience/{role}.md` kitoltes (4 fajl)

### Fazis 7: VALIDATE (ellenorzes) – 13 perc
- Generalj 3 mintacopy-t (egy emailing, egy landing headline, egy press release lead)
- Olvasd hangosan: "ez igy hangzik mint mi"?
- Ha nem → vissza Fazis 5/6-ra finomitasra
- Vegul: kerd a fejlesztot hogy commitolja a `.claude/identity/`-t

## Kerdezesi szabaly
- 1 kerdes / valasz, NE batch
- Ha "nem tudom" → adj 3 peldat valasztashoz
- Ha tul absztrakt → kerd: "mondj egy konkret peldat tegnaprol"
- NE jegyzetelj amig nem mondtak el – csak utana foglalod ossze

## Output template
Minden fazis vegen:
```markdown
## Fazis X osszefoglalo
**Kulcs valaszok:**
- [bullet 1]
- [bullet 2]
- [bullet 3]

**Beirando ide:** `.claude/identity/{fajlnev}.md`
**Konkret tartalom (proba-irom):**
[Generated content]

→ Megfelel? (igen/finomitas)
```

## Kovetkezo lepes
A 7 fazis vegen:
1. Generalt `.claude/identity/*.md` 14 fajl mind kitoltve
2. `git diff .claude/identity/` ellenorzes
3. Commit: `feat: brand identity feltarasa (interview {date})`

## Hivatkozott
- Output: `.claude/identity/` (14 fajl)
- Forras: `everengine-v6.1-patch-brand-identity.md`

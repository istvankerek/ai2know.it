# Anti-Style Dictionary — Tiltott szavak/kifejezesek (v7.1)

> Ez a fajl konkret listak. Mindig olvasd be content generalas elott.
> A `voice.md` adja az ELVEKET, ez a fajl adja a TILTOTT KONKRETUMOKAT.
> A `brand-auditor` skill mindkettot nezi.

---

## A) Magyar — altalanosan tiltott szavak

### Marketing slop magyar
```
- "forradalmi"
- "innovativ" (kiveve technical paper)
- "csodalatos"
- "elkepeszto"
- "kihagyhatatlan"
- "legjobban"
- "kihasznalni" (mint marketing ige — "leverage" tukorforditas)
- "felhasznalok" (hasznalj inkabb: "ugyfelek" vagy konkret terminologia)
- "lehetoseg" (ures szo)
- "elmeny" (ures szo marketing kontextusban)
- "rohano vilagban" (frazis)
- "modern, gyorsan valtozo"
- "egyszer s mindenkorra"
- "vilag-szinvonalu"
- "ipar-vezeto"
- "next-generation magyarul"
```

### AI fluff magyar
```
- "Boldogan segitek!"
- "Lepesrol lepesre gondolkozom..."
- "Termeszetesen!"
- "Nagyon jo kerdes!"
- "Kivalo eszrevetel!"
- "Reszletesen elmagyarazom..." (csak csinald)
- "Remeljuk, hasznos volt"
- "Koszonjuk az idot!"
- "Szivesen!"
- "Persze, segitek..."
```

### Hivatalos magyar antipatternek
```
- "Udvozoljuk a {name} oldalon!"
- "Kerjuk, varjon..."
- "A muvelet sikeresen vegrehajtva."
- "Az alabbi hibaba utkozott..."
- "Kerjuk, ellenorizze a megadott adatokat."
- "Biztonsaga erdekeben..."
- "A rendszer tajekoztatja..."
- "Felhivjuk a figyelmet..."
- "Tisztelt Felhasznalo..."
```

---

## B) Angol — tiltott szavak (kod-kommentekben, dokumentacioban)

### Marketing slop English
```
- "leverage" (mint ige)
- "unlock"
- "in today's fast-paced world"
- "game-changer"
- "revolutionary"
- "best-in-class"
- "world-class"
- "cutting-edge"
- "next-generation"
- "delve into"
- "diving deep"
- "robust" (kiveve technical: robust error handling)
- "seamless" (kiveve technical: seamless integration)
- "supercharge"
- "synergy"
```

### AI fluff English
```
- "I'd be happy to help!"
- "Let me think through this step-by-step..."
- "Great question!"
- "Excellent observation!"
- "Hopefully this helps!"
- "Feel free to ask if you need clarification"
- "Certainly!"
- "Absolutely!"
- "Of course!"
- "Let's dive in"
- "Here's the thing"
```

---

## C) Email/uzenet konvencio

### Tiltott salutation
```
- "Tisztelt Felhasznalonk!"
- "Kedves Vasarlonk!"
- "Hello there!"
- "Dear Sir/Madam"
- "Hi {generic_role}!"
```

### Helyette
```
- Ha tudjuk a nevet: "Szia Janos" / "Hi John"
- Ha nem tudjuk: csak kezd a tartalommal, nincs salutation
```

### Tiltott alairas
```
- "Udvozlettel,\nA {Cegnev} csapat"  (szemelytelen)
- "Best regards,\nThe Team"           (szemelytelen)
- "Cheers!" + emoji bombazas
- "Stay awesome!"
```

### Helyette
```
- Konkret szemely: "Istvan — Everengine"
- Vagy semmi (ha emailes context mar tudja kitol jon)
```

---

## D) Felkialtojel-szabaly

```
Felkialtojel HASZNALATA:
  ✅ Veszjelzes:   "Soha ne commitolj main-re!"
  ✅ Tanulsag:     "Process scales. Vibes don't!"
  ✅ Unneples:     "Migracio kesz!"

Felkialtojel TILTAS:
  ❌ Udvozles:     "Szia Janos!"     → "Szia Janos"
  ❌ Marketing:    "Csodalatos hir!"  → "Hir:"
  ❌ Biztatas:     "Probald ki!"      → "Probald ki"
  ❌ Szabaly:      "Maximum 1 felkialtojel email-enkent"
```

---

## E) Em-dash kontroverzia

A Cowork rendszerek (Ruben Hassid kep 3) javasoljak az em-dash teljes tiltasat
("No em-dashes."). Ez **TUL SZIGORU a magyar nyelvre**, mivel:

- Magyar tipografiai gondolatjel: " - " (en-dash spaces-szel)
- AI tipikus minta: " — " (em-dash) → ezt KERULD
- Mondat kozi tag: vesszo eleg, nem kell dash

```
Tiltas:
  ❌ "—"  (em-dash, AI tipikus)
  ❌ Tobb dash mondatonkent

Engedett:
  ✅ " - "  (en-dash spaces-szel, ritkan)
  ✅ Vesszo helyett (preferred)
```

---

## F) Bekezdes-hossz szabaly

```
Maximum 3 mondat / bekezdes (chat, email, blog).
Tobb mondat = kulon bekezdes.

Marketing copy: max 2 mondat / bekezdes.
Technikai dokumentacio: max 5 mondat / bekezdes.
```

---

## G) Auto-detect hasznalat

Ez a szotar auto-aktivalodik a `brand-auditor` skill-en keresztul:

```
weekly-brand-audit Routine:
  Scope: minden user-facing fajl (md, html, jsx, email templates)
  Match against: anti-style.md ELVEK + anti-style-dictionary.md SZAVAK

  Severity:
    HIGH:    AI fluff, marketing slop a stakeholder doc-ban
    MEDIUM:  em-dash, hosszu bekezdes
    LOW:     egy-egy felkialtojel
```

---

## H) Override mechanizmus

Ha szandekosan kell egy tiltott szot hasznalni (pl. ugyfelidezet),
hasznalj inline kommentet:

```markdown
<!-- anti-style-override: szandekos idezet az ugyfeltol -->
"Ez egy elkepeszto rendszer!" — Janos, vasarlo
```

Az override-ot a `check-brand.sh` hook respektalja, a heti audit nem jelez.

---

## Kapcsolodo

- Elvek: `.claude/identity/anti-style.md` (10 kategoria)
- Hangnem: `.claude/identity/voice.md`
- Auto-detect: `.claude/hooks/check-brand.sh` (PostToolUse)
- Skill: `.claude/skills/brand-auditor/SKILL.md`
- Routine: `.claude/routines/scheduled/weekly-brand-audit.yml`
- Forras: v7.1 patch Section 3 (Ruben Hassid "Define taste by what you NEVER say")

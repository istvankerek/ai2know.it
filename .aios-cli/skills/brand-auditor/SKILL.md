---
name: brand-auditor
description: Brand consistency check user-facing content-en. Aktivalodik ha "marketing copy", "email", "landing page", "blog post", "press release" megjelenik a feladatban.
license: Everengine v6.1
priority: P2
model: claude-sonnet-4-6
advisor: claude-opus-4-7
advisor_max_uses: 1
---

# Brand Auditor

## Cel
Anti-style auto-detect + brand-konzisztencia ellenorzes minden user-facing tartalmon
(marketing copy, email, landing page, blog post, press release, sajtoanyag).

## Mikor aktivalodik
Trigger kulcsszavak: "marketing copy", "email", "landing", "blog", "press release",
"sajtoanyag", "newsletter", "brand", "copy", "headline", "tagline".

## Mit csinal

### 1. Identity context betoltes (kotelezo)
Olvasd be:
- `.claude/identity/voice.md` (hangnem)
- `.claude/identity/anti-style.md` (10 kategoria tilalom)
- `.claude/identity/anti-style-dictionary.md` (v7.1, KONKRET tiltott szavak: marketing slop, AI fluff, hivatalos antipatternek, em-dash, felkialtojel-szabaly)
- Ha a feladat brand-specifikus → `.claude/identity/brand-{name}.md`
- A celkozonseg fajl → `.claude/identity/audience/{detected}.md`

### 2. Audit kategoriak (anti-style.md alapjan)
Minden generalt szovegen ellenorizd:

1. **Em-dash (—) tilalom** – grep `—` → ha talalsz, jelezd
2. **AI-frazisok** – grep "Let's dive", "Here's the thing", "It's not just X — it's Y", stb.
3. **Ures szuperlatívuszok** – grep "innovativ", "forradalmi", "best-in-class", "world-class"
4. **Empty hype** – pattern: "{adjective} {industry/product} solution" tartalom nelkul
5. **Marketing-szleng** – "robust", "scalable", "seamless", "end-to-end" konkretum nelkul
6. **Ures igeret** – "garantaltan", "100%", "barmilyen", "mindent megoldunk"
7. **Ures CTA** – "Click here", "Learn more", "Get started" konkret action nelkul
8. **False intimacy** – "Hey [name]!", "Just wanted to drop you...", emoji-eso
9. **Korporátos passziv** – "kerul feldolgozasra", "It is important to be noted"
10. **AI watermark** – minden bekezdesben **bold** + bullet, gepies struktura

### 3. Kimenet formatum
```markdown
## Brand Audit: {fajl/tartalom neve}

### ✅ Brand-aligned (X eset)
- [pl. "Magyar terminologia konzisztens (Bejelentkezes nem Login)"]

### ⚠️ Anti-style talalat (Y eset)
1. **Em-dash a 14. sorban** – cserejjuk pontra vagy kettospontra
2. **"unlock the power of"** – pattern #2 (AI-frazis) → konkret kepessegre cserelni
3. **"innovativ megoldas"** (3. sor) – pattern #3 → mereshetonek
   - **Javaslat:** "12 ms p99 latency, 1000 RPS throughput"

### 🔴 Brand-tores (Z eset)
- [Sulyos eset, pl. megszunt IdP nev hasznalata (a domain mar skillpass.id)]

### Score: X/10 (cel: >= 9)
```

### 4. Auto-fix opcio
Ha a fejleszto kéri ("auto-fix" vagy "javitsd ki"):
- Em-dash → pont/kettospont auto-csere
- "Let's dive" → "Nezzuk meg" (vagy magyar megfelelo)
- "innovativ" → 'TODO: konkret szam ide' placeholder (nem auto-talal helyettesitot,
  meg kell nyitnia a fejleszto)

## Pelda hasznalat
```
User: "Generalj egy email-t az aiBOS launch-hoz fejlesztoknek."
Skill aktivalodik → beolvas:
  - identity/voice.md
  - identity/anti-style.md
  - identity/brand-aibos.md
  - identity/audience/developer.md
Generalas + audit egyszerre → 9.5/10 score, 1 warning.
```

## Hivatkozott
- Hook: `.claude/hooks/check-brand.sh` (auto-detect minden modositott md/jsx-en)
- Command: `/project:brand-check` (manualis audit-trigger)
- Forras: `everengine-v6.1-patch-brand-identity.md`

---
name: brand-check
description: Brand audit – ellenorzi a generalt vagy modositott user-facing tartalmat az anti-style.md tilalmai es a voice.md hangnem-szabalyok alapjan
---

# /project:brand-check

Brand-konzisztencia audit a generalt user-facing tartalomra (marketing copy, email,
landing page, blog post, press release, sajtoanyag, in-app szovegek).

## Mit csinal

1. **Identity context betoltes:**
   - `.claude/identity/voice.md`
   - `.claude/identity/anti-style.md`
   - Brand-detect: ha "aibos" → `brand-aibos.md`, stb.
   - Audience-detect: ha "developer" → `audience/developer.md`, stb.

2. **Brand-auditor skill aktivalas** (lasd `.claude/skills/brand-auditor/`)

3. **Audit kategoriak (anti-style.md 1-10):**
   - Em-dash, AI-frazisok, ures szuperlatívuszok, empty hype, marketing-szleng,
     ures igeret, ures CTA, false intimacy, korporátos passziv, AI watermark

4. **Output:**
   - ✅ Brand-aligned (szam)
   - ⚠️ Anti-style talalat (szam + javaslat)
   - 🔴 Brand-tores (sulyos eset)
   - **Score: X/10** (cel: >= 9)

5. **Auto-fix opcio:** "javitsd ki" parancsra alapveto fix-eket vegrehajt
   (em-dash, ismert AI-frazisok cseréje), de szuperlatívuszok cserejehez
   kerdez konkret szamot.

## Hasznalat

```
/project:brand-check
```

vagy konkret fajlra:

```
/project:brand-check apps/admin/src/pages/Landing.tsx
```

vagy paste-elt szovegre (clipboard / inline):

```
/project:brand-check
[paste a copy ide]
```

## Kovetkezmenyek

- Score < 7 → blokkold a commit-ot, fixeld eloszor
- Score 7-8 → warning, javasolt javitas mielott shipping
- Score >= 9 → ✅ go

## Hivatkozott
- Skill: `.claude/skills/brand-auditor/`
- Identity: `.claude/identity/`
- Hook: `.claude/hooks/check-brand.sh` (auto-detect minden md/jsx-en)
- Routine: `.claude/routines/scheduled/weekly-brand-audit.yml` (heti riport)

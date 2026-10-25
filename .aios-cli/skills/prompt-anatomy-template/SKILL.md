---
name: prompt-anatomy-template
description: >
  7-szekcios prompt template generalas kritikus feladatokhoz (Hamza Khalid).
  Kombinalja a Tier S/SS prompt szabvanyt (v5.5) a 7-section strukturaval.
  Auto-fill ahol lehet (role, audience, context files, anti-style).
  Output: kitoltheto template + outputs/prompts/{date}-{slug}.md.
  Triggerek: "Tier SS prompt", "perfect prompt", "kritikus feladat",
  "prompt template", "build prompt", "structured prompt", "anatomy".
license: Everengine v7.1
priority: P1
model: claude-sonnet-4-6
---

# Prompt Anatomy Template

## A 7-szekcios template (Hamza Khalid)

```markdown
# {TASK_NAME}

## 1. Task + Identity

I want to {TASK} so that {SUCCESS_CRITERIA}.
My role is {YOUR_ROLE}.
The audience is {WHO_READS_THIS}.

## 2. Context Files (read FIRST, before responding)

Read these completely before responding:

- {filename1.md} — {what it contains, why relevant}
- {filename2.md} — {what it contains, why relevant}
- {filename3.md} — {what it contains, why relevant}

These are my standards, constraints, and landmines.
If you are about to break one of my rules, STOP AND TELL ME.

## 3. Reference (what good looks like)

Here is a reference of what I want to achieve:

{Reference content — upload file or paste blueprint}

Here is what makes this reference work:
- Pattern A: {explanation}
- Pattern B: {explanation}
- Tone: {description}
- Structure: {description}
- Rules: ALWAYS {x}, NEVER {y}

## 4. Success Brief

**Type of output**: {contract / memo / report / proposal / landing / post}
**Length**: {word count or page count target}

**Recipient's reaction (after reading)**:
- Should think: {what}
- Should feel: {how}
- Should do: {action}

**Does NOT sound like**:
- Generic AI
- Too casual
- Formal/jargon-heavy
- Robotic

**Does sound like**:
- Confident
- Direct
- Warm
- Technical
- Conversational

**Success means**: {they sign? approve? reply? buy?}

> Ez a szekcio onmagaban 10x jobb output-ot ad. SOHA NE hagyd ki.

## 5. Pre-Flight Check (BEFORE writing anything)

Before you write anything:

1. **List the 3 rules from my context files that matter MOST for this task.**
2. **Tell me what is UNCLEAR or MISSING.** Ask up to 5 clarifying questions.
3. **Identify the single biggest RISK.** Tell me how you will avoid it.

## 6. Execution Plan (after my answers)

After I answer your questions:

1. Give me your execution plan (5 steps maximum).
2. For each step, tell me what you will do AND WHY.
3. Only begin work once I say "Go".

## 7. Self Assessment (when delivering first draft)

When you deliver the first draft:

1. Mark sections you are MOST confident about with **[STRONG]**.
2. Mark sections you are LEAST confident about with **[WEAK]**.
3. Tell me what you would change with one more revision.

> Works with Opus 4.7 and Sonnet 4.6. Best results with uploaded context files.
```

## Auto-fill mechanizmus

A skill automatikusan kitolt mezoket a kontextus alapjan:

```yaml
auto_fill:
  YOUR_ROLE:
    detect_from: ".claude/identity/about-us.md, ~/.claude/CLAUDE.md"
    default: "Senior software engineer"

  WHO_READS_THIS:
    detect_from: "context (developer/decision-maker/end-user)"
    default: "Developer"

  Context Files:
    auto_suggest:
      - .claude/identity/voice.md
      - .claude/identity/anti-style.md
      - .claude/identity/anti-style-dictionary.md  # v7.1
      - .claude/identity/audience/{detected}.md
      - .claude/memory/global.md
      - .claude/memory/patterns.md
      - .claude/memory/mistakes.md

  Does NOT sound like:
    auto_populate_from: ".claude/identity/anti-style.md"

  Does sound like:
    auto_populate_from: ".claude/identity/voice.md"
```

## Tier rendszer mapping (v5.5 → v7.1)

| Tier | Régi (v5.5) | Új (v7.1 anatomy) |
|------|-------------|--------------------|
| Tier B | Vague, no context | Section 1 only |
| Tier A | + context | Section 1+2 |
| Tier S | + examples + tone | Section 1+2+3+4 (no pre-flight) |
| Tier SS | + step-by-step + role | All 7 sections |

## Mikor SS vs S?

```
Tier SS (mind 7 szekcio): kritikus feladat
  - Architektura terv
  - Investor pitch deck
  - Production deploy plan
  - Customer-facing crisis communication

Tier S (1-4 szekcio): standard komplex
  - Uj feature spec
  - Code review request
  - Bug analysis

Tier A (1-2 szekcio): standard
  - CRUD endpoint
  - Unit test
  - Documentation update

Tier B (1 szekcio): quick task
  - Rename
  - Format
  - Lookup
```

## Output

Minden Tier SS prompt hasznalat utan:

```markdown
✅ Prompt template generated: outputs/prompts/{YYYY-MM-DD}-{slug}.md
   Filled sections: 7/7
   Auto-filled: 3 (role, audience, anti-style)
   Manual fill needed: 4

📊 Quality estimate: Tier SS (highest quality)
🎯 Best model match: Sonnet 4.6 + Opus 4.7 advisor (xhigh effort)
💰 Estimated cost: $0.40 - $1.20 per execution
```

## Hivatkozott

- v7.1 patch Section 6 (Hamza Khalid: "Anatomy of Perfect Claude Prompt")
- Sister skill: `prompt-quality-boost` (Tier C/D → S/SS auto-fogalmazas)
- Sister skill: `brainstorming` (5-fazisu refinement Tier SS-hez)
- Sister identity: `voice.md`, `anti-style.md`, `anti-style-dictionary.md`

# Kod Review (Parallel v6.2)

Parallel review pattern: ket fuggetlen subagent friss kontextusban, decision matrix
SHIP × SHIP = ✅ MERGE, egyebb = 🔴 FIX/BLOCK.

## Pattern

Spawn ket parallel subagent (Task tool):

### Reviewer A: SPEC COMPLIANCE
**Friss kontextus, csak ezeket olvassa:**
- `tasks/todo.md` (acceptance criteria)
- `git diff main...HEAD`
- `CLAUDE.md` Aranyszabalyok

**Kerdesek:**
1. Megfelel-e az acceptance criteria-nak? (item-by-item)
2. Minden elem implementalva? (nincs "TODO holnap")
3. Scope creep-ek?
4. 5. Aranyszabaly (TDD Iron Law): van-e teszt minden uj kodhoz?

**Output:** SHIP | FIX (es konkret hianylista)

### Reviewer B: CODE QUALITY
**Friss kontextus, csak a kodot es a teszteket olvassa.**

7 szempont:
1. **Security:** secret, SQL injection, XSS, authz bypass, CORS
2. **Performance:** N+1, O(n²), blocking I/O, missing index
3. **Correctness:** null deref, race condition, missing await
4. **Konvenciok:** feature-based fajlnev, Zod validacio, magyar JSDoc, RFC 7807
5. **Teszt lefedettseg:** coverage javult? Edge case-ek?
6. **Maintainability:** nev-pontossag, function meret < 50 sor
7. **Breaking change:** semver, migration plan, backwards compat

**Output:** SHIP | FIX (kategoria + konkret hibalista)

## Decision Matrix

|             | A: SHIP | A: FIX |
|-------------|---------|--------|
| **B: SHIP** | ✅ MERGE | 🟡 FIX (csak A jelez) |
| **B: FIX**  | 🟡 FIX (csak B jelez) | 🔴 BLOCK |

## Lepesek (Lead = orchestracio)

1. `git diff --staged` + `git diff` attekintes (Lead)
2. Spawn parallel subagent A (Sonnet 4.6) – SPEC compliance prompt
3. Spawn parallel subagent B (Sonnet 4.6 + Opus 4.7 advisor max 1) – QUALITY prompt
4. Vard mindketto outputja (parallel, ne sequencialisan)
5. Decision matrix → MERGE / FIX / BLOCK
6. Strukturalt riport visszaadasa fejlesztonek

## Kimenet

```markdown
## Review eredmeny

### Reviewer A (SPEC) – {SHIP | FIX}
- ✅ [megfelel item]
- 🟡 [hianyzo item]

### Reviewer B (QUALITY) – {SHIP | FIX}
- 🔴 [security: konkret hiba] (kategoria + sor)
- 🟡 [perf: N+1 a UserService.list-ben]
- ✅ [correctness OK]

### Decision
✅ MERGE | 🟡 FIX (X sor) | 🔴 BLOCK ({why})
```

## Mikor NE hasznald

- Egysoros / format / rename → overhead nagyobb mint nyereseg
- Hot fix prod incident → egy fast review, retro kesobb
- Spike / proof-of-concept → nem merge cel

## Hivatkozott
- Skill: `.claude/skills/parallel-reviewer-orchestrator/`
- Sister skill: `.claude/skills/code-review/` (single-reviewer fallback)
- Forras: v7.0 master PART 2 Section 29

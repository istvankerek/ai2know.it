# Token Discipline (always-on)

> **Forrás:** v7.5 "Lean Mind" patch (Deliverable 2 / 3.3)
> **Always-on:** ez a fájl NINCS frontmatter `paths:` mezővel, minden session-be betöltődik.

A token a session legdrágább erőforrása. Minden CLAUDE.md sor, minden tool output, minden
MCP-tool definíció **minden turn-ön újra-fizetődik** (cache hit nélkül). Az alábbi 7 szabály
**determinisztikus**, és minden agent + minden subagent köteles betartani.

---

## 1. Soha ne olvass > 2000 sor fájlt offset/limit nélkül

```python
# ❌ ROSSZ
Read(file_path="/path/to/large.rs")   # 4000+ sor → 25,000+ token a contextbe

# ✅ JÓ — offset + limit kötelező
Read(file_path="/path/to/large.rs", offset=120, limit=80)
```

Ha nem tudod hol a releváns rész:
- **Grep** előbb a kulcsszóra (kapd vissza sor-számokat)
- **Read** csak az adott sor körüli ablakkal

## 2. Soha ne pipe-old a raw test/log output-ot a context-be

```bash
# ❌ ROSSZ
cargo test                              # 50,000+ token panic-stack-tel
pnpm test                               # 30,000+ token green output-tal

# ✅ JÓ — szűrj a forrásnál grep/head segítségével
cargo test 2>&1 | grep -B1 -A3 -E 'FAILED|panicked|error\[E' | head -150
pnpm test 2>&1 | grep -A 5 -E 'FAIL|ERROR|failed' | head -120
```

A `pre-bash-cap.sh` hook (v7.5) ezt automatikusan beilleszti ismert noisy parancsokra.

## 3. Subagent-first: >5 fájl olvasáshoz

Ha a feladat **5+ fájlt** kell olvasson (codebase-explore, refaktor-impact-elemzés,
test-failure-diagnosis), **delegáld subagent-nek**:

```
Main session: Task tool → subagent_type=Explore (vagy haiku-subagent)
Subagent: olvas 30+ fájlt, visszaad 200-tokenes összegzést
Main: tovább megy 200 tokennel, NEM 50,000-rel
```

A `CLAUDE_CODE_SUBAGENT_MODEL=claude-haiku-4-5` env-var biztosítja a Haiku route-ot
(-80% subagent cost vs Opus).

## 4. Cap outputs

A `~/.claude/settings.json` env-ben:

```json
"BASH_MAX_OUTPUT_LENGTH": "20000",        // Bash tool hard cap
"MAX_MCP_OUTPUT_TOKENS": "8000"            // MCP tool hard cap
```

**Utolsó vonal védelem.** A megfelelő megoldás a 2. pont (filter at source).

## 5. `/compact` 60-70% kontextusnál — soha ne várd ki az auto-compact-ot

```
60% context  → /compact <focus>   (manuális, goal-focused summary)
70% context  → REGRET threshold — utolsó lehetőség manual compactra
80% context  → auto-compact aktiválódik (rosszabb összegzés)
```

Az `/compact <focus>` egy fókusz-szövegre összegzi a kontextust (pl.
`/compact "auth refactor — completed CreateUserEndpoint, still TODO: tests"`).

## 6. Local inference (MLX, Ollama, llama.cpp) boilerplate / classify feladatra

| Feladat | Routing |
|---------|---------|
| Boilerplate scaffold (CRUD endpoint, scaffold REST handler) | **Local Ollama** (qwen3.5:27b cloud) |
| Intent/language detect, classifier | **Local MLX** (qwen 7B) |
| Daily coding (új feature, refactor ≤300 LOC) | **Sonnet 4.6** |
| Architektúra, security audit, debug elusive concurrency | **Opus 4.7** (only-when-needed) |

A `cclocal` alias (`~/.zshrc`) átirányít helyi MLX/Ollama-ra.

## 7. Prompt caching kötelező minden API-rétegben (>1024 token prefix, 3+ olvasás)

API-direct hívásnál (Anthropic SDK, NEM Claude Code CLI):

```python
system=[
    # Layer 1: rövid változó instrukció (NE cache-eld)
    {"type": "text", "text": dynamic_directive},
    # Layer 2: hosszú system prompt (1h cache)
    {"type": "text", "text": LONG_SYSTEM_PROMPT,
     "cache_control": {"type": "ephemeral", "ttl": "1h"}},
]
```

**Megtérülés:** 5m cache 3+ olvasás után, 1h cache 5+ olvasás után.
Cache read = **0.1× input cost** (90% kedvezmény).

---

## Anti-patterns (NE csinald)

| Anti-pattern | Miért rossz | Helyette |
|--------------|-------------|----------|
| 500-soros CLAUDE.md mindennel | Minden tool-call szorzójával fizetődik | < 200 sor + `@imports` + `.claude/rules/` |
| Opus minden task-ra | 25× drágább mint Haiku, gyakran felesleges | Routing layer (Haiku/Sonnet/Opus) |
| `cargo test` Bash-ből nyersen | 50,000+ token noise | Subagent test-runner Haiku-val |
| `/clear` mid-feature | Cache-prefix elvész, tudás is | `/compact <focus>` |
| Timestamp / UUID a cached prefixben | 100% cache miss minden requesten | Prefix után tedd; daily trunkáld |
| Random-id-k a system prompt elején | Minden request új cache kulcs | Hash-eld vagy mozgasd tail-be |
| Subagent fan-out 5+ párhuzamosan | 7× cost (Agent Teams számai) | Sequential subagents vagy fork+cache |
| Extended thinking minden requesten | Output rate (5×) számlázott thinking | `MAX_THINKING_TOKENS=8000` + `--effort low` egyszerű taskra |

---

## Hivatkozott

- Forrás: `specification/skeleton-specifications/compass_artifact_wf-bef6d0f4-...-_text_markdown.md`
- Rule sister: `70-secrets-handling.md`
- Skills: `token-report-generator`, `claude-code-session-handoff`
- Settings: `~/.claude/settings.json` + `.claude/settings.json` env-vars
- Hooks: `.claude/hooks/pre-bash-cap.sh`, `pre-read-warn.sh`, `post-tool-cost.sh`

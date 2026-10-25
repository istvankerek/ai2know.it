# Modell és CLI Routing Policy (v8.0)

> Egyetlen igazságforrás: `.aios-cli/orchestrator/policy/routing-policy.toml`.
> A lenti táblázat generált (`scripts/aios policy-doc`), kézzel ne szerkeszd.
> Automatikus javaslat minden promptra: `.claude/hooks/intelligent-router.sh` → `aios route`.

## Használat

```bash
scripts/aios route "feladat" [--files a b] [--json]   # javaslat, nem indít semmit
scripts/aios run "feladat" [--dry-run] [--confirm]    # indítás fallback lánccal
scripts/aios providers                                # telepített CLI-k + helyi szerverek
scripts/aios explain [TIER]                           # tier lánc
scripts/aios budget --period week                     # futások összesítése (ledger)
```

## Biztonsági kapuk

- **Adatosztály**: `sensitive` (PII, titok, ügyféladat, jogi tervezet, `.env`, `secrets/`) → csak
  helyi modell vagy Claude. Gemini és Codex nem kapja meg.
- **Titok a promptban** → `aios run` megáll (exit 3), semmi nem megy ki.
- **CRITICAL** tier → `--confirm` nélkül nem indul (exit 4).
- **Helyi modell** csak `127.0.0.1` / `localhost` címen engedett (policy validátor).
- **Ledger** csak metaadatot és prompt hash-t tárol, szöveget nem.

<!-- AIOS:POLICY-TABLE:BEGIN -->
| Tier | Lanc (elso = elsodleges) | Megjegyzes |
|------|--------------------------|------------|
| PLAN | claude:plan (`claude-fable-5-1`) → claude:critical (`claude-opus-5-5`) → codex:deep (`gpt-5.5`) | Architektura, plan-vN, ADR, rendszertervezes |
| CRITICAL | claude:critical (`claude-opus-5-5`) → codex:deep (`gpt-5.5`) | Security, prod, migracio, adatvesztes, breaking change; `--confirm` kell |
| STANDARD | claude:standard (`claude-sonnet-5-5`) → codex:balanced (`gpt-5.3-codex`) → claude:critical (`claude-opus-5-5`) | Feature, bug fix, refactor, atlagos modositas |
| REVIEW | claude:review (`claude-sonnet-5-5`) → codex:deep (`gpt-5.5`) | Kod review, PR atnezes |
| SCOPED | codex:balanced (`gpt-5.3-codex`) → claude:standard (`claude-sonnet-5-5`) | Jol korulhatarolt implementacio, boilerplate, batch, tesztgeneralas |
| LARGE_CONTEXT | gemini:default (`auto`) → claude:standard (`claude-sonnet-5-5`) | Nagy kontextus (>200K token), teljes repo audit, web kutatas |
| MECHANICAL | mlx:default (`default`) → lmstudio:default (`default`) → llamacpp:default (`default`) → claude:mechanical (`claude-haiku-4-5-20251001`) → codex:fast (`gpt-5.3-codex-spark`) | Formazas, atnevezes, regex, osztalyozas, egyszeru lookup |
| CONSENSUS | claude:critical (`claude-opus-5-5`) → codex:deep (`gpt-5.5`) → gemini:default (`auto`) | Kritikus dontes: Claude + Codex + Gemini parhuzamosan (scripts/multi-vendor-consensus.sh); párhuzamos |

| Provider | Típus | Engedett adatosztály |
|----------|-------|----------------------|
| claude | cli (`claude`) | public, internal, sensitive |
| codex | cli (`codex`) | public, internal |
| gemini | cli (`gemini`) | public, internal |
| mlx | local (`http://127.0.0.1:8080/v1`) | public, internal, sensitive |
| lmstudio | local (`http://127.0.0.1:1234/v1`) | public, internal, sensitive |
| llamacpp | local (`http://127.0.0.1:8081/v1`) | public, internal, sensitive |
<!-- AIOS:POLICY-TABLE:END -->

## Felülírás

- Modell: `AIOS_MODEL_<PROVIDER>_<VARIANT>`, pl. `AIOS_MODEL_CLAUDE_CRITICAL=claude-opus-5-5`.
- Helyi URL: `AIOS_LOCAL_MLX_URL`, `AIOS_LOCAL_LMSTUDIO_URL`, `AIOS_LOCAL_LLAMACPP_URL`.
- Tier kézi választás: `scripts/aios route "…" --tier REVIEW`.
- Claude Code session-ben: `/model`, `/effort`; egyszeri max: `ultrathink`.

## Codex profilok (`.codex/config.toml`)

| Profil | Modell | Effort | Policy variant |
|--------|--------|--------|----------------|
| fast | gpt-5.3-codex-spark | low | `codex:fast` |
| balanced | gpt-5.3-codex | medium | `codex:balanced` |
| deep | gpt-5.5 | xhigh | `codex:deep` |

Custom agentek: `explorer_fast`, `worker_standard`, `reviewer_deep`.

## Helyi modellek

MLX (`mlx_lm.server`), LM Studio, llama.cpp (`llama-server`). Mindegyik OpenAI-kompatibilis
`/v1` végponttal. Részletek: `local-models` skill.

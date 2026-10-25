# /project:cli-switch – CLI Váltás

## Leírás

Vált a három támogatott CLI között (claude, codex, gemini).
Frissíti az `AIOS_ACTIVE_CLI` env var-t és újragenerálja a konfigurációs fájlokat.

## Használat

```
/project:cli-switch claude
/project:cli-switch codex
/project:cli-switch gemini
```

## Mit csinál

1. Ellenőrzi az argumentumot (claude/codex/gemini)
2. Frissíti az `AIOS_ACTIVE_CLI` értékét a `.claude/settings.json`-ban
3. Futtatja: `.aios-cli/scripts/generate-cli-configs.sh {cli}`
4. Visszajelzést ad a sikeres váltásról

## Lépések

### 1. Argumentum ellenőrzés

Ha az argumentum nem `claude`, `codex` vagy `gemini`:
```
Érvénytelen CLI: {argumentum}
Érvényes értékek: claude, codex, gemini
```

### 2. Settings frissítése

Futtasd:
```bash
jq '.env.AIOS_ACTIVE_CLI = "{CLI}"' .claude/settings.json > /tmp/settings.tmp \
  && mv /tmp/settings.tmp .claude/settings.json
```

### 3. Config regenerálás

```bash
./.aios-cli/scripts/generate-cli-configs.sh {CLI}
```

### 4. Visszajelzés

```
Aktív CLI: {CLI}
Generált fájl: {fájl neve}

Megjegyzés a CLI-ről:
- claude: Komplex reasoning, skills rendszer, hook-ok
- codex: Mechanikus batch, high-throughput módosítások
- gemini: 2M context, web grounding, nagy kódbázis audit
```

## Mikor válts

| Feladat | CLI |
|---------|-----|
| Normál fejlesztés, feature implementáció | claude (alapértelmezett) |
| Tömeges fájl módosítás, rename, format | codex |
| Teljes monorepo audit, web kutatás | gemini |
| Kritikus döntés több vélemény kell | multi-vendor-consensus skill |

## Kapcsolódó

- `.aios-cli/core/routing-policy.md` – CLI routing policy részletei
- `.claude/skills/cli-router/SKILL.md` – automatikus CLI javaslat
- `.claude/skills/multi-vendor-consensus/SKILL.md` – 3 CLI párhuzamos futtatás

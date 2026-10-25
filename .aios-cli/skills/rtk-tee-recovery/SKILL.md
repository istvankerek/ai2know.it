---
name: rtk-tee-recovery
description: >
  RTK tee log recovery: ha kompresszalt output nem eleg debug-hoz, olvasd a helyi
  tee log-ot UJRAFUTTATAS HELYETT. Nulla AI cost (helyi fajl). Memory observation
  auto-save bug fix utan.
  Triggerek: "rtk tee", "rtk failure", "tee log", "rtk fail", "miert hibazott",
  "rtk recovery", "raw output kell", "nem eleg a kompresszalt".
license: Everengine v7.2
priority: P2
model: claude-haiku-4-5-20251001
---

# RTK Tee Recovery

## Mikor hasznald

```
RTK-zott parancs FAIL
   ↓
A kompresszalt output NEM ELEG (kell a teljes stack trace, hash, raw bytes)
   ↓
DE: nem akarod ujra futtatni (lassu, draga, allapot-romlas)
   ↓
→ TEE LOG OLVASAS (lokalis cache, zero AI token)
```

## Workflow

### 1. Legutobbi tee log keresese
```bash
# Default path: $HOME/.local/share/rtk/tee
ls -lt ~/.local/share/rtk/tee/ | head -10

# Vagy env-bol
ls -lt "$RTK_TEE_LOG_PATH/" | head -10
```

### 2. Releveans log kivalasztasa
```bash
# Legutobbi
LATEST=$(ls -t ~/.local/share/rtk/tee/ | head -1)
echo "Recovering: $LATEST"

# Specifikus parancs
ls -lt ~/.local/share/rtk/tee/ | grep "cargo-test"
```

### 3. Olvasas (chunk-olva, NE egesz fajlt)
```bash
# Eleje (stdout normal start)
cat ~/.local/share/rtk/tee/$LATEST | head -200

# Vege (hibauzenetek, stack trace)
cat ~/.local/share/rtk/tee/$LATEST | tail -100

# Specifikus szovegre keres
grep -A 5 "panicked\|Error\|FAIL" ~/.local/share/rtk/tee/$LATEST
```

## Token economy

| Mod | Cost | Idő | Jegyzet |
|-----|------|-----|---------|
| **Tee recovery** | 0 token AI-nak | <1 sec | Helyi fajl, csak ha kell olvas a Claude |
| Ujrafuttatas | Teljes parancs ujra | Sec-ek/percek | Allapot-romlas kockazat |
| `rtk discover` | ~500 token | <2 sec | Csak metadata |
| Raw cat distclean | ~500-50K token | Inst | Ne tedd, kompresszald! |

## Memory observation (auto-save bug fix utan)

```bash
# Hivd ezt a script-et a debug-3strike skill Strike 1 lezarasakor
./scripts/save-rtk-failure-observation.sh

# Vagy manualisan
claude memory save \
  --type bugfix \
  --title "RTK tee recovery: $COMMAND failed" \
  --content "$(head -50 ~/.local/share/rtk/tee/$LATEST)" \
  --tags "rtk-tee,$COMMAND,debug"
```

## Tee log retention

```toml
# ~/.config/rtk/config.toml
[tee]
enabled = true
mode = "failures"     # csak fail eseten ment (default)
max_files = 50        # ezen tul rotalja
ttl_days = 7          # 7 nap utan torli
```

## Tilalmak

❌ Tee log kuldese harmadik fel AI-nak (privacy: rendszer-uti, env vars stb. lehet benne)
❌ Tee log commitolasa Git-be (ne keruljon adattara)
❌ Override `mode = "all"` permission nelkul (lemez teljesen tele lesz)

## Hivatkozott

- Sister skill: `rtk-optimizer` (proactive optimization)
- Skill: `debug-3strike` (Strike 1: tee log olvas)
- Script: `scripts/save-rtk-failure-observation.sh` (auto-memory save)
- Config: `~/.config/rtk/config.toml [tee]`
- Forras: v7.2 patch Section 7

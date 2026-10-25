# AIOS Identity – Összefoglaló (v6.1)

> A teljes identity fájlok helye: `.claude/identity/`
> Ez az összefoglaló a CLI adapterek számára gyors referenciát ad.

## Mikor töltsd be az identity fájlokat

| Trigger | Betöltendő fájlok |
|---------|-------------------|
| Marketing szöveg, email, landing, blog | `voice.md`, `anti-style.md`, `brand-*.md` |
| Fejlesztői dokumentáció | `voice.md`, `anti-style.md` |
| Termékspecifikus tartalom (aiBOS) | `brand-aibos.md`, `voice.md` |
| Termékspecifikus tartalom (jFlow) | `brand-jflow.md`, `voice.md` |
| Termékspecifikus tartalom (SkillPass.ID) | `brand-skillpass.md`, `voice.md` |
| Célközönség kommunikáció | `audience/{developer,decision-maker,end-user,support-agent}.md` |
| Általános brand check | mind a 14 fájl |

## Identity fájlok listája

```
.claude/identity/
├── about-us.md              # Kik vagyunk, honnan jövünk
├── mission.md               # MIT teszünk és MIÉRT
├── vision.md                # HOVA tartunk (5 év)
├── values.md                # Core Values (5)
├── voice.md                 # HOGYAN beszélünk (megszólítás, hangnem)
├── anti-style.md            # MIT SOHA NEM teszünk (10 kategória)
├── brand-aibos.md           # aiBOS termék brand template
├── brand-jflow.md           # jFlow termék brand template
├── brand-skillpass.md       # SkillPass.ID (IdP + ügyfélportál) brand
└── audience/
    ├── developer.md
    ├── decision-maker.md
    ├── end-user.md
    └── support-agent.md
```

## Legfontosabb anti-style szabályok (kiemeltek)

1. **Nincs em-dash (—)** – pont vagy kettőspont helyette
2. **Nincs AI fluff** – "innovatív megoldás", "world-class", "Let's dive" tiltott
3. **Identitás domain mindig `skillpass.id`** – megszűnt IdP név nem szerepelhet
4. **Nincs smiley emoji** üzleti kommunikációban
5. **Nincs passzív szerkezet** ahol aktív is megfelel

## Brand aktiváció

- Auto: `.claude/hooks/check-brand.sh` (PostToolUse, md/jsx/tsx módosításnál)
- Skill: `brand-auditor` (marketing copy triggerekre)
- Manual: `/project:brand-check`
- Heti: `.claude/routines/scheduled/weekly-brand-audit.yml`

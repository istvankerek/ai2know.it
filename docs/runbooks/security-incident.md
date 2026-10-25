# Biztonsagi Incidens – Runbook

## Tunet
Secret kiszivargott, jogosulatlan hozzaferes, gyanús aktivitas.

## Sulyossag
🔴 Kritikus

## Azonnali teendok (elso 5 perc)
1. NE torolj semmit — bizonyitek megorzese!
2. Ha secret kiszivargott: azonnal rotald a kulcsot
3. Ha jogosulatlan hozzaferes: zarod ki a felhasznalot/IP-t
4. Ertesitsd a tech lead-et es a biztonsagi felelost

## Diagnozis
- Activity log ellenorzes: ki, mikor, mit csinallt
- Git history: `git log --all --full-history -- "*.env*"`
- Login history: sikertelen belepeesi kiseretek
- Halozati logok: Caddy access log

## Megoldas

### Secret kiszivargott
```bash
# 1. Rotald az osszes erintett kulcsot
# 2. Ellenorizd a Git tortenetet
git log --all --diff-filter=A -- "*.env" "*secret*" "*credential*"
# 3. Ha commit-ba kerult: git filter-branch vagy BFG
# 4. Ertesitsd az erintett szolgaltatasokat (SkillPass.ID kliens secret rotacio, Mailgun, stb.)
```

### Jogosulatlan hozzaferes
```bash
# 1. Felhasznalo zarolasa
# 2. Session-ok ervenytelenitse
# 3. IP blacklist frissites (Caddy/Cloudflare)
# 4. Jelszovaltoztatas kenyszeritese
```

## Megelozes
- PreToolUse hook-ok aktivan (check-safety.sh, check-injection.sh)
- Rendszeres security scan: /project:security-scan
- Secret rotation negyedevente

## Eszkalacio
Azonnal ertesitendo: tech lead, CTO, jogaszat ha GDPR erintett

# Deploy

Deploy a megadott kornyezetbe: $ARGUMENTS (local/test/prod)

## Elofeltetelek

1. Futtasd a pre-deploy ellenorzeseket:
   - `./scripts/test.sh` — minden teszt zold
   - `npx tsc --noEmit` — TypeScript hibamentes
   - `./scripts/lint.sh` — 0 warning
   - `git status` — nincs commitolatlan valtozas

2. Kornyezet ellenorzese:
   - **local**: nincs extra kovetelmeny
   - **test**: ellenorizd a test DB allapotat
   - **prod**: 🔴 L1 APPROVE szukseges! Plan Mode kotelzo!

## Vegrehajtas

```bash
./scripts/deploy.sh $ARGUMENTS
```

## Prod deploy extra lepesek

Ha `$ARGUMENTS` = "prod":
- Kerj explicit jovahagyast a felhasznalotol
- Keszits backup-ot elotte: `./scripts/backup-manual.sh`
- Ellenorizd a COORDINATION.md-t nyitott kerdesekert
- Deploy utan: `docker compose ps` allapot ellenorzes

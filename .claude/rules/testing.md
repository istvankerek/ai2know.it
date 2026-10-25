# Teszteles Szabalyok

## Unit tesztek (Vitest)
- Minden service es util fuggvenyhez kotelzo
- Coverage cel: minimum 80%
- Mock-ok: kulso fuggosegekre igen, adatbazisra NEM
- Fajlnev: `{Function}.test.ts` az eredeti fajl mellett

## Integracios tesztek
- Minden API endpoint-hoz kotelzo
- Valos adatbazis hasznalata (Docker test container)
- Coverage cel: minimum 60%
- Teszteles: happy path + hibas input + jogosultsag

## E2E tesztek (Playwright)
- Kritikus user flow-khoz kotelzo:
  - Bejelentkezes
  - CRUD muveletek
  - Lista szures/rendezes/export
- Screenshot comparison opcionalis

## Altalanos szabalyok
- Tesztet irsz -> FUTTASD LE (`./scripts/test.sh`)
- Commit elott minden tesztnek zoldnek kell lennie
- Ne irj tesztet ami mas teszttol fugg (izolalt tesztek)
- Arrange-Act-Assert minta
- Beszedes teszt nevek magyarul: `"letrehozza a felhasznalot helyes adatokkal"`

## Futtatas
```bash
./scripts/test.sh          # Minden
./scripts/test.sh unit     # Csak unit
./scripts/test.sh integration  # Csak integracios
./scripts/test.sh e2e      # Csak E2E
```

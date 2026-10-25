# Minden teszt futtatas

Futtasd az osszes tesztet es jelents az eredmenyrol.

## Lepesek

1. **Unit tesztek** (Vitest):
   ```bash
   cd apps/frontend && npx vitest run
   cd apps/admin && npx vitest run
   ```

2. **Backend tesztek** (Rust):
   ```bash
   cd apps/backend && cargo test
   ```

3. **Integracios tesztek**:
   ```bash
   ./scripts/test.sh integration
   ```

4. **E2E tesztek** (Playwright):
   ```bash
   ./scripts/test.sh e2e
   ```

5. **Type check**:
   ```bash
   npx tsc --noEmit
   ```

6. **Lint**:
   ```bash
   ./scripts/lint.sh
   ```

## Alternativ: mindent egyben

```bash
./scripts/test.sh
```

## Kimenet

Jelents az eredmenyrol:
- ✅ Sikeres tesztek szama
- 🔴 Sikertelen tesztek reszletei
- Coverage szazalek (cel: 80% unit, 60% integration)

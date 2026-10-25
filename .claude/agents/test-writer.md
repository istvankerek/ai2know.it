---
name: test-writer
description: >
  Test generator specialist. Unit, integration es e2e tesztek.
  Rust: #[test], #[tokio::test], mockall. TypeScript: vitest, MSW.
  Triggerek: "test", "teszt", "unit test", /project:test, uj endpoint.
tools:
  - Read
  - Write
  - Grep
  - Glob
  - Bash
model: claude-sonnet-4-6
skills:
  - unit-test-writer
  - integration-test
---

# Test Writer

## Prioritas
1. Happy path (alap mukodes — minimum 1 teszt minden public fv-hez)
2. Edge case-ek (ures input, hatar ertekek, null/None, max meret)
3. Error path-ek (hibas input, timeout, auth fail, db connection lost)
4. Concurrency (ha releváns: race condition, deadlock, double-spend)

## Rust konvenciok
- `#[cfg(test)] mod tests {}` modul-szervezes
- `assert_eq!`, `assert!(matches!(...))` precizion
- `tokio::test` async tesztekhez
- `mockall` crate mock-okhoz
- Test data: `seed::user_factory()` patternek (NEM hardcoded literal-ok)

## TypeScript konvenciok
- vitest: `describe/it/expect`
- Testing Library: `render, screen, fireEvent`
- MSW: API mock-ok (handlers.ts kozpontositva)
- Zod schema validacio teszt-szinten is (ne csak runtime)
- Magyarul a test name-ek (`it("letrehozza a felhasznalot helyes adatokkal")`)

## Coverage cel
- Unit: >= 80%
- Integration: >= 60%
- E2E: kritikus user flow-k (login, CRUD, export)

## Output
- Test fajl(ok) `*.test.ts` / `*_test.rs`
- Import structuration (no circular deps)
- Coverage report a fontos brancsekrol

## Hivatkozott
- Sister skill: `unit-test-writer`, `integration-test`, `e2e-test`
- Rules: `.claude/rules/testing.md`
- Forras: v7.4 patch Section 5.2

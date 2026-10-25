---
name: code-style
description: >
  Kod stilus: TypeScript konvenciok, Rust konvenciok, import sorrend,
  elnevezesi mintak, feature-based struktura.
  Triggerek: automatikus (rules/code-style.md + PostToolUse hook).
  NE hasznald: manualisan – a hook es rules automatikusan kezeli.
model: claude-haiku-4-5-20251001
---

# Code Style

## Felelossegek
- TypeScript strict mode betartatas
- Import sorrend (React -> kulso -> belso -> tipusok)
- Nevezesi konvenciok (PascalCase, camelCase, UPPER_SNAKE)
- Feature-based fajlnevezes ({Action}{Entity}Endpoint.ts)
- ESLint + Prettier automatikus formatas (auto-lint.sh hook)
- Rust konvenciok (rustfmt)

---
name: feature-flags
description: >
  Feature flag rendszer: funkciok be/kikapcsolasa, A/B teszteles,
  fokozatos kiveteles (gradual rollout), felhasznalo celzas.
  Triggerek: "feature flag", "toggle", "A/B teszt", "rollout".
  NE hasznald: normal konfiguracio, env valtozok.
model: claude-sonnet-4-6
---

# Feature Flags

## Felelossegek
- Feature flag CRUD (admin UI)
- Boolean / percentage / user-targeted flagek
- Fokozatos kiveteles (1% -> 10% -> 50% -> 100%)
- A/B teszteles tamogatas
- SDK: useFeatureFlag() hook
- Audit log (ki, mikor, mit kapcsolt)

---
name: integration-test
description: >
  Integration teszt: API endpoint tesztek, DB tesztek, service
  integracio, test fixtures, seed data.
  Triggerek: "integration test", "api teszt", "endpoint teszt".
  NE hasznald: unit test, e2e test, performance test.
model: claude-sonnet-4-6
---

# Integration Test

## Felelossegek
- API endpoint tesztek (HTTP request/response)
- Valos adatbazis hasznalata (Docker test container)
- Test fixtures es seed data
- Service integracio teszteles
- Coverage cel: minimum 60%
- Happy path + hibas input + jogosultsag teszteles

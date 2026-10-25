---
name: unit-test-writer
description: >
  Unit teszt generalas: Arrange-Act-Assert, magyar teszt nevek,
  edge case-ek, mock factory, coverage ellenorzes.
  Triggerek: "unit test", "teszt iras", "teszt generalas", "coverage".
  NE hasznald: integration test, e2e test, kod review.
model: claude-sonnet-4-6
---

# Unit Test Writer

## Felelossegek
- Vitest teszt generalas (frontend)
- Cargo test generalas (backend)
- Arrange-Act-Assert minta
- Magyar teszt nevek ("letrehozza a felhasznalot helyes adatokkal")
- Edge case-ek azonositasa es tesztelese
- Mock factory-k
- Coverage cel: minimum 80%

## Helyes output pelda

```typescript
// src/modules/users/create-user/CreateUserService.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';

import { CreateUserService } from './CreateUserService';
import { makeUserRepository } from './test-utils/user-repository.mock';

import type { CreateUserInput } from './CreateUserDto';

describe('CreateUserService', () => {
  let repository: ReturnType<typeof makeUserRepository>;
  let service: CreateUserService;

  beforeEach(() => {
    repository = makeUserRepository();
    service = new CreateUserService(repository);
  });

  it('letrehozza a felhasznalot helyes adatokkal', async () => {
    // Arrange
    const input: CreateUserInput = {
      name: 'Kovacs Janos',
      email: 'janos@pelda.hu',
      role: 'editor',
    };
    repository.findByEmail.mockResolvedValue(null);
    repository.create.mockResolvedValue({ id: 'u_1', ...input });

    // Act
    const result = await service.execute(input);

    // Assert
    expect(result.id).toBe('u_1');
    expect(repository.create).toHaveBeenCalledWith(input);
  });

  it('hibat dob ha az email mar letezik', async () => {
    // Arrange
    repository.findByEmail.mockResolvedValue({ id: 'u_2' });

    // Act + Assert
    await expect(
      service.execute({ name: 'X', email: 'x@y.hu', role: 'viewer' })
    ).rejects.toThrow('EMAIL_ALREADY_EXISTS');
  });
});
```

## Helytelen output pelda (NE csinald igy)

```typescript
// ❌ Angol teszt nev, nincs AAA struktura
test('creates user', async () => {
  const r = await new CreateUserService(null as any).execute({} as any);
  expect(r).toBeTruthy();
});

// ❌ `any` type, DB mockolas helyett real DB hivas
// ❌ Nincs edge case (ismetelt email, ervenytelen role)
// ❌ Nincs mock factory
```

## Szabalyok
1. AAA minta kotelezo: `// Arrange`, `// Act`, `// Assert` kommentek
2. Magyar teszt nevek: `"letrehozza a felhasznalot..."`
3. `any` type TILOS — hasznalj mock factory-t vagy `vi.Mocked<T>`
4. Minden publikus fuggvenyhez min. 1 happy path + 1 edge case
5. Kulso fuggosegek mockolasa, DB NEM (integration test dolga)
6. Fajlnev: `{Function}.test.ts` az eredeti fajl mellett
7. Coverage cel: minimum 80%

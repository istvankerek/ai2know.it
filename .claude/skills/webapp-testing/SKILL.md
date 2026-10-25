---
name: webapp-testing
description: |
  E2E, accessibility es performance teszteles: Playwright, axe-core, Lighthouse.
  Triggerek: "playwright teszt", "e2e teszt", "accessibility audit",
  "a11y check", "lighthouse audit", "webapp teszt", "browser teszt".
license: Everengine v6.5
priority: P2
model: claude-sonnet-4-6
---

# Webapp Testing Skill

## Cel
Teljes webapp tesztelesi lefedes: E2E funkcionalitas, accessibility, teljesitmeny.

## Eszkozok

| Eszköz | Cel | Parancs |
|--------|-----|---------|
| Playwright | E2E + funkcionalitas | `npx playwright test` |
| axe-core | Accessibility (WCAG 2.1) | `npx playwright test --grep @a11y` |
| Lighthouse | Teljesitmeny + SEO | `npx lighthouse <url>` |

## E2E Teszt Struktura

```typescript
// tests/e2e/{feature}.spec.ts
import { test, expect } from '@playwright/test';

test.describe('{Feature neve}', () => {
  test('letrehozza a felhasznalot helyes adatokkal', async ({ page }) => {
    // Arrange
    await page.goto('/users/create');

    // Act
    await page.fill('[data-testid="email"]', 'test@example.com');
    await page.click('[data-testid="submit"]');

    // Assert
    await expect(page).toHaveURL('/users');
    await expect(page.locator('.success-toast')).toBeVisible();
  });
});
```

## Accessibility Ellenorzesek

```typescript
import AxeBuilder from '@axe-core/playwright';

test('megfelel a WCAG 2.1 AA-nak', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toHaveLength(0);
});
```

## Futtatasi Parancsok

```bash
./scripts/test.sh e2e          # Minden E2E
npx playwright test --ui       # Interaktiv mod
npx playwright show-report     # HTML riport
```

## Kritikus Flow-ok (kotelezok)
1. Bejelentkezes (SkillPass.ID OIDC)
2. CRUD muveletek
3. Lista szures + rendezes
4. Hibakezelesi uzenet megjelenese

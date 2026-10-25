---
name: frontend-design
description: >
  Production-grade frontend kod – nem "AI slop". Modern React patterns,
  shadcn/ui best practice, Tailwind CSS, accessibility, performance.
  Vite + React Router v7 + TypeScript strict.
  Triggerek: "uj komponens", "UI elem", "form keszites", "landing page",
  "admin felulet", "design system", "responsive layout"
  NE hasznald: backend, API, database feladat, kod review
priority: P1
model: claude-sonnet-4-7
advisor:
  model: claude-opus-4-7
  max_uses: 3
---

# Frontend Design Skill

## Alapelvek (Anthropic Production-Grade)

### Nincs "AI slop"
❌ Generic Tailwind kombinaciok amit ChatGPT is leir
❌ "Modern, sleek" amit minden landing page hasznal
❌ Tultengo color palette ahol minden pasztel
❌ Decorative elements without purpose
❌ Fake gradient overlays

### Igen, valodi minoseg
✅ Konkret design system (token-alapu)
✅ Hierarchikus typography (Type scale ratio)
✅ Whitespace mint design element
✅ Accessibility elso (a11y, keyboard nav, ARIA)
✅ Performance (lazy loading, virtual scroll, suspense)
✅ Loading states (skeleton, optimistic UI)
✅ Error states (RFC 7807 user-friendly)

## Everengine konvenciok

### Stack
- Vite 6 + React Router v7 (file-based routing)
- TypeScript strict
- Tailwind CSS + shadcn/ui
- TF.js (intelligens menu)
- Magyar i18n minden szovegben

### Komponens template

```tsx
// apps/admin/src/modules/users/CreateUserForm.tsx

import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Button } from "@/components/ui/button"
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { useTranslation } from "react-i18next"

/**
 * Felhasznalo letrehozo urlap.
 * Validacio: Zod | Submit: react-hook-form | i18n: react-i18next
 * A11y: minden input ARIA label, hibak screen reader-nek olvashatok
 */
const CreateUserSchema = z.object({
  email: z.string().email("Ervenyes email cim szukseges"),
  fullName: z.string().min(2, "Legalabb 2 karakter"),
  role: z.enum(["admin", "user", "viewer"]),
})

export type CreateUserDto = z.infer<typeof CreateUserSchema>

export function CreateUserForm({ onSubmit }: { onSubmit: (data: CreateUserDto) => Promise<void> }) {
  const { t } = useTranslation("users")
  const form = useForm<CreateUserDto>({
    resolver: zodResolver(CreateUserSchema),
  })

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="space-y-6 max-w-md"
        aria-label={t("create-user-form.aria-label")}
      >
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("fields.email")}</FormLabel>
              <FormControl>
                <Input {...field} type="email" autoComplete="email" />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? t("submitting") : t("create")}
        </Button>
      </form>
    </Form>
  )
}
```

## Design system tokens

```css
/* apps/admin/src/styles/design-tokens.css */
:root {
  /* Type scale (1.250 ratio – Major Third) */
  --text-xs: 0.8rem;
  --text-base: 1rem;
  --text-lg: 1.25rem;
  --text-xl: 1.563rem;
  --text-2xl: 1.953rem;

  /* Spacing (4px base) */
  --space-1: 0.25rem;
  --space-4: 1rem;
  --space-6: 1.5rem;

  /* Color: semantic, NOT decorative */
  --color-background: #fafafa;
  --color-surface: #ffffff;
  --color-text-primary: #18181b;
  --color-border: #e4e4e7;
  --color-accent: #2563eb;
  --color-success: #16a34a;
  --color-error: #dc2626;
}
```

## Anti-patterns (lasd .claude/identity/anti-style.md)

❌ `<div className="bg-gradient-to-r from-pink-500 via-purple-500 to-blue-500">` (AI slop)
❌ `<h1>Welcome to our platform!</h1>` ("Welcome" antipattern)
❌ Tul sok decoration: `hover:scale-105 transform transition-all duration-300`

✅ `<div className="bg-surface border-b border-border">` (semantic)
✅ `<h1 className="text-2xl font-semibold text-text-primary">Felhasznalok kezelese</h1>` (konkret + magyar)
✅ `<Button variant="primary" size="default">{t("create-user")}</Button>` (variants + i18n)

---
name: form-builder
description: >
  Urlap generalas ModuleConfig alapjan: Zod validacio, mezotipusok,
  section-ok, conditional megjelenes, fajl feltoltes.
  Triggerek: "form", "urlap", "add page", "edit page", "mezok", "validacio".
  NE hasznald: lista nezet, dashboard, profil beallitasok.
model: claude-sonnet-4-6
---

# Form Builder

## Felelossegek
- Form layout (section-okkel csoportositva)
- Mezo tipusok: text, number, email, select, multiselect, date,
  file, rich-text, relation, taxonomy, boolean, color, url
- Zod validacio schema generalas
- Conditional fields (mezo A erteketol fugg mezo B megjelenese)
- Fajl feltoltes (MinIO presigned URL)
- Auto-save (draft)
- i18n label-ek

## Helyes output pelda

```typescript
// src/modules/users/create-user/CreateUserDto.ts
import { z } from 'zod';

export const CreateUserDto = z.object({
  name: z.string()
    .min(2, 'A nev legalabb 2 karakter')
    .max(100, 'A nev maximum 100 karakter'),
  email: z.string()
    .email('Ervenytelen email formatum'),
  role: z.enum(['admin', 'editor', 'viewer'], {
    errorMap: () => ({ message: 'Ervenytelen szerepkor' }),
  }),
  avatar: z.string().url().optional(),
});

export type CreateUserInput = z.infer<typeof CreateUserDto>;
```

```typescript
// src/modules/users/create-user/CreateUserForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useTranslation } from 'react-i18next';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Select } from '@/components/ui/select';

import { CreateUserDto, type CreateUserInput } from './CreateUserDto';

export function CreateUserForm({ onSubmit }: { onSubmit: (data: CreateUserInput) => void }) {
  const { t } = useTranslation('users');
  const { register, handleSubmit, formState: { errors } } = useForm<CreateUserInput>({
    resolver: zodResolver(CreateUserDto),
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <Input
        label={t('form.name')}
        {...register('name')}
        error={errors.name?.message}
      />
      <Input
        label={t('form.email')}
        type="email"
        {...register('email')}
        error={errors.email?.message}
      />
      <Select
        label={t('form.role')}
        {...register('role')}
        options={[
          { value: 'admin', label: t('role.admin') },
          { value: 'editor', label: t('role.editor') },
          { value: 'viewer', label: t('role.viewer') },
        ]}
        error={errors.role?.message}
      />
      <Button type="submit">{t('form.submit')}</Button>
    </form>
  );
}
```

## Helytelen output pelda (NE csinald igy)

```typescript
// ❌ any type, nincs Zod
const schema: any = { name: String, email: String };

// ❌ Magyar valtozonev
const felhasznaloLetrehozas = z.object({ nev: z.string() });

// ❌ Hardcoded label, nincs i18n
<label>Email cim</label>

// ❌ Nincs hibauzenet
const dto = z.object({ name: z.string(), email: z.string() });
```

## Szabalyok
1. Minden form Zod validacioval + `zodResolver` hasznalat
2. Minden validacio magyar hibauzenettel
3. Label-ek `useTranslation()`-bol, SOHA hardcoded
4. `any` type TILOS — `z.infer<typeof Schema>` hasznalata
5. Valtozok angolul, hibauzenetek magyarul
6. Conditional field: `watch()` + `useEffect` helyett Zod `.refine()` vagy `.discriminatedUnion()`
7. Fajl feltoltes: presigned URL, NE kozvetlen upload

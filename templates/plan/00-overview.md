# Plan-v{{N}}: {{CIM}}

> Státusz: TERVEZET – owner jóváhagyásra vár
> Branch: `{{BRANCH}}`
> Routing: `scripts/aios route "{{FELADAT}}"` → tier: {{TIER}}

## Indok (owner kérés, {{DATUM}})

{{Mit kért az owner, saját szavaival, pontokba szedve.}}

## Owner döntések (tények, nem vitatjuk újra – L-01)

| ID | Döntés |
|----|--------|
| D-V{{N}}-01 | {{döntés}} |

## Javasolt döntések (jóváhagyás kell)

| ID | Javaslat | Indok |
|----|----------|-------|
| P-V{{N}}-01 | {{javaslat}} | {{indok}} |

## Ökoszisztéma ellenőrzés

- [ ] Auth: skillpass.id OIDC (`skillpass-auth`), saját auth nincs
- [ ] Ügyfélfelület: skillpass workspace shell (`skillpass-portal`)
- [ ] Admin: aibos.space konzol + contract (`aibos-admin-contract`)
- [ ] Érzékeny adat: routing adatosztály ellenőrizve (`scripts/aios route`)

## Fázisok

| # | Fájl | Tartalom |
|---|------|----------|
| F1 | `01-f1-{{nev}}.md` | {{tartalom}} |

Minden fázis: failing teszt → implementáció → `implementation-notes.md` bejegyzés →
validáció → git save point.

## Elfogadási feltételek

- {{mérhető feltétel}}

## Telepítés

Non-prod (`local` / `test`) + automatizált smoke. Prod csak az owner "mehet" válasza után (L-03).

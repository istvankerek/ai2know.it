# Kod Stilus Szabalyok

## TypeScript
- **strict** mod kotelzo (`"strict": true` tsconfig-ban)
- **SOHA** `any` type — hasznalj `unknown`-t es type guard-ot
- **SOHA** `as` type assertion kerulo megoldaskent
- **Zod** validacio minden endpoint input/output-on
- Prefer `interface` over `type` publikus API-hoz

## Nevezes
- PascalCase: komponensek, interfeszek, type-ok
- camelCase: fuggvenyek, valtozok, property-k
- UPPER_SNAKE_CASE: konstansok
- kebab-case: fajlnevek (kiveve: {Action}{Entity} mintak)
- Feature-based fajlnev: `CreateUserEndpoint.ts`, NEM `controller.ts`

## Import sorrend
1. React / React Router
2. Kulso konyvtarak (zod, axios, stb.)
3. Belso modulok (lib/, components/)
4. Tipusok (type imports)
- Ures sor a csoportok kozott

## JSDoc
- Magyarul irjuk a dokumentaciot
- Minden publikus fuggvenyhez es interfeszhez
- `@param`, `@returns`, `@throws` kotelzo

## Egyeb
- Logger modul hasznalata — SOHA `console.log`
- Hibak: RFC 7807 formatum
- Nincs hardcoded URL — kornyezeti valtozo
- Nincs magic number — neves konstans

## Scope fegyelem (v2.3.5)

### Egy feladat = egy scope
- Csak azt modositsd amit a feladat ker
- NE refaktoralj "utkozben" — ha refaktoralas kell, jelezd kulon
- NE nevezz at fajlokat/valtozokat amikhez nem nyultak kerve
- NE frissits dependency-ket a feladat reszeként (hacsak nem ez a feladat)
- NE "javits" kodot ami nem kapcsolodik az aktualis feladathoz

### Ha mast is eszreveszel
1. Jelezd a fejlesztonek: "Eszrevettem hogy X-ben Y problema van"
2. Kerdezd meg: "Javitsam most vagy nyissak rola kulon feladatot?"
3. Ha kulon → jegyezd fel a COORDINATION.md-be
4. SOHA ne javits csendben, szolás nelkul

### Commit granularitas
- Egy commit = egy logikai valtozas
- NE keverj ossze fuggetlen modositasokat egy commitban
- Commit uzenet pontosan irja le MIT valtoztattal es MIERT

### Pelda

```
❌ ROSSZ:
  Feladat: "Add email validation to CreateUser"
  Amit csinalt: email validacio + atnevezte a fajlt +
                frissitette a lodash-t + refaktoralta a logger-t

✅ JO:
  Feladat: "Add email validation to CreateUser"
  Amit csinalt: email validacio hozzaadasa, semmi mas
  Plusz: "Eszrevettem hogy a logger-ben nincs error level.
         Javitsam kulon commitban?"
```

## No Placeholder szabaly (v2.3.5)

### SOHA ne irj
- `// TODO` — ha van tennivalo, jelezd szoban vagy COORDINATION.md-ben
- `// FIXME` — ha hibat talalsz, javitsd most vagy jelezd
- `// HACK` — ha workaround kell, magyarazd el MIERT es ADR-t javasolj
- `/* placeholder */` — ha nem tudod megvalositani, mondd el
- `throw new Error("Not implemented")` — ha nincs implementalva, ne commitold
- `lorem ipsum` / mock szoveg — hasznalj valodi tartalmat vagy seed data-t
- Ures fuggveny torzs — ha nem kell a fuggveny, ne hozd letre
- `any` type — ha nem tudod a tipust, kerdezz

### Helyette csinald ezt

```typescript
// ❌ // TODO: add validation later
// ✅ Valositsd meg a validaciot most, vagy jelezd szoban:
//    "A validaciohoz Zod schema kell, ami a CreateUserDto-ban lesz.
//     Csinaljam most?"

// ❌ function processPayment() { /* placeholder */ }
// ✅ Ne hozd letre a fuggvenyt, vagy valositsd meg teljesen

// ❌ const data = [{ name: "Test User", email: "test@test.com" }];
// ✅ Hasznalj seed data-t: scripts/seed-db.sh

// ❌ // HACK: this works but should be refactored
// ✅ Javitsd meg rendesen, vagy jelezd: "Ez workaround, mert X.
//    Javaslom ADR-t: docs/adr/NNN-payment-workaround.md"
```

### Kivetelek (amikor elfogadhato)
- `// NOTE:` — magyarazat MIERT csinalunk valamit igy (ez NEM TODO)
- `// SAFETY:` — biztonsagi megjegyzes (miert van extra ellenorzes)
- Teszt fajlokban mock adat — ez normalis, de legyen realisztikus
- `scripts/seed-db.sh` — a seed data definicio szerint "hamis" adat, de strukturalt

### Automatikus ellenorzes
A `.claude/hooks/check-placeholders.sh` PostToolUse hook minden Edit/Write utan ellenorzi a forrasfajlokat es figyelmeztet (nem blokkol) ha placeholder mintat talal.

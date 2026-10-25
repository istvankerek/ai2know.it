---
name: security-audit
description: >
  Biztonsagi audit: secret scan, dependency audit, OWASP check, SQL injection,
  XSS, SSRF, CORS ellenorzes.
  Triggerek: "security", "biztonsagi", "audit", "vulnerability", "owasp",
  "secret scan", /security-scan.
  NE hasznald: normal kod review, feature fejlesztes, teszteles.
model: claude-sonnet-4-6
---

# Security Audit

## Felelossegek
- Secret scan (API kulcsok, tokenek, jelszavak)
- Dependency audit (npm audit, cargo audit)
- OWASP Top 10 ellenorzes
- SQL injection vedelem audit
- XSS vedelem audit
- CORS konfiguracio ellenorzes
- .env kitettsg ellenorzes

## Helyes output pelda

A security audit kimenet minden esetben egy **strukturalt checklist report**, a kovetkezo formatumban:

```markdown
# Security Audit Report — {{PROJECT_NAME}}
**Datum:** 2026-04-12
**Scope:** apps/backend, apps/frontend, apps/admin, docker/

## ✅ Passed (8)
- [x] Secret scan: nincs hardcoded API kulcs vagy token
- [x] npm audit: 0 kritikus, 0 magas severity
- [x] cargo audit: 0 sebezhetoseg
- [x] Parameterized SQL query minden sqlx hivasnal
- [x] httpOnly cookie session token-hez (NEM localStorage)
- [x] CSP header (default-src 'self')
- [x] HTTPS redirect Caddy szinten
- [x] Password hash: nincs (SkillPass.ID auth; aibos.space: aibos-auth)

## ⚠️ Warnings (2)
- [ ] **CORS wildcard dev env-ben** — apps/backend/src/main.rs:42
  - Kockazat: kozepes
  - Teendo: explicit whitelist a dev kornyezetben is
- [ ] **Elavult dependency**: `axios@0.27.2` (apps/admin/package.json)
  - CVE-2023-45857 (prototype pollution)
  - Teendo: frissites >=1.6.0-ra

## 🔴 Critical (1)
- [ ] **SQL injection lehetoseg** — apps/backend/src/modules/products/search_products/endpoint.rs:38
  - String concatenation: `format!("SELECT * FROM products WHERE name LIKE '%{}%'", query)`
  - Teendo: parameterized query azonnal (`sqlx::query!` makro)
  - Sulyossag: KRITIKUS — exploit lehetseges

## Osszefoglalas
| Kategoria | Elenorzott | Passed | Warning | Critical |
|-----------|-----------|--------|---------|----------|
| Secrets   | 127 fajl  | 127    | 0       | 0        |
| SQL       | 42 query  | 41     | 0       | 1        |
| Deps      | 183 pkg   | 181    | 2       | 0        |
| Headers   | 8 check   | 8      | 0       | 0        |

**Eredmeny:** 1 kritikus hiba javitando deploy elott.
```

## Helytelen output pelda (NE csinald igy)

```markdown
# ❌ Strukturalatlan szoveg (nehez kovetni)
Atneztem a kodot, tobb gond is van. A products modulban van valami SQL
injection, a axios regi, es a CORS sem jo...

# ❌ Nincs fajl+sor hivatkozas
"Van SQL injection lehetoseg a backend-en"  # hol?

# ❌ Nincs sulyossag
"Regi dependency-k vannak"  # melyik? mennyire veszelyes?

# ❌ Nincs teendo
"Secret scan lefuttattam, nincs jo"  # mit kell tenni?
```

## Szabalyok
1. Kimenet KOTELEZO formatum: Passed / Warnings / Critical
2. Minden talalat: fajl + sor + CVE (ha van) + sulyossag + teendo
3. Osszefoglalo tablazat kategoriakra bontva
4. Kritikus hiba = deploy BLOCK (nem mehet prod-ba)
5. Warning = javitando, de nem blocker
6. `npm audit` es `cargo audit` kotelzo futtatas
7. OWASP Top 10 minden pontjara legyen checklist elem

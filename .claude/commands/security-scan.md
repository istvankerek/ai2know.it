# Biztonsagi Scan

OWASP + secret scan a teljes projektre.

## Ellenorzesek

### 1. Secret scan
```bash
# Keress titkos kulcsokat a kodban
grep -rn "AKIA\|sk-\|ghp_\|password\s*=" apps/ --include="*.ts" --include="*.tsx" --include="*.rs"
grep -rn "API_KEY\|SECRET\|TOKEN\|PRIVATE_KEY" apps/ --include="*.ts" --include="*.tsx" --include="*.rs" | grep -v ".env"
```

### 2. .env kitettsg
- Ellenorizd hogy .env fajlok gitignore-ban vannak
- Ellenorizd hogy nincs .env a Git torteenetben: `git log --all --full-history -- "*.env*"`

### 3. Fuggoseg audit
```bash
cd apps/frontend && npm audit
cd apps/admin && npm audit
cd apps/backend && cargo audit
```

### 4. OWASP Top 10
- **Injection**: parameterized query mindenhol? (nincs string concat SQL)
- **Broken Auth**: SkillPass.ID hasznalat? (nincs sajat auth; aibos.space kivetel)
- **Sensitive Data**: HTTPS mindenhol? Secret titkositva?
- **XSS**: input sanitizalas? React alapertelmezett escaped?
- **CSRF**: token implementalva?
- **Misconfiguration**: CORS whitelist? Debug mod kikapcsolva prod-ban?

### 5. Docker biztonsag
- Non-root user a Dockerfile-okban?
- Nincs hardcoded credential a compose fajlokban?
- Prod compose vedett?

## Kimenet

- 🔴 Kritikus (azonnali javitas)
- 🟡 Kozepes (1 heten belul)
- 🔵 Alacsony (kovetkezo sprint)

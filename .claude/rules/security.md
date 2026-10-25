# Biztonsagi Szabalyok

## Autentikacio
- **SkillPass.ID az EGYETLEN identity provider** — NE implementalj sajat auth-ot
- **Kivetel:** aibos.space sajat operatori auth (aibos-auth, kotelezo TOTP) — lasd `rules/ecosystem.md`
- Partner: OIDC Code + PKCE confidential client BFF-en at; M2M csak client_credentials, legszukebb scope
- JWT validacio minden vedett endpoint-on (middleware/auth.rs)
- Token tarolasa: httpOnly cookie, SOHA localStorage

## Autorizacio
- Role-based access control (RBAC)
- `require_permission!` makro Rust-ban
- Jogosultsag ellenorzes minden CRUD muveleten

## Adatbazis
- **Parameterized query KIZAROLAG** — SOHA string concatenation
- Prepared statement hasznalata
- SQL injection vedelem: sqlx parameteres lekerdezesek

## CORS
- Explicit whitelist — SOHA `*`
- Engedelyezett origin-ek kornyezeti valtozokbol

## Titkok kezelese
- Secret SOHA kodban vagy Git-ben
- Kornyezeti valtozok hasznalata (.env)
- .env fajlok gitignore-ban
- API kulcsok: `ek_live_` es `ek_test_` prefix

## Egyeb
- CSRF token vedelem
- Rate limiting (Caddy + backend)
- HTTPS mindenhol (Cloudflare + Caddy)
- Input sanitizalas XSS ellen
- Felesleges header-ok eltavolitasa (X-Powered-By, stb.)
- Content Security Policy header-ok

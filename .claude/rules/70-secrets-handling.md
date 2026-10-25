# Secrets Handling (always-on)

> **Forrás:** v7.5 "Lean Mind" patch + Everengine biztonsági konvenciók
> **Always-on:** ez a fájl minden session-be betöltődik.

A skeleton **default-DENY** policy-t használ secret-ekre: ami nincs explicit
engedélyezve, az TILOS.

---

## Tiltott olvasás (`settings.json permissions.deny`)

A `~/.claude/settings.json` (user-global) és `.claude/settings.json` (project-shared)
**deny** szekciójának minimum tartalma:

```json
"permissions": {
  "deny": [
    "Read(./.env)",
    "Read(./.env.*)",
    "Read(./secrets/**)",
    "Read(./node_modules/**)",
    "Read(./target/**)",
    "Read(./dist/**)",
    "Read(./build/**)",
    "Read(./coverage/**)",
    "Read(./.next/**)",
    "Read(./tmp/**)",
    "Read(./logs/**)",
    "Read(./*.log)",
    "Bash(curl http*)",
    "Bash(rm -rf /*)"
  ]
}
```

## Secret-pattern-ek (NEM lehet kódban / git-ben / context-ben)

| Pattern | Példa | Hol legyen? |
|---------|-------|-------------|
| API key | `sk_live_*`, `ek_live_*`, `gho_*` | `.env` (gitignore-olva) |
| Password | bcrypt hash | DB only |
| Token | JWT, OAuth refresh, session | secure storage (Redis + TLS / WP options) |
| HMAC secret | `EWM_API_SECRET` | env var |
| DB connection string | `postgres://user:pass@host` | `.env`, NEM kódban |
| Private key | `BEGIN RSA PRIVATE KEY` | `~/.ssh/`, secure vault, NEM repo |
| AWS credentials | `aws_access_key_id` | `~/.aws/credentials` |

## Default-DENY tools

| Tool | Default policy | Mikor felülírható? |
|------|----------------|--------------------|
| `Bash(curl ...)` | DENY | explicit allowlist (whitelist URL) |
| `Bash(wget ...)` | DENY | explicit allowlist |
| `Bash(rm -rf /*)` | DENY | NEVER |
| `Read(./.env*)` | DENY | NEVER (use `.env.example`) |
| `Write(./.env*)` | DENY | NEVER |
| `Write(CLAUDE.md)` | DENY (auto-commit hook védelem) | Edit OK, Write NEM |

## Skill `disable-model-invocation`

A **side-effect-es** skill-eknek (deploy, send-mail, db-write, file-delete) **kötelező**
a `disable-model-invocation: true` frontmatter:

```yaml
---
name: deploy-prod
description: Production deployment trigger
allowed-tools: Bash, Write
disable-model-invocation: true   # NEM aktiválható model által, csak manual user
---
```

Ez **L0 invariáns** v7.5-től (Q-1 HITL függő — javaslat: L0).

## Logging — PII redaction

Production log-ba **soha** ne kerüljön:
- Email cím teljes formában (mask: `j***@example.com`)
- Telefon (mask: `+36 30 *** ****`)
- IP cím (anonymize: `192.168.x.x`)
- Name (csak ha lehet, anonymize ID-vé)
- Password (NEVER even hashed in log)

A `Logger` modul autoredact-elje a sensitive mezőket:
```rust
tracing::error!(
    user_id = %user.id,         // OK (UUID)
    email = %redact(&user.email), // mask
    "auth failed"
);
```

## Activity log külön kezelés (audit-trail-mandatory)

A `log_activity()` (PostgreSQL audit) **engedélyezett** PII-t tárolhat (immutable audit trail),
DE:
- TTL: 90 nap után automatikus S3 WORM archive
- Hozzáférés: csak admin role
- Export-tilalom: GDPR right-to-be-forgotten kompatibilis

## Git pre-commit hygiene

```bash
# .git/hooks/pre-commit vagy .claude/hooks/check-injection.sh
git diff --cached --name-only | while read f; do
  if grep -qE '(api[_-]?key|secret|password|token).*=.*["\047][A-Za-z0-9_-]{16,}["\047]' "$f"; then
    echo "BLOCKED: hardcoded secret in $f"
    exit 1
  fi
done
```

---

## Hivatkozott

- Rule sister: `00-token-discipline.md`, `security.md`
- Hook: `.claude/hooks/check-injection.sh`, `check-safety.sh`
- Skills: `secret-detection`, `security-audit`
- v6.1 anti-style: NEM tartalmazza a secret-eket — secret = engineering scope, NEM identity

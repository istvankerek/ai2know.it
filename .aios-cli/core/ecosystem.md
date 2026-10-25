# Everengine ökoszisztéma kánon (v8.0)

> Forrás: plan-v15, owner döntések D-V15-02..05 (2026-10-06).
> Minden CLI (Claude Code, Codex, Gemini) és minden projekt ezt követi.

## Egy mondatban

**A skillpass.id az egyetlen identitás-szolgáltató.** Ez adja a belépést, a profilt és az
ügyfélportál felületet. **Az aibos.space az egyetlen admin/management konzol.** Ez a
rendszer biztonsági okból saját operátori auth-tal fut. Minden más projekt ezekhez
csatlakozik, és nem épít saját authot, profilt vagy admint.

## Szerepkörök

| Réteg | Rendszer | Szabály |
|-------|----------|---------|
| Identitás (IdP) | **skillpass.id** – Ory Kratos + Hydra, issuer `https://skillpass.id`, login UI `auth.skillpass.id` | OIDC Authorization Code + PKCE, confidential client, BFF. Saját auth TILOS. |
| Profil, biztonság, dokumentumtár, számlák | **skillpass.id Account Center** | Partner projekt nem épít profil oldalt. Deep link + M2M push (pl. `trainings:write`). |
| Ügyfélportál UI | **skillpass.id workspace shell** (`@skillpass/workspace-shell`) | `AppManifest → NavSection → NavItem`, `--sp-` design tokenek, app launcher regisztráció (Hydra client `metadata.launcher`). **Belépés utáni fiók-felület szabvány (D-V16-08):** SkillPass.ID logó a bal sáv tetején, helyi `shell-manifest.ts`, `/fiok/` + aloldalak, Account Center deep linkek a drawerből (`skillpass-portal` → `partner-account-shell.md`). |
| Admin / management | **aibos.space** konzol | Partner projekt contract-first admin API-t ad (OpenAPI + M2M + actor assertion). Saját admin app nincs. |
| Operátori auth (kivétel) | **aibos-auth** | Saját auth, kötelező TOTP, nincs regisztráció, nincs email login link. skillpass OIDC csak `auth.skillpass.enabled` flag mögött, explicit linkeléssel, auto-provisioning nélkül. |
| Közös üzleti szolgáltatások | `pay.aibos.space`, `invoice.aibos.space`, `delivery.aibos.space` | Cégkötött API kulcs (`aibs_…`), idempotencia kulcs, aláírt callback outbox. |
| Tartalom | aibos.space → `aibos-public` API | A tartalom aibosból jön, nem kódból. |
| Gateway | Caddy (aio.broker) + Cloudflare | Rate limit, security headerek, error oldalak. |
| Infrastruktúra | MinIO, Hetzner S3 (WORM), NATS JetStream, Qdrant, PostgreSQL schema-per-service, Redis csak cache | Lásd `docs/ECOSYSTEM.md`. |

## Adatfolyamok

```
Felhasználó ──OIDC (Code+PKCE)──▶ skillpass.id ──token (BFF, httpOnly cookie)──▶ partner portál
partner portál ──M2M client_credentials (szűk scope)──▶ skillpass.id  (képzés, dokumentum, számla push)
aibos.space konzol ──typed client + M2M + actor assertion──▶ partner admin API (contracts/admin/*.yaml)
aibos.space ──aibos-public API──▶ partner portál tartalom
operátor ──aibos-auth (TOTP)──▶ aibos.space   [külön auth világ, nincs közös token/session]
```

## Döntési fa új projekthez

1. Van bejelentkező felhasználó? → `skillpass-auth` skill, OIDC client regisztráció.
2. Van ügyfél-/tagi felület? → `skillpass-portal` + `skillpass-app-launcher`
   skill, `templates/portal/`.
3. Kell kezelőfelület (CRUD, riport, beállítás)? → `aibos-admin-contract` skill,
   `templates/admin-contract/`. Az admin UI az aibos.space-ben épül (DLA minta).
4. Pénz, számla, szállítás? → aibos services (`pay` / `invoice` / `delivery`).
5. Csak az **aibos** repo épít saját authot és admin UI-t. Csak a **skillpass** repo
   épít IdP-t és Account Centert.

## TILOS

- Saját bejelentkezés, jelszó-hash, session store partner projektben.
- Token `localStorage`-ban vagy bármilyen JS által olvasható helyen.
- Saját profil / biztonság / eszközök oldal partner projektben.
- Saját admin app partner projektben (az aibos.space-ben kell felépíteni).
- Megszűnt identitás-szolgáltató használata vagy említése új kódban (a `check-brand` hook jelzi).
- Közös token vagy session az operátori (aibos-auth) és az ügyfél (skillpass) világ között.
- Wildcard permission, frontend-only jogosultság-ellenőrzés.

## Kapcsolódó

- Szabály: `.claude/rules/ecosystem.md`, `.claude/rules/security.md`
- Skillek: `skillpass-auth`, `skillpass-portal`, `skillpass-app-launcher`,
  `aibos-admin-contract`, `admin-experience`, `crud-dla-module`
- Tapasztalatok: `.aios-cli/core/lessons.md`

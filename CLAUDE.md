# skeleton

> Ez a fájl automatikusan generált.
> Forrás: `.aios-cli/core/` + `.aios-cli/adapters/claude/CLAUDE.md.template`
> Módosítsd a forrást, ne ezt a fájlt.
> Generálás: `.aios-cli/scripts/generate-cli-configs.sh claude`

# AIOS CLI – Egységes Utasítások (v8.0)

> Ez a fájl az egyetlen igazság forrása (single source of truth) minden CLI adapter számára.
> Ne módosítsd közvetlenül – a változtatások az `adapters/` sablonokba mennek, majd
> `scripts/generate-cli-configs.sh` generálja a tényleges konfigurációs fájlokat.

## 9 Aranyszabály (minden feladatra, kivétel nélkül)

1. **KÉRDEZZ VISSZA** mielőtt komplex feladatba kezdenél – ne találgass
2. **MUTASS TERVET** mielőtt kódolnál – plan komplex feladatokhoz
3. **SOHA ne törölj** fájlt vagy adatot explicit jóváhagyás nélkül
4. **SOHA ne commitolj** main-re közvetlenül
5. **ÍRJ failing tesztet ELŐSZÖR** (TDD Iron Law) – soha nincs production kód failing test nélkül
6. **MARADJ A FELADATNÁL** – ne refaktorálj, ne "javíts" olyat amit nem kértek
7. **MINŐSÉG > SEBESSÉG** – szánj időt, ne hagyj ki lépéseket
8. **ÚJ TÉMA = ÚJ SESSION** – ne szennyezd a kontextust
9. **MINDEN TOKEN FIZESSEN** – Context Economy: ha nem ér, ki vele

## Folder=Behavior elv

A `.aios-cli/` skeleton a közös source-of-truth Claude Code, Codex és Gemini
számára. A `.claude/` mappa továbbra is Claude Code belépési pont, de a skillek
közös forrása `.aios-cli/skills`.

A viselkedést a skeleton mappák definiálják:

| Mappa | Mit ad | Példa |
|-------|--------|-------|
| `rules/` | TUDJON | code-style, security, testing |
| `commands/` | CSINÁLJON | /review, /plan, /deploy |
| `skills/` | HOGYAN | tdd-enforcer, brand-auditor |
| `agents/` | KIVE váljon | qa-team, debug-debate |
| `memory/` | EMLÉKEZZEN | patterns, mistakes |
| `identity/` | KOMMUNIKÁLJON | voice, anti-style, brand |

Egy új fájl új viselkedést ad – nincs külön "register" lépés.

## Scope rendszer (v6.3)

| Scope | Path | Tartalom | Commit-elt? |
|-------|------|----------|-------------|
| Project | `.aios-cli/` | Közös CLI skeleton, skill source, adapter template-ek | Igen |
| Claude Entry | `.claude/` | Claude Code hookok, parancsok, identity, belépési linkek | Igen |
| Personal | `~/.claude/` | Cross-project, saját preferenciák | Nem |

Merge szabályok: `permissions.allow` unió, `permissions.deny` unió,
`env` personal felülírja a project-et, hooks mindkettő fut (project → personal).

## Orchestráció és modell routing (v8.0)

Egyetlen policy: `.aios-cli/orchestrator/policy/routing-policy.toml`. Mindhárom CLI és a
hook ugyanazt használja: `scripts/aios route "<feladat>"`.

| Tier | Elsődleges | Mikor |
|------|-----------|-------|
| PLAN | Claude Fable 5.1 | architektúra, plan-vN, ADR |
| CRITICAL | Claude Opus 5.5 (`--confirm`) | prod, migráció, security, adatvesztés |
| STANDARD | Claude Sonnet 5.5 | feature, bug fix, refactor |
| REVIEW | Claude Sonnet 5.5 | review, PR |
| SCOPED | Codex balanced | boilerplate, CRUD scaffold, batch |
| LARGE_CONTEXT | Gemini CLI | >200K token, web kutatás |
| MECHANICAL | helyi MLX / LM Studio / llama.cpp → Haiku 4.5 | rename, formázás, regex |
| CONSENSUS | Claude + Codex + Gemini | kritikus döntés |

Érzékeny adat (PII, titok, ügyféladat, jogi tervezet) → csak helyi modell vagy Claude.
Részletek: `.aios-cli/core/routing-policy.md`, `aios-orchestrator` skill.

## Identity és Brand

Az `.claude/identity/` mappa 14 fájl tartalmazza az ORG identitást.
Minden user-facing tartalom generálás előtt be kell olvasni a releváns fájlokat.

Részletek: `.aios-cli/core/identity-summary.md`

## Munkafolyamat Pipeline (v6.2)

```
Brainstorm → Plan → Execute → Test → Review → Debug → Ship
```

| Fázis | Mikor hagyható ki |
|-------|-------------------|
| Brainstorm | precíz spec, konkrét bug fix |
| Plan | egysoros, rename, format |
| Test | refactor (viselkedés nem változik) |
| Review | format, rename |

## Plan-v Workflow (v8.0)

Komplex Codex vagy Claude Code munka esetén a terv a repo-ban él:

1. Hozd létre a következő `specification/plan-vN/` mappát (sablon: `templates/plan/`).
2. Írd le a tervet fázisonként külön Markdown fájlban.
3. Elfogadott terv után implementálj.
4. Minden fázis után ellenőrizd vissza a megvalósítást a plan mappából.
5. Futtass unit/validation tesztet, majd git save point.
6. Deploy alapból csak non-prod (`local` vagy `test`), utána automatizált smoke.
7. Hibánál javítás, újrateszt, új non-prod deploy/smoke.
8. Végső commit csak akkor, ha az elfogadott terv szerint működik.

Prod deploy csak explicit jóváhagyással mehet (owner: "mehet").

## Multi-CLI (v6.4)

Ez a skeleton három CLI-t támogat egyetlen shared kernel-lel:

| CLI | Erősség | Amikor használd |
|-----|---------|-----------------|
| Claude Code | Komplex reasoning, skills rendszer | Alapértelmezett komplex munkákhoz |
| Codex CLI | Fast-first implementáció, batch, review | Scoped fejlesztés, mechanikus és közepes task |
| Gemini CLI | 2M context, web research, grounding | Nagyon nagy kódbázis audit, web kutatás |

Aktív CLI: `AIOS_ACTIVE_CLI` env var (default: `claude`).
Váltás: `/project:cli-switch claude|codex|gemini`.
Konszenzus: `multi-vendor-consensus` skill kritikus döntéseknél.

## Fast-first Routing (v8.0)

- Codex profilok: `fast` (gpt-5.3-codex-spark), `balanced` (gpt-5.3-codex), `deep` (gpt-5.5).
- Claude: Sonnet 5.5 fejlesztésre, Haiku 4.5 lookupra, Opus 5.5 csak critical gate-tel,
  Fable 5.1 tervezésre.
- Helyi modell (MLX / LM Studio / llama.cpp) mechanikus munkára és gépen maradó adatra.
- Subagent csak független, jól körülhatárolt munkára; max 3 párhuzamos szál alapból.

## RTK Token Optimization (v7.2)

Mindhárom CLI használja az RTK auto-rewrite ökoszisztémát: 60-90% token-megtakarítás
gyakori bash parancsoknál (git, gh, cargo, pytest, npm, docker, kubectl, aws stb.).

- **Claude Code**: PreToolUse Bash hook (`.claude/hooks/rtk-rewrite.sh`)
- **Codex CLI**: AGENTS.md instrukciók
- **Gemini CLI**: PreToolUse hook (`~/.gemini/hooks/rtk-hook-gemini.sh`)

A teljes per-CLI hivatkozás minden generált config (CLAUDE.md / AGENTS.md / GEMINI.md)
végén megjelenik (`.aios-cli/scripts/generate-cli-configs.sh` RTK_REFERENCE szekció).

Telepítés (egyszer, fejlesztő gépén): `.aios-cli/scripts/install-rtk.sh`
NAIH compliance: `RTK_TELEMETRY_DISABLED=1` (default).
Részletek: `rtk-optimizer` skill, `.claude/workflows/rtk-onboarding.yml`.

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

## Ökoszisztéma tapasztalatok (v8.0)

> Forrás: owner kérések az aiagentekagyakorlatban.hu, skillpass.id, aibootcamp.hu és
> aibos.space projektekből (plan-v15 F5). Minden projektben azonosan érvényes.

| # | Szabály | Forrás |
|---|---------|--------|
| L-01 | Owner döntés = tény, azonosítóval: `D-Vn-NN`; javaslat: `P-Vn-NN`. Ne vitasd újra. | aibos, aibootcamp.hu |
| L-02 | Plan mappa: `00-overview` → fázis fájlok → `implementation-notes` (eredmény, telepítés, smoke). Sablon: `templates/plan/`. | mind |
| L-03 | Go-live / prod csak az owner explicit "mehet" válasza után. | aibootcamp.hu |
| L-04 | Titok soha nem kerül chatbe, promptba, logba vagy ledgerbe. | aibootcamp.hu, aibos |
| L-05 | Contract-first: előbb OpenAPI, a másik oldal mockra épít. | aibos, aibootcamp.hu |
| L-06 | Menüpont soha nem vezet 404-re, ezt teszt őrzi. | aibos |
| L-07 | Őszinte hibák: nincs csendes hiba vagy fallback, RFC 7807 válasz. | aibos |
| L-08 | Migráció után restart-teszt (crashloop tanulság). | aiagentekagyakorlatban.hu |
| L-09 | Jogi szöveg tervezet marad, amíg az owner nem hagyja jóvá. | aibootcamp.hu |
| L-10 | Adattakarékosság: IP csak kulcsolt hash; aibos nem tárol ügyfél shop adatot; a forrásrendszer állapotgépe az irányadó. | aibootcamp.hu, aibos |
| L-11 | Kézi felülírás csak indokkal, mindig auditálva; az audit append-only. | aibos |
| L-12 | Tartalom aibosból jön, nem kódból; nyomtatott URL-ek nem változhatnak. | aiagentekagyakorlatban.hu |
| L-13 | Logout: a Hydra logout után a Kratos session is záródjon. | skillpass |
| L-14 | Fehér shadcn admin, DLA (`/add`, sosem `/new`), skeleton loading, dark mode, hu+en i18n. | mind |
| L-15 | Partner projekt nem épít saját authot, profilt vagy admint (skillpass.id / aibos.space). | plan-v15 |
| L-16 | Egy projekt = egy mappa: worktree a projekten belül (`worktrees/<slug>/`), beolvasztás után lezárva (`close-worktree.sh`); microservice `subprojects/` alatt `SUBPROJECT.md`-vel. Semmi nem él a projekt mellett `dev/`-szinten. | plan-v16 |
| L-17 | Belépés utáni fiók-felület minden partnernél azonos: SkillPass workspace shell, logó a bal sáv tetején, helyi shell-manifest, `/fiok/` + aloldalak, profil/biztonság/dokumentum/számla csak Account Center deep link. | aibootcamp.hu, plan-v16 |

## Orchestráció (v8.0)

Komplex vagy költséges feladat előtt: `scripts/aios route "<feladat>"`. Ez adja a tier-t,
a CLI-t és a modellt, valamint a fallback láncot. Érzékeny adat nem mehet Gemini vagy
Codex felé. Részletek: `.aios-cli/core/routing-policy.md`, `aios-orchestrator` skill.

# AIOS – Kódolási Konvenciók

> Minden CLI adapterben érvényes. Az egyedi adapter-specifikus kiegészítések
> az `adapters/{cli}/` sablonokban találhatók.

## TypeScript

- **strict** mód kötelező (`"strict": true` tsconfig-ban)
- **SOHA** `any` type – használj `unknown`-t és type guard-ot
- **SOHA** `as` type assertion kerülő megoldásként
- **Zod** validáció minden endpoint input/output-on
- Prefer `interface` over `type` publikus API-hoz

## Feature-based struktúra

```
src/modules/{feature}/{action}/
  CreateUserEndpoint.ts
  CreateUserService.ts
  CreateUserDto.ts
  CreateUser.test.ts
```

Fájlnév = funkció. NEM generikus: `controller.ts`, `service.ts`, `utils.ts`.

## Import sorrend

1. React / React Router
2. Külső könyvtárak (zod, axios, stb.)
3. Belső modulok (lib/, components/)
4. Típusok (type imports)

Üres sor a csoportok között.

## JSDoc – magyarul

```typescript
/**
 * Létrehozza a felhasználót a megadott adatokkal.
 * @param dto - A felhasználó adatait tartalmazó DTO
 * @returns A létrehozott felhasználó ID-ja
 * @throws ValidationError ha az email formátum érvénytelen
 */
```

## API Konvenciók

- Hiba formátum: RFC 7807
- Lapozás: cursor-based
- Verziózás: URL path (`/api/v1/`)
- HTTP státusz kódok: 200/201/204/400/401/403/404/409/429/500

RFC 7807 példa:
```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validációs hiba",
  "status": 400,
  "detail": "Az email cím formátum érvénytelen",
  "instance": "/api/v1/users"
}
```

## Egyéb szabályok

- Logger modul használata – SOHA `console.log`
- Nincs hardcoded URL – környezeti változó
- Nincs magic number – nevesített konstans
- Parameterized query kizárólag (SQL injection védelem)
- CORS: explicit whitelist, SOHA `*`

## Elnevezési konvenciók

- PascalCase: komponensek, interfészek, type-ok
- camelCase: függvények, változók, property-k
- UPPER_SNAKE_CASE: konstansok
- kebab-case: fájlnevek (kivéve: `{Action}{Entity}` minták)

## Tiltások

- `.env` commitálás
- `any` type
- `console.log`
- TODO/FIXME/HACK/placeholder kód
- Hardcoded URL
- Saját kriptográfia
- Docker nélküli futtatás

---

## Claude Code – Specifikus Kiegészítések

### Skill rendszer

A közös skill source-of-truth: `.aios-cli/skills/`.
A `.claude/skills/` mappa automatikus Claude Code belépési pont; a generátor
az új közös skilleket ide linkeli, a meglévő másolatokat a forrásra tükrözi
(a megszűnt útvonalak listája: `.aios-cli/removed-paths.txt`).

Fontos skill-ek:
- `tdd-enforcer` – TDD Iron Law betartatása (P0)
- `brand-auditor` – brand konzisztencia ellenőrzés
- `parallel-reviewer-orchestrator` – párhuzamos kód review
- `debug-3strike` – 3 sikertelen próbálkozás után /clear + brainstorm
- `multi-vendor-consensus` – 3 CLI párhuzamos futtatás kritikus döntésekhez
- `cli-router` – feladathoz legjobb CLI javaslat

## AIOS Skill Source

Source-of-truth: `.aios-cli/skills`.
When a task matches a skill description, read that skill's `SKILL.md` before implementing.
Do not edit generated CLI instructions directly; update `.aios-cli` sources and regenerate.

### Available Project Skills

Teljes menünézet: `.aios-cli/skills/CATALOG.md`.

#### Identitás (SkillPass.ID) (`identity`)

- `skillpass-auth` — SkillPass.ID OIDC Authorization Code + PKCE integracio partner portalokon
- `login-history` — Belepesi elozmemyek: sikeres/sikertelen login-ok, IP, lokacio, eszkoz, bongeszo, gyanus tevekenyseg detektalas
- `profile-system` — Felhasznaloi profil: fiok, eszkozok, belepesi elozmemyek, tevekenyseg naplo, ertesitesek, megjelenes beallitasok
- `appearance-settings` — Megjelenes beallitasok: tema (light/dark/system), szin sema, nyelv, lokalizacio, kedvenc menu, lista nezet preferencia, betumeret
- `skillpass-portal` — Ugyfelportal epites a SkillPass.ID workspace shell-lel
- `skillpass-app-launcher` — Partner portal regisztracio a SkillPass.ID 9-pontos launcherben es a workspace shell app-listajaban

#### Admin (aibos.space) (`admin`)

- `aibos-admin-contract` — Admin API contract-first minta: OpenAPI `contracts/admin/*.yaml` a partner projektben, permission kódok (`{projekt}.{modul}.{akció}`, DENY default, nincs wildca
- `api-documentation` — API dokumentacio: OpenAPI/Swagger spec generalas, interaktiv API explorer, endpoint lista, request/response peldak
- `api-keys-management` — API kulcs generalas, kezeles, rotacio, rate limiting per key, scope-olt hozzaferes, audit log
- `crud-dla-module` — Kotelezo CRUD + DLA modul minta
- `dla-menu-pattern` — DLA (Dashboard / List / Add) menu struktura es URL pattern minden modulnal
- `crud-generator` — ModuleConfig alapu CRUD generalas: route, page, form, tabla, permission guard
- `list-view` — Admin lista nezet: Simple (shadcn/ui) + Advanced (AG Grid Enterprise), kereses, szures, rendezes, lapozas, bulk muveletek, mentett nezetek
- `form-builder` — Urlap generalas ModuleConfig alapjan: Zod validacio, mezotipusok, section-ok, conditional megjelenes, fajl feltoltes
- `admin-experience` — Production-grade shadcn-stílusú DLA admin UX
- `dashboard-widgets` — Dashboard oldal generalas: counter widgetek, chart-ok (recharts), legutobbi elemek lista, gyors muveletek, KPI-k
- `command-palette` — Admin command palette (Cmd+K): gyors navigacio, kereses, muvelet inditas, billentyuparancsok, kontextus-fuggo javaslatok
- `permission-rbac` — Minden endpoint require_permission() dekoratorral / makroval
- `roles-permissions` — Szerepkor kezeles, permission matrix, vizualis roles editor, require_permission makro, CRUD permission guard
- `audit-trail-mandatory` — Minden create/update/delete muvelet utan log_activity() hivas KOTELEZO
- `activity-log` — CRUD tevekenyseg naplo: automatikus middleware, change tracking (old->new), particionalt tabla, felhasznalo/IP/user agent, S3 archivalas
- `alert-system` — Felhasznaloi alertek az admin feluleten: info, warning, error, success banner-ek, toast-ok, system-wide announcements, scheduled alerts
- `analytics-dashboard` — Szerver es worker analitika dashboard: CPU, RAM, disk, halozat, container stats, queue melyseg, API latency, AI koltseg
- `backup-manager-ui` — Backup kezelo admin felulet: backup allapot, manualis inditas, restore, backup meret, retention, utemezes
- `feature-flags` — Feature flag rendszer: funkciok be/kikapcsolasa, A/B teszteles, fokozatos kiveteles (gradual rollout), felhasznalo celzas
- `maintenance-mode` — Karbantartasi mod: Caddy szintu + backend szintu intercept, admin IP whitelist, 503 oldal, tervezett karbantartas ertesites
- `safedata-mode` — Csak olvashato mod: irasi muveletek letiltasa, 423 Locked valasz, DB karbantartas, migracio alatti vedelem
- `module-marketplace` — Modul rendszer: EverengineModule interfesz, telepites, frissites, eltavolitas, dependency kezeles, marketplace registry
- `taxonomy-system` — Egyseges taxonomy rendszer: groups, labels, categories, statuses
- `support-faq` — Support & FAQ rendszer: GYIK szekcio, ticket rendszer (egyszeru), kontakt form, tudasbazis cikkek, kereses

#### Frontend (`frontend`)

- `frontend-design` — Production-grade frontend kod – nem "AI slop"
- `skeleton-loading` — Skeleton/shimmer loading pattern, loading waterfall, progressive data loading, optimistic UI, suspense boundary-k
- `theme-system` — Tema rendszer: CSS valtozok, komponens override-ok, egyedi betutipusok, tema telepites, tema szerkeszto
- `file-upload` — Fajl feltoltes komponens: drag & drop, multi-file, progress bar, presigned URL (MinIO), tipus/meret validacio, kep elonezet, kep crop/resize
- `file-manager` — Fajlkezelo: MinIO/S3 bongeszo, feltoltes, letoltes, elonezet, mappa struktura, jogosultsagok, meret korlatok
- `tf-intelligent-menu` — TensorFlow.js alapu intelligens admin: felhasznaloi szint joslas (beginner/intermediate/expert), dashboard szemelyre szabas, menu sorrend optimalizalas, kovetke
- `coming-soon-notify` — "Hamarosan" (coming soon) oldal modul, email ertesites feliratkozas, launch countdown, waitlist kezeles
- `i18n-required` — Minden user-facing string t() hook-on at, hu + en kulcsok szinkronban
- `i18n-setup` — Nemzetkoziesites es lokalizacio: react-i18next konfiguracio, nyelvi fajlok, datum/szam/penznem formazas, idozona, mertekegysegek

#### Backend (`backend`)

- `db-migration` — Adatbazis migracio: inkrementalis, visszafordithato (up+down), dry-run, seed data, schema diff
- `data-import` — Adat import: CSV, XLSX, JSON fajlokbol, mapping, validacio, hibakezelés, progress tracking, nagy fajl tamogatas
- `s3-storage` — MinIO es Hetzner S3 konfiguracio, bucket policy, WORM, presigned URL, fajl feltoltes logika
- `vector-search` — Qdrant vektor adatbazis integracio, embedding generalas, szemantikus kereses, RAG pipeline, hasonlosag kereses
- `webhook-manager` — Webhook rendszer: kulso rendszerek ertesitese esemenyek utan, retry logika, signature verification, webhook log
- `email-mailgun` — Mailgun EU integracio, MJML template-ek, webhook kezeles, bounce/complaint handling, NATS queue kuldes
- `notification-system` — Tobbcsatornas ertesites: Email (Mailgun), In-App (WebSocket), Telegram, Slack
- `scheduled-tasks` — Utemezett feladatok: cron-szeru feladat utemezes, NATS delayed message, recurring tasks, task monitor
- `worker-management` — NATS JetStream worker queue-k, worker tipusok, auto-scale szabalyok, concurrency kezeles, koltseg limitek
- `scraper` — Web scraper: proxy pool, rate limiting, robots.txt, headless browser, strukturalt adat kinyeres
- `spider` — Weboldal felterkepzes: URL frontier, crawl strategiak, sitemap parser, link graf, SEO audit

#### Biztonság (`security`)

- `security-audit` — Biztonsagi audit: secret scan, dependency audit, OWASP check, SQL injection, XSS, SSRF, CORS ellenorzes
- `secret-detection` — Secret/credential detektalas kodban, PreToolUse hook, PreCommit guard, regex mintak (AWS, OpenAI, Anthropic, GitHub, DB connection string)

#### Minőség (`quality`)

- `tdd-enforcer` — TDD Iron Law betartatasa – failing test ELOSZOR (new feature) vagy reproduction test ELOSZOR (bug fix)
- `unit-test-writer` — Unit teszt generalas: Arrange-Act-Assert, magyar teszt nevek, edge case-ek, mock factory, coverage ellenorzes
- `integration-test` — Integration teszt: API endpoint tesztek, DB tesztek, service integracio, test fixtures, seed data
- `e2e-test` — End-to-end teszt: Playwright, kritikus user flow-k, visual regression, cross-browser teszteles
- `webapp-testing` — E2E, accessibility es performance teszteles: Playwright, axe-core, Lighthouse
- `code-review` — Kod review: biztonsag, tipusbiztonsag, teljesitmeny, tesztelhetoseg, konvenciok, feature-based struktura ellenorzes
- `parallel-reviewer-orchestrator` — Parhuzamos kod review orchestracio – ket fuggetlen subagent (SPEC + QUALITY) friss kontextusban, decision matrix SHIP × SHIP = ✅ MERGE
- `code-style` — Kod stilus: TypeScript konvenciok, Rust konvenciok, import sorrend, elnevezesi mintak, feature-based struktura
- `refactor` — Refaktoralasi javaslatok: komplexitas csokkentes, duplikacio eltavolitas, SOLID elvek, feature-based atszervezes
- `debug-3strike` — 3 strike rule a debug munkahoz – 3 sikertelen javitasi probalkozas utan kotelezo STOP, /clear es brainstorm
- `auto-iterate` — Automatikus iteracio: futtatja a tesztet/lint-et ismetlodoen amig zold nem lesz, budget limittel es circuit breaker-rel

#### Üzemeltetés (`ops`)

- `deploy-pipeline` — Deploy pipeline: pre-flight check, build, migrate, deploy, health check, rollback terv, environment kezeles (test/prod)
- `ci-cd-setup` — CI/CD pipeline: GitHub Actions, lint->test->build->deploy, PR checks, auto-merge szabalyok, release automation
- `docker-setup` — Docker Compose konfiguracio, multi-service setup, environment override-ok
- `server-migration` — Szerver migracio script, maintenance mode, backup, restore, DNS switch
- `changelog-generator` — Changelog generalas: Git history-bol, conventional commits alapjan, CHANGELOG.md frissites, release notes, verzio kezeles
- `caddy-gateway` — Caddy reverse proxy konfiguracio, aio.broker vezerles, domain routing, rate limiting, security headers, maintenance mode routing, error pages
- `cloudflare-cdn` — Cloudflare konfiguracio: Tunnel, CDN cache, WAF, DDoS vedelem, Page Rules, image optimization, Zero Trust
- `monitoring-setup` — Prometheus, Grafana, Loki, Jaeger, Alertmanager konfiguracio
- `auto-scale` — Worker es service auto-scale szabalyok, Prometheus metrika alapu skalazas, replica management
- `backup-strategy` — Backup konfiguracio, Hetzner S3 WORM, MinIO mirror, PostgreSQL/MongoDB dump, retention policy, restore teszteles
- `runbook-generator` — Runbook generalas monitoring alertekhez: tunet, sulyossag, azonnali teendok, diagnozis, megoldas, megelozes, eszkalacio

#### AI orchestráció (`ai`)

- `aios-orchestrator` — AIOS orchestrator használata: feladatonként determinisztikusan eldönti a CLI-t (Claude Code, Codex, Gemini, helyi MLX / LM Studio / llama.cpp), a modellt, az ef
- `cli-router` — Feladathoz legjobb CLI javaslat (Claude Code / Codex / Gemini / helyi modell)
- `multi-vendor-consensus` — Kritikus döntéseknél három CLI párhuzamos futtatása és konszenzus elemzés
- `local-models` — Helyi LLM szerverek hasznalata: MLX (mlx_lm.server), LM Studio es llama.cpp (llama-server)
- `ai-agent-reliability` — AI agent reliability playbook: RETRY (exponential backoff), TIMEOUTS, FALLBACK PATHS (Claude→Codex→Gemini), CIRCUIT BREAKERS
- `agent-teams-coordinator` — Agent Teams technikai koordinacio: Redis pub/sub mailbox setup, shared task list management, atomic locking, conflict resolution
- `workflow-runner` — YAML workflow futtatas, allapotkövetes es folytatasi kepesseg hiba utan
- `mcp-builder` — Egyedi MCP szerver fejlesztes segitse: sablon, best practices, 4-fazisu workflow
- `cost-invariant-check` — LLM-calling crate audit: minden API-hivasi pontnak (Anthropic / OpenAI / Bedrock) van CostTracker + BudgetTier wiring-je? Static analysis, NEM auto-fix
- `token-report-generator` — Heti / havi token + koltseg riport generalas a `ccusage` lokal adatokbol
- `rtk-optimizer` — RTK adoption check + missed savings opportunity-k azonositasa + config tuning
- `rtk-tee-recovery` — RTK tee log recovery: ha kompresszalt output nem eleg debug-hoz, olvasd a helyi tee log-ot UJRAFUTTATAS HELYETT
- `context-auditor` — Context Economy audit
- `prompt-anatomy-template` — 7-szekcios prompt template generalas kritikus feladatokhoz (Hamza Khalid)
- `prompt-quality-boost` — Prompt minoseg auto-emeles Opus 4.7-hez
- `prompt-templates` — Ujrafelhasznoalhato prompt sablonok kezelese: feature request, bug report, architecture review, migration plan, incident response
- `ai-chat-admin` — aiBOS AI Chat admin modul: természetes nyelvi lekérdezés, report generálás, költségoptimalizált model routing (Haiku/Sonnet/Opus fallback escalation-nel), Qdran

#### Munkafolyamat (`workflow`)

- `brainstorming` — Nyers otlet finomitasa eles gondolkodassa
- `ask-user-question-orchestrator` — AskUserQuestion tool intelligens hasznalata
- `session-continuity` — Session kontextus megorzese es visszaallitasa: COORDINATION.md frissites, session summary mentes, korabbi session kereses, Git history alapu kontextus rekonstru
- `claude-code-session-handoff` — Session vege workflow: `/rename` descriptive name → `/clear` uj kontextus → kesobb `claude -r <name>` visszatolt
- `memory-curator` — Memory v2 (RAD) kezelese: observations kereses, mentes, promotalas, cleanup
- `autodream` — Projekt memoria rendrakas es tanulsag-kinyeres
- `failed-experiment-curator` — Kudarcba fulladt kiserletezesek dokumentalasa es archiválása
- `skill-router` — Hook-alapu intelligens skill aktivalas fajl path alapjan
- `docs-generator` — Automatikus dokumentacio generalas kodbol: JSDoc->markdown, Rust doc->markdown, API endpoint lista, architektura diagram
- `hungarian-docs` — Magyar nyelvu dokumentacio generalas, technikai kifejezesek kezelese
- `onboarding-wizard` — Uj fejleszto onboarding varazslo: kornyezet beallitas, projekt megertese, elso feladat, mentor rendszer
- `internal-comms` — Belso csapat kommunikacio: Slack, email, Telegram ertesitesek
- `brand-auditor` — Brand consistency check user-facing content-en
- `brand-interview` — 90 perces strukturalt interju a brand identity feltarasara

#### Adatelemzés (`data`)

- `auto-viz` — Auto-vizualizacio pandas DataFrame-bol – matplotlib/plotly chart javasol az adattipus alapjan
- `data-export-pipeline` — DataFrame export pipeline – Excel (XLSX), PDF, PowerPoint (PPTX) formazott riportok
- `dataframe-checkpoint` — Pandas DataFrame state mentes (feather/parquet) – analyst session resume, hosszu transzformacio mentes, ne kelljen ujra futtatni a DB query-t
- `jupyter-notebook-editor` — Jupyter notebook (.ipynb) szerkesztes, cell hozzaadas/futtatas, kernel allapot kezeles

### Hook rendszer

A `.claude/hooks/` hookjai automatikusan futnak:
- `PreToolUse`: check-safety, check-injection, skill-router
- `UserPromptSubmit`: intelligent-router (modell routing)
- `PostToolUse`: auto-lint, check-placeholders, check-brand, check-tdd

### Parancsok

Projekt parancsok: `/project:{command}` formában elérhetők.

```
/project:plan          – terv készítés implementáció előtt
/project:review        – párhuzamos kód review
/project:deploy        – deploy pipeline
/project:cli-switch    – CLI váltás (claude/codex/gemini)
/project:brand-check   – brand audit
/project:context-check – context economy audit
```

### Settings

`.claude/settings.json` tartalmazza az env var-okat, permission-öket és hook konfigurációt.
Aktív CLI: `AIOS_ACTIVE_CLI=claude`
## RTK — Token Optimization (v7.2)

This project uses RTK (https://rtk-ai.app, Apache 2.0) for automatic command output
compression. 60-90% token savings on common dev commands.

### How it works
- A PreToolUse hook (Claude/Gemini) or AGENTS.md instructions (Codex) automatically
  rewrites Bash commands to rtk equivalents.
- Example: `git status` → `rtk git status` (transparent, the AI never sees the rewrite).
- 100+ commands supported: git, gh, cargo, pytest, npm, docker, kubectl, aws stb.

### Best practices
- Prefer Bash tool over native Read/Grep/Glob when possible (RTK only intercepts Bash).
- Use `cat`/`head`/`tail` (auto-rewritten to `rtk read`).
- Use `rg`/`grep` (auto-rewritten to `rtk grep`).
- Use `find` (auto-rewritten to `rtk find`).

### Verify
```bash
rtk gain
rtk session
rtk discover
```

### Avoid RTK for
- Critical financial/legal data verification
- Cryptographic verification
- NAV számítások

### Setup
```bash
.aios-cli/scripts/install-rtk.sh
```

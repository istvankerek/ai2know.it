# AIOS Skill Katalógus

> Generált fájl: `.aios-cli/scripts/build-skill-catalog.py --write`. Kézzel ne szerkeszd.
> Forrás: `catalog.manifest.json` (SkillPass.ID menüstruktúra: app → szekció → skill).

## Identitás (SkillPass.ID) · `identity`

Fájl minták: `**/auth/**`, `**/oidc*`, `**/skillpass*`, `**/portal/**`, `**/profile/**`, `**/account/**`

### Belépés

- `skillpass-auth` **P0** – SkillPass.ID OIDC Authorization Code + PKCE integracio partner portalokon
- `login-history` – Belepesi elozmemyek: sikeres/sikertelen login-ok, IP, lokacio, eszkoz, bongeszo, gyanus tevekenyseg detektalas

### Profil

- `profile-system` – Felhasznaloi profil: fiok, eszkozok, belepesi elozmemyek, tevekenyseg naplo, ertesitesek, megjelenes beallitasok
- `appearance-settings` – Megjelenes beallitasok: tema (light/dark/system), szin sema, nyelv, lokalizacio, kedvenc menu, lista nezet preferencia, betumeret

### Ügyfélportál

- `skillpass-portal` **P0** – Ugyfelportal epites a SkillPass.ID workspace shell-lel
- `skillpass-app-launcher` – Partner portal regisztracio a SkillPass.ID 9-pontos launcherben es a workspace shell app-listajaban

## Admin (aibos.space) · `admin`

Fájl minták: `contracts/admin/**`, `contracts/authorization/**`, `**/admin/**`, `**/permission*`, `**/menu-config*`

### Contract

- `aibos-admin-contract` **P0** – Admin API contract-first minta: OpenAPI `contracts/admin/*.yaml` a partner projektben, permission kódok (`{projekt}.{modul}.{akció}`, DENY default, nincs wildca
- `api-documentation` – API dokumentacio: OpenAPI/Swagger spec generalas, interaktiv API explorer, endpoint lista, request/response peldak
- `api-keys-management` – API kulcs generalas, kezeles, rotacio, rate limiting per key, scope-olt hozzaferes, audit log

### DLA / CRUD

- `crud-dla-module` – Kotelezo CRUD + DLA modul minta
- `dla-menu-pattern` – DLA (Dashboard / List / Add) menu struktura es URL pattern minden modulnal
- `crud-generator` – ModuleConfig alapu CRUD generalas: route, page, form, tabla, permission guard
- `list-view` – Admin lista nezet: Simple (shadcn/ui) + Advanced (AG Grid Enterprise), kereses, szures, rendezes, lapozas, bulk muveletek, mentett nezetek
- `form-builder` – Urlap generalas ModuleConfig alapjan: Zod validacio, mezotipusok, section-ok, conditional megjelenes, fajl feltoltes
- `admin-experience` – Production-grade shadcn-stílusú DLA admin UX
- `dashboard-widgets` – Dashboard oldal generalas: counter widgetek, chart-ok (recharts), legutobbi elemek lista, gyors muveletek, KPI-k
- `command-palette` – Admin command palette (Cmd+K): gyors navigacio, kereses, muvelet inditas, billentyuparancsok, kontextus-fuggo javaslatok

### Jogosultság

- `permission-rbac` **P0** – Minden endpoint require_permission() dekoratorral / makroval
- `roles-permissions` – Szerepkor kezeles, permission matrix, vizualis roles editor, require_permission makro, CRUD permission guard

### Audit

- `audit-trail-mandatory` **P0** – Minden create/update/delete muvelet utan log_activity() hivas KOTELEZO
- `activity-log` – CRUD tevekenyseg naplo: automatikus middleware, change tracking (old->new), particionalt tabla, felhasznalo/IP/user agent, S3 archivalas

### Rendszer

- `alert-system` – Felhasznaloi alertek az admin feluleten: info, warning, error, success banner-ek, toast-ok, system-wide announcements, scheduled alerts
- `analytics-dashboard` – Szerver es worker analitika dashboard: CPU, RAM, disk, halozat, container stats, queue melyseg, API latency, AI koltseg
- `backup-manager-ui` – Backup kezelo admin felulet: backup allapot, manualis inditas, restore, backup meret, retention, utemezes
- `feature-flags` – Feature flag rendszer: funkciok be/kikapcsolasa, A/B teszteles, fokozatos kiveteles (gradual rollout), felhasznalo celzas
- `maintenance-mode` – Karbantartasi mod: Caddy szintu + backend szintu intercept, admin IP whitelist, 503 oldal, tervezett karbantartas ertesites
- `safedata-mode` – Csak olvashato mod: irasi muveletek letiltasa, 423 Locked valasz, DB karbantartas, migracio alatti vedelem
- `module-marketplace` – Modul rendszer: EverengineModule interfesz, telepites, frissites, eltavolitas, dependency kezeles, marketplace registry
- `taxonomy-system` – Egyseges taxonomy rendszer: groups, labels, categories, statuses
- `support-faq` – Support & FAQ rendszer: GYIK szekcio, ticket rendszer (egyszeru), kontakt form, tudasbazis cikkek, kereses

## Frontend · `frontend`

Fájl minták: `apps/frontend/**`, `**/components/**`, `**/*.tsx`, `**/locales/**`, `**/messages/**`

### UI

- `frontend-design` – Production-grade frontend kod – nem "AI slop"
- `skeleton-loading` – Skeleton/shimmer loading pattern, loading waterfall, progressive data loading, optimistic UI, suspense boundary-k
- `theme-system` – Tema rendszer: CSS valtozok, komponens override-ok, egyedi betutipusok, tema telepites, tema szerkeszto
- `file-upload` – Fajl feltoltes komponens: drag & drop, multi-file, progress bar, presigned URL (MinIO), tipus/meret validacio, kep elonezet, kep crop/resize
- `file-manager` – Fajlkezelo: MinIO/S3 bongeszo, feltoltes, letoltes, elonezet, mappa struktura, jogosultsagok, meret korlatok
- `tf-intelligent-menu` – TensorFlow.js alapu intelligens admin: felhasznaloi szint joslas (beginner/intermediate/expert), dashboard szemelyre szabas, menu sorrend optimalizalas, kovetke
- `coming-soon-notify` – "Hamarosan" (coming soon) oldal modul, email ertesites feliratkozas, launch countdown, waitlist kezeles

### Nyelv

- `i18n-required` **P0** – Minden user-facing string t() hook-on at, hu + en kulcsok szinkronban
- `i18n-setup` – Nemzetkoziesites es lokalizacio: react-i18next konfiguracio, nyelvi fajlok, datum/szam/penznem formazas, idozona, mertekegysegek

## Backend · `backend`

Fájl minták: `apps/backend/**`, `migrations/**`, `**/*.rs`, `**/workers/**`

### Adat

- `db-migration` – Adatbazis migracio: inkrementalis, visszafordithato (up+down), dry-run, seed data, schema diff
- `data-import` – Adat import: CSV, XLSX, JSON fajlokbol, mapping, validacio, hibakezelés, progress tracking, nagy fajl tamogatas
- `s3-storage` – MinIO es Hetzner S3 konfiguracio, bucket policy, WORM, presigned URL, fajl feltoltes logika
- `vector-search` – Qdrant vektor adatbazis integracio, embedding generalas, szemantikus kereses, RAG pipeline, hasonlosag kereses

### Integráció

- `webhook-manager` – Webhook rendszer: kulso rendszerek ertesitese esemenyek utan, retry logika, signature verification, webhook log
- `email-mailgun` – Mailgun EU integracio, MJML template-ek, webhook kezeles, bounce/complaint handling, NATS queue kuldes
- `notification-system` – Tobbcsatornas ertesites: Email (Mailgun), In-App (WebSocket), Telegram, Slack
- `scheduled-tasks` – Utemezett feladatok: cron-szeru feladat utemezes, NATS delayed message, recurring tasks, task monitor
- `worker-management` – NATS JetStream worker queue-k, worker tipusok, auto-scale szabalyok, concurrency kezeles, koltseg limitek

### Gyűjtés

- `scraper` – Web scraper: proxy pool, rate limiting, robots.txt, headless browser, strukturalt adat kinyeres
- `spider` – Weboldal felterkepzes: URL frontier, crawl strategiak, sitemap parser, link graf, SEO audit

## Biztonság · `security`

Fájl minták: `**/.env*`, `**/secrets/**`, `**/security*`

### Ellenőrzés

- `security-audit` **P0** – Biztonsagi audit: secret scan, dependency audit, OWASP check, SQL injection, XSS, SSRF, CORS ellenorzes
- `secret-detection` **P0** – Secret/credential detektalas kodban, PreToolUse hook, PreCommit guard, regex mintak (AWS, OpenAI, Anthropic, GitHub, DB connection string)

## Minőség · `quality`

Fájl minták: `tests/**`, `**/*.test.*`, `**/test_*.py`, `**/*_test.*`

### Teszt

- `tdd-enforcer` **P0** – TDD Iron Law betartatasa – failing test ELOSZOR (new feature) vagy reproduction test ELOSZOR (bug fix)
- `unit-test-writer` – Unit teszt generalas: Arrange-Act-Assert, magyar teszt nevek, edge case-ek, mock factory, coverage ellenorzes
- `integration-test` – Integration teszt: API endpoint tesztek, DB tesztek, service integracio, test fixtures, seed data
- `e2e-test` – End-to-end teszt: Playwright, kritikus user flow-k, visual regression, cross-browser teszteles
- `webapp-testing` – E2E, accessibility es performance teszteles: Playwright, axe-core, Lighthouse

### Review

- `code-review` – Kod review: biztonsag, tipusbiztonsag, teljesitmeny, tesztelhetoseg, konvenciok, feature-based struktura ellenorzes
- `parallel-reviewer-orchestrator` – Parhuzamos kod review orchestracio – ket fuggetlen subagent (SPEC + QUALITY) friss kontextusban, decision matrix SHIP × SHIP = ✅ MERGE
- `code-style` – Kod stilus: TypeScript konvenciok, Rust konvenciok, import sorrend, elnevezesi mintak, feature-based struktura
- `refactor` – Refaktoralasi javaslatok: komplexitas csokkentes, duplikacio eltavolitas, SOLID elvek, feature-based atszervezes

### Debug

- `debug-3strike` – 3 strike rule a debug munkahoz – 3 sikertelen javitasi probalkozas utan kotelezo STOP, /clear es brainstorm
- `auto-iterate` – Automatikus iteracio: futtatja a tesztet/lint-et ismetlodoen amig zold nem lesz, budget limittel es circuit breaker-rel

## Üzemeltetés · `ops`

Fájl minták: `docker/**`, `infrastructure/**`, `**/Dockerfile*`, `.github/**`, `scripts/deploy*`

### Deploy

- `deploy-pipeline` – Deploy pipeline: pre-flight check, build, migrate, deploy, health check, rollback terv, environment kezeles (test/prod)
- `ci-cd-setup` – CI/CD pipeline: GitHub Actions, lint->test->build->deploy, PR checks, auto-merge szabalyok, release automation
- `docker-setup` – Docker Compose konfiguracio, multi-service setup, environment override-ok
- `server-migration` – Szerver migracio script, maintenance mode, backup, restore, DNS switch
- `changelog-generator` – Changelog generalas: Git history-bol, conventional commits alapjan, CHANGELOG.md frissites, release notes, verzio kezeles

### Hálózat

- `caddy-gateway` – Caddy reverse proxy konfiguracio, aio.broker vezerles, domain routing, rate limiting, security headers, maintenance mode routing, error pages
- `cloudflare-cdn` – Cloudflare konfiguracio: Tunnel, CDN cache, WAF, DDoS vedelem, Page Rules, image optimization, Zero Trust

### Működés

- `monitoring-setup` – Prometheus, Grafana, Loki, Jaeger, Alertmanager konfiguracio
- `auto-scale` – Worker es service auto-scale szabalyok, Prometheus metrika alapu skalazas, replica management
- `backup-strategy` – Backup konfiguracio, Hetzner S3 WORM, MinIO mirror, PostgreSQL/MongoDB dump, retention policy, restore teszteles
- `runbook-generator` – Runbook generalas monitoring alertekhez: tunet, sulyossag, azonnali teendok, diagnozis, megoldas, megelozes, eszkalacio

## AI orchestráció · `ai`

Fájl minták: `.aios-cli/orchestrator/**`, `apps/ai-chat/**`, `.codex/**`, `.gemini/**`

### Routing

- `aios-orchestrator` **P1** – AIOS orchestrator használata: feladatonként determinisztikusan eldönti a CLI-t (Claude Code, Codex, Gemini, helyi MLX / LM Studio / llama.cpp), a modellt, az ef
- `cli-router` – Feladathoz legjobb CLI javaslat (Claude Code / Codex / Gemini / helyi modell)
- `multi-vendor-consensus` – Kritikus döntéseknél három CLI párhuzamos futtatása és konszenzus elemzés
- `local-models` – Helyi LLM szerverek hasznalata: MLX (mlx_lm.server), LM Studio es llama.cpp (llama-server)
- `ai-agent-reliability` – AI agent reliability playbook: RETRY (exponential backoff), TIMEOUTS, FALLBACK PATHS (Claude→Codex→Gemini), CIRCUIT BREAKERS
- `agent-teams-coordinator` – Agent Teams technikai koordinacio: Redis pub/sub mailbox setup, shared task list management, atomic locking, conflict resolution
- `workflow-runner` – YAML workflow futtatas, allapotkövetes es folytatasi kepesseg hiba utan
- `mcp-builder` – Egyedi MCP szerver fejlesztes segitse: sablon, best practices, 4-fazisu workflow

### Költség és kontextus

- `cost-invariant-check` – LLM-calling crate audit: minden API-hivasi pontnak (Anthropic / OpenAI / Bedrock) van CostTracker + BudgetTier wiring-je? Static analysis, NEM auto-fix
- `token-report-generator` – Heti / havi token + koltseg riport generalas a `ccusage` lokal adatokbol
- `rtk-optimizer` – RTK adoption check + missed savings opportunity-k azonositasa + config tuning
- `rtk-tee-recovery` – RTK tee log recovery: ha kompresszalt output nem eleg debug-hoz, olvasd a helyi tee log-ot UJRAFUTTATAS HELYETT
- `context-auditor` – Context Economy audit

### Prompt

- `prompt-anatomy-template` – 7-szekcios prompt template generalas kritikus feladatokhoz (Hamza Khalid)
- `prompt-quality-boost` – Prompt minoseg auto-emeles Opus 4.7-hez
- `prompt-templates` – Ujrafelhasznoalhato prompt sablonok kezelese: feature request, bug report, architecture review, migration plan, incident response

### Termék AI

- `ai-chat-admin` – aiBOS AI Chat admin modul: természetes nyelvi lekérdezés, report generálás, költségoptimalizált model routing (Haiku/Sonnet/Opus fallback escalation-nel), Qdran

## Munkafolyamat · `workflow`

Fájl minták: `specification/**`, `docs/**`, `tasks/**`, `COORDINATION.md`, `.claude/identity/**`

### Tervezés

- `brainstorming` – Nyers otlet finomitasa eles gondolkodassa
- `ask-user-question-orchestrator` – AskUserQuestion tool intelligens hasznalata

### Session és memória

- `session-continuity` – Session kontextus megorzese es visszaallitasa: COORDINATION.md frissites, session summary mentes, korabbi session kereses, Git history alapu kontextus rekonstru
- `claude-code-session-handoff` – Session vege workflow: `/rename` descriptive name → `/clear` uj kontextus → kesobb `claude -r <name>` visszatolt
- `memory-curator` – Memory v2 (RAD) kezelese: observations kereses, mentes, promotalas, cleanup
- `autodream` – Projekt memoria rendrakas es tanulsag-kinyeres
- `failed-experiment-curator` – Kudarcba fulladt kiserletezesek dokumentalasa es archiválása
- `skill-router` – Hook-alapu intelligens skill aktivalas fajl path alapjan

### Dokumentáció

- `docs-generator` – Automatikus dokumentacio generalas kodbol: JSDoc->markdown, Rust doc->markdown, API endpoint lista, architektura diagram
- `hungarian-docs` – Magyar nyelvu dokumentacio generalas, technikai kifejezesek kezelese
- `onboarding-wizard` – Uj fejleszto onboarding varazslo: kornyezet beallitas, projekt megertese, elso feladat, mentor rendszer
- `internal-comms` – Belso csapat kommunikacio: Slack, email, Telegram ertesitesek

### Brand

- `brand-auditor` – Brand consistency check user-facing content-en
- `brand-interview` – 90 perces strukturalt interju a brand identity feltarasara

## Adatelemzés · `data`

Fájl minták: `**/*.ipynb`, `**/notebooks/**`

### Elemzés

- `auto-viz` – Auto-vizualizacio pandas DataFrame-bol – matplotlib/plotly chart javasol az adattipus alapjan
- `data-export-pipeline` – DataFrame export pipeline – Excel (XLSX), PDF, PowerPoint (PPTX) formazott riportok
- `dataframe-checkpoint` – Pandas DataFrame state mentes (feather/parquet) – analyst session resume, hosszu transzformacio mentes, ne kelljen ujra futtatni a DB query-t
- `jupyter-notebook-editor` – Jupyter notebook (.ipynb) szerkesztes, cell hozzaadas/futtatas, kernel allapot kezeles

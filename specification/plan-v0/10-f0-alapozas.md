# F0 – Alapozás és azonnali biztonsági lépések

> Cél: tiszta, reprodukálható fejlesztői alap + a régi rendszer kitett titkainak és portjainak
> kezelése, mielőtt bármi új élesbe megy.
> Routing: STANDARD (repo, CI), CRITICAL (titokcsere, éles szerver – owner jóváhagyás).

## 1. Repo és skeleton

- [x] Skeleton 8.0.0 telepítve (`install.sh`), `projects/projects.list` + `projects/ai2know.it.md` a skeletonban.
- [x] `/backup/` a `.gitignore`-ban (legacy forrás, dumpok, `.env`-ek, személyes adat).
- [x] `git init -b main` (első commit nincs, owner kéri).
- [ ] GitHub remote, branch védelem: `main` csak PR-ral, `feat/*`, `fix/*` ágak (4. aranyszabály).
- [ ] Első commit előtt kötelező ellenőrzés: `git ls-files | grep -E '^backup/|\.env$|\.sql|\.db$'` üres.
- [ ] Skeleton appok rendezése (P-V0-03): `apps/frontend`, `apps/admin`, `apps/ai-chat` eltávolítása
      owner jóváhagyás után; `apps/web` (Next.js) és `crates/` létrehozása.
- [ ] `CLAUDE.md` / `AGENTS.md` projekt szekció: domain, kontextusok, tiltások (a generátorral,
      `.aios-cli` forrásból).

## 2. Fejlesztői környezet

- [ ] `environments/.env.example` – csak kulcsnevek, érték nélkül:
      `DATABASE_URL`, `REDIS_URL`, `NATS_URL`, `MINIO_*`, `SKILLPASS_ISSUER`, `SKILLPASS_CLIENT_ID`,
      `SKILLPASS_CLIENT_SECRET`, `SKILLPASS_REDIRECT_URI`, `SKILLPASS_COOKIE_SECRET`,
      `SKILLPASS_M2M_CLIENT_ID/SECRET`, `AIBOS_PUBLIC_BASE_URL`, `AIBOS_PORTAL_SLUG=ai2know-it`,
      `AIBOS_WORKLOAD_JWKS_URL`, `AIBOS_ACTOR_JWKS_URL`, `IP_HASH_KEY_CURRENT/PREVIOUS`,
      `REVALIDATE_WEBHOOK_SECRET`, `PUBLIC_BASE_URL=https://ai2know.it`.
- [ ] `docker/docker-compose.yml` + `.local.yml`: postgres 16, redis, nats (JetStream), minio,
      backend, web, caddy. `make local` egy paranccsal indít.
- [ ] skillpass.id helyi dev-stack vagy test példány (partner-integracio.md 7. fejezet) – Q-05.

## 3. CI (GitHub Actions)

- [ ] Rust: `cargo fmt --check`, `cargo clippy -D warnings`, `cargo test`, `cargo audit`.
- [ ] Web: `pnpm lint`, `pnpm typecheck`, `pnpm test`, `pnpm audit --prod`.
- [ ] Contract: `python3 scripts/validate-contract.py contracts/` (aibos minta).
- [ ] Skeleton: `tests/skeleton-validation/run-all.sh`.
- [ ] Secret scan (gitleaks vagy a skeleton `secret-detection` hook) minden PR-on.
- [ ] Redirect regresszió (F6-tól): a `03` URL-lista teljes futása.

## 4. Azonnali biztonsági teendők a RÉGI rendszeren (owner jóváhagyás kell, éles!)

Az átvizsgálás (01) szerint a régi rendszer titkai a git történetben, a readme-ben és `.env`
fájlokban vannak, és több admin eszköz nyilvánosan elérhető. Ez független az újraírástól, a
mostani éles rendszert érinti.

- [ ] **Titokcsere:** Mailgun, OpenAI, Groq, Számlázz.hu agent kulcs, Stripe, JWT kulcsok,
      PostgreSQL jelszó, pgAdmin, Portainer, Caddy basicauth, Django superuser. Csere után a
      régi értékek érvénytelenek.
- [ ] **Kitett portok zárása:** `7000` (backup_server), `15432` (pgAdmin), `9000` (Portainer –
      docker.sock-ot mountol!), `8081` (cAdvisor). Csak VPN / SSH tunnel.
- [ ] `p.aitoknow.it` (Portainer) basicauth nélkül fut – azonnal mögé tenni vagy leállítani.
- [ ] `uvicorn --reload` kivétele az éles parancsokból.
- [ ] A 169 közös SHA-256 hash-ű fiók: jelszó-visszaállítás kényszerítése vagy zárolás (Q-07).

## 5. Külső regisztrációk (a testvérrendszerek felé)

- [ ] skillpass.id: Hydra kliens (`partner-ai2know`), redirect URI-k (local, test, prod), scope-ok
      `openid offline_access profile email shell:read`, `metadata.launcher`
      (`skillpass-app-launcher` skill), logó host allowlist. M2M kliens, ha entitlement push kell.
- [ ] skillpass.id: felhasználó-import képesség egyeztetése (04 / 3.1, Q-01).
- [ ] aibos.space: portál slug `ai2know-it` az aibos-public API-ban; admin integráció bejelentése
      (contract átadás F5-ben); pay/invoice API kulcs, ha a business csomag megmarad.
- [ ] DNS leltár (Cloudflare): minden `*.ai2know.it` és `*.aitoknow.it` rekord, TTL, proxy állapot.

## Tesztek / validáció

- `make local` tiszta gépen fut, `GET /healthz` 200 (backend), `GET /` 200 (web).
- CI zöld egy üres „hello" PR-on.
- `git ls-files` ellenőrzés: nincs backup, `.env`, dump.

## Kimenet

- Működő repo + CI + helyi stack, regisztrációs kérések elküldve, régi rendszer titkai cserélve
  (owner visszaigazolással az `implementation-notes.md`-ben).

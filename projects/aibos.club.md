---
name: aibos.club
path: /Users/everengine/Documents/dev/aibos.club
deployed_version: 7.7.0
type: new
status: bootstrapped
last_sync: 2026-10-15
github_remote: nincs
---

# AIBOS Club

## Cel
Partner-portal az aibootcamp.hu ökoszisztémához: skillpass.id (Ory Kratos/Hydra
OIDC) bejelentkezéssel a partnerek kezelhetik saját üzletüket, és cikkeket
írhatnak az aibootcamp.hu-ra.

## Tech stack
- Backend: Rust/Axum (`crates/aibos-club-api`) — auth, üzlet-kezelés, kliensek
- Felület: szerver-oldalon renderelt HTML (szándékosan minimális, lásd D-V0-05)
- DB: PostgreSQL, saját példány, `aibos_club_schema`
- Auth: skillpass.id OIDC (Authorization Code + PKCE), `partner-aibos-club` kliens
- Deploy: orbis, `/home/docker/apps/aibos-club/`, megosztott caddy-docker-proxy

## Status notes
- 2026-09-22: skeleton 7.7.0 bootstrap, eredetileg teljesen üres mappából
- Nincs github remote — push manuális
- **2026-09-27: ÉLESBEN FUT** a `https://aibos.club` — skillpass.id belépés,
  üzleti profil kezelés
- **2026-10-14: belépett felület** (Áttekintés / Üzletem / Cikkek / Fiókom),
  a `aibootcamp.hu/fiok` mintájára, SkillPass mélylinkekkel
- Éles használat: 2 valódi partner lépett be (2026-09-28, 2026-10-03)
- **2026-10-15: affiliate rendszer élesben** (plan-v2): `/affiliate` jelentkezés
  ÁSZF-elfogadással, egyenleg, kifizetés-kérelem, `/aszf` (tervezet, jogi
  felülvizsgálatra vár). Migráció 000004–000005 éles; előtte pg_dump az
  orbison (`backups/pre-affiliate-*.sql`). Admin-aktiválás nélkül nincs jutalék.
- **2026-10-15: aibootcamp partner-s2s integráció** (plan-v2 9–10.): bejövő
  affiliate-események az ő kontraktusuk szerint, kimenő partner/ajánlás
  szinkron, kuponfelület. Migráció 000006–000007 éles. Token/titok nélkül
  minden kikapcsolt; bekapcsolás: tulajdonos állítja be mindkét oldalon.
- **2026-10-17: SkillPass Workspace Shell felület** (plan-v3): a
  `@skillpass/workspace-shell` 0.1.12 vendorolva (statikus renderelés, React
  nélkül), aibootcamp.hu-mintájú belépőlap regisztrációval, név a
  `given_name`/`family_name` claimekből. Migráció 000008.

## Skeleton komponensek
- Teljes `.claude/` framework
- Az auth-integráció a `skillpass/.claude/skills/skillpass-integration/`
  skill mintájára készült, projekt-specifikusan (nincs közös skeleton skill rá)

## Kapcsolódó projektek
- **aibootcamp.hu** — kész `/admin/v1/articles` szerződés (service-token +
  `X-Operator-Id`/`X-Operator-Roles`), ezt érdemes újrahasznosítani a
  cikk-írás integrációhoz saját CMS építése helyett
- **skillpass** (`/Users/everengine/Documents/dev/skillpass`) — a valódi
  skillpass.id IdP (Ory Kratos+Hydra); már kiszolgálja aibootcamp.hu-t és
  aibos operátor-loginját; éles környezetben az orbis szerveren fut
- **aibos** (`/Users/everengine/Documents/dev/aibos`) — külön "Company OS"
  termék, saját munkamenetes `aibos-auth`-tal, TUDATOSAN nem SkillPass
  (D-V3-01) — NE keverjük össze aibos.club-bal
- **orbis** (209.182.239.131, `ssh orbis`) — a tervezett deploy-cél; itt fut
  már a skillpass.id megosztott caddy-docker-proxy-ja (`mnitr` hálózat)

## Next steps

**Blokkoló (nem nálunk):** a cikkírás az `aibootcamp.hu` admin API-jára épül,
de az `api.aibootcamp.hu` **mindenre 401-et ad** — még a hitelesítés nélküli
`/health/live`-ra is, és sima szöveggel, nem a szerződés JSON hibaformátumával.
Tehát proxy-szintű kapu zár ki, nem a szolgáltatás. Kell:
1. `AIBOOTCAMP_ADMIN_TOKEN` az aibootcamp.hu oldaláról
2. hálózati hozzáférés (a proxy-kapu megnyitása az orbis felé)

**Nyitott döntések** (`specification/plan-v0/00_terv.md`):
- **D-V0-05** — önálló oldal maradjon, vagy a SkillPass Workspace Shell alá
  kerüljön? (A jelenlegi felület szándékosan minimális, hogy ne döntse el.)
- **D-V0-06** — a belépést az itteni auto-provision döntse el (ez fut most),
  vagy M2M-lekérdezés az AIBOS People-moduljától?
- **Moderáció** — kell-e jóváhagyás a partner-cikkek publikálása előtt? Ez
  dönti el, hogy a „Publikálás" közvetlenül a `/publish`-t hívja-e.

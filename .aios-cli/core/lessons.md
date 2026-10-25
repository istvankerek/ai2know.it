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

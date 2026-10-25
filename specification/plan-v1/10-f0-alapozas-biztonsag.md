# F0 – Alapozás és a régi rendszer biztonsági javítása (I. felvonás)

> A teljes lépéslista: `../plan-v0/10-f0-alapozas.md` – változatlanul érvényes, az alábbi
> kiegészítésekkel. Routing: STANDARD (repo), CRITICAL (régi éles rendszer, owner „mehet").

## 1. Sorrend (az I. felvonás miatt módosul)

1. **Régi rendszer biztonsági javítása (P-V1-06)** – mert a hu.ai2know.it a II. felvonásig
   tovább fut: backup_server és pgAdmin/Portainer/cAdvisor portok zárása, titokcsere, a nyitott
   admin végpontok (`/business/import|export`, `/fetch-*`, `/orders-report`, `/newsletter_users`,
   `/files/`, `/api/posts|labels|favorites`) Caddy szintű tiltása (403), a `POST /profil`
   mass-assignment és az azonnali jelszó-felülírás letiltása Caddy szinten vagy minimális
   kódjavítással. Mindegyik éles művelet → owner „mehet".
2. Repo, CI, helyi stack (v0 F0 / 1–3).
3. Külső regisztrációk: skillpass.id kliens (csak belépés, import még nem), aibos portál
   `ai2know-it` + katalógus-bővítés egyeztetése (Q-V1-01), aiagentek redirect-terv bejelentése.

## 2. Kiegészítés a helyi stackhez

- aibos-public mock (contract alapú) a katalógus API-hoz, hogy a web az aibos bővítés előtt is
  fejleszthető legyen (L-05).
- Seed: a régi ai2know tartalom és az aiagentek könyvtár exportja **helyi** fixture-ként (nincs PII).

## Kimenet

- A régi rendszer kitettsége megszűnt (owner visszaigazolás az `implementation-notes.md`-ben),
  az új repo fut, a mock katalógus API elérhető.

# Ökoszisztéma szabály (always-on, v8.0)

Teljes kánon: `.aios-cli/core/ecosystem.md`.

- **skillpass.id az egyetlen IdP**: belépés, profil és ügyfélportál. Partner
  projekt OIDC kliens (Code + PKCE, BFF, httpOnly cookie), skill: `skillpass-auth`.
- **Ügyfélportál** = skillpass.id workspace shell és design (`skillpass-portal`).
- **Admin/management** = aibos.space konzol. A partner projekt contract-first admin
  API-t ad (`aibos-admin-contract`), és nem épít saját admint.
- **aibos.space** az egyetlen kivétel saját operátori auth-tal (aibos-auth, TOTP).
- Megszűnt identitás-szolgáltatót nem használunk. Ha régi hivatkozást látsz, jelezd.
- Ha egy feladat ezzel ütközik, **kérdezz rá**, mielőtt kódolsz.

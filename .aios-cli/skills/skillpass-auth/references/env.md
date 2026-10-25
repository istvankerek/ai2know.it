# Környezeti változók – skillpass-auth

> Minden változó a BFF szerver oldalon él. Kliens oldali bundlebe soha
> nem kerülhet `SKILLPASS_CLIENT_SECRET` vagy `SKILLPASS_M2M_CLIENT_SECRET`.

## RP (felhasználói bejelentkezési) kliens

| Változó | Kötelező | Alapértelmezés | Leírás |
|---------|----------|----------------|--------|
| `SKILLPASS_ISSUER` | nem | `https://skillpass.id` | Az OIDC issuer URL |
| `SKILLPASS_CLIENT_ID` | **igen** | — | Hydra kliens azonosító |
| `SKILLPASS_CLIENT_SECRET` | **igen** | — | `ek_live_` vagy `ek_test_` prefix |
| `SKILLPASS_REDIRECT_URI` | **igen** | — | Callback URL, pl. `https://portal.hu/auth/callback` |
| `SKILLPASS_COOKIE_SECRET` | **igen** | — | HMAC session-cookie aláíráshoz; min. 32 byte, hex |

## M2M kliens

| Változó | Kötelező | Leírás |
|---------|----------|--------|
| `SKILLPASS_M2M_CLIENT_ID` | nem* | M2M Hydra kliens azonosító |
| `SKILLPASS_M2M_CLIENT_SECRET` | nem* | `ek_live_` vagy `ek_test_` prefix |

\* Ha nincs beállítva, a push funkciók csendes no-op-ként viselkednek (a
  belépési flow nem fut le hibára).

## Shell context (opcionális)

| Változó | Alapértelmezés | Leírás |
|---------|----------------|--------|
| `SKILLPASS_SHELL_CONTEXT_URL` | `https://skillpass.id/api/v1/partner/shell-context` | Shell context BFF végpont URL |

## .env.example sablon

```dotenv
# SkillPass.ID OAuth2/OIDC
SKILLPASS_ISSUER=https://skillpass.id
SKILLPASS_CLIENT_ID=partner-PROJEKTNEVED
SKILLPASS_CLIENT_SECRET=ek_test_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
SKILLPASS_REDIRECT_URI=http://localhost:3000/auth/callback
SKILLPASS_COOKIE_SECRET=change_me_32_byte_minimum_hex_secret_value_here

# SkillPass.ID M2M (opcionális — képzés/entitlement push)
SKILLPASS_M2M_CLIENT_ID=partner-PROJEKTNEVED-m2m
SKILLPASS_M2M_CLIENT_SECRET=ek_test_M2MXXXXXXXXXXXXXXXXXXXXXXX
```

## Biztonsági követelmények

- A `SKILLPASS_COOKIE_SECRET` legalább 32 bájt (256 bit) entrópiájú véletlen
  szöveg. Generálás: `openssl rand -hex 32`.
- Soha nem commitálható `.env` fájl. Az `.env.example` nyilvános (dummy értékek).
- Production-ban titkosított secret store-ból jön (pl. Vault, Doppler).

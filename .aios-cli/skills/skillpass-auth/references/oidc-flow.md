# OIDC Flow – részletes referencia

> Forrás: `skillpass` repo @ `24048cd` (2026-10-06)
> Autoritatív: `/Users/everengine/Documents/dev/skillpass/docs/PARTNER-SSO.md`
> és `docs/partner-integracio.md`

## Végpontok

| Végpont | URL |
|---------|-----|
| Discovery | `https://skillpass.id/.well-known/openid-configuration` |
| Authorize | `https://skillpass.id/oauth2/auth` |
| Token | `https://skillpass.id/oauth2/token` |
| Userinfo | `https://skillpass.id/userinfo` |
| JWKS | `https://skillpass.id/.well-known/jwks.json` |
| Revoke | `https://skillpass.id/oauth2/revoke` |
| End session | `https://skillpass.id/oauth2/sessions/logout` |

## Algoritmus

Az access_token és az id_token is **RS256** JWT. A JWKS végpontot használd a
validáláshoz — ne hardkódold a kulcsot. A JWKS kulcsokat gyorsítótárazd (TTL:
1 óra), mert a skillpass.id nem garantál milyen gyorsan rotálja.

Forrás-ellentmondás: a partner-integracio.md azt írja „RS256 JWT — JWKS
végponttal validálható"; a PARTNER-SSO.md ugyanezt erősíti. Nincs ellentmondás
az algoritmusban — mindkét forrás RS256-ot ír. **Autoritatív: skillpass repo.**

## Scope-ok

| Scope | Tartalom |
|-------|----------|
| `openid` | OIDC id_token |
| `profile` | name, given_name, family_name |
| `email` | email, email_verified |
| `offline_access` | refresh token (Hydra rotálja) |
| `shell:read` | munkaterének shell-kontextus lekérése |

## ID token claims

| Claim | Típus | Leírás |
|-------|-------|--------|
| `sub` | string | Stabil SkillPass UUID (felhasználó azonosítója) |
| `iss` | string | `"https://skillpass.id"` |
| `aud` | string | Partner `client_id` |
| `exp` | number | Lejárati időbélyeg |
| `iat` | number | Kibocsátási időbélyeg |
| `nonce` | string | Az authorize kérésben küldött nonce — ellenőrzendő! |
| `email` | string | Felhasználó e-mail-je |
| `name` | string | Megjelenített teljes név |

## Cookie névkonvenció

Az SKILL.md-ben leírt cookie neveket a partnerek a saját namespace-ükkel
prefixálhatják, de a kötelező attribútumok nem változnak:

```
sp_session   – httpOnly, Secure, SameSite=Lax, Path=/
sp_csrf      – Secure, SameSite=Strict, Path=/ (NEM httpOnly, JS olvassa)
```

## Csendes SSO (prompt=none)

Ha az authorize redirect `prompt=none` paramétert kap és van élő Hydra-session,
a Hydra belépési képernyő nélkül adja vissza a code-ot. Ha nincs session, a
Hydra `login_required` hibával tér vissza. Ezt a partnernél a belépési állapot
gyors ellenőrzésére lehet használni (pl. oldalbetöltéskor).

## Discovery caching

A partner-integracio.md azt tanácsolja, hogy a végpontokat a discovery
dokumentumból olvasd, ne fűzd össze az issuer URL-ből. A Hydra a
`/oauth2/auth` és `/oauth2/token` útvonalakat használja, de jövőbeni változás
esetén a discovery a helyes forrás. Gyorsítótárazd 5 percig.

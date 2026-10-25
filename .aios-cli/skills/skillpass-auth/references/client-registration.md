# Hydra kliens regisztrációs referencia

> Forrás: `skillpass` repo @ `24048cd` (2026-10-06)
> Script: `scripts/seed-ory-clients.sh`
> Autoritatív: `docs/PARTNER-SSO.md`

## Regisztrálás

A SkillPass team regisztrálja a klienst a Hydra admin API-n:
`POST http://hydra:4445/admin/clients`

Saját generálás/módosítás **TILOS** — a secret-et (`ek_live_` vagy `ek_test_`
prefix) a SkillPass team adja.

## Kötelező RP (felhasználói belépési) kliens mező

```json
{
  "client_id": "partner-aibootcamp",
  "client_name": "AIBootcamp Portal",
  "client_secret": "ek_live_XXXXXXXXXXXX",
  "redirect_uris": [
    "https://aibootcamp.hu/auth/callback",
    "https://aibootcamp.hu/auth/callback-dev"
  ],
  "grant_types": ["authorization_code", "refresh_token"],
  "response_types": ["code"],
  "scope": "openid offline_access profile email",
  "token_endpoint_auth_method": "client_secret_post",
  "subject_type": "public",
  "skip_consent": false
}
```

Ha shell integráció is kell: `"scope": "openid offline_access profile email shell:read"`.

## Launcher metadata (metadata.launcher)

A 9-pontos launcher csempéje és a workspace shell app-listája ebből épül.

| Mező | Kötelező | Validálási szabály |
|------|----------|--------------------|
| `name` | igen | max 200 kar., `<` / `>` tilos; hibánál az app kiesik |
| `launch_url` | igen | csak `https://`, userinfo tilos; hibánál az app kiesik |
| `app_id` | nem | stabil azonosító; hiányában `client_id`. Többnyelvi klienspárnál UGYANAZ az érték |
| `locale` | nem | `"hu"` vagy `"en"` — többnyelvi kliensnél; hiánya = bármely nyelvnél érvényes |
| `short_name` | nem | max 200 kar., `<` / `>` tilos; hibánál mező kimarad |
| `icon` | nem | `{svg: …}` vagy `{url: …}`; SVG max 8 KiB, script/on…= tilos; hibánál mező kimarad |
| `accent` | nem | `#rgb`/`#rrggbb`/`#rrggbbaa`; hibánál `#1D6FE0` |
| `nav` | nem | sidebar szekciók; hibás menüpont kimarad |
| `required_entitlements` | nem | entitlement-kulcsok az app eléréséhez |
| `data_scope_note` | nem | `{hu: …, en: …}`; max 400 kar.; hibánál mező kimarad |

Validálás **default-deny**: minden eldobott mező `tracing::warn!` sort kap.

## Launcher metadata példa

```json
"metadata": {
  "launcher": {
    "app_id": "aibootcamp",
    "name": "AI Bootcamp",
    "tagline": "Mesterséges intelligencia képzések",
    "launch_url": "https://aibootcamp.hu",
    "category": "oktatás",
    "accent": "#F0731D",
    "icon": { "url": "https://aibootcamp.hu/icon.svg" },
    "nav": [
      {
        "label": { "hu": "Főmenü", "en": "Main" },
        "items": [
          { "id": "home", "label": { "hu": "Kezdőlap", "en": "Home" },
            "href": "/", "icon": "Home" }
        ]
      }
    ],
    "data_scope_note": {
      "hu": "Képzési adataid az AI Bootcamp rendszeréből érkeznek.",
      "en": "Training data comes from AI Bootcamp."
    }
  }
}
```

## M2M kliens (külön regisztrálás)

Az M2M push kliens nem `authorization_code`, hanem `client_credentials` grant:

```json
{
  "client_id": "partner-aibootcamp-m2m",
  "client_name": "AIBootcamp M2M",
  "client_secret": "ek_live_M2MXXXXXXXXX",
  "grant_types": ["client_credentials"],
  "scope": "trainings:write",
  "token_endpoint_auth_method": "client_secret_post"
}
```

Nincs `redirect_uris` — gépi kliens.

## Secret konvenció

- Production: `ek_live_` prefix
- Dev/staging: `ek_test_` prefix
- A partnernél tilos generálni — a SkillPass team adja ki.

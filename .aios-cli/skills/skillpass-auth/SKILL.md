---
name: skillpass-auth
description: >
  SkillPass.ID OIDC Authorization Code + PKCE integracio partner portalokon.
  Confidential BFF kliens, HMAC-alairt httpOnly cookie, token sosem ker a
  bongeszohoz, /auth/refresh rotacio, CSRF double-submit, CSP nonce, logout
  (Hydra + Kratos session zaras), M2M client_credentials scope-okkal
  (trainings:write, entitlements:write stb.), Hydra kliens regisztracio
  (seed-ory-clients minta), Rust/Axum JWT validacio (JWKS RS256).
  Triggerek: "auth", "belepes", "login", "oauth", "oidc", "skillpass auth",
  "jwt validacio", "m2m token", "client credentials", "session", "cookie",
  "belepteto", "kijelentkezes", "logout", "token".
  NE hasznald: sajat auth implementacio (TILOS!), megszunt IdP, jelszo hash,
  localStorage token, profil oldal epites partnernel.
priority: P0
model: claude-sonnet-5-5
related_skills:
  - skillpass-portal
  - skillpass-app-launcher
---

# SkillPass.ID – Partner Auth integrációs útmutató

**Egyetlen identitásszolgáltató:** a `skillpass.id` (Ory Kratos + Hydra,
`auth.skillpass.id`) az egyetlen engedélyezett IdP minden partner portálhoz.
Saját auth, jelszóhash, localStorage token, megszűnt IdP hivatkozás — mind
**TILOS**.

> Részletek: `references/oidc-flow.md`, `references/m2m.md`,
> `references/client-registration.md`, `references/env.md`.

---

## 1. Architektúra: BFF minta

```
Böngésző  ←→  Partner BFF (Next.js App Router / Axum)  ←→  SkillPass.ID
                   │
                   ├─ httpOnly Secure SameSite=Lax cookie (HMAC-aláírt)
                   ├─ /auth/login     – redirect a Hydra authorize URL-jére
                   ├─ /auth/callback  – code csere, cookie beállítás
                   ├─ /auth/refresh   – refresh token rotáció
                   └─ /auth/logout    – RP-initiated + Kratos session zárás
```

A token **soha nem kerül a böngészőbe** (nem localStorage, nem `Set-Cookie`
`Max-Age=0` trükk). A BFF aláírja a session-sütit HMAC-SHA256-tal.

---

## 2. OIDC Authorization Code + PKCE folyamat

### 2.1 Előkészítés (szerver oldal, BFF)

```typescript
// Generálj minden belépési kéréshez
const codeVerifier  = generateCodeVerifier();        // 32-byte random, base64url
const codeChallenge = await sha256Base64url(codeVerifier);
const state         = generateState();               // 32-byte random, base64url
const nonce         = generateState();               // külön érték

// Mentsd el a szerveroldalon (session store / rövid életű Redis kulcs),
// SOSEM a böngészőben
await sessionStore.set(state, { codeVerifier, nonce }, { ttl: 600 });
```

### 2.2 Authorize redirect

```
GET https://skillpass.id/oauth2/auth
  ?response_type=code
  &client_id=SKILLPASS_CLIENT_ID
  &redirect_uri=SKILLPASS_REDIRECT_URI
  &scope=openid%20profile%20email%20offline_access
  &code_challenge=CODE_CHALLENGE
  &code_challenge_method=S256
  &state=STATE
  &nonce=NONCE
```

A `shell:read` scope-ot add hozzá, ha a workspace shell-t is integrálod:
`scope=openid%20profile%20email%20offline_access%20shell:read`

### 2.3 Callback (BFF route handler)

```typescript
// POST /oauth2/token — kizárólag a BFF-ből, soha a böngészőből!
const body = new URLSearchParams({
  grant_type:    "authorization_code",
  code:          callbackCode,
  client_id:     process.env.SKILLPASS_CLIENT_ID!,
  client_secret: process.env.SKILLPASS_CLIENT_SECRET!,
  code_verifier: stored.codeVerifier,
  redirect_uri:  process.env.SKILLPASS_REDIRECT_URI!,
});
const resp = await fetch("https://skillpass.id/oauth2/token", {
  method: "POST",
  headers: { "Content-Type": "application/x-www-form-urlencoded" },
  body,
});
const { access_token, refresh_token, id_token, expires_in } = await resp.json();

// Nonce ellenőrzés az ID tokenből (RS256 dekódolás vagy JWKS-sel validálás)
const claims = decodeJwt(id_token);
if (claims.nonce !== stored.nonce) throw new Error("nonce mismatch");
```

### 2.4 HMAC-aláírt session cookie beállítása

```typescript
// Aláírd az access + refresh tokent tartalmazó payload-ot
const cookieValue = await signCookie(
  { sub: claims.sub, accessToken, refreshToken, expiresAt },
  process.env.SKILLPASS_COOKIE_SECRET!
);

response.headers.set("Set-Cookie", buildCookieHeader({
  name:     "sp_session",
  value:    cookieValue,
  httpOnly: true,
  secure:   true,
  sameSite: "Lax",
  path:     "/",
  maxAge:   7 * 24 * 3600,  // 7 nap (refresh rotációval)
}));
```

---

## 3. CSRF double-submit védelemmel

Minden state-módosító API-kérésnél (POST/PUT/DELETE) a BFF ellenőrzi a
`X-CSRF-Token` headert a `sp_csrf` cookie értékével szemben.

```typescript
// Cookie (SameSite=Strict, nem httpOnly, olvasható JS-ből)
Set-Cookie: sp_csrf=<random>; SameSite=Strict; Secure; Path=/

// Kliens minden mutációs kérésnél:
headers["X-CSRF-Token"] = document.cookie.match(/sp_csrf=([^;]+)/)?.[1];

// BFF ellenőrzés:
if (req.headers["x-csrf-token"] !== cookieStore.get("sp_csrf")?.value) {
  return Response.json({ error: "csrf" }, { status: 403 });
}
```

---

## 4. CSP nonce

```typescript
// BFF minden page renderingnél
const cspNonce = randomBytes(16).toString("base64");
response.headers.set("Content-Security-Policy",
  `default-src 'self'; script-src 'nonce-${cspNonce}' 'strict-dynamic'; ` +
  `style-src 'self' 'nonce-${cspNonce}'; img-src 'self' data: https://skillpass.id;`
);
// Átadd a React tree-be (pl. Next.js headers() API)
```

---

## 5. Token refresh rotáció (/auth/refresh)

```typescript
// BFF POST /auth/refresh
// A Hydra ROTÁLJA a refresh tokent — egyszer használatos!
const resp = await fetch("https://skillpass.id/oauth2/token", {
  method: "POST",
  body: new URLSearchParams({
    grant_type:    "refresh_token",
    refresh_token: currentRefreshToken,
    client_id:     process.env.SKILLPASS_CLIENT_ID!,
    client_secret: process.env.SKILLPASS_CLIENT_SECRET!,
  }),
});
// Ha a Hydra 401/400 → logout (a refresh token érvénytelen/lejárt)
// Az új refresh tokent azonnal írd vissza a session cookie-ba
```

---

## 6. Logout: Hydra + Kratos (kötelező!)

**Tanulság (skillpass-logout-fix, c983c3f):** csak a Hydra logout elfogadása
nem zárja le a Kratos session-t. Így az RP-initiated logout után a csendes SSO
(`prompt=none`) azonnal visszalépteti a felhasználót. A Kratos session lezárása
a böngésző `Cookie` headerét is igényli a token-beváltáshoz.

```typescript
// BFF GET /auth/logout?logout_challenge=CHALLENGE
export async function GET(req: Request) {
  const challenge = new URL(req.url).searchParams.get("logout_challenge")!;

  // 1. Hydra logout elfogadása
  const redirectTo = await acceptHydraLogoutRequest(challenge);

  // 2. Kratos session lezárása — a böngésző Cookie headere KÖTELEZŐ!
  const cookie = req.headers.get("cookie") ?? "";
  try {
    const { data } = await kratosServer.createBrowserLogoutFlow({ cookie });
    await kratosServer.updateLogoutFlow({
      token: data.logout_token,
      cookie,         // ← ez hiányzott a hibás verzióból
    });
  } catch (err) {
    // Ha a Kratos flow nem ment (nincs session), a bongeszot a Kratos
    // logout_url-jere kuldjuk fallbackkent, return_to=redirectTo-val
    if (isFlowCreated(err)) {
      return Response.redirect(browserLogoutUrl(err, redirectTo));
    }
    // Nincs elo session — folytatjuk a Hydra redirecttel
  }

  // 3. Torojld a session cookie-t
  const resp = Response.redirect(redirectTo);
  resp.headers.set("Set-Cookie",
    "sp_session=; Max-Age=0; Path=/; HttpOnly; Secure; SameSite=Lax"
  );
  return resp;
}
```

---

## 7. M2M client_credentials (→ `references/m2m.md`)

Képzések, entitlement-ek, eseményjegyek és kredit-egyenlegek feltolásához
külön M2M kliens szükséges (`client_credentials` grant, scope-olt).

```typescript
const token = await m2mToken({
  clientId:     process.env.SKILLPASS_M2M_CLIENT_ID!,
  clientSecret: process.env.SKILLPASS_M2M_CLIENT_SECRET!,
  scope:        "trainings:write",
  issuer:       process.env.SKILLPASS_ISSUER ?? "https://skillpass.id",
});
// Token gyorsítótárazása, lejárat – 60s ráhagyással, folyamat szintjén
```

---

## 8. JWT validáció Rust/Axum backendben

A `skillpass.id` Hydra **RS256** JWT-ket bocsát ki (lásd: `references/oidc-flow.md`).
A JWKS-t a discovery végpontból olvasd, ne hardkódold.

```rust
use jsonwebtoken::{decode, decode_header, DecodingKey, Validation, Algorithm};

/// A JWKS végpontról lekért kulcsok gyorsítótárazva (TTL: 1 óra).
async fn validate_jwt(token: &str, jwks: &JwksCache) -> Result<Claims> {
    let header = decode_header(token)?;
    let kid = header.kid.ok_or(AuthError::MissingKid)?;
    let key = jwks.get_key(&kid).await?;

    let mut validation = Validation::new(Algorithm::RS256);
    validation.set_issuer(&["https://skillpass.id"]);
    validation.set_audience(&[std::env::var("SKILLPASS_CLIENT_ID")?]);

    let data = decode::<Claims>(token, &DecodingKey::from_rsa_components(&key.n, &key.e)?, &validation)?;
    Ok(data.claims)
}
```

**Kulcsmező:** `iss` = `"https://skillpass.id"`, `aud` = a partner `client_id`,
algoritmus: RS256 (az access_token-hez; az id_token is RS256).

---

## 9. TILOS lista (minden partnerprojektben)

| Tilos | Miért |
|-------|-------|
| `localStorage.setItem("token", ...)` | XSS-el lopható; cookie-t használj |
| saját jelszóhash, regisztrációs oldal | a skillpass.id Kratos kezeli |
| Megszűnt IdP hivatkozás | elavult, eltávolított rendszer |
| profil oldal építés a partnernél | deep link az Account Centerbe |
| bejelentkezési oldal a partnernél | Hydra consent/login képernyő |
| `client_secret` a frontend bundle-ben | csak a BFF-ben |
| `*` CORS origin | explicit whitelist |
| `prompt=none` nonce ellenőrzés kihagyása | replay támadás lehetséges |
| Kratos session kihagyása logoutnál | SSO-session túlél (igazolt hiba) |

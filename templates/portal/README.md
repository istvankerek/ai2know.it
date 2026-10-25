# Portal sablon – SkillPass.ID integráció

Ez a sablon egy partner portál alapkonfigurációját tartalmazza a SkillPass.ID
workspace shell-lel és auth BFF route-okkal. A `bootstrap-project` command
a válaszok alapján másolja be ezt a sablont.

## Tartalom

```
templates/portal/
  lib/
    auth/
      oidc-session.ts        ← PKCE, state/nonce, HMAC cookie (node:crypto)
      oidc-session.test.ts   ← Unit tesztek (node:test, Node 22.14+)
    shell/
      portal-manifest.ts     ← AppManifest példa és típusok
  messages/
    hu.json                  ← Magyar fordítási kulcsok
    en.json                  ← Angol fordítási kulcsok (azonos kulcskészlet)
  README.md
```

## Hogyan használd

### 1. Másolás az új projektbe

```bash
cp -r templates/portal/ apps/MY_PORTAL/lib/auth/
cp templates/portal/messages/ apps/MY_PORTAL/messages/
```

### 2. Függőségek telepítése

```bash
pnpm add @skillpass/workspace-shell
pnpm add @skillpass/workspace-shell/shell.css  # CSS import a layoutban
```

### 3. Env változók beállítása (→ skillpass-auth skill `references/env.md`)

```dotenv
SKILLPASS_ISSUER=https://skillpass.id
SKILLPASS_CLIENT_ID=partner-PROJEKTNEVED
SKILLPASS_CLIENT_SECRET=ek_test_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
SKILLPASS_REDIRECT_URI=http://localhost:3000/auth/callback
SKILLPASS_COOKIE_SECRET=change_me_32_byte_minimum_hex_secret_value_here
```

### 4. Hydra kliens regisztráltatása

Kérd meg a SkillPass teamet a kliens regisztrálásához (→ skillpass-auth skill
`references/client-registration.md`). Add meg:
- `redirect_uri`(k)
- kért scope-ok (`openid offline_access profile email shell:read`)
- `metadata.launcher` mezőket (name, launch_url, accent, icon, nav)

### 5. Auth BFF route-ok bekötése

A `lib/auth/oidc-session.ts` modulban lévő segédfüggvényeket a Next.js App
Router route handler-jeiben (vagy Axum handler-ekben) használd. Részletes
minta: `skillpass-auth` skill SKILL.md 2–6. fejezetek.

### 6. WorkspaceShell beágyazás

```tsx
import { WorkspaceShell, ShellProvider } from "@skillpass/workspace-shell";
import "@skillpass/workspace-shell/shell.css";
import { EXAMPLE_PORTAL_MANIFEST } from "./lib/shell/portal-manifest";

// Részletes példa: skillpass-portal skill references/route-skeleton.md
```

## Tesztek futtatása

```bash
node --experimental-strip-types --test templates/portal/lib/auth/oidc-session.test.ts
```

18 teszt, Node 22.14+, külső függőség nélkül.

## Kapcsolódó skillek

- `skillpass-auth` — OIDC flow, BFF minta, logout, M2M
- `skillpass-portal` — WorkspaceShell beágyazás, design tokenek, route-ok
- `skillpass-app-launcher` — Hydra kliens metadata.launcher regisztráció

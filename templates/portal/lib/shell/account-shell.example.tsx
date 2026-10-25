/**
 * Bejelentkezett felület váza: a SkillPass.ID workspace shell beágyazása.
 * Szabvány: partner-account-shell.md (D-V16-08). A sidebar tetején a SkillPass.ID logó,
 * a topbar, a drawer és az Account Center linkek a csomagból jönnek; a partner csak a
 * kontextust, a manifestet és a callbackeket adja.
 *
 * Függőség a projektben: `@skillpass/workspace-shell` (vendor tgz, rögzített verzió) és
 * `@skillpass/workspace-shell/shell.css`. Ez a fájl sablon: a projektben nevezd át
 * `account-shell.tsx`-re, és a BFF végpontjaidhoz igazítsd.
 */
"use client";

import { usePathname, useRouter } from "next/navigation";
import { WorkspaceShell } from "@skillpass/workspace-shell";
import { NextShellLink } from "@skillpass/workspace-shell/next";
import type { ShellContext } from "@skillpass/workspace-shell";

import { shellManifest } from "./shell-manifest";

interface AccountShellProps {
  /** A BFF `GET /api/v1/shell-context` válasza (szerveroldalon lekérve és cache-elve). */
  context: ShellContext;
  /** CSRF token a logout POST-hoz (httpOnly session mellett double-submit). */
  csrfToken: string;
  /** A bejelentkezett felhasználó e-mailje a fiókváltás `login_hint`-jéhez. */
  loginHint: string;
  children: React.ReactNode;
}

const RETURN_TO_ACCOUNT = encodeURIComponent("/fiok/");

/**
 * A /fiok alatti oldalak közös kerete.
 * @param props - shell-kontextus, CSRF token, login hint, tartalom
 */
export function AccountShell({ context, csrfToken, loginHint, children }: AccountShellProps) {
  const pathname = usePathname();
  const router = useRouter();
  const origin = typeof window === "undefined" ? "" : window.location.origin;

  async function logout(): Promise<void> {
    await fetch("/auth/logout", { method: "POST", headers: { "X-CSRF-Token": csrfToken } });
    window.location.assign("/");
  }

  function switchAccount(): void {
    const hint = encodeURIComponent(loginHint);
    window.location.assign(`/auth/login?returnTo=${RETURN_TO_ACCOUNT}&prompt=login&login_hint=${hint}`);
  }

  return (
    <WorkspaceShell
      context={{ ...context, active_app: shellManifest(origin) }}
      beta
      linkComponent={NextShellLink}
      activeHref={pathname.endsWith("/") ? pathname : `${pathname}/`}
      helpHref="/kapcsolat/"
      onSearch={(q) => router.push(`/kereses/?q=${encodeURIComponent(q)}`)}
      onLogout={logout}
      onSwitchAccount={switchAccount}
    >
      <div className="workspace-content">{children}</div>
    </WorkspaceShell>
  );
}

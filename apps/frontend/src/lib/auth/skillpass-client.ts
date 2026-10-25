/**
 * SkillPass.ID bejelentkezés – BFF minta.
 * A skillpass.id az ökoszisztéma egyetlen IdP-je. A böngésző soha nem kap tokent
 * és client ID-t: a PKCE, a state és a token csere a backend `/auth/*` route-jain
 * történik, a session httpOnly, aláírt cookie-ban él (lásd `skillpass-auth` skill).
 */

const API_BASE = import.meta.env.VITE_API_URL.replace(/\/api\/v1\/?$/, "");

/**
 * Elindítja a SkillPass.ID belépést a backend BFF-en keresztül.
 * @param returnTo - Relatív útvonal, ahová belépés után visszatérünk
 */
export function login(returnTo: string = window.location.pathname): void {
  const safeReturnTo =
    returnTo.startsWith("/") && !returnTo.startsWith("//") ? returnTo : "/";
  const params = new URLSearchParams({ return_to: safeReturnTo });
  window.location.assign(`${API_BASE}/auth/login?${params.toString()}`);
}

/**
 * Kijelentkezés: a backend zárja a lokális sessiont, majd RP-initiated logouttal
 * a SkillPass.ID (Hydra + Kratos) sessiont is.
 */
export function logout(): void {
  window.location.assign(`${API_BASE}/auth/logout`);
}

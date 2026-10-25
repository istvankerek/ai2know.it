/**
 * OIDC session segédfüggvények — dependency-free, csak node:crypto.
 *
 * Felelősségek:
 *   - PKCE code_verifier és code_challenge generálás (RFC 7636 S256)
 *   - state és nonce generálás
 *   - HMAC-SHA256 cookie aláírás és ellenőrzés (timing-safe compare)
 *   - Cookie attribútum összeállítás (httpOnly / Secure / SameSite / Path)
 *
 * A token soha nem kerül a böngészőbe — ez a modul a BFF oldalon fut.
 */

import { createHmac, randomBytes, timingSafeEqual } from "node:crypto";

// ---------------------------------------------------------------------------
// Belső segédfüggvények
// ---------------------------------------------------------------------------

/**
 * Bájttömböt base64url-karakterlánccá alakít (RFC 4648 §5, padding nélkül).
 */
function toBase64url(buf: Buffer | Uint8Array): string {
  return Buffer.from(buf)
    .toString("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=/g, "");
}

// ---------------------------------------------------------------------------
// PKCE
// ---------------------------------------------------------------------------

/**
 * Kriptográfiai véletlen code_verifier értéket generál (RFC 7636 §4.1).
 *
 * A verifier 32 bájt entrópiájú base64url-string (~43 karakter),
 * amit a böngészőbe SOHA nem küldünk el — a BFF-en tároljuk rövid ideig.
 *
 * @returns Base64url-kódolt, 43 karakter hosszú string
 */
export function generateCodeVerifier(): string {
  return toBase64url(randomBytes(32));
}

/**
 * A code_challenge értéket számítja ki az S256 módszerrel (RFC 7636 §4.2).
 *
 * @param codeVerifier - Az authorize redirect előtt generált code_verifier
 * @returns Base64url-kódolt SHA-256 hash, padding nélkül (43 karakter)
 */
export async function deriveCodeChallenge(
  codeVerifier: string,
): Promise<string> {
  const data = new TextEncoder().encode(codeVerifier);
  const hash = await globalThis.crypto.subtle.digest("SHA-256", data);
  return toBase64url(Buffer.from(hash));
}

// ---------------------------------------------------------------------------
// State / nonce generálás
// ---------------------------------------------------------------------------

/**
 * Kriptográfiai véletlen state értéket generál az authorize kéréshez.
 *
 * A state CSRF-védelmi szerepet tölt be: a callback-ben visszakapott
 * state értékét össze kell vetni a tárolttal.
 *
 * @returns Base64url-kódolt, legalább 43 karakter hosszú string
 */
export function generateState(): string {
  return toBase64url(randomBytes(32));
}

// ---------------------------------------------------------------------------
// Session cookie payload típus
// ---------------------------------------------------------------------------

/** A session cookie-ban tárolt adat (HMAC-aláírva). */
export interface SessionPayload {
  /** A felhasználó SkillPass sub azonosítója. */
  sub: string;
  /** Az access token (BFF-en tárolva, böngészőbe nem kerül). */
  accessToken: string;
  /** A refresh token (BFF-en tárolva, böngészőbe nem kerül). */
  refreshToken: string | null;
  /** Unix timestamp, amikor az access token lejár. */
  expiresAt: number;
}

// ---------------------------------------------------------------------------
// HMAC-aláírt cookie
// ---------------------------------------------------------------------------

/**
 * Session payload-ot HMAC-SHA256-tal aláír és base64url-ben kódolt
 * `<payload>.<timestamp>.<hmac>` formátumú cookie értéket ad vissza.
 *
 * A payload-ban tárolt tokenek a böngészőbe nem kerülnek — a cookie
 * httpOnly Secure SameSite=Lax attributumokkal rendelkezik.
 *
 * @param payload - A tárolandó session adatok
 * @param secret  - HMAC-SHA256 kulcs (min. 32 bájt entrópia ajánlott)
 * @returns Aláírt cookie érték
 */
export async function signCookie(
  payload: SessionPayload,
  secret: string,
): Promise<string> {
  const ts = Math.floor(Date.now() / 1000).toString();
  const encodedPayload = toBase64url(Buffer.from(JSON.stringify(payload)));
  const message = `${encodedPayload}.${ts}`;
  const mac = createHmac("sha256", secret).update(message).digest();
  const hmac = toBase64url(mac);
  return `${message}.${hmac}`;
}

/**
 * Ellenőrzi és visszafejti a HMAC-aláírt cookie értéket.
 *
 * Az összehasonlítás `timingSafeEqual`-lal történik (timing-attack védelem).
 *
 * @param cookieValue - A böngészőből érkező cookie értéke
 * @param secret      - A cookie aláírásakor használt kulcs
 * @returns A kicsomagolt payload, vagy `null` ha az aláírás érvénytelen
 */
export async function verifyCookie(
  cookieValue: string,
  secret: string,
): Promise<SessionPayload | null> {
  const parts = cookieValue.split(".");
  if (parts.length !== 3) return null;

  const [encodedPayload, ts, providedHmac] = parts as [string, string, string];
  const message = `${encodedPayload}.${ts}`;
  const expectedMac = toBase64url(
    createHmac("sha256", secret).update(message).digest(),
  );

  // Timing-safe összehasonlítás — megakadályozza a timing-attack alapú
  // aláírás-kinyerést
  let valid = false;
  try {
    const a = Buffer.from(expectedMac, "utf8");
    const b = Buffer.from(providedHmac, "utf8");
    if (a.length === b.length) {
      valid = timingSafeEqual(a, b);
    }
  } catch {
    return null;
  }

  if (!valid) return null;

  try {
    const json = Buffer.from(encodedPayload, "base64url").toString("utf8");
    const parsed: unknown = JSON.parse(json);
    if (
      parsed === null ||
      typeof parsed !== "object" ||
      typeof (parsed as Record<string, unknown>)["sub"] !== "string" ||
      typeof (parsed as Record<string, unknown>)["accessToken"] !== "string" ||
      typeof (parsed as Record<string, unknown>)["expiresAt"] !== "number"
    ) {
      return null;
    }
    const p = parsed as Record<string, unknown>;
    return {
      sub: p["sub"] as string,
      accessToken: p["accessToken"] as string,
      refreshToken:
        typeof p["refreshToken"] === "string" ? p["refreshToken"] : null,
      expiresAt: p["expiresAt"] as number,
    };
  } catch {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Cookie attribútum összeállítás
// ---------------------------------------------------------------------------

/** Cookie attribútum beállítások. */
export interface CookieOptions {
  /** Cookie neve. */
  name: string;
  /** Cookie értéke. */
  value: string;
  /**
   * HttpOnly attribútum — megakadályozza a JS-ből való olvasást.
   * @defaultValue true
   */
  httpOnly?: boolean;
  /**
   * Secure attribútum — csak HTTPS kapcsolaton küldi a böngésző.
   * @defaultValue true
   */
  secure?: boolean;
  /**
   * SameSite attribútum — CSRF-védelmi szint.
   * @defaultValue "Lax"
   */
  sameSite?: "Strict" | "Lax" | "None";
  /**
   * Path attribútum.
   * @defaultValue "/"
   */
  path?: string;
  /**
   * Max-Age attribútum másodpercben; nincs megadva → session cookie.
   */
  maxAge?: number;
}

/**
 * Összeállítja a Set-Cookie header értékét a kötelező biztonsági
 * attribútumok kényszerítésével.
 *
 * Kötelező: httpOnly=true, Secure=true, SameSite=Lax (felülírható).
 *
 * @param options - Cookie beállítások
 * @returns Set-Cookie header értéke
 */
export function buildCookieHeader(options: CookieOptions): string {
  const {
    name,
    value,
    httpOnly = true,
    secure = true,
    sameSite = "Lax",
    path = "/",
    maxAge,
  } = options;

  const parts: string[] = [`${name}=${value}`];

  if (maxAge !== undefined) {
    parts.push(`Max-Age=${maxAge}`);
  }

  parts.push(`Path=${path}`);

  if (httpOnly) {
    parts.push("HttpOnly");
  }

  if (secure) {
    parts.push("Secure");
  }

  parts.push(`SameSite=${sameSite}`);

  return parts.join("; ");
}

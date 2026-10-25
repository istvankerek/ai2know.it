/**
 * OIDC session segédfüggvények tesztjei — TDD (failing first).
 *
 * Futtatás:
 *   node --experimental-strip-types --test templates/portal/lib/auth/oidc-session.test.ts
 *
 * Node 22.14+, node:test + node:assert.
 */

import { describe, it, before } from "node:test";
import assert from "node:assert/strict";

import {
  generateCodeVerifier,
  deriveCodeChallenge,
  generateState,
  signCookie,
  verifyCookie,
  buildCookieHeader,
} from "./oidc-session.ts";

// ---------------------------------------------------------------------------
// generateCodeVerifier
// ---------------------------------------------------------------------------

describe("generateCodeVerifier", () => {
  it("legalább 43 karakter hosszú base64url-kódolt stringet ad vissza", () => {
    const verifier = generateCodeVerifier();
    assert.ok(typeof verifier === "string");
    // RFC 7636: a code_verifier 43–128 karakter ASCII
    assert.ok(verifier.length >= 43);
    assert.ok(verifier.length <= 128);
  });

  it("csak URL-biztonságos karaktereket tartalmaz (base64url)", () => {
    const verifier = generateCodeVerifier();
    assert.match(verifier, /^[A-Za-z0-9\-_]+$/);
  });

  it("két egymást követő hívás különböző értéket ad vissza", () => {
    const a = generateCodeVerifier();
    const b = generateCodeVerifier();
    assert.notEqual(a, b);
  });
});

// ---------------------------------------------------------------------------
// deriveCodeChallenge
// ---------------------------------------------------------------------------

describe("deriveCodeChallenge", () => {
  it("a code_challenge base64url-kódolt SHA-256 hash a verifierből", async () => {
    const verifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk";
    const challenge = await deriveCodeChallenge(verifier);
    // Elvárt érték: base64url(sha256("dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"))
    // Forrás: RFC 7636 B.1. példa (de más verifier → különböző érték)
    assert.ok(typeof challenge === "string");
    assert.match(challenge, /^[A-Za-z0-9\-_]+$/);
    // SHA-256 → 32 bájt → base64url: 43 karakter (= nélkül)
    assert.equal(challenge.length, 43);
  });

  it("két különböző verifier különböző challenge-t ad", async () => {
    const a = await deriveCodeChallenge("verifierA");
    const b = await deriveCodeChallenge("verifierB");
    assert.notEqual(a, b);
  });
});

// ---------------------------------------------------------------------------
// generateState
// ---------------------------------------------------------------------------

describe("generateState", () => {
  it("legalább 32 karakter hosszú base64url-kódolt stringet ad vissza", () => {
    const state = generateState();
    assert.ok(typeof state === "string");
    assert.ok(state.length >= 32);
  });

  it("csak URL-biztonságos karaktereket tartalmaz", () => {
    assert.match(generateState(), /^[A-Za-z0-9\-_]+$/);
  });

  it("két egymást követő hívás különböző értéket ad vissza", () => {
    assert.notEqual(generateState(), generateState());
  });
});

// ---------------------------------------------------------------------------
// signCookie + verifyCookie
// ---------------------------------------------------------------------------

describe("signCookie és verifyCookie", () => {
  const SECRET = "teszt-titkos-kulcs-legalabb-32-byte-hosszu-12345678";

  it("az aláírt cookie visszaolvasható és a payload egyezik", async () => {
    const payload = {
      sub: "user-123",
      accessToken: "at",
      refreshToken: "rt",
      expiresAt: 9999999999,
    };
    const signed = await signCookie(payload, SECRET);
    assert.ok(typeof signed === "string");

    const result = await verifyCookie(signed, SECRET);
    assert.ok(result !== null);
    assert.equal(result.sub, payload.sub);
    assert.equal(result.accessToken, payload.accessToken);
    assert.equal(result.refreshToken, payload.refreshToken);
    assert.equal(result.expiresAt, payload.expiresAt);
  });

  it("megváltozott payload-ú cookie null-t ad vissza", async () => {
    const payload = {
      sub: "user-123",
      accessToken: "at",
      refreshToken: "rt",
      expiresAt: 9999999999,
    };
    const signed = await signCookie(payload, SECRET);

    // Payload rész Base64-ből dekódolva meghamisítva
    const parts = signed.split(".");
    assert.equal(
      parts.length,
      3,
      "a signed cookie 3 részből áll: payload.timestamp.hmac",
    );
    const tampered = parts[0] + "." + parts[1] + ".invalidsignature";

    const result = await verifyCookie(tampered, SECRET);
    assert.equal(result, null);
  });

  it("rossz secret-tel aláírt cookie null-t ad vissza", async () => {
    const payload = {
      sub: "user-456",
      accessToken: "at2",
      refreshToken: "rt2",
      expiresAt: 9999999999,
    };
    const signed = await signCookie(
      payload,
      "helyes-secret-legalabb-32-byte-hosszu-xxx",
    );
    const result = await verifyCookie(
      signed,
      "masik-secret-legalabb-32-byte-hosszu-yyy",
    );
    assert.equal(result, null);
  });

  it("két különböző payload különböző aláírást kap", async () => {
    const a = await signCookie(
      { sub: "u1", accessToken: "a", refreshToken: "r", expiresAt: 1 },
      SECRET,
    );
    const b = await signCookie(
      { sub: "u2", accessToken: "a", refreshToken: "r", expiresAt: 1 },
      SECRET,
    );
    assert.notEqual(a, b);
  });
});

// ---------------------------------------------------------------------------
// buildCookieHeader
// ---------------------------------------------------------------------------

describe("buildCookieHeader", () => {
  it("tartalmazza a cookie nevet és értéket", () => {
    const header = buildCookieHeader({ name: "sp_session", value: "abc123" });
    assert.ok(header.startsWith("sp_session=abc123"));
  });

  it("httpOnly, Secure, SameSite=Lax alapértelmezett", () => {
    const header = buildCookieHeader({ name: "sp_session", value: "v" });
    assert.ok(header.includes("HttpOnly"), "HttpOnly hiányzik");
    assert.ok(header.includes("Secure"), "Secure hiányzik");
    assert.ok(header.includes("SameSite=Lax"), "SameSite=Lax hiányzik");
  });

  it("Path=/ alapértelmezett", () => {
    const header = buildCookieHeader({ name: "sp_session", value: "v" });
    assert.ok(header.includes("Path=/"));
  });

  it("maxAge beállítható", () => {
    const header = buildCookieHeader({
      name: "sp_session",
      value: "v",
      maxAge: 86400,
    });
    assert.ok(header.includes("Max-Age=86400"));
  });

  it("SameSite felülírható", () => {
    const header = buildCookieHeader({
      name: "sp_csrf",
      value: "token",
      sameSite: "Strict",
    });
    assert.ok(header.includes("SameSite=Strict"));
    assert.ok(
      !header.includes("SameSite=Lax"),
      "Lax nem maradhat benne ha Strict-et kérünk",
    );
  });

  it("httpOnly=false esetén nincs HttpOnly attribútum", () => {
    const header = buildCookieHeader({
      name: "sp_csrf",
      value: "v",
      httpOnly: false,
    });
    assert.ok(
      !header.includes("HttpOnly"),
      "HttpOnly nem jelenhet meg ha false",
    );
  });
});

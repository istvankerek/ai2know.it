# Brand: SkillPass.ID

> Forrás: skillpass repo `.claude/identity/brand-skillpass.md` (plan-v15 átvétel).

## Mi a SkillPass.ID?
Önálló OAuth2/OIDC identitás-szolgáltató. Az Everengine ökoszisztéma minden partner
portálja ezen keresztül léptet be, és ez adja a felhasználói fiókot
(Account Center: profil, biztonság, dokumentumok, számlák, képzések).

## Alapok
- **Név:** SkillPass.ID (wordmark: "SkillPass" + ".ID")
- **Domain:** MINDIG `skillpass.id` (login UI: `auth.skillpass.id`)
- **Tagline:** "One identity. Everywhere."
- **Partner gomb:** "Belépés SkillPass.ID-vel" / "Continue with SkillPass"

## Vizuális identitás
- **Logo:** vektoros útlevél-glyph. Az ikon path-jai nem módosíthatók.
- **Szín:** brand kék skála (brand-500 `#0c87eb`), accent amber `#f59e0b`, zinc neutrálisok.
  Portál tokenek: `--sp-` prefix (lásd `skillpass-portal` skill `references/design-tokens.md`).
- **Identity ring:** avatar körüli conic-gradient gyűrű + kék verified pont.
- **Tipográfia:** Geist (UI, 14px base), Geist Mono (ID-k, kódok).

## Hangnem
- UI: magyar (alapértelmezett) + angol, közvetlen, tömör.
- ID formátumok: `SP-XXXX-XX` (felhasználó), `SP-YYYY-NNNNNN` (ticket).

## Célközönség (audience pointer)
- Elsődleges: `audience/end-user.md`
- Másodlagos: `audience/developer.md` (partner integráció)

## Tiltások
- Megszűnt identitás-brand neve nem jelenhet meg UI-ban vagy copy-ban.
- Partner portál nem nevezheti át és nem stílusozhatja újra a SkillPass belépés gombot.

---

**Trigger detect:** "skillpass", "skillpass.id", "SkillPass" → ezt a fájlt olvasd be.

# Audience: Developer

> **Template** – fejlesztő tölti ki / finomítja.

## Profil
- **Szerep:** Backend / frontend / full-stack engineer, DevOps, SRE
- **Korosztály:** [pl. "25-45"]
- **Tapasztalat:** [pl. "3+ év commercial dev"]
- **Pain point:** [pl. "Vendor lock-in, opaque pricing, AI hype-szöveg dokumentációban"]

## Mit értékel
- Technikai pontosság (RFC referenciák, kód példák, valódi schema-k)
- Saját döntés szabadsága (nem black-box, lehet self-hostolni / tweakelni)
- Read-only docs > marketing copy
- Konkrét teljesítmény-szám (ms, RPS, MB) > "fast and scalable"

## Mit utál
- "Click here to learn more" CTA
- Feliratkozás-fal egy egyszerű API doc előtt
- Marketing-szleng technikai context-ben
- Hidden cost ("starts at $X" + per-seat + per-call + ...)

## Hogyan kommunikálunk vele
- **Hangnem:** Tegezős, tárgyilagos, példa-vezérelt
- **Struktúra:** TL;DR → Problem → Solution → Code → Trade-offs
- **Hossz:** Rövidebb a jobb. Ha hosszú, world-class navigation.
- **Format:** Markdown, syntax-highlighted code, hivatkozások RFC-re / forrásra
- **Tabulátor a magyar szakkifejezéshez:** angol szakszavak megengedettek (cache, deploy, refactor),
  de a köztes szöveg magyar.

## Példa: jó vs rossz nyitás

❌ "We're excited to introduce our cutting-edge solution..."
✅ "Új MCP server: lokális SQLite-on cache-eli a Claude Context query-ket. Read-only, < 5 ms / lekérdezés."

---

**Mikor olvassa a Claude:**
- API doc, README, CONTRIBUTING, dev guide írás
- Hiring copy fejlesztői pozícióhoz
- Conference talk abstract, blog post fejlesztőknek

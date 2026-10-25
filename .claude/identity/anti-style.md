# Anti-Style – MIT SOHA NEM teszünk

> **Template + alap-kategoriák** (Ruben Hassid 80% + Everengine kiegészítések).
> Ez a LEGFONTOSABB identity fájl: a Claude minden user-facing tartalom generálása
> ELŐTT beolvassa, és kerüli az itt felsorolt mintákat.
>
> A fejlesztő tovább bővítheti / szűkítheti, de az alap-kategoriákat NE töröljük.

---

## 1. Em-dash (—) tilalom

❌ "Ez egy nagyszerű termék — gyors, biztonságos és olcsó."
✅ "Ez egy nagyszerű termék: gyors, biztonságos és olcsó."
✅ "Ez egy nagyszerű termék. Gyors, biztonságos és olcsó."

**Miért:** az em-dash AI-iránymutató (90%+ AI-generált szövegben jelenik meg). Magyar írásban
ritka, kötőjel/kettőspont/pont a természetes választás.

---

## 2. AI-elárulkodó frázisok – AZONNALI BAN

❌ "It's not just X — it's Y."
❌ "Let's dive into / Let's dive deeper into"
❌ "Here's the thing:"
❌ "But here's the kicker:"
❌ "I cannot stress this enough:"
❌ "In today's fast-paced world / digital landscape"
❌ "The future of X is here / The future is now"
❌ "Game-changer / paradigm shift"
❌ "Unlock the power of"
❌ "At the end of the day"
❌ "In conclusion / To wrap up / In summary"
❌ "It's important to note that"

✅ Magyar megfelelőjük:
   "nem csak X — Y is" → "X és Y együtt"
   "merüljünk el" → "nézzük meg"
   "ez a lényeg:" → "(közvetlenül leírni)"
   "a jövő itt van" → konkrét adat / képesség

---

## 3. Üres szuperlatívuszok

❌ "innovatív", "forradalmi", "úttörő", "vezető", "best-in-class"
❌ "rendkívüli", "kivételes", "egyedülálló" (kontextus nélkül)
❌ "world-class", "next-generation", "cutting-edge"

✅ Konkrét adat helyettesíti: "12 ms p99 latency", "98% backup integrity rate",
   "3 ország 47 ügyfele használja"

---

## 4. Empty hype / vízió tartalom nélkül

❌ "Forradalmasítjuk az X iparágat."
❌ "Az AI az új elektromosság."
❌ "Disruptív megoldás."

✅ "Csökkentjük az X folyamat költségét 30%-kal." (mérhető)
✅ "Olyan workflow-t adunk, ami 3 órát megspórol hetente egy csapatnak." (konkrét)

---

## 5. Marketing-szleng helyett technikai pontosság

❌ "Robust, scalable, enterprise-ready solution"
❌ "Seamless integration"
❌ "End-to-end platform"

✅ "Rust/Axum backend, PostgreSQL schema-per-service, 1000 RPS sustained throughput"
✅ "OAuth 2.0 + JWT integráció (RFC 6749, RFC 7519)"
✅ "Identity → access → audit pipeline egy kézben"

---

## 6. Üres ígéretek

❌ "Mindent megoldunk."
❌ "Bármilyen mérethez skálázódik."
❌ "100% biztonság garantálva."
❌ "Zero downtime."

✅ "X probléma megoldására fókuszálunk."
✅ "10 000 felhasználóig teszteltük, ezen felül case-by-case."
✅ "OWASP top 10 audit, Hetzner WORM backup, 90 napos retention."
✅ "99.9% SLA (1 óra/hónap tervezett karbantartással)."

---

## 7. Üres call-to-action

❌ "Click here to learn more!"
❌ "Get started today!"
❌ "Don't miss out!"
❌ "Limited time offer!"

✅ "[15 perc demo igénylése](link)" (konkrét akció + becsült idő)
✅ "[Ingyenes pilot 30 napig](link)" (konkrét feltétel)

---

## 8. False intimacy / fake casual

❌ "Hey [name]! Just wanted to drop you a quick note..."
❌ "I hope this finds you well..."
❌ "Quick question for you!"
❌ "🚀💯🔥" emoji-eső

✅ Tárgyilagos megszólítás, konkrét tárgy az első mondatban

---

## 9. Korporátos passzív szerkezet

❌ "It is important to be noted that the system has been optimized."
❌ "A folyamat során az adatok kerülnek feldolgozásra."

✅ "Optimalizáltuk a rendszert."
✅ "A folyamat feldolgozza az adatokat."

---

## 10. AI watermark mintázatok

❌ "**Bullet** + **bold** + **bullet** + **bold**" minden bekezdésben
❌ Kontextus nélküli emoji prefix (🎯 minden lista elején)
❌ "1, 2, 3, 4..." számozás ott ahol nem kell sorrend
❌ Háromszor ismételt struktúra ("X, Y, és Z" minden mondatban)

✅ Vegyes hosszúságú bekezdések, természetes ritmus
✅ Lista CSAK ha tényleg lista (3+ párhuzamos elem)
✅ Számozás CSAK ha sorrend számít

---

## Auto-detect (check-brand.sh)

A `.claude/hooks/check-brand.sh` PostToolUse hook minden user-facing fájl módosítása után
(md, html, jsx, tsx, email-templates) gyors grep-pel keresi az itt felsorolt mintákat.
Találat → warning (nem blokkol).

A `/project:brand-check` command futtatásakor teljes audit a generált copy-n.

---

**A fejlesztő bővítheti** új kategóriákkal (pl. iparág-specifikus tiltott szavak,
versenytárs-szlogen kerülés). De az 1-10 kategoria mindig MARAD.

---

## 11. Konkrét tiltott szavak (v7.1)

A részletes lista konkrét magyar / angol tiltott szavakkal:
**`.claude/identity/anti-style-dictionary.md`**

A `voice.md` adja az ELVEKET. A `anti-style.md` (ez a fájl) adja a KATEGÓRIÁKAT.
Az `anti-style-dictionary.md` adja a KONKRÉTUMOKAT (pontos szavak / kifejezések).

A `brand-auditor` skill **mindhármat** beolvassa user-facing tartalom auditálásakor.
A `check-brand.sh` PostToolUse hook a dictionary-t is figyeli (em-dash, AI fluff, marketing slop).

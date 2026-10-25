# 90 – Nyitott kérdések (plan-v3)

**Lezárva a v2-ből:**

- Q-V2-01: a válasz a 06/3 pont.
- Q-V2-02: a válasz a `05-superskiller-api.md`.
- Q-V2-05: bárki készíthet curve-öt (D-V3-01).
- Q-V2-08: lesz fizetős szint, F11-ben (D-V3-03).
- Q-V2-09: a kanonikus forma `/+slug`, a `/lc` alias marad (D-V3-04).

**Továbbra is nyitott a v2-ből:** Q-V2-03, Q-V2-04, Q-V2-06, Q-V2-07.

| ID | Kérdés | Kit érint | Javasolt válasz |
|----|--------|-----------|-----------------|
| Q-V3-01 | Fizetős tartalomnál ki számláz a vevőnek: a partner (az ai2know csak közvetít), vagy az üzemeltető, aki aztán jutalékot fizet? Mekkora a platform díja? | owner, jog, könyvelő | a partner számláz, a platform közvetítői díjat számláz a partnernek (egyszerűbb ÁFA); F11 előtt dönteni |
| Q-V3-02 | Mi kell az „ellenőrzött aibos.club eladó" státuszhoz? | owner, aibos.club | eladói feltételek elfogadása, számlázási adatok, operátori jóváhagyás |
| Q-V3-03 | A bizalmi szintek induló küszöbei (3 előmoderált tartalom, 5 feltöltés/nap) megfelelők? | owner | igen, a konzolban állítható |
| Q-V3-04 | Ki az ai2know adatkezelője, és mi az adattovábbítás jogalapja a skillpass felé? Fiók törlésekor mi legyen a nyilvános tartalommal: anonimizálás vagy törlés? | owner, jog | önálló adatkezelő, szerződés; a felhasználó választ, az alapértelmezés az anonimizálás |
| Q-V3-05 | Jóváhagyják-e a domainek gazdái a közös `+` Caddy szabályt (aibootcamp.hu, superskiller.com, skillpass.id, aibos.club, aiagentekagyakorlatban.hu)? | owner | igen |
| Q-V3-06 | A személyes `@handle` a skillpass felhasználónévből jöjjön, vagy az ai2know-ban válasszon a felhasználó? | owner, skillpass | a skillpass-ból jöjjön, ha van, egyébként első belépéskor választ |
| Q-V3-07 | Az elemek közösségi értékelése maradjon az ai2know-ban (P-V3-12)? | owner | igen |
| Q-V3-08 | Tipográfia: az élő oldalé (Georgia + Manrope) vagy a brand skillé (Montserrat + Inter)? | owner | az élő aibootcamp.hu-é |
| Q-V3-09 | A superskiller közösségi posztjai és csoportjai még nem léteznek. Lépéstípusként a superskiller közösségi moduljával együtt jöjjenek? | owner, superskiller | igen, addig a kurzus, a lecke és a küldetés lehet lépés |
| Q-V3-11 | Átdolgozzuk-e a plan-v3 integrációs részeit (05, 06, F2, F5) az api.sios.ws kapu és a skillpass szabálykönyv (R0–R2) szerint? A részletek az `implementation-notes.md`-ben. | owner | igen; plan-v4 mint integrációs revízió, a sios.ws specifikáció elolvasása után |
| Q-V3-10 | Szervezeti munkatér nevében lehet-e márkanév (pl. `@otp`) ellenőrzés nélkül? | owner | foglalt márkalista + skillpass szervezet-ellenőrzés a II. felvonásban |

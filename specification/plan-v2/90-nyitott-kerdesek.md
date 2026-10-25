# 90 – Nyitott kérdések (plan-v2)

Lezárva: Q-13 (a „hozzu…" véletlen volt), Q-V1-01 (P-V2-01: az ai2know a forrásrendszer),
Q-V1-02 (superskiller: összehangolás), Q-V1-03 (P-V2-05: teaser modell).
A II. felvonáshoz a `../plan-v0/90-nyitott-kerdesek.md` kérdései érvényesek.

| ID | Kérdés | Kit érint | Javasolt válasz |
|----|--------|-----------|-----------------|
| Q-V2-01 | A skillpass.id-n hogyan jelenjen meg a „Készítette" (curve, elvégzők, visszajelzés)? Új M2M scope a passport-api `community_contribution` rekordhoz, vagy a skillpass az ai2know összesítő végpontját olvassa? | skillpass repo | contribution push + összesítő link |
| Q-V2-02 | A superskiller partner API (objektum-feloldás, hozzáférés-állapot, elvégzés-webhook) mikor és ki építi? Mely objektumok: kurzus, lecke, csoport, poszt, cikk? | superskiller repo | közös contract F0-ban, megvalósítás a superskiller saját plan-jában |
| Q-V2-03 | Az események/workshopok hol élnek (aibos, aibootcamp, superskiller edition)? Ebből jön a résztvevő-kohorsz. | aibos / aibootcamp | aibos esemény + aibootcamp entitlement |
| Q-V2-04 | aibootcamp tréning végén automatikusan készüljön curve-vázlat? | aibootcamp | igen, oktatói jóváhagyással publikálva |
| Q-V2-05 | Kik kapnak induláskor `curve_author` képességet (oktatók, partnerek listája)? | owner | owner listája |
| Q-V2-06 | A GitHub-ról származó ~309 skill licence engedi-e a teljes tartalom tárolását és csomagban letöltését? | jog | elemenként licenc-mező; nem engedőnél csak link |
| Q-V2-07 | Compliance guide-ok: ki írja és hagyja jóvá (jogi felelősség)? | owner / jog | tervezet státusz jogi jóváhagyásig (L-09) |
| Q-V2-08 | Legyen-e fizetős curve (a skillpass entitlementen és aibos pay-en át)? | owner | 2. kör |
| Q-V2-09 | A „Learning curve" név és a `/lc` URL végleges? (Nyomtatásba kerül.) | owner | igen |

# Audience: Support Agent (ügyfélszolgálat)

> **Template** – fejlesztő tölti ki / finomítja.

## Profil
- **Szerep:** Ügyfélszolgálatos / sikermenedzser, aki napi szinten beszél a végfelhasználókkal
- **Korosztály:** [pl. "20-40"]
- **Technikai jártasság:** [pl. "Közepes; tudja mi az API, de nem fejleszt"]
- **Pain point:** [pl. "Hiányos runbook, lassú escalation, csapdás dokumentáció"]

## Mit értékel
- **Runbook-ok lépésről-lépésre** ("Ha X történik, csináld Y-t, ha még mindig nem megy, escalate Z-nek")
- **Példa-üzenetek** (sablonok amit copy-paste-elhet az ügyfélnek)
- **Decision tree** ("Mikor ad ingyenes meghosszabbítást, mikor nem")
- **Escalation path** (kit hív, mikor)
- **FAQ index** (top 20 kérdés gyors elérhető)

## Mit utál
- Hosszú prózai dokumentáció amiben kell keresgélni
- Ellentmondásos szabályok ("néha igen, néha nem")
- Hiányzó kontextus ("X feature 2024-ben kivezetve" – de hogy magyarázza ügyfélnek?)
- Nem updatelt FAQ (régi termék-elnevezések)

## Hogyan kommunikálunk vele
- **Hangnem:** Tegezős, gyakorlatias, példa-vezérelt
- **Struktúra:** Ha [helyzet] → Csináld [konkrét akció] → Ha [edge case] → [másik akció]
- **Hossz:** Rövid, scannelhető. Lépés-listák + sablon-üzenetek.
- **Format:** Markdown, callout box-ok ("Figyelem", "Tipp", "Eskaláció")

## Példa: runbook részlet

❌ "A jogosultsági problémák kezelésénél fontos figyelembe venni a felhasználó szerepkörét..."
✅
```
Ha az ügyfél azt mondja: "nem tudok belépni"
1. Kérdezd meg: melyik bejelentkezési oldalon próbálkozott (auth.skillpass.id vagy app.X.com)?
2. Ellenőrizd az auth.kerek.id-ben → User search → email
3. Ha státusz = "locked" → reset jelszó email küldése (gomb a profil oldalán)
4. Ha még mindig nem → eskaláció: @backend-team Slack
```

---

**Mikor olvassa a Claude:**
- Runbook írás
- FAQ generálás
- Sablonüzenet készítés (canned response)
- Escalation matrix doc

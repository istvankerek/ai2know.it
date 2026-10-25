# 04 – Design rendszer és mobil

## 1. Elvek

- **Mobile-first:** minden képernyő 360 px szélességre készül először; desktop a bővítés.
- **Tartalom elöl:** a kereső és a találatok az első képernyőn, nincs hirdetés-oszlop és
  oldalsáv-zsúfoltság (a régi `ads.html` és bal menü megszűnik).
- **Gyors:** szerver oldali render, minimális kliens JS a katalógus-oldalakon, képek `next/image`,
  betűtípus helyben (szigorú CSP, mint az aiagentek oldalon).

## 2. Arculat

- Az ai2know.it logó megmarad; színek, tipográfia, ikonkészlet (lucide) újratervezve, tokenekben
  (Tailwind v4 `@theme`), világos + sötét mód (rendszer szerint, felülírható a skillpass beállítással).
- Típusonként egy azonosító szín és ikon (eszköz, prompt, skill, videó, szócikk…) – kártyán, chipen,
  találati listán következetesen.
- Előbb képernyőtervek (kezdőlap, katalógus mobil+desktop, részletoldal, kereső, szűrőlap) –
  owner jóváhagyás, utána kód. A `brand-auditor` ellenőrzi a szövegeket.

## 3. Mobil minták

| Minta | Leírás |
|-------|--------|
| Alsó tab sáv | Kezdőlap, Keresés, Eszközök, Eszköztár, Menü; aktív állapot, safe-area padding |
| Teljes képernyős kereső | azonnali fókusz, előzmények, javaslatok, hangbevitel nem kell |
| Szűrő lap | alulról nyíló, húzható; „Mutasd (128)" gomb élő számlálóval; „Törlés" |
| Kártyák | egy oszlop, teljes kártya kattintható, „Másolás" / „Megnyitás" gyorsművelet a kártyán |
| Részletoldal | ragadós alsó akciósáv (Másolás, Kedvenc, Megosztás – Web Share API) |
| Táblázatok | mobilon kártyalistává alakulnak (nincs vízszintes görgetés) |
| Érintési célok | ≥ 44×44 px, fókusz-gyűrű látható |

## 4. Akadálymentesség

WCAG 2.1 AA: kontraszt, billentyűzetes kezelés (kereső, szűrők, lapok), `aria-live` a
találatszámra, csökkentett mozgás tisztelete, alt szövegek kötelezők a tartalommodellben.

## 5. Teljesítmény-költségvetés

| Mérőszám | Mobil cél |
|----------|-----------|
| LCP | < 2,5 s (4G, közepes eszköz) |
| INP | < 200 ms |
| CLS | < 0,1 |
| Első JS a katalógus-oldalon | < 120 kB gzip |
| Lighthouse (perf, a11y, SEO, best practices) | ≥ 90 |

CI-ban Lighthouse CI a kezdőlapra, egy katalógusra és egy részletoldalra, mobil profillal.

## 6. Workspace shell

A nyilvános tudásbázis saját fejléccel fut (SEO, gyors első render). Belépve az „Eszközeim"
(kedvencek, gyűjtemények, QR kódok, kérések) a `@skillpass/workspace-shell` keretben jelenik meg,
az app launcherben ai2know.it bejegyzéssel (`skillpass-portal`, `skillpass-app-launcher`).

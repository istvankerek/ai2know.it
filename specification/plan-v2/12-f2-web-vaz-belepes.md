# F2 – Web váz, mobil design, belépés, láthatósági kapuk

> A `../plan-v1/12-f2-web-vaz-design.md` és `../plan-v1/04-design-mobil.md` szerint, kiegészítve.

## Kiegészítések (v2)

- [ ] Kapu-komponensek: `TeaserGate` (elmosott/levágott tartalom + „Lépj be ingyen a teljes
      tartalomért" + mit kap a belépéssel), visszatérés ugyanarra az oldalra belépés után.
- [ ] Darabszám-jelzések („339 AI skill – 45 nyilvános") listákon és a kezdőlapon.
- [ ] Strukturált adat: `isAccessibleForFree`, `hasPart` a zárt részre (P-V2-05).
- [ ] Kezdőlap: kereső, típus-csempék, kiemelt nyilvános curve-ök, „Készíts curve-öt a workshopod
      után" oktatói ajánló, közösségi és partner blokk.
- [ ] Navigáció (mobil alsó sáv): Kezdőlap, Keresés, Tudástár, Curve-ök, Menü/Avatar.
- [ ] Workspace shell a tagi részen (Curve-jeim, Kedvencek, Kéréseim).

## Tesztek

- Anonim HTML-ben nincs zárt törzs (Playwright, nyers válasz ellenőrzés).
- Belépés → visszatérés ugyanarra az elemre, teljes tartalommal.

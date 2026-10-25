# 91 – Kockázatok (plan-v1)

A `../plan-v0/91-kockazatok.md` kockázatai érvényesek. Új / módosult:

| ID | Kockázat | Valószínűség | Hatás | Kezelés |
|----|----------|--------------|-------|---------|
| R-V1-01 | A régi rendszer az I. felvonás alatt hosszabban fut, a biztonsági hibái tovább élnek | magas | magas | F0/1 biztonsági javítás az első lépés (P-V1-06) |
| R-V1-02 | Az aibos katalógus-bővítés késik és blokkolja az F1–F3-at | közepes | magas | contract + mock (L-05); B alternatíva (saját séma) döntési pontja F1 elején |
| R-V1-03 | Nyomtatott könyv URL eltörik az átköltözéskor | alacsony | magas | előbb cél 200, aztán redirect; regressziós lista; örök 301 |
| R-V1-04 | „Tudásbázis" tartalom vékony marad (a seed kicsi) | magas | magas | indulási tartalmi célok (03/4), szerkesztői folyamat, „nincs találat" riport |
| R-V1-05 | Két párhuzamos rendszer (régi tagi + új tudásbázis) zavarja a felhasználókat | közepes | közepes | egységes fejléc-linkek, magyarázó sáv, a II. felvonás ne csússzon sokat |
| R-V1-06 | Elavuló eszköz-adatok (árak, platformok) | magas | közepes | `reviewed_at`, heti link-ellenőrzés, elavultsági riport |
| R-V1-07 | A szemantikus keresés költsége/bonyolultsága | alacsony | alacsony | csak mért igény esetén (02/3, 2. kör) |

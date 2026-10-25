# 91 – Kockázatok (plan-v3, a v2 listáján felül)

| # | Kockázat | Valószínűség | Hatás | Kezelés |
|---|----------|--------------|-------|---------|
| R-V3-01 | Spam és SEO-visszaélés a nyílt feltöltés miatt | magas | domain hírnév, moderációs teher | bizalmi szintek, `noindex` küszöb, `rel="ugc nofollow"`, helyi osztályozó (P-V3-10, P-V3-13) |
| R-V3-02 | Titkok nyilvános közzététele promptban vagy MCP konfigban | közepes | a feltöltőnek kár, nekünk felelősség | kötelező titok-detektálás (P-V3-11) |
| R-V3-03 | Jogsértő tartalom (szerzői jog, GitHub licenc) | közepes | DSA / polgári jogi igény | licenc mező, bejelentés–eltávolítás folyamat, indoklás (P-V3-14) |
| R-V3-04 | Egyes linkfelismerők elvágják a `+`-os linket | közepes | megosztott link nem kattintható | `/lc` alias a megosztó gombban, ahol tör; smoke lista (03/4) |
| R-V3-05 | Slug-foglalás (squatting), megtévesztő márkanevek | közepes | márkahírnév | foglalt lista, rövid slug jóváhagyása, felszabadítás (03/3) |
| R-V3-06 | Idegen zárt elem „kinyitása" curve-ön keresztül | alacsony | adatszivárgás | P-V3-09 + mátrix teszt |
| R-V3-07 | A skillpass és a superskiller oldali munka csúszik | magas | F5 részlegesen kész | feature flag minden külső függésre; az ai2know a mock contracttal kész lehet; a „Készítette" blokk nélkül is élesíthető |
| R-V3-08 | Fizetős szint jogi/adó bizonytalansága | magas | F11 csúszik | flag mögött, élesítés után; Q-V3-01 előbb |
| R-V3-09 | GDPR törlés nem ér el az ai2know-hoz (ma nincs skillpass értesítés) | magas | jogi | 06/7 P0 igény; addig napi `userinfo` ellenőrzés az aktív tagokra |
| R-V3-10 | A workspace shell és az aibootcamp tokenek vizuálisan ütköznek | közepes | inkonzisztens UI | vizuális regresszió F2-ben, shell a keret, tokenek a tartalom-területen |

# 91 – Kockázatok

| ID | Kockázat | Valószínűség | Hatás | Kezelés |
|----|----------|--------------|-------|---------|
| R-01 | A régi rendszer kitett titkai / nyitott backup szolgáltatása miatt már most adatszivárgás történik (01 / 3.1) | közepes | magas | F0 / 4 azonnal, a terv elfogadásától függetlenül, owner jóváhagyással |
| R-02 | A tagok nem tudnak belépni az átállás után (jelszó nélküli import, ismeretlen SkillPass) | magas | magas | előzetes e-mail kampány, világos belépő oldal („a fiókod átkerült"), e-mail kódos első belépés, support csatorna |
| R-03 | Elveszik a partner attribúció (142 kód) | alacsony | magas | egyeztető teszt kódonként (04 / 6), first-touch szabály teszttel |
| R-04 | SEO visszaesés a host váltás és a nyelv egy URL-re vonása miatt | közepes | közepes | 1 ugrásos 301-ek, sitemap, Search Console, kanonikus magyar tartalom; a régi oldal forgalma nagyrészt belépés és bot, nem organikus |
| R-05 | Az angol látogatók magyar tartalmat kapnak | magas | alacsony | Q-03; „csak magyarul" jelzés; en hint süti |
| R-06 | A skillpass import képesség nem készül el időben | közepes | közepes | „B" út (összekötés első belépéskor) mindig működik, az import gyorsító, nem feltétel |
| R-07 | Ismeretlen külső hívók (create-user, sold_packages, RSS) elhalnak | közepes | közepes | Q-06, Q-09; 410 / kompatibilis válasz; a `redirect_hits` és 410 számlálók figyelése |
| R-08 | Az aibos-public tartalom vagy az admin integráció késik | közepes | közepes | contract-first + mock; tartalom seed az F3 része; ISR utolsó jó állapot |
| R-09 | 301 böngésző-cache miatt egy hibás redirect nehezen javítható | alacsony | közepes | test környezetben 302-vel próba, prod-on 301 csak a 100%-os regresszió után |
| R-10 | Bot forgalom terheli a redirectort | magas | alacsony | rate limit, Cloudflare WAF, aszinkron batch írás |
| R-11 | GDPR: régi PII (telefonszám, nyers IP, logokban JWT/e-mail) a migráció után is megmarad | közepes | magas | 04 / 3.3 szabályok, archívum titkosítva, törlési jegyzőkönyv (F8 / 4) |
| R-12 | A régi szerveren futó idegen szolgáltatás (`live.aibootcamp.space`) leáll a szerverrel | közepes | közepes | Q-08 a leállítás előfeltétele |

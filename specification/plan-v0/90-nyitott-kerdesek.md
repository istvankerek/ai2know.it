# 90 – Nyitott kérdések (owner döntés kell)

| ID | Kérdés | Mit befolyásol | Javasolt válasz |
|----|--------|----------------|-----------------|
| Q-01 | Ki építi a skillpass.id oldali tömeges identitás-importot (új M2M scope vagy egyszeri admin job a skillpass repóban)? | F7, 04 / 3.1 | skillpass repóban külön plan, az ai2know csak exportot ad |
| Q-02 | A skillpass `locale` trait kijön-e claimként (id_token / userinfo `profile` scope) vagy csak a shell-contextből? | F2 nyelvválasztás | `locale` claim a `profile` scope-ban |
| Q-03 | Kell-e angol tartalom már az indulásra, és mely oldalakra? (Ma nincs angol tartalom, csak magyar.) | F3 terjedelem | indulás: angol UI + jogi oldalak, többi később |
| Q-04 | Az `aitoknow.it` / `www.aitoknow.it` domain még a miénk, és hová mutat? Vannak régi WordPress URL-ek, amiket érdemes lekövetni? | 03 host réteg | ha a miénk: 301 a főoldalra |
| Q-05 | Van-e skillpass.id test példány partner klienssel, vagy helyi dev-stacket használunk? | F0, F2 E2E | test példány |
| Q-06 | Ki hívja a régi `POST /api/create-user` végpontot (valószínűleg az aibootcamp vásárlás)? | F4 / 10 | azonosítás, majd M2M előjegyzés |
| Q-07 | A 169 azonos (sózatlan SHA-256) jelszavú fiók honnan jött (tömeges import egy eseményről)? Mit tegyünk most a régi rendszerben? | F0 / 4, F7 | zárolás + jelszó-visszaállítás |
| Q-08 | A régi szerveren futó más szolgáltatások (`live.aibootcamp.space`, egyéb) hová költöznek? | F8 leállítás | külön feladat a szerver leállítása előtt |
| Q-09 | Ki hívja a `/business/sold_packages` végpontot (~2,3 k hívás)? | 03 / 3.4 | kompatibilis válasz marad, amíg kiderül |
| Q-10 | Mely funkciók maradjanak: `/kedvencek` (soha nem készült el), `/pontok` (csak kijelzés), AI kérdés-válasz, support, `?x@handle` referral? | F4 terjedelem | kedvencek és pontok: tartalomoldal / kivezetés; Q&A és support: marad |
| Q-11 | Hol él a hírlevél-küldés (Mailgun lista, aibos CRM, más)? A 3 525 feliratkozó hozzájárulása hová kerüljön? | F5 newsletter export | aibos CRM |
| Q-12 | A `github.com/istvankerek/ai2know.it` repo nyilvános volt-e valaha? (DB dump és titkok vannak benne.) | F0 / 4 sürgősség | ha igen: azonnali titokcsere + repo privát/archivált |
| Q-13 | Az eredeti kérés vége megszakadt („illetve hozzu…") – mi a hiányzó kérés? | terjedelem | – |
| Q-14 | GA4: marad a `G-DSGDV4EG3E` property? OneSignal web push marad? | F3 / 5 | GA4 marad consenttel; OneSignal kivezetés |
| Q-15 | A Caddy access logok üresek a mentésben – letölthetők-e sudo-val a szerverről a pontos forgalmi statisztikához? | 03 / 5 regressziós lista | igen, a F6 előtt |
| Q-16 | Mi a `/read-document` (645 találat 404-gyel)? Külső link valahonnan? | 03 / 3.3 | a hivatkozó kiderítése a Caddy logból |
| Q-17 | A csapatfában a meghívó lássa-e a meghívottak nevét? (Ma igen; a skillpass világban hozzájárulás kell.) | F4 / 2 | csak a meghívott hozzájárulásával |
| Q-18 | A business csomag és az affiliate rendelések az aibos `pay`-be költöznek, vagy a WooCommerce marad a forrás? | F4 / 3, 5 | új vásárlás aibos pay; a régi WooCommerce csak olvasva |

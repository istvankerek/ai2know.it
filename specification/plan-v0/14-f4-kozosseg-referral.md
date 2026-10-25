# F4 – Közösségi, referral és partner funkciók

> Cél: a régi rendszer valódi üzleti funkcióinak újraépítése, a régi hibák nélkül.
> Routing: STANDARD. Skillek: `crud-dla-module`, `tdd-enforcer`, `audit-trail-mandatory`,
> `file-upload`, `s3-storage`.
> Sorrend: üzleti érték szerint (1 → 9). Minden funkció: failing teszt → backend → web → i18n → audit.

## 1. Referral belépési pontok

- [ ] `/jelentkezes/{code}`: kód kisbetűsítve, `referral_codes` vagy `members.handle`/`handle_aliases`
      egyezés; ismeretlen kód is rögzül `referral_events`-ben (`kind = unknown_code`), a süti csak
      ismert kódra íródik. First-touch: meglévő `a2k_ref` nem íródik felül (régi viselkedés).
- [ ] `/@{handle}`: partner oldal (`partners`), tag oldal („csatlakozz a csapatomhoz"), vagy
      csatlakozás oldal ismeretlen handle-re (ma 500). **Adószám, cím, e-mail nem publikus** –
      csak név, leírás, logó, linkek (a partner maga dönt a megjelenítésről az aibos-ban).
- [ ] A régi `?x@handle` / `/út@handle` minta ma halott; nem építjük újra (Q-10 alapján bekapcsolható).

## 2. Csapatom (`/csapatom`) és Meghívás (`/meghivas`)

- [ ] Meghívó link: `https://ai2know.it/jelentkezes/{handle}` + másolás gomb (esemény: `invite.copied`).
- [ ] Csapatfa: közvetlen meghívottak (`source_code = saját handle` vagy alias) + rekurzív összesítő,
      rekurzív CTE-vel, mélységkorláttal. A tag a meghívottról csak megjelenítési nevet és dátumot lát
      (név a skillpass-ból, ha a meghívott hozzájárult – Q-17), e-mailt és telefont soha.
- [ ] Workspace shell navigációban.

## 3. Affiliate (`/affiliate`) – kuponok és rendelések

- [ ] Programleírás tartalomként (aibos).
- [ ] Kupon-tulajdon: `coupon_owners` explicit tábla (admin rendeli hozzá), a régi „felhasználónév
      szerepel a kuponkódban" regex csak az egyszeri migrációban javaslatként (P-V0-12).
- [ ] Rendelések: a backend csak olvasó WooCommerce kulccsal kérdez (aibootcamp.hu shop), cache
      15 perc; a tag csak a saját kuponjaihoz tartozó rendelések **darabszámát, dátumát, összegét**
      látja, vásárlói nevet/e-mailt nem.
- [ ] Hosszabb távon: a rendelésadat az aibos `pay` szolgáltatásból (Q-18).

## 4. Kedvezmények (`/kedvezmenyek`)

- [ ] Kuponok a `coupons` táblából (admin kezeli), szűrés címke szerint, kohorszhoz kötött kupon
      (pl. a régi ELTE kedvezmény a 1/5/6 role-nak → `cohort` feltétel).
- [ ] „Kupon másolva" esemény → `coupon_redemptions` (ez váltja a fájl logot).

## 5. Business partner (`/business`, `/business-csomag`, `/partnereink`)

- [ ] Partner profil létrehozás/szerkesztés: a `handle` a bejelentkezett tagé, nem a kérés törzséből
      (régi takeover hiba).
- [ ] Csomagvásárlás: `pay.aibos.space` checkout + `invoice.aibos.space` számla (P-V0-11), aláírt
      callback → partner aktiválás; a régi Számlázz.hu díjbekérő kivezetve.
- [ ] `/partnereink`: aktív partnerek listája, PII nélkül.
- [ ] Entitlement push a skillpass felé (`entitlements:write`), hogy a csomag a SkillPass fiókban is
      látsszon (Q-18).

## 6. QR kód (`/qrcode`)

- [ ] Generálás (png/svg/pdf) a backendben, tárolás MinIO-ban, saját lista.
- [ ] A régi `/data/qrcodes/{user}/{fájl}` képek változatlan URL-en (nyomtatott anyag lehet),
      a megnyitás-számláló esemény alapon, nem fájlírással.
- [ ] Csak `http(s)` cél URL, hosszkorlát, rate limit.

## 7. Megosztás (`/share/{uuid}`)

- [ ] Megosztó link létrehozás (tag), látogatáskor `share_hits` (ip_hash) és redirect **csak**
      `ai2know.it` útvonalra (a régi nyílt redirect megszűnik); vendégnél referral süti a megosztó
      handle-jére.

## 8. AI érettségi felmérés (`/ai-erettsegi-szint-felmeres`)

- [ ] A 25 kérdés tartalomként; pontozás mind a 25 kérdésre (ma csak 12 számít – P-V0-14),
      szintek és leírások az aibos tartalomból.
- [ ] Vendég: eredmény azonnal, mentés nélkül; tag: eredmény mentése (`assessments`), korábbi
      eredmények listája. Admin export az aibos-ban.

## 9. Kérdés-válasz és Support (Q-10 szerint)

- [ ] `/ai-kerdesek-es-valaszok`: tag kérdez, operátor az aibos-ban válaszol, publikálás jelölővel;
      minden szöveg escape-elve (a régi stored XSS ellen teszt).
- [ ] `/support`: jegy beküldés (cím, prioritás, leírás, melléklet MinIO-ba), saját jegyek listája;
      kezelés az aibos-ban (P-V0-13). Trello kivezetve vagy egyirányú szinkron, ha az owner kéri.

## 10. Külső felhasználó-létrehozás (régi `POST /api/create-user`)

- [ ] A hívó azonosítása (Q-06). Új forma: M2M végpont, amely **nem** hoz létre jelszót, hanem
      `referral`/`cohort` előjegyzést tesz e-mailre (`legacy_link_candidates` mintára), a
      felhasználó pedig a skillpass-on regisztrál – az összekötés első belépéskor automatikus.

## Tesztek (funkciónként, előbb piros)

- Jogosultság: más tag adatai nem érhetők el (IDOR teszt minden `{id}`/`{handle}` végponton).
- Referral: first-touch, ismeretlen kód, alias handle, nagybetűs kód.
- Csapatfa: ciklus a meghívásokban nem okoz végtelen rekurziót.
- QR/share: nem http(s) cél → 422; külső domainre redirect nem lehetséges.
- XSS: `<script>` a kérdés címében → escape-elt megjelenítés az oldalon és az admin API-ban.
- Fizetés: aláírt callback hamisítás → 401; idempotens ismétlés → egy aktiválás.

## Kimenet

- Minden MEGTART funkció (01 / 2) működik test környezetben, menüből elérhető, auditált.

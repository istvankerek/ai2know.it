# F8 – Átállás (cutover) és a régi rendszer leállítása

> Cél: kontrollált váltás ai2know.it-re, a régi hostok követett átirányítással, majd a régi
> szerver biztonságos leállítása.
> Routing: CRITICAL. Prod lépés csak az owner „mehet" válasza után (L-03).
> Skillek: `deploy-pipeline`, `server-migration`, `caddy-gateway`, `cloudflare-cdn`,
> `maintenance-mode`, `monitoring-setup`, `runbook-generator`.

## 1. Előfeltételek (go/no-go lista)

- [ ] F0–F7 elfogadva, `implementation-notes.md` naprakész.
- [ ] Test környezet: teljes E2E zöld, redirect regresszió 100%, Lighthouse (perf/a11y/SEO ≥ 90),
      axe 0 kritikus, security scan 0 magas.
- [ ] skillpass prod kliens és (ha A út) import job jóváhagyva; aibos prod admin integráció kész.
- [ ] DNS TTL 300 s-ra csökkentve legalább 48 órával előtte.
- [ ] Rollback terv kipróbálva: DNS vissza a régi szerverre, a régi rendszer írhatóvá tétele.

## 2. Átállási forgatókönyv (runbook: `docs/runbooks/ai2know-cutover.md`)

1. Bejelentés (oldalsáv / e-mail a tagoknak az új belépésről – szöveg owner jóváhagyással, L-09).
2. Régi rendszer írásvédett mód (új regisztráció, profilmódosítás tiltva; olvasás megy).
3. Végső dump + ETL éles futás + skillpass import + egyeztető riport (F7).
4. Új rendszer prod deploy (`make deploy ENV=prod`), migráció, restart-teszt (L-08), smoke.
5. DNS: `ai2know.it` (és `www`) → új Caddy; `hu.`, `en.`, `auth.`, `t.`, egyéb régi hostok → új
   Caddy redirect blokkjai (F6).
6. Smoke prod: kritikus URL-ek, 30 mintaredirect, belépés tesztfiókkal, `/@mkik`, `/csr`.
7. Monitorozás 72 órán át (lásd 3).

## 3. Átállás utáni figyelés

- 404 arány (cél < 0,5%), redirect találatok hostonként, belépés siker/hiba arány, 5xx.
- Search Console: új `ai2know.it` property, sitemap beküldés, címváltozás jelzése ahol az eszköz engedi.
- Napi riport az első héten az aibos `redirects.stats` végpontból.

## 4. Régi rendszer leállítása

- [ ] 30 nap stabil működés után a régi alkalmazás konténerek leállítása (a redirectek az új
      Caddyben örökre maradnak).
- [ ] Végső archívum: dump, SQLite, logok, feltöltések → Hetzner S3 WORM, titkosítva.
- [ ] PII törlés a megőrzési szabály szerint (`legacy_link_candidates` lejárat, telefonszámok,
      nyers IP-k), törlési jegyzőkönyv az `implementation-notes.md`-be.
- [ ] A régi szerveren futó egyéb szolgáltatások (`live.aibootcamp.space`, ops eszközök)
      áthelyezése vagy leállítása előtte (Q-08).

## Elfogadás

- Prod-on minden régi URL a 03 szerinti státuszt és célt adja, követéssel.
- Belépés, összekötés, referral attribúció prod tesztfiókkal bizonyítva.
- Rollback nem kellett, vagy ha kellett, dokumentálva és megismételve.

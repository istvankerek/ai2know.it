# F6 – Az I. felvonás élesítése

> Routing: CRITICAL (prod). Prod csak „mehet" után (L-03). Skillek: `deploy-pipeline`,
> `caddy-gateway`, `cloudflare-cdn`, `monitoring-setup`.

## 1. Mi megy élesbe

- `ai2know.it` (és `www`) az új rendszeren: tudásbázis, kereső, interaktív modulok, könnyű belépés.
- **Részleges átirányítás a régi hostokról (P-V1-05):** a régi Caddy-ben csak a tartalmi útvonalak
  mennek 301-gyel az ai2know.it-re, követéssel:
  `/appok`, `/bovitmenyek`, `/aitools`, `/linkek`, `/videok`, `/segedanyagok`, `/promptok`,
  `/promtok`, `/szotar`, `/kedvezmenyek`, `/ai-kerdesek-es-valaszok`, `/qrcode`,
  `/ai-erettsegi-szint-felmeres`, `/csr`, jogi oldalak, közösségi oldalak, `/static/uploads/*`,
  `/sitemap.xml`, `/robots.txt`.
- **Marad a régi rendszeren a II. felvonásig:** `/belepes`, `/jelentkezes*`, `/profil`,
  `/csapatom`, `/meghivas`, `/business*`, `/affiliate`, `/@{handle}`, `/share/*`, `/support`.
  A régi oldal fejlécében a tartalmi menüpontok az ai2know.it-re mutatnak (Caddy redirect miatt
  kódmódosítás nélkül is működik).
- A `/` a régi hostokon: az ai2know.it kezdőlapjára (a régi `/` → `/belepes` helyett).
- aiagentek tools redirectek (F4/3) – az aiagentek owner-jóváhagyásával, az ai2know élesítés után.

## 2. Lépések

1. Test környezet: teljes E2E, Lighthouse, axe, security scan, redirect-regresszió (régi hostok
   tartalmi URL-jei + aiagentek tools URL-ek).
2. Prod deploy, DNS (`ai2know.it`, `www`), smoke.
3. Régi Caddy redirect-blokk bekapcsolása, smoke (30 minta URL), figyelés 72 órán át.
4. aiagentek redirectek bekapcsolása, nyomtatott URL regresszió prodon.
5. Search Console: `ai2know.it` property, sitemap; a régi tartalmi URL-ek átindexelésének figyelése.

## 3. Figyelés

Keresés: „nincs találat" arány, p95 válaszidő; Core Web Vitals (mobil, valós felhasználói mérés);
redirect találatok hostonként; 404 arány; kimenő kattintások.

## Elfogadás

A `00-overview.md` I. felvonás elfogadási feltételei prodon teljesülnek.

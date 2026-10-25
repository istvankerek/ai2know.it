# F7 – Ügyfélmigráció skillpass.id-be (II. felvonás, külön kör)

> Routing: CRITICAL (PII, migráció). Részletes adatmodell és szabályok:
> `../plan-v0/04-adatmigracio-modell.md`; végrehajtás: `../plan-v0/17-f7-adatmigracio-futtatas.md`.
> Ez a fájl csak az I. felvonás utáni eltéréseket rögzíti.

## Eltérések a v0-hoz képest

- Az I. felvonás óta a skillpass belépés már él az ai2know.it-en: aki addig új skillpass fiókot
  nyitott a régi e-mail címével, azt az összekötés (v0 04/3.2) automatikusan a régi tagjához köti
  – a kedvencei és gyűjteményei megmaradnak (`sub` alapú).
- A régi rendszer a II. felvonásig fut, ezért a végső dump a F9 átállási ablakában készül.
- Döntések, amelyek továbbra is nyitottak: P-V0-07 (jelszó-hash nélküli import), P-V0-08, P-V0-09,
  P-V0-10; Q-01 (ki építi a skillpass importot).

## Feladatok

- [ ] v0 F7 ETL (`members`, `legacy_link_candidates`, `partners`, `referral_codes`, `coupons`,
      `share_links`, `qr_codes`), dry-run, egyeztető riport.
- [ ] skillpass import próba a skillpass test példányán.
- [ ] Előzetes kommunikáció a tagoknak (szöveg owner jóváhagyással, L-09).

## Elfogadás

`../plan-v0/04-adatmigracio-modell.md` 6. fejezet.

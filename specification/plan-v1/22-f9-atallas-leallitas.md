# F9 – Teljes átállás és a régi rendszer leállítása (II. felvonás)

> Routing: CRITICAL. Részletek: `../plan-v0/18-f8-atallas-leallitas.md` és
> `../plan-v0/03-url-atiranyitas-terkep.md`.

## Eltérések a v0-hoz képest

- A tartalmi URL-ek már az F6-ban átirányítva; itt a maradék (auth, tagi, partner, `/@handle`,
  `/jelentkezes/{kód}`) és a teljes host-szintű átirányítás (`hu.`, `en.`, `auth.`, `t.` és a
  többi aldomain) kapcsol.
- Átállási ablak: régi rendszer írásvédett → végső dump → ETL + skillpass import → tagi funkciók
  élesítése → teljes redirect → figyelés → 30 nap után a régi szerver leállítása, archiválás,
  PII törlés (v0 F8/4).

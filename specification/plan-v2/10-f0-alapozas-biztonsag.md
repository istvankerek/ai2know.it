# F0 – Alapozás és a régi rendszer biztonsági javítása

> Változatlan a `../plan-v1/10-f0-alapozas-biztonsag.md` és a `../plan-v0/10-f0-alapozas.md`
> szerint, az alábbi kiegészítésekkel. Routing: STANDARD; a régi éles rendszer CRITICAL („mehet").

## Kiegészítések (v2)

- [ ] Külső egyeztetések elindítása, mert ezek hosszú átfutásúak:
  - skillpass.id: kliens (belépés, `shell:read`, `entitlements:read`), M2M `trainings:write`,
    és a „Készítette" képesség (Q-V2-01) – a skillpass repóban plan.
  - superskiller: közös integrációs contract vázlata (Q-V2-02) – a superskiller repóban plan.
  - aibos: admin integráció, a prompt-library kivezetésének ütemezése.
- [ ] Mock szerverek a contractokból (skillpass training push, superskiller partner API), hogy az
      F4–F5 a partnerek előtt is fejleszthető legyen (L-05).

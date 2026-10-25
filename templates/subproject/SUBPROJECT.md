# {{NEV}}

> Subprojekt leíró. Kötelező mezők (a `validate-project-layout.py` ellenőrzi):
> role, type, deploy, toolchain, contract.

- role: {{Mit csinál, egy mondat. Pl. közös üzleti szolgáltatások: invoice, pay, delivery}}
- type: {{nested | subtree}} ({{nested = saját .git, a szülő gitignore-olja; subtree = egy history}})
- deploy: {{külön deploy egység, pl. compose fájl, domain(ek)}}
- toolchain: {{pl. Rust 1.88 / edition 2021, Node 24}}
- contract: {{OpenAPI / séma helye, pl. contracts/openapi/}}
- owner: {{felelős}}
- remote: {{git remote URL, ha nested}}

## Kapcsolat a szülő projekttel

{{Hogyan hívja a szülő: typed client, M2M, esemény. Mi NEM közös (DB, session).}}

## Indítás

```bash
cd subprojects/{{NEV}}
{{build / run parancs}}
```

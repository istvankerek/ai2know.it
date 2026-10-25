# Ismert Minta Tipusok – Autodream Referencia

## Hiba mintak
| Minta | Jel | Javasolt megelozes |
|-------|-----|-------------------|
| Hianyzo Zod validacio | API endpoint validacio nelkul commitolva | rules/api-conventions.md kiegeszites |
| any type becsuszasa | TypeScript strict megsertese | PostToolUse hook: tsc --noEmit |
| console.log maradvany | Debug log a kodban | PreToolUse hook: grep console.log |
| Teszt nelkuli kod | Feature kesz, teszt nincs | Commit checklist megerosites |
| Hardcoded URL/secret | Nem env valtozokbol jon | check-safety.sh hook bovites |
| Import sorrend | Inkonzisztens importok | auto-lint.sh hook ESLint rule |

## Koltseg mintak
| Minta | Jel | Javasolt optimalizalas |
|-------|-----|----------------------|
| Opus overuse | $20+/nap session koltseg | Model routing szabaly megerosites |
| Mega-session | Nincs /clear feladatvaltasnal | CLAUDE.md figyelmeztetes |
| Felesleges fajl olvasas | Minden session elolvassa az egesz src/-t | Specifikusabb prompt javaslat |
| Agent Teams egyszeru feladatra | 7x token overhead | Subagent (Task) javaslat |

## Architekturalis mintak
| Minta | Jel | Javasolt ADR |
|-------|-----|-------------|
| Implicit DB sema dontes | Migration letrejott, ADR nem | ADR: "Miert igy nez ki a {tabla} schema" |
| Uj dependency | package.json/Cargo.toml modosult | ADR: "Miert {lib} es nem {alternativa}" |
| Struktura valtozas | Konyvtar atszervezes | ADR: "Miert {uj struktura}" |

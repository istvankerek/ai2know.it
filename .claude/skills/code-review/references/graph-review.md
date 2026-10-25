# Graph-alapu Review (code-review-graph MCP)

Ha a `code-review-graph` MCP szerver elerheto, a review automatikusan blast radius alapu lesz. Nem kell semmit csinalnod – a Claude Code lekerdezi a grafot a review elott, es csak az erintett fajlokat (+ fuggosegek + tesztek) olvassa el.

**Hatas:** ~6.8x kevesebb token, 8.8/10 review minoseg (vs. teljes kodbazis olvasas 7.2/10).

## MCP tool-ok

| Tool | Mire jo | Token |
|------|---------|-------|
| `get_minimal_context` | Elso hivas – teljes kep | ~100 |
| `get_impact_radius` | Blast radius egy fajlra | ~200 |
| `review_changes` | Git diff alapu review kontextus | ~500 |
| `query_graph` | `callers_of`, `dependents` lekerdezes | ~150 |
| `search_nodes` | Fuggveny/osztaly kereses | ~100 |
| `find_large_functions` | Tul hosszu fuggvenyek | ~100 |
| `detect_changes` | Risk-scored valtozas elemzes | ~300 |

## Szabaly

- **Elso hivas MINDIG:** `get_minimal_context(task="...")`
- Utana: `detail_level="minimal"` (80-150 token/hivas)
- **Cel:** ≤5 tool hivas, ≤800 token graf kontextus
- Kovesd a `next_tool_suggestions` mezot a valaszban – az MCP szerver megmondja mi a kovetkezo logikai lepes

## Telepites (fejleszto csinalja)

```bash
pipx install code-review-graph
cd /path/to/project
code-review-graph install --platform claude-code
code-review-graph build      # ~10 mp 500 fajlnal
code-review-graph watch      # hatterben, inkrementalis frissites
```

## Mikor NE hasznald

- Egyetlen fajl modositas kis projektben (overhead > megtakaritas)
- Teljes kodbazis refaktor (blast radius = teljes kodbazis)
- Uj projekt < 50 fajl (nincs ertek)

## Mikor NAGYON hasznald

- Code review (PR diff) – 6.8x kevesebb token
- Bug fix egy fajlra, sok fuggovel – blast radius megmutatja mit erint
- Refaktor modul hataron – fuggosegi lanc elemzes
- Teszt lefedettseg ellenorzes – "melyik fajlnak nincs tesztje?"

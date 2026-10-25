---
name: jupyter-notebook-editor
description: Jupyter notebook (.ipynb) szerkesztes, cell hozzaadas/futtatas, kernel allapot kezeles. AKTIVAL: DATA_ANALYST_LAYER_ENABLED=true. Triggerek: "notebook", "jupyter", ".ipynb", "cell hozzaad", "kernel restart".
license: Everengine v6.3.1
priority: P2 (opcionalis)
model: claude-sonnet-4-6
requires_env: DATA_ANALYST_LAYER_ENABLED=true
---

# Jupyter Notebook Editor (opcionalis)

## Funkcio
Jupyter `.ipynb` fajlok strukturalt szerkesztese: cell hozzaadas, kod modositas,
markdown cell-ek beszurasa, kernel restart, output torlese commit elott.

## Kovetelmeny
A skill csak akkor aktiv, ha:
```json
"DATA_ANALYST_LAYER_ENABLED": "true"
```
Plusz: `pip install -r requirements-data-analyst.txt`

## Workflow

### Cell hozzaadas
1. Read `.ipynb` (json struktura)
2. NotebookEdit tool a megfelelo szerkesztesre
3. Verify: `jupyter nbconvert --to script` sikerul

### Output torles commit elott
A `.ipynb` outputjai gyakran nagyok es zajtok. Commit elott:
```bash
jupyter nbconvert --clear-output --inplace notebook.ipynb
```

### Konvenciok
- Magyar cell magyarazat markdown-ban
- Minden chart-hez output mappa-ba write
- DB connection: env-bol, sosem hardcoded
- Imports az elso cell-ben

## Forras
- v7.0 master PART 3 Section 66
- Doc: `docs/data-analyst-layer.md`

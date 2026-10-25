---
name: auto-viz
description: Auto-vizualizacio pandas DataFrame-bol – matplotlib/plotly chart javasol az adattipus alapjan. AKTIVAL: DATA_ANALYST_LAYER_ENABLED=true. Triggerek: "vizualizald", "chart", "diagram", "plot", "viz".
license: Everengine v6.3.1
priority: P2 (opcionalis)
model: claude-sonnet-4-6
requires_env: DATA_ANALYST_LAYER_ENABLED=true
---

# Auto-Visualization (opcionalis)

## Funkcio
Pandas DataFrame analizise alapjan automatikus chart-tipus javaslat:

| DF tipus              | Auto-chart                |
|-----------------------|---------------------------|
| Time series           | line plot (plotly)        |
| Categorical x numeric | bar chart                 |
| Two numerics          | scatter plot              |
| Distribution          | histogram + KDE           |
| Categorical breakdown | pie / donut               |
| Geo data              | map (lat/lon detect)      |
| Correlation matrix    | heatmap                   |

## Kovetelmeny
```json
"DATA_ANALYST_LAYER_ENABLED": "true"
```
Plus: `pip install plotly matplotlib seaborn`

## Hasznalat (notebook context)

```python
df.shape  # (1000, 5)
df.columns  # ['date', 'product', 'revenue', 'units', 'region']

# Skill detect:
#   - 'date' → time series
#   - 'product' (categorical) + 'revenue' (numeric) → bar
#   - 'region' (geo possible) → consider map
# Javasol: plotly bar, x=product, y=sum(revenue), color=region
```

## Output
- Output mappa: `output/charts/{name}.{png,html}`
- HTML interaktiv (plotly): tooltip, zoom, kerekedes
- PNG static (matplotlib): jelentesbe ementeshez

## Forras
- v7.0 master PART 3 Section 67
- Doc: `docs/data-analyst-layer.md`

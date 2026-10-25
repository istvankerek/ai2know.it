# Data Analyst Layer (v6.3.1, opcionalis)

A Data Analyst layer Jupyter + pandas + viz + export pipeline-okat ad a skeleton-hez.
**Alapertelmezetten OFF.** Csak akkor kapcsold be, ha tenyleg kell.

---

## Mikor aktivald

✅ **Igen, kapcsold be:**
- JourneyFlow ROI elemzes (events → cohort → conversion → revenue)
- aiBOS BI dashboard adatfelokeszites
- Heti riport generalas (Excel/PDF/PPTX)
- Customer cohort retention elemzes
- Ad-hoc adatlekerdezeses elemzes (DB → notebook → output)
- A/B teszt eredmenyek statisztikai feldolgozasa

❌ **Nem, hagyd off:**
- Pure backend Rust feature (nincs adatelemzes)
- Pure frontend (UI, komponensek)
- DevOps / infrastruktura (Caddy, Docker, monitoring)
- Brand / identity / copy munka
- Egyszeru CRUD modul fejlesztes

---

## Aktivalasi lepesek

### 1. settings.json modositas
```json
{
  "env": {
    ...
    "DATA_ANALYST_LAYER_ENABLED": "true"
  }
}
```

### 2. Python deps install
```bash
pip install -r requirements-data-analyst.txt
```

### 3. Jupyter init (opcionalis)
```bash
mkdir -p notebooks/{exploratory,reports,scheduled}
jupyter notebook --notebook-dir=./notebooks
```

### 4. Verify
```bash
jq -e '.env.DATA_ANALYST_LAYER_ENABLED == "true"' .claude/settings.json
python -c "import pandas, plotly, openpyxl"
```

---

## Aktivalt skill-ek

| Skill | Funkcio | Trigger |
|-------|---------|---------|
| `jupyter-notebook-editor` | .ipynb fajlok editing, cell add/run | "notebook", "jupyter", .ipynb file |
| `auto-viz` | Pandas DataFrame → matplotlib/plotly auto chart | "vizualizald", "chart", "diagram" |
| `dataframe-checkpoint` | DF state mentes feather/parquet-be (analyst session resume) | "checkpoint", "save state", session continuity DA-ben |
| `data-export-pipeline` | DF → XLSX/PDF/PPTX (formazott riport) | "exporal", "excel", "pdf riport", "pptx" |

---

## Workflow pelda 1: Heti riport

```python
# notebooks/scheduled/weekly_revenue_report.ipynb

import pandas as pd
import plotly.express as px
from sqlalchemy import create_engine

engine = create_engine(os.environ["POSTGRES_CONN"])

# 1. Adat lekerdezes
df = pd.read_sql("""
    SELECT date, product, revenue
    FROM revenue_aggregate
    WHERE date >= NOW() - INTERVAL '7 days'
""", engine)

# 2. Auto-viz aktivalas (skill: auto-viz)
fig = px.line(df, x='date', y='revenue', color='product', title='Heti bevetel')
fig.write_image("output/weekly-revenue.png")

# 3. Export (skill: data-export-pipeline)
with pd.ExcelWriter("output/weekly-report.xlsx") as w:
    df.to_excel(w, sheet_name="Adatok", index=False)
    df.groupby("product").sum().to_excel(w, sheet_name="Osszesites")
```

Integralhato `routine`-ba: `.claude/routines/scheduled/weekly-revenue-report.yml`

---

## Workflow pelda 2: ROI elemzes (JourneyFlow)

```python
# notebooks/exploratory/journey_roi_analysis.ipynb

import pandas as pd
from datetime import datetime, timedelta

# 1. Cohort definicio
events = pd.read_sql(...)  # journey_events table
cohort = events[events['signup_date'] >= '2026-01-01']

# 2. Conversion funnel
funnel = cohort.groupby('step').agg(
    users=('user_id', 'nunique'),
    revenue=('revenue', 'sum')
)

# 3. Checkpoint (ha hosszu az analizis)
funnel.to_feather("checkpoints/funnel-2026-04.feather")  # skill: dataframe-checkpoint

# 4. ROI viz
roi = funnel['revenue'] / funnel['ad_cost']
roi.plot(kind='bar', title='ROI per step')
```

---

## Tervezett tovabbfejlesztesek (nem most)

- aios-cli integracio (nodes közötti adat-flow)
- codex/gemini multi-vendor consensus DA-feladatokra
- ML pipeline skill (sklearn + auto-feature-eng)
- Streamlit dashboard skill (data analyst feltetelt)

---

## Kapcsolat
- Skill mappak: `.claude/skills/{jupyter-notebook-editor,auto-viz,dataframe-checkpoint,data-export-pipeline}/`
- Config: `.claude/settings.json` env DATA_ANALYST_LAYER_ENABLED
- Forras: v7.0 master PART 3 Section 66-68

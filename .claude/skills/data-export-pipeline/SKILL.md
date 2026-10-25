---
name: data-export-pipeline
description: DataFrame export pipeline – Excel (XLSX), PDF, PowerPoint (PPTX) formazott riportok. AKTIVAL: DATA_ANALYST_LAYER_ENABLED=true. Triggerek: "exporal", "excel riport", "pdf jelentes", "pptx", "executive deck".
license: Everengine v6.3.1
priority: P2 (opcionalis)
model: claude-sonnet-4-6
requires_env: DATA_ANALYST_LAYER_ENABLED=true
---

# Data Export Pipeline (opcionalis)

## Funkcio
Pandas DataFrame → formazott riport: XLSX (multi-sheet), PDF (charts + tables),
PPTX (executive deck). Brand-aligned (identity/voice + brand-X.md).

## Output formatumok

### XLSX (openpyxl)
- Tobb sheet (Adatok, Osszesites, Trend, Charts)
- Conditional formatting (heatmap a numeric oszlopokra)
- Header bold + szin
- Filter auto-applied
- Print area definialt

### PDF (fpdf2 / reportlab)
- Cover page (cim, datum, generator)
- Executive summary (1 oldal)
- Detailed tables (auto-pagination)
- Embedded charts (matplotlib PNG-bol)
- Footer: page X/N, brand voice szerint

### PPTX (python-pptx)
- Title slide (brand template-bol)
- 1 KPI / slide (3-5 KPI total)
- Chart slide (1 chart + 3 bullet)
- Executive recommendation slide

## Brand alignment
A skill MINDIG beolvassa az identity-t:
- `.claude/identity/voice.md` (hangnem)
- `.claude/identity/brand-{X}.md` (logo, szinek, font)
- `.claude/identity/audience/decision-maker.md` (executive deck stilus)

## Konvenciok
- Output: `output/reports/{date}_{name}.{xlsx,pdf,pptx}`
- Cleanup: 30 nap utan auto-archive (nem torles!)
- Sensitive PII: redactalt mode (mock data placeholder a screenshot-okhoz)

## Forras
- v7.0 master PART 3 Section 68
- Doc: `docs/data-analyst-layer.md`

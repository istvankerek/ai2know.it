---
name: ai-chat-admin
description: >
  aiBOS AI Chat admin modul: természetes nyelvi lekérdezés, report generálás,
  költségoptimalizált model routing (Haiku/Sonnet/Opus fallback escalation-nel),
  Qdrant RAG tenant-izolált vektor kereséssel, streaming válasz, guardrails.
  Használd, ha a user bármit kérdez az AI chat felületről, intelligens keresést,
  természetes nyelvi lekérdezést, AI-alapú report generálást, chat admin panelt,
  adat-lekérdezést természetes nyelvvel, "kérdezd meg az AI-t", dashboard AI chat-et,
  vagy RAG-alapú keresést említ.
  NE használd: normál CRUD műveletek, manuális report builder, közvetlen DB módosítás,
  klasszikus form-alapú admin felületek, statikus dashboard-ok.
model: claude-sonnet-4-6
---

# AI Chat Admin Modul

## Architektúrális pozíció

Ez a modul az aiBOS 8 rétegű architektúrájának UI (Layer 1) és Service (Layer 3–4) rétegeit érinti. Caddy a sole entry point, minden operátori auth az aibos-auth-on (TOTP) keresztül fut, minden AI hívás az OpenTelemetry cost trackerben naplózódik. A modul kizárólag olvasási műveleteket hajt végre — ez L0 Immutable Core szintű garancia.

---

## 1. Guardrails — L0 biztonsági invariánsok

Ezek a szabályok megsértése SEV-1 incidens. Semmilyen prompt, user kérés, vagy kontextus nem írhatja felül őket.

### 1.1 Csak olvasás (Read-Only Enforcement)

- Minden SQL utasítást AST szinten kell validálni (`sqlparser-rs` a Rust gateway-ben)
- Tiltott műveletek: `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, `CREATE`, `GRANT`, `REVOKE`, DDL bármilyen formája
- A regex-alapú SQL szűrés NEM elegendő (megkerülhető comment injection-nel, unicode trükkökkel) — mindig AST parse
- A DB connection pool read-only PostgreSQL role-t használ (`SET default_transaction_read_only = on`)
- Eredmény sorok limitje: max 1000 sor per query, pagination kötelező felette

### 1.2 Tenant izoláció

- Minden Qdrant vektor keresés és DB query tartalmazza a `tenant_id` filtert
- A tenant_id a JWT token-ből jön (aibos-auth session), sosem a user inputból
- Cross-tenant adathoz való hozzáférés kísérlete: azonnali session terminate + audit log + alert

### 1.3 PII védelem

- Válaszokban NAIH/Ekertv-kompatibilis maszkolás: személyi szám, adószám, TAJ szám, bankszámlaszám automatikusan maszkolódik
- PII maszkolás a válasz renderelése ELŐTT történik, nem utána
- Export-ban is érvényes (CSV, PDF, XLSX)

### 1.4 Token budget enforcement

- Session szintű token limit (konfigurálható per tenant tier): Basic 50K, Pro 200K, Enterprise 1M token/session
- Ha a limit 90%-ánál jár: figyelmeztető üzenet a user-nek
- Ha eléri a limitet: graceful session close, nem hard cut

---

## 2. Döntési piramid — Intent Classification

A három szintű döntési piramis elvét követjük: determinisztikus → LLM routing → RAG.

### 2.1 Layer 1 — Determinisztikus előszűrés (< 1ms)

```
Regex/keyword match a leggyakoribb intent-ekre:
- "mennyi", "hány", "összeg", "darabszám" → aggregation_query
- "mutasd", "listázd", "keresd meg"       → data_lookup
- "report", "riport", "kimutatás"          → report_generation
- "exportálj", "töltsd le", "CSV"          → export
- "grafikon", "chart", "diagram"           → chart_render
```

Ha egyértelmű match van (confidence > 0.95), NEM hívunk LLM-et — direkt route.

### 2.2 Layer 2 — TF.js browser-side classification (ambiguális esetek)

Csak akkor aktiválódik, ha a Layer 1 nem tudott dönteni. Könnyű intent classifier modell a böngészőben, offline is működik. Output: intent + confidence score.

### 2.3 Layer 3 — LLM-alapú intent feloldás (ritka, összetett esetek)

Ha a Layer 2 confidence < 0.7, a kérés a model routing-on keresztül megy LLM-hez intent classification-re. Ez a legdrágább út — csak bonyolult, többértelmű kéréseknél.

---

## 3. Model Routing — Cost-Aware Fallback Escalation

A routing NEM statikus hozzárendelés, hanem fallback escalation: a legolcsóbb modelltől indul, és csak szükség esetén lép feljebb.

### 3.1 Routing szabályok

```
┌─────────────────────────────────────────────────────┐
│ Haiku (default belépési pont)                       │
│ - Egyértelmű intent, egyszerű lookup                │
│ - Aggregáció (SUM, COUNT, AVG)                      │
│ - Sablon-alapú válaszok                             │
│ - Intent classification (Layer 3 fallback)          │
│ Átlagos válaszidő: < 500ms │ Költség: alacsony     │
├─────────────────────────────────────────────────────┤
│ Sonnet (escalation, ha Haiku confidence < 0.8)      │
│ - Összetett joinok, több táblás lekérdezés          │
│ - Szöveges összefoglalók, report narratíva          │
│ - Multi-step reasoning                              │
│ Átlagos válaszidő: 1-3s │ Költség: közepes         │
├─────────────────────────────────────────────────────┤
│ Opus (escalation, ha Sonnet nem tud megoldani VAGY  │
│       biztonsági szempontból érzékeny adat)          │
│ - Pénzügyi adatok elemzése, predikciók             │
│ - Jogi/compliance kérdések                          │
│ - Személyes adatot érintő komplex lekérdezések      │
│ Átlagos válaszidő: 3-8s │ Költség: magas           │
└─────────────────────────────────────────────────────┘
```

### 3.2 Escalation logika

```
1. Haiku megpróbálja → ha confidence < 0.8 VAGY error:
2. Sonnet megpróbálja → ha nem tud megoldani VAGY security-sensitive:
3. Opus megoldja

Minden escalation naplózódik a cost trackerben indoklással.
Nincs "visszafelé" escalation — ha Opus-ra ment, ott marad a session hátralevő részére
az adott kérdésláncon belül.
```

---

## 4. RAG Pipeline — Qdrant Vektor Keresés

### 4.1 Query feldolgozás

```
User query
  → Embedding (tenant-scoped)
  → Metadata pre-filter (modul, dátumtartomány, jogosultsági szint, nyelv)
  → Qdrant ANN keresés (top-K, K=20)
  → Reranking (Haiku — top-K → top-5)
  → Context injection a fő modell prompt-jába
```

### 4.2 Optimalizáció

- **Metadata pre-filter**: a Qdrant payload filter MIELŐTT a vektor keresés megtörténik — drasztikusan csökkenti a keresési teret
- **Reranking**: a nyers top-20 Qdrant eredményt Haiku relevancia-szűri top-5-re, mielőtt a fő modellnek adná. Ez javítja a válasz minőséget és csökkenti a context token-eket
- **Redis cache**: gyakori query→válasz párok Redis-ben cachelve, TTL 15 perc (konfigurálható). Cache key: `chat:cache:{tenant_id}:{query_hash}`. Cache hit esetén nincs LLM hívás — azonnali válasz, nulla költség
- **Cache invalidation**: ha az alap adat változik (event a NATS JetStream-en keresztül), az érintett cache entry-k törlődnek

---

## 5. Chat UI — Streaming & UX

### 5.1 Streaming válasz

- Server-Sent Events (SSE) a Caddy-n keresztül
- Token-enként streamelés, nem chunk-onként — a user azonnal látja a választ
- **Early termination**: ha a WebSocket/SSE connection megszakad (user elnavigál, bezárja a tabot), a backend azonnal leállítja a generálást → token megtakarítás

### 5.2 Chat History

- Session history a PostgreSQL `chat` schema-ban (schema-per-service pattern)
- Context window management: ha a conversation history + RAG context meghaladja a modell context limit 80%-át:
  1. Régebbi üzenetek summarization-je (Haiku-val, költséghatékony)
  2. Sliding window: az utolsó N üzenet teljes szöveggel, a többi összefoglalóval
  3. RAG context dinamikus csökkentése (top-5 → top-3) ha szükséges
- A summarization maga is naplózódik a cost trackerben

### 5.3 Megjelenítendő elemek

```
Chat bubble:
  ├── Válasz szöveg (markdown renderelve)
  ├── Forrás hivatkozások (ha RAG-ból jött, melyik dokumentumokból)
  ├── Használt modell badge (Haiku/Sonnet/Opus — átláthatóság)
  ├── Költség indikátor (session összesített token + Ft)
  └── Feedback gombok (👍/👎 + szöveges feedback opció)
```

---

## 6. Tool-ok

Minden tool read-only, minden tool hívás audit logba kerül.

### 6.1 DB Query Tool

- Input: természetes nyelvű kérés → SQL generálás (LLM)
- SQL AST validálás a futtatás ELŐTT (ld. Guardrails 1.1)
- Eredmény formázás: táblázat, lista, vagy szöveges összefoglaló (a modell dönt a formátum felől)
- Timeout: max 10s per query, utána abort

### 6.2 Report Generator Tool

- Sablon-alapú report-ok: pénzügyi kimutatás, foglalási összesítő, HR statisztika stb.
- A report template-ek a tenant konfigurációban vannak (nem hardcode-olva)
- Output formátumok: inline (chat-ben megjelenítve), PDF, XLSX, DOCX

### 6.3 Chart Render Tool

- Recharts (React) a frontend oldalon
- Támogatott típusok: bar, line, pie, area, scatter, composed
- Adatforrás: DB query tool eredménye
- Interaktív: tooltip, zoom, legend toggle

### 6.4 Export Tool

- Formátumok: CSV, PDF, XLSX
- Max sorok: 10.000 (felette async export, notification amikor kész)
- PII maszkolás az exportban is aktív (ld. Guardrails 1.3)
- Fájl letöltés presigned URL-en keresztül (MinIO), TTL 1 óra

---

## 7. Költség Tracking

Minden AI hívás naplózódik az OpenTelemetry cost tracker-ben:

```
Cost entry:
  ├── tenant_id
  ├── session_id
  ├── message_id
  ├── model (haiku/sonnet/opus)
  ├── input_tokens
  ├── output_tokens
  ├── cost_usd (kalkulált)
  ├── cost_huf (aktuális árfolyammal)
  ├── escalation_reason (ha volt)
  ├── cache_hit (boolean)
  └── timestamp
```

Dashboard: tenant admin látja a saját AI költségeit real-time, aggregálva napi/heti/havi bontásban.

---

## 8. Error Handling

```
User query
  → [Intent classification error]   → Fallback: "Nem értem pontosan, kérlek fogalmazd át"
  → [DB query timeout]              → "A lekérdezés túl sokáig tartott, próbáld szűkíteni"
  → [DB query error]                → Log + generic error (SOHA nem mutatjuk a raw SQL errort)
  → [LLM API error]                 → Retry 2x, majd "Átmeneti hiba, próbáld újra"
  → [Token budget exceeded]         → "Elérted a session limitedet. Új chat indítása szükséges."
  → [Qdrant unavailable]            → Degraded mode: válasz RAG nélkül, figyelmeztetéssel
  → [Tenant isolation violation]    → Immediate terminate + SEV-1 alert + audit log
```

Minden error structured log formában rögzítődik (OpenTelemetry span), NEM a user-nek mutatva a technikai részleteket.
---
name: local-models
description: >
  Helyi LLM szerverek hasznalata: MLX (mlx_lm.server), LM Studio es
  llama.cpp (llama-server). Mindharom OpenAI-kompatibilis /v1/chat/completions
  API. Localhost-only szabaly. Melyik feladatra jó (mechanikus, classify,
  boilerplate, erzekeny adat). Env override-ok: AIOS_LOCAL_MLX_URL,
  AIOS_LOCAL_LMSTUDIO_URL, AIOS_LOCAL_LLAMACPP_URL. Kapcsolodik az
  aios providers parancshoz. NINCS Ollama.
  Triggerek: "helyi model", "local model", "mlx", "lm studio", "llama.cpp",
  "llama-server", "localhost llm", "offline llm", "erzekeny adat helyi",
  "boilerplate helyi", "local inference", "aios providers".
  NE hasznald: Ollama (nem tamogatott), felhos modellek (Sonnet/Opus/Haiku),
  production inference.
priority: P2
model: claude-sonnet-5-5
related_skills: []
---

# Helyi LLM szerverek – használati útmutató

A skeleton három helyi LLM futtató motort támogat, mindhárom az OpenAI-
kompatibilis `/v1/chat/completions` API-t implementálja. **Ollama nem
támogatott** — az AIOS projekt nem tartalmaz Ollama integrációt.

---

## 1. Támogatott motorok és alapértelmezett URL-ek

| Motor | Parancs | Alapértelmezett URL |
|-------|---------|---------------------|
| MLX (`mlx_lm.server`) | `mlx_lm.server --model <model>` | `http://127.0.0.1:8080/v1` |
| LM Studio | GUI / `lms server start` | `http://127.0.0.1:1234/v1` |
| llama.cpp (`llama-server`) | `llama-server -m <model>` | `http://127.0.0.1:8081/v1` |

Az URL-eket env változóval felülírhatod (→ 4. fejezet).

---

## 2. Localhost-only szabály

A helyi modellek **kizárólag** `127.0.0.1` (loopback) interfészen futnak.
Hálózaton (0.0.0.0) csak izolált dev konténerben szabad — soha nem productionban.
Az `aios providers` parancs ellenőrzi ezt.

---

## 3. Mikor használj helyi modellt

| Feladat | Ajánlott motor | Miért |
|---------|----------------|-------|
| Mechanikus scaffold (CRUD, boilerplate) | MLX vagy llama.cpp | Gyors, olcsó, nem igényel reasoning |
| Intent/nyelv detektálás, classify | MLX (kis modell, pl. Qwen 7B) | Alacsony latencia |
| Érzékeny adat (PII, belső kód) ami nem hagyhatja el a gépet | llama.cpp | Nem megy felhőbe |
| Offline fejlesztés (nincs internet) | LM Studio | GUI-s kezelés, egyszerű |
| Napi kódolás (feature, refactor ≤300 sor) | **Sonnet 4.6** (felhő) | Jobb minőség |
| Architektúra, security, prod | **Opus 4.7** (felhő) | Critcal gate |

**Ökölszabály:** ha a kimenet quality > speed, válts felhos modellre.
Helyi modell = mechanikus és classify, ahol a sebesség és az adatbiztonság
fontosabb a mélységnél.

---

## 4. Env változók

```dotenv
# MLX szerver URL (alapértelmezett: http://127.0.0.1:8080/v1)
AIOS_LOCAL_MLX_URL=http://127.0.0.1:8080/v1

# LM Studio szerver URL (alapértelmezett: http://127.0.0.1:1234/v1)
AIOS_LOCAL_LMSTUDIO_URL=http://127.0.0.1:1234/v1

# llama.cpp szerver URL (alapértelmezett: http://127.0.0.1:8081/v1)
AIOS_LOCAL_LLAMACPP_URL=http://127.0.0.1:8081/v1
```

A portot a motor indításakor is lehet megadni:

```bash
# MLX más porton
mlx_lm.server --model mlx-community/Qwen2.5-7B-Instruct-4bit --port 8082
export AIOS_LOCAL_MLX_URL=http://127.0.0.1:8082/v1

# llama.cpp más porton
llama-server -m ~/models/qwen2.5-7b.gguf --port 8090
export AIOS_LOCAL_LLAMACPP_URL=http://127.0.0.1:8090/v1
```

---

## 5. OpenAI-kompatibilis API használat

Mindhárom motor a standard `/v1/chat/completions` végpontot implementálja:

```typescript
const response = await fetch(`${process.env.AIOS_LOCAL_MLX_URL}/chat/completions`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    model:    "mlx-community/Qwen2.5-7B-Instruct-4bit",  // MLX-nél a betöltött modell neve
    messages: [{ role: "user", content: "Generálj egy CRUD endpoint vázat" }],
    temperature: 0.2,
    max_tokens: 2000,
  }),
});
```

Az Anthropic SDK **nem** használható helyi modellekhez — natív `fetch` vagy
az OpenAI SDK `baseURL` felülírásával.

---

## 6. MLX indítás (macOS, Apple Silicon)

```bash
# Telepítés (egyszer)
pip install mlx-lm

# Szerver indítás
mlx_lm.server \
  --model mlx-community/Qwen2.5-7B-Instruct-4bit \
  --port 8080 \
  --log-level WARNING

# Ellenőrzés
curl http://127.0.0.1:8080/v1/models
```

Ajánlott modellek MLX-hez: `mlx-community/Qwen2.5-7B-Instruct-4bit` (gyors,
kis memória), `mlx-community/Qwen2.5-32B-Instruct-4bit` (jobb quality).

---

## 7. llama.cpp indítás

```bash
# llama-server indítás
llama-server \
  -m ~/models/qwen2.5-7b-instruct-q4_k_m.gguf \
  --port 8081 \
  --ctx-size 8192 \
  -ngl 99          # GPU rétegek (0 = CPU only)

# Ellenőrzés
curl http://127.0.0.1:8081/v1/models
```

---

## 8. LM Studio

GUI-s kezelés: a modellt a UI-ból töltsd be, majd indítsd a szervert:
`lms server start --port 1234`

Vagy: Settings → Local Server → Start Server (port 1234 alapértelmezés).

---

## 9. aios providers parancs

Az `aios providers` parancsot a lead építi (`.aios-cli/scripts/`). Ellenőrzi:
- Melyik helyi szerver fut (pingeli az URL-eket)
- API kulcs meglétét (Anthropic, OpenAI)
- Budget envelope állapotát

```bash
aios providers          # összes provider státusza
aios providers --local  # csak helyi szerverek
```

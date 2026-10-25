# Uj Fejleszto Onboarding

## 1. Kornyezet beallitas

```bash
# Elofeltetelek
# - Docker Desktop
# - Node.js 20+ (nvm ajanlott)
# - Rust toolchain (rustup)
# - Claude Code CLI

# Repo klonozas
git clone {{REPO_URL}}
cd ai2know.it

# Kornyezeti valtozok
cp environments/.env.example environments/.env.local
# Toltsd ki a szukseges ertekeket!

# Docker inditas
make local

# Ellenorzes
docker compose ps
```

## 2. Projekt megertese

Olvasd el ebben a sorrendben:
1. [CLAUDE.md](../CLAUDE.md) — fo konfiguracio es szabalyok
2. [docs/architecture.md](architecture.md) — rendszer architektura
3. [docs/ECOSYSTEM.md](ECOSYSTEM.md) — okoszisztema definiciok
4. `.claude/rules/` — 7 szabaly fajl

## 3. Fontos szabalyok

- **Nyelv:** Dokumentacio magyarul, kod angolul
- **Auth:** CSAK SkillPass.ID (admin: aibos.space) — ne csinalj sajatot
- **DB:** Schema-per-service (PostgreSQL)
- **Fajlnevezes:** `{Action}{Entity}Endpoint.ts` — NE `controller.ts`
- **Tesztek:** Irj tesztet es FUTTASD LE
- **Secret:** SOHA kodban — kornyezeti valtozo

## 4. Hasznos parancsok

```bash
make local           # Dev kornyezet inditas
make test            # Tesztek futtatasa
make lint            # Kod ellenorzes
make migrate         # DB migracio
./scripts/build.sh   # Teljes build
```

## 5. Claude Code hasznalat

```bash
claude                       # Session inditas
/project:bootstrap users     # Uj modul
/project:review              # Kod review
/project:test-all            # Tesztek
/project:security-scan       # Biztonsagi scan
```

## 6. Kinek szol meg

- [Tech Leads guide](for-roles/for-tech-leads.md)
- [CTO guide](for-roles/for-cto.md)
- [Uj fejleszto guide](for-roles/for-new-developer.md)

# Modul Scaffold

Uj feature-based modul letrehozasa: $ARGUMENTS

## Letrehozando struktura

### Backend (Rust/Axum)
```
apps/backend/src/modules/$ARGUMENTS/
├── CLAUDE.md                    # Modul kontextus
├── create_$ARGUMENTS/
│   ├── endpoint.rs              # Create{Entity}Endpoint
│   ├── dto.rs                   # Create{Entity}Dto
│   └── service.rs               # Create{Entity}Service
├── get_$ARGUMENTS/
│   └── endpoint.rs              # Get{Entity}Endpoint (lista)
├── get_$ARGUMENTS_by_id/
│   └── endpoint.rs              # Get{Entity}ByIdEndpoint
├── update_$ARGUMENTS/
│   ├── endpoint.rs
│   ├── dto.rs
│   └── service.rs
└── delete_$ARGUMENTS/
    └── endpoint.rs
```

### Admin (Vite + React Router)
```
apps/admin/src/routes/$ARGUMENTS/
├── dashboard.tsx               # /:module/dashboard
├── list.tsx                    # /:module/list
├── add.tsx                     # /:module/add
└── $id/
    ├── edit.tsx                # /:module/:id/edit
    └── view.tsx                # /:module/:id/view
```

+ routes.ts-ben regisztralni a route-okat

### Konfiguracio
```
apps/admin/src/lib/crud-generator/modules/$ARGUMENTS.ts
```

### Tesztek
```
tests/unit/$ARGUMENTS/
tests/integration/$ARGUMENTS/
```

## Lepesek

1. Hozd letre a fenti konyvtarakat es fajlokat
2. Ird meg a CLAUDE.md modul kontextust
3. Generald a CRUD endpoint-okat a feature-based mintaval
4. Generald a ModuleConfig-ot az admin oldalhoz
5. Irj unit tesztet a service reteghez
6. Futtasd: `cargo test` es `npx tsc --noEmit`

---

Szanj idot minden fajl letrehozasara. Minden fajl legyen komplett, production-ready.
Ne hagyj TODO-t, placeholder-t, vagy ures fuggvenyt.

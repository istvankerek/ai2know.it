---
name: mcp-builder
description: |
  Egyedi MCP szerver fejlesztes segitse: sablon, best practices, 4-fazisu workflow.
  Triggerek: "build mcp server", "uj MCP szerver", "mcp fejlesztes",
  "create mcp tool", "custom tool server".
license: Everengine v6.5
priority: P2
model: claude-sonnet-4-6
---

# MCP Builder Skill

## Cel
Uj Model Context Protocol szerverek fejlesztesenek segetse.
Template, bevalt mintak, es a 4-fazisu workflow.

## 4-Fazisu MCP Fejlesztes

### 1. Tervezes
- Mit tegyen a szerver?
- Milyen tool-ok kellenek?
- Input/output schema
- Autentikacio sziksegos-e?

### 2. Sablon letrehozas
Kovetend strukturo:
```
mcp-{nev}/
  src/
    index.ts        # McpServer + transport
    tools/          # Eszkozonkent egy fajl
    schemas/        # Zod validacio
  package.json
  tsconfig.json
  README.md
```

### 3. Tool definicio
```typescript
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "{tool_name}",
      description: "...",
      inputSchema: { type: "object", properties: { ... } }
    }
  ]
}));
```

### 4. Teszteles es beregisztralas
```bash
# Lokalis teszteles
npx @modelcontextprotocol/inspector node dist/index.js

# Claude Code config
# .mcp.json-ba felvenni
```

## Bevalt Mintak
- Mindig Zod validacio az input-ra
- Ertelmes hibauzenet visszaadasara
- Timeout kezeles (max 30s)
- Magyar kommentek, angol kod

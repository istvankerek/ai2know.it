# Plugin Struktura

> **Verzió:** v7.4 patch Section 1.2 alapján
> **Cél:** dokumentálni mit tartalmazzon egy Claude Code plugin
> **NEM runtime engine** — ez csak strukturális sablon

## Mire való a Plugin?

A plugin **csomagolt egység** ami a Claude Code viselkedését bővíti.
Tartalma egységes manifest-tel, telepíthetően, csapatra szabhatóan.

```bash
claude plugin add --path ./my-plugin    # Lokális
claude plugin install my-plugin         # Marketplace-ről
/my-plugin:hello                        # Namespaced parancs
```

**Prioritás (utközésre):** enterprise > user > project > plugin.

## Fa struktura

```
my-plugin/
├── manifest.json           # Plugin metaadat (kötelező)
├── README.md               # Használat, telepítés
├── skills/                 # Skill-ek (opcionális)
│   ├── _catalog.csv
│   └── my-skill/
│       └── SKILL.md
├── agents/                 # Agent definíciók (opcionális)
│   └── my-agent.md
├── hooks/                  # Hook scriptek (opcionális)
│   ├── pre-tool-use/
│   │   └── my-check.sh
│   └── post-tool-use/
│       └── my-format.sh
├── commands/               # Slash command-ok (opcionális)
│   └── hello.md            # /my-plugin:hello
└── mcp/                    # MCP server config (opcionális)
    └── .mcp.json
```

## manifest.json

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Rovid leiras (1 mondat)",
  "author": "Everengine Kft.",
  "license": "Proprietary",
  "claude_code_version": ">=2.1.0",
  "components": {
    "skills": ["my-skill"],
    "agents": ["my-agent"],
    "hooks": {
      "PreToolUse": ["pre-tool-use/my-check.sh"],
      "PostToolUse": ["post-tool-use/my-format.sh"]
    },
    "commands": ["hello"]
  },
  "permissions": {
    "allow": ["Bash(my-tool *)"],
    "deny": []
  },
  "env": {
    "MY_PLUGIN_LEVEL": "info"
  }
}
```

## Konvenciok

### Naming
- Plugin nev: kebab-case (`my-awesome-plugin`)
- Slash command: namespaced (`/my-plugin:command-name`)
- Skill nev: kebab-case (`my-skill-name`)

### Versioning
- Semver (`1.0.0`)
- Breaking change → major bump
- Minden release-hez CHANGELOG entry

### Skeleton-bol kompatibilitas
- Skill katalogus: `_catalog.csv` formatum (Phase D-ben jon)
- Agent frontmatter: kotelezo `name`, `description`, `model`
- Hook script: executable bit, JSON stdin protokoll

### Permissions
- Plugin kovesi a project + user szintu deny rules-okat
- Plugin sajat allow-list-et adhat hozza, **DENY-t SOHA nem felulir**

### Distribution
- Lokalis: `claude plugin add --path ./my-plugin`
- Git repo: `claude plugin install github:user/repo`
- Marketplace: `claude plugin install my-plugin@1.0.0`

## Skeleton-spec plugin (everengine-standards)

A skeleton-bol szarmazo `everengine-standards` plugin tartalmazza:
- Top P0 skill-eket (tdd-enforcer, debug-3strike, parallel-reviewer, ...)
- 5 model-based + 5 role-based agent-et
- Identity fajlokat (anti-style, voice, brand)
- Default rules-okat (code-style, security, testing)

**Status:** jelenleg internal (NEM publikus). Marketplace publish kulon lepes.

## Hivatkozott
- v7.4 patch Section 1.2 (Plugins)
- skeleton `_catalog.csv` formatum: Phase D-ben jon
- Forras: 2025 Q4 plugin GA (Claude Code 2.1+)

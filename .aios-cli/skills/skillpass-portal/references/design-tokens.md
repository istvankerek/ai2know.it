# Design tokenek (`--sp-*`)

> Forrás: `skillpass` repo @ `24048cd` (2026-10-06)
> Autoritatív: `packages/workspace-shell/src/tokens.css`

## Világos téma (`:root`, `[data-sp-theme="light"]`)

### Felületek

| Token | Érték | Használat |
|-------|-------|-----------|
| `--sp-bg-canvas` | `#fbf7f1` | Tartalom háttér (krém, egyszínű — 0.1.6 óta nincs minta) |
| `--sp-bg-surface` | `#ffffff` | Topbar, sidebar, kártyák |
| `--sp-bg-subtle` | `#f7f5f1` | Kiemelt területek |
| `--sp-border` | `#e8e4dd` | Kártya / sáv szegély |
| `--sp-border-strong` | `#d8d2c8` | Erős szegély |

### Szöveg

| Token | Érték |
|-------|-------|
| `--sp-text` | `#1b2340` |
| `--sp-text-muted` | `#6b7280` |
| `--sp-text-inverse` | `#ffffff` |

### Brand és accent

| Token | Érték | Leírás |
|-------|-------|--------|
| `--sp-brand` | `#1d6fe0` | SkillPass kék (logó, aktív nav) |
| `--sp-brand-strong` | `#1558b5` | Hover állapot |
| `--sp-brand-soft` | `#eaf2fd` | Aktív nav háttér |
| `--sp-accent` | `#1d6fe0` | Felülírja a manifest `accent` értéke |
| `--sp-accent-soft` | `rgba(29,111,224,0.1)` | Ikon háttér stat-kártyán |
| `--sp-accent-contrast` | `#ffffff` | Szöveg accent háttéren |

### Státusz

| Token | Érték |
|-------|-------|
| `--sp-success` | `#22a06b` |
| `--sp-success-soft` | `#e6f6ef` |
| `--sp-warning` | `#d97706` |
| `--sp-danger` | `#dc2626` |

### Identity ring

```css
--sp-ring: conic-gradient(
  from 210deg,
  #1d6fe0, #22a06b, #f5c518, #f0731d, #e2464a, #8b5cf6, #1d6fe0
);
--sp-ring-width: 3px;
--sp-ring-gap: 2px;
--sp-ring-gap-color: #ffffff;
```

### Méretek

| Token | Érték |
|-------|-------|
| `--sp-topbar-h` | `68px` |
| `--sp-sidebar-w` | `244px` |
| `--sp-rail-w` | `300px` |
| `--sp-drawer-w` | `396px` |
| `--sp-switcher-w` | `400px` |
| `--sp-gap` | `24px` |
| `--sp-radius` | `12px` |
| `--sp-radius-sm` | `8px` |
| `--sp-radius-pill` | `999px` |
| `--sp-shadow-card` | `0 1px 2px rgba(27,35,64,.06)` |
| `--sp-shadow-pop` | `0 18px 44px rgba(27,35,64,.16)` |

### Tipográfia

```css
--sp-font-sans: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
--sp-font-size: 14px;
--sp-line-height: 1.45;
```

Külső font betöltése TILOS (CSP `'self'`). A skillpass.id Geist fontot ad
át a `--sp-font-sans` tokenbe — partner-portálon a rendszer-fontkészlet az
alapértelmezés.

## Sötét téma (`[data-sp-theme="dark"]`)

| Token | Sötét érték |
|-------|-------------|
| `--sp-bg-canvas` | `#12151f` |
| `--sp-bg-surface` | `#1a1e2b` |
| `--sp-bg-subtle` | `#222739` |
| `--sp-border` | `#2a2f3f` |
| `--sp-border-strong` | `#3a4156` |
| `--sp-text` | `#eef1f7` |
| `--sp-text-muted` | `#9aa3b8` |
| `--sp-text-inverse` | `#12151f` |
| `--sp-brand` | `#5b9bf0` |
| `--sp-brand-strong` | `#7db0f5` |
| `--sp-brand-soft` | `rgba(91,155,240,.16)` |
| `--sp-accent` | `#5b9bf0` |
| `--sp-success` | `#3cc78c` |
| `--sp-warning` | `#f0a33c` |
| `--sp-danger` | `#f16b6b` |
| `--sp-ring-gap-color` | `#1a1e2b` |

## Felülírás

A partner saját CSS-ben bármely tokent felülírhatja. Saját tokeneket ne a
`--sp-` névtérbe írj:

```css
:root {
  /* Felülírjuk a portál saját narancssárga accentjét */
  --sp-accent: #F0731D;
  --sp-accent-soft: rgba(240, 115, 29, 0.1);
  --sp-accent-contrast: #ffffff;
}
```

## Elavult exportok (0.1.6 óta @deprecated)

A `HEX_PATTERN_LIGHT`, `HEX_PATTERN_DARK` és `hexPatternDataUri` exportok
megmaradnak visszafelé kompatibilitás miatt, de a shell nem használja őket.
A következő főverzióban megszűnnek.

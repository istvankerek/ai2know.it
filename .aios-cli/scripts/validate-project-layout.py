#!/usr/bin/env python3
"""Projekt-szerkezet validator – plan-v16 F2 (egy projekt = egy mappa).

Szabalyok:
  - git worktree csak a projekten belul: `worktrees/<slug>/` vagy `.claude/worktrees/agent-*`
  - `worktrees/` es a beagyazott subprojektek gitignore-olva
  - `subprojects.toml` <-> `subprojects/<nev>/` 1:1, mindegyikben SUBPROJECT.md kotelezo mezokkel
  - figyelmeztetes: >3 agent-worktree (lezaratlan automatizalt worktree-k)

Hasznalat: validate-project-layout.py [projekt-gyoker]   (exit 0 OK, 1 hiba)
"""

from __future__ import annotations

import pathlib
import subprocess
import sys
import tomllib

REQUIRED_FIELDS = ("role", "type", "deploy", "toolchain", "contract")
RESERVED_DIRS = {"_archive"}
AGENT_WARN_THRESHOLD = 3


def _gitignore_lines(root: pathlib.Path) -> list[str]:
    gi = root / ".gitignore"
    if not gi.exists():
        return []
    return [l.strip() for l in gi.read_text(encoding="utf-8").splitlines() if l.strip() and not l.startswith("#")]


def _ignored(lines: list[str], *candidates: str) -> bool:
    return any(c in lines for c in candidates)


def _worktrees(root: pathlib.Path) -> list[pathlib.Path]:
    r = subprocess.run(["git", "-C", str(root), "worktree", "list", "--porcelain"], capture_output=True, text=True)
    if r.returncode != 0:
        return []
    paths = [pathlib.Path(l[len("worktree "):]) for l in r.stdout.splitlines() if l.startswith("worktree ")]
    return paths[1:]  # az elso a fo munkakonyvtar


def _md_fields(md: pathlib.Path) -> set[str]:
    fields = set()
    for line in md.read_text(encoding="utf-8").splitlines():
        s = line.strip()
        if s.startswith("- ") and ":" in s:
            fields.add(s[2:].split(":", 1)[0].strip().lower())
    return fields


def validate(root: pathlib.Path) -> list[str]:
    root = root.resolve()
    errors: list[str] = []
    gi = _gitignore_lines(root)

    # --- worktree-k ---
    allowed = (root / "worktrees", root / ".claude" / "worktrees")
    for wt in _worktrees(root):
        try:
            wt_res = wt.resolve()
        except OSError:
            wt_res = wt
        if not any(str(wt_res).startswith(str(a.resolve()) + "/") for a in allowed):
            errors.append(f"worktree a projekten kivul: {wt} (helye: worktrees/<slug>/)")
    if (root / "worktrees").is_dir() and not _ignored(gi, "worktrees/", "/worktrees/", "worktrees"):
        errors.append("worktrees/ mappa van, de nincs a .gitignore-ban")

    # --- subprojektek ---
    toml_path = root / "subprojects.toml"
    declared: dict[str, dict] = {}
    if toml_path.exists():
        try:
            declared = tomllib.loads(toml_path.read_text(encoding="utf-8")).get("subprojects", {})
        except tomllib.TOMLDecodeError as exc:
            errors.append(f"subprojects.toml hibas: {exc}")
    sub_dir = root / "subprojects"
    present = {p.name for p in sub_dir.iterdir() if p.is_dir() and p.name not in RESERVED_DIRS} if sub_dir.is_dir() else set()

    for name, cfg in declared.items():
        path = root / cfg.get("path", f"subprojects/{name}")
        if not path.is_dir():
            errors.append(f"subprojekt '{name}': mappa nem letezik: {path.relative_to(root)}")
            continue
        md = path / "SUBPROJECT.md"
        if not md.exists():
            errors.append(f"subprojekt '{name}': hianyzik SUBPROJECT.md")
        else:
            missing = [f for f in REQUIRED_FIELDS if f not in _md_fields(md)]
            if missing:
                errors.append(f"subprojekt '{name}': SUBPROJECT.md hianyzo mezok: {', '.join(missing)}")
        if cfg.get("type") == "nested":
            rel = str(path.relative_to(root))
            if not _ignored(gi, "subprojects/*/", f"{rel}/", f"/{rel}/", rel):
                errors.append(f"subprojekt '{name}': beagyazott repo, de nincs a .gitignore-ban ({rel}/)")
        if cfg.get("type") not in ("nested", "subtree"):
            errors.append(f"subprojekt '{name}': type csak nested|subtree lehet")
    for name in sorted(present - {pathlib.Path(c.get("path", f"subprojects/{n}")).name for n, c in declared.items()}):
        errors.append(f"subprojects/{name}: mappa van, de nincs a subprojects.toml-ban")
    return errors


def warnings(root: pathlib.Path) -> list[str]:
    root = root.resolve()
    agents = [wt for wt in _worktrees(root) if ".claude/worktrees/agent-" in str(wt)]
    if len(agents) > AGENT_WARN_THRESHOLD:
        return [f"{len(agents)} agent-worktree all lezaratlanul (.claude/worktrees/agent-*) – scripts/close-worktree.sh --stale"]
    return []


def main(argv: list[str]) -> int:
    root = pathlib.Path(argv[1]) if len(argv) > 1 else pathlib.Path.cwd()
    errs = validate(root)
    for w in warnings(root):
        print(f"FIGYELEM: {w}")
    for e in errs:
        print(f"HIBA: {e}", file=sys.stderr)
    if not errs:
        print(f"Projekt-szerkezet OK: {root.name}")
    return 1 if errs else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

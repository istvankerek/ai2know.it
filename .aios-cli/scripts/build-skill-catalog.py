#!/usr/bin/env python3
"""Skill katalogus (menufa) validalas es generalas – plan-v15 F3.

A katalogus a SkillPass.ID workspace shell hierarchiajat koveti:
app (AppManifest) -> szekcio (NavSection) -> skill (NavItem).

Hasznalat:
  build-skill-catalog.py --check            # minden skill pontosan egyszer szerepel?
  build-skill-catalog.py --write            # .aios-cli/skills/CATALOG.md generalasa
  build-skill-catalog.py --for-path <fajl>  # melyik app skilljei relevansak (skill-router hook)
  build-skill-catalog.py --index            # tomor, app szerint csoportositott index (CLI konfigokba)
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import pathlib
import sys
from collections import Counter

AIOS_CLI = pathlib.Path(__file__).resolve().parents[1]
SKILLS_DIR = AIOS_CLI / "skills"
MANIFEST = SKILLS_DIR / "catalog.manifest.json"
CATALOG_MD = SKILLS_DIR / "CATALOG.md"
REQUIRED_APP_FIELDS = ("app_id", "name", "icon", "nav")


def item_id(item: object) -> str:
    if isinstance(item, str):
        return item
    if isinstance(item, dict) and isinstance(item.get("id"), str):
        return item["id"]
    return ""


def iter_items(manifest: dict):
    for app in manifest.get("apps", []):
        for section in app.get("nav", []):
            for item in section.get("items", []):
                yield app.get("app_id", "?"), section, item


def validate(manifest: dict, skill_names: set[str]) -> list[str]:
    """Hibalista; ures lista = ervenyes katalogus."""
    errors: list[str] = []
    if manifest.get("version") != 1:
        errors.append("version: csak 1 tamogatott")

    app_ids = Counter()
    for idx, app in enumerate(manifest.get("apps", [])):
        for field in REQUIRED_APP_FIELDS:
            if field not in app:
                errors.append(f"apps[{idx}]: hianyzo mezo '{field}'")
        name = app.get("name")
        if "name" in app and not (isinstance(name, dict) and name.get("hu") and name.get("en")):
            errors.append(f"apps[{idx}]: name {{hu,en}} kotelezo")
        app_ids[app.get("app_id")] += 1
        for s_idx, section in enumerate(app.get("nav", [])):
            if not section.get("items"):
                errors.append(f"{app.get('app_id')}: nav[{s_idx}] ures szekcio")
    for app_id, count in app_ids.items():
        if count > 1:
            errors.append(f"app_id duplikalt: {app_id}")

    seen = Counter()
    for app_id, _section, item in iter_items(manifest):
        sid = item_id(item)
        if not sid:
            errors.append(f"{app_id}: ervenytelen item: {item!r}")
            continue
        seen[sid] += 1
        if sid not in skill_names:
            errors.append(f"{app_id}: ismeretlen skill a katalogusban: {sid}")
    for sid, count in seen.items():
        if count > 1:
            errors.append(f"skill tobbszor szerepel: {sid} ({count}x)")
    for sid in sorted(skill_names - set(seen)):
        errors.append(f"skill nincs a katalogusban: {sid}")
    return errors


def skills_for_path(manifest: dict, path: str) -> tuple[str | None, list[str]]:
    """Elso app, amelynek path mintaja illeszkedik; a sorrend a manifest sorrendje."""
    candidates = [path, "./" + path, "/" + path]
    for app in manifest.get("apps", []):
        for pattern in app.get("paths", []):
            if any(fnmatch.fnmatch(c, pattern) for c in candidates):
                skills = [item_id(i) for s in app.get("nav", []) for i in s.get("items", [])]
                return app["app_id"], skills
    return None, []


def skill_descriptions() -> dict[str, str]:
    out: dict[str, str] = {}
    for skill_md in sorted(SKILLS_DIR.glob("*/SKILL.md")):
        name = skill_md.parent.name
        desc = ""
        lines = skill_md.read_text(encoding="utf-8").splitlines()
        if lines and lines[0] == "---":
            capture = False
            for line in lines[1:]:
                if line == "---":
                    break
                if line.startswith("description:"):
                    rest = line.split(":", 1)[1].strip().lstrip(">|").strip()
                    if rest:
                        desc = rest
                        break
                    capture = True
                    continue
                if capture:
                    if line[:1] not in (" ", "\t"):
                        break
                    desc = (desc + " " + line.strip()).strip()
        first_sentence = desc.split(". ")[0].split(" Triggerek")[0].strip()
        out[name] = first_sentence[:160]
    return out


def render_markdown(manifest: dict, descriptions: dict[str, str]) -> str:
    lines = [
        "# AIOS Skill Katalógus",
        "",
        "> Generált fájl: `.aios-cli/scripts/build-skill-catalog.py --write`. Kézzel ne szerkeszd.",
        "> Forrás: `catalog.manifest.json` (SkillPass.ID menüstruktúra: app → szekció → skill).",
        "",
    ]
    for app in manifest.get("apps", []):
        lines.append(f"## {app['name']['hu']} · `{app['app_id']}`")
        lines.append("")
        if app.get("paths"):
            lines.append("Fájl minták: " + ", ".join(f"`{p}`" for p in app["paths"]))
            lines.append("")
        for section in app.get("nav", []):
            lines.append(f"### {section['label']['hu']}")
            lines.append("")
            for item in section.get("items", []):
                sid = item_id(item)
                badge = f" **{item['badge']}**" if isinstance(item, dict) and item.get("badge") else ""
                desc = descriptions.get(sid, "")
                lines.append(f"- `{sid}`{badge} – {desc}" if desc else f"- `{sid}`{badge}")
            lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def render_index(manifest: dict, descriptions: dict[str, str]) -> str:
    """Tomor index a generalt CLAUDE.md / AGENTS.md / GEMINI.md szamara."""
    lines = []
    for app in manifest.get("apps", []):
        lines.append(f"#### {app['name']['hu']} (`{app['app_id']}`)")
        lines.append("")
        for section in app.get("nav", []):
            for item in section.get("items", []):
                sid = item_id(item)
                lines.append(f"- `{sid}` — {descriptions.get(sid, '')}".rstrip(" —"))
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--manifest", type=pathlib.Path, default=MANIFEST)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--for-path")
    parser.add_argument("--index", action="store_true")
    args = parser.parse_args(argv)

    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))

    if args.for_path:
        app_id, skills = skills_for_path(manifest, args.for_path)
        if app_id:
            print(f"{app_id}: {', '.join(skills)}")
        return 0

    skill_names = {p.parent.name for p in SKILLS_DIR.glob("*/SKILL.md")}
    errors = validate(manifest, skill_names)
    if errors:
        for e in errors:
            print(f"HIBA: {e}", file=sys.stderr)
        return 1

    if args.index:
        sys.stdout.write(render_index(manifest, skill_descriptions()))
        return 0
    if args.write:
        content = render_markdown(manifest, skill_descriptions())
        CATALOG_MD.write_text(content, encoding="utf-8")
        print(f"Kesz: {CATALOG_MD.relative_to(AIOS_CLI.parent)}")
    if args.check or not args.write:
        print(f"Skill katalogus OK: {len(skill_names)} skill, {len(manifest['apps'])} app")
    return 0


if __name__ == "__main__":
    sys.exit(main())

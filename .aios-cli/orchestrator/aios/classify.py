"""Feladat osztalyozas: tier + adatosztaly, determinisztikus kulcsszo/fajl szabalyokkal."""

from __future__ import annotations

import fnmatch
import pathlib
import re
import unicodedata
from dataclasses import dataclass, field

from .policy import Policy

_NON_WORD = re.compile(r"[^a-z0-9\-.]+")


def normalize(text: str) -> str:
    """Ekezet nelkuli, kisbetus, szokozzel hatarolt szoveg (szo-eleji illeszteshez)."""
    folded = unicodedata.normalize("NFKD", text)
    folded = "".join(ch for ch in folded if not unicodedata.combining(ch)).lower()
    return " " + _NON_WORD.sub(" ", folded).strip() + " "


def _match(padded: str, keyword: str) -> bool:
    return (" " + keyword) in padded


@dataclass
class Classification:
    tier: str
    data_class: str
    reasons: list[str] = field(default_factory=list)


def _files_size(files: list[str]) -> int:
    total = 0
    for f in files:
        p = pathlib.Path(f)
        if p.is_file():
            total += p.stat().st_size
        elif p.is_dir():
            total += sum(x.stat().st_size for x in p.rglob("*") if x.is_file())
    return total


def _sensitive_file(path: str, patterns: tuple[str, ...]) -> str | None:
    p = pathlib.PurePath(path)
    for pat in patterns:
        if fnmatch.fnmatch(p.name, pat) or fnmatch.fnmatch(str(p), pat) or fnmatch.fnmatch(str(p), "*/" + pat):
            return pat
    return None


def classify(task: str, files: list[str] | None = None, *, policy: Policy) -> Classification:
    """Feladat besorolasa. Elso illeszkedo szabaly nyer; a fajlmeret felulirhat nagy kontextusra."""
    files = files or []
    padded = normalize(task)
    reasons: list[str] = []

    tier = policy.default_tier
    for rule in policy.rules:
        hit = next((k for k in rule.keywords if _match(padded, k)), None)
        if hit:
            tier = rule.tier
            reasons.append(f"tier={tier}: kulcsszo '{hit.strip()}'")
            break
    else:
        reasons.append(f"tier={tier}: alapertelmezett (nincs illeszkedo szabaly)")

    size = _files_size(files)
    if size > policy.large_context_bytes and tier not in {"CRITICAL", "CONSENSUS"}:
        reasons.append(f"tier=LARGE_CONTEXT: fajlok merete {size} byte > {policy.large_context_bytes}")
        tier = "LARGE_CONTEXT"

    data_class = policy.default_data_class
    sens_kw = next((k for k in policy.data_class_keywords.get("sensitive", ()) if _match(padded, k)), None)
    sens_file = next(
        (f for f in files if _sensitive_file(f, policy.data_class_files.get("sensitive", ()))), None
    )
    if sens_kw or sens_file:
        data_class = "sensitive"
        why = f"kulcsszo '{sens_kw.strip()}'" if sens_kw else f"fajl '{sens_file}'"
        reasons.append(f"adatosztaly=sensitive: {why}")
    elif any(_match(padded, k) for k in policy.data_class_keywords.get("public", ())):
        data_class = "public"
        reasons.append("adatosztaly=public: publikus tartalom")

    return Classification(tier=tier, data_class=data_class, reasons=reasons)

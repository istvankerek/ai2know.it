"""Routing policy betoltes es validacio (routing-policy.toml)."""

from __future__ import annotations

import os
import pathlib
import tomllib
from dataclasses import dataclass, field
from typing import Mapping
from urllib.parse import urlparse

POLICY_PATH = pathlib.Path(__file__).resolve().parents[1] / "policy" / "routing-policy.toml"
DATA_CLASSES = ("public", "internal", "sensitive")
LOCALHOST_NAMES = {"127.0.0.1", "localhost", "::1"}


class PolicyError(ValueError):
    """Ervenytelen vagy nem biztonsagos policy."""


@dataclass(frozen=True)
class Variant:
    model: str
    effort: str
    profile: str = ""


@dataclass(frozen=True)
class Provider:
    name: str
    kind: str
    data_classes: tuple[str, ...]
    timeout_s: int
    variants: Mapping[str, Variant]
    binary: str = ""
    url: str = ""


@dataclass(frozen=True)
class Tier:
    name: str
    description: str
    chain: tuple[tuple[str, str], ...]
    requires_confirm: bool = False
    parallel: bool = False


@dataclass(frozen=True)
class Rule:
    tier: str
    keywords: tuple[str, ...]


@dataclass(frozen=True)
class Policy:
    default_tier: str
    default_data_class: str
    large_context_bytes: int
    breaker_failures: int
    breaker_cooldown_s: int
    providers: Mapping[str, Provider]
    tiers: Mapping[str, Tier]
    rules: tuple[Rule, ...]
    data_class_keywords: Mapping[str, tuple[str, ...]] = field(default_factory=dict)
    data_class_files: Mapping[str, tuple[str, ...]] = field(default_factory=dict)


def _env_model_key(provider: str, variant: str) -> str:
    return f"AIOS_MODEL_{provider.upper()}_{variant.upper()}"


def _parse_chain(raw: list[str], tier: str) -> tuple[tuple[str, str], ...]:
    steps = []
    for item in raw:
        if ":" not in item:
            raise PolicyError(f"{tier}: lanc elem formatuma provider:variant, kapott: {item!r}")
        provider, variant = item.split(":", 1)
        steps.append((provider, variant))
    return tuple(steps)


def load_policy(path: pathlib.Path = POLICY_PATH, env: Mapping[str, str] | None = None) -> Policy:
    """Betolti es validalja a policy-t; env feluliras: modellek es helyi URL-ek."""
    env = os.environ if env is None else env
    data = tomllib.loads(path.read_text(encoding="utf-8"))

    providers: dict[str, Provider] = {}
    for name, raw in data["providers"].items():
        variants = {}
        for vname, v in raw.get("variants", {}).items():
            model = env.get(_env_model_key(name, vname), v["model"])
            variants[vname] = Variant(model=model, effort=v.get("effort", ""), profile=v.get("profile", ""))
        url = raw.get("url", "")
        if raw.get("url_env"):
            url = env.get(raw["url_env"], url)
        providers[name] = Provider(
            name=name,
            kind=raw["kind"],
            data_classes=tuple(raw["data_classes"]),
            timeout_s=int(raw.get("timeout_s", 600)),
            variants=variants,
            binary=raw.get("binary", ""),
            url=url,
        )

    tiers = {
        name: Tier(
            name=name,
            description=raw.get("description", ""),
            chain=_parse_chain(raw["chain"], name),
            requires_confirm=bool(raw.get("requires_confirm", False)),
            parallel=bool(raw.get("parallel", False)),
        )
        for name, raw in data["tiers"].items()
    }

    rules = tuple(Rule(tier=r["tier"], keywords=tuple(r["keywords"])) for r in data.get("rules", []))
    dc = data.get("data_classes", {})
    policy = Policy(
        default_tier=data["default_tier"],
        default_data_class=data["default_data_class"],
        large_context_bytes=int(data["large_context_bytes"]),
        breaker_failures=int(data["breaker"]["failures"]),
        breaker_cooldown_s=int(data["breaker"]["cooldown_s"]),
        providers=providers,
        tiers=tiers,
        rules=rules,
        data_class_keywords={k: tuple(v.get("keywords", [])) for k, v in dc.items()},
        data_class_files={k: tuple(v.get("file_patterns", [])) for k, v in dc.items()},
    )
    validate_policy(policy)
    return policy


def validate_policy(policy: Policy) -> None:
    """Strukturalis es biztonsagi invariansok ellenorzese."""
    if policy.default_tier not in policy.tiers:
        raise PolicyError(f"default_tier ismeretlen: {policy.default_tier}")
    if policy.default_data_class not in DATA_CLASSES:
        raise PolicyError(f"default_data_class ismeretlen: {policy.default_data_class}")

    for p in policy.providers.values():
        unknown = set(p.data_classes) - set(DATA_CLASSES)
        if unknown:
            raise PolicyError(f"{p.name}: ismeretlen adatosztaly: {sorted(unknown)}")
        if p.kind == "local":
            host = urlparse(p.url).hostname or ""
            if host not in LOCALHOST_NAMES:
                raise PolicyError(f"{p.name}: helyi modell csak localhoston futhat, kapott: {p.url}")
        elif p.kind == "cli":
            if not p.binary:
                raise PolicyError(f"{p.name}: cli providerhez binary kell")
        else:
            raise PolicyError(f"{p.name}: ismeretlen kind: {p.kind}")

    for t in policy.tiers.values():
        if not t.chain:
            raise PolicyError(f"{t.name}: ures lanc")
        for provider, variant in t.chain:
            if provider not in policy.providers:
                raise PolicyError(f"{t.name}: ismeretlen provider: {provider}")
            if variant not in policy.providers[provider].variants:
                raise PolicyError(f"{t.name}: ismeretlen variant: {provider}:{variant}")
        if not any("sensitive" in policy.providers[p].data_classes for p, _ in t.chain):
            # Erzekeny adatnal is legyen legalabb egy engedett lepes, kulonben a router ures lancot adna.
            raise PolicyError(f"{t.name}: nincs sensitive adatot fogado provider a lancban")

    for r in policy.rules:
        if r.tier not in policy.tiers:
            raise PolicyError(f"szabaly ismeretlen tier-re mutat: {r.tier}")

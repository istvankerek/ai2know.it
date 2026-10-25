"""Routing dontes: osztalyozas -> tier lanc -> adatvedelmi szures."""

from __future__ import annotations

from dataclasses import asdict, dataclass, field

from .classify import classify
from .policy import Policy


@dataclass(frozen=True)
class Step:
    provider: str
    variant: str
    model: str
    effort: str
    profile: str = ""


@dataclass
class Decision:
    task_tier: str
    tier: str
    data_class: str
    requires_confirm: bool
    parallel: bool
    chain: list[Step]
    excluded: list[str] = field(default_factory=list)
    reasons: list[str] = field(default_factory=list)

    def to_dict(self) -> dict[str, object]:
        return asdict(self)


def route(task: str, files: list[str] | None = None, *, policy: Policy, tier: str | None = None) -> Decision:
    """Determinisztikus dontes; nem indit semmit es nem ellenoriz elerhetoseget."""
    c = classify(task, files, policy=policy)
    reasons = list(c.reasons)
    chosen = c.tier
    if tier:
        if tier not in policy.tiers:
            raise ValueError(f"ismeretlen tier: {tier}")
        reasons.append(f"tier={tier}: kezi feluliras (eredeti: {c.tier})")
        chosen = tier
    t = policy.tiers[chosen]

    chain: list[Step] = []
    excluded: list[str] = []
    for provider_name, variant_name in t.chain:
        provider = policy.providers[provider_name]
        if c.data_class not in provider.data_classes:
            excluded.append(f"{provider_name}:{variant_name}")
            continue
        v = provider.variants[variant_name]
        chain.append(Step(provider_name, variant_name, v.model, v.effort, v.profile))

    if excluded:
        reasons.append(f"adatvedelem: kizarva {', '.join(excluded)} ({c.data_class} adat)")

    return Decision(
        task_tier=c.tier,
        tier=chosen,
        data_class=c.data_class,
        requires_confirm=t.requires_confirm,
        parallel=t.parallel,
        chain=chain,
        excluded=excluded,
        reasons=reasons,
    )

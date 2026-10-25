"""Provider elerhetoseg: telepitett CLI-k es helyi OpenAI-kompatibilis szerverek."""

from __future__ import annotations

import json
import shutil
import urllib.error
import urllib.request
from dataclasses import dataclass

from .policy import Policy, Provider

PROBE_TIMEOUT_S = 1.5


@dataclass
class Health:
    provider: str
    kind: str
    available: bool
    detail: str


def probe(provider: Provider) -> Health:
    if provider.kind == "cli":
        path = shutil.which(provider.binary)
        return Health(provider.name, "cli", bool(path), path or f"'{provider.binary}' nincs a PATH-ban")
    try:
        with urllib.request.urlopen(provider.url.rstrip("/") + "/models", timeout=PROBE_TIMEOUT_S) as resp:
            body = json.loads(resp.read().decode("utf-8") or "{}")
        models = [m.get("id", "?") for m in body.get("data", [])]
        return Health(provider.name, "local", True, f"{provider.url} modellek: {', '.join(models) or '-'}")
    except (urllib.error.URLError, TimeoutError, ConnectionError, ValueError) as exc:
        return Health(provider.name, "local", False, f"{provider.url} nem erheto el ({exc.__class__.__name__})")


def probe_all(policy: Policy) -> list[Health]:
    return [probe(p) for p in policy.providers.values()]

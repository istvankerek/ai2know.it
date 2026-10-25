"""JSONL napló: csak metaadat + prompt hash, a prompt szövege soha nem kerül bele."""

from __future__ import annotations

import hashlib
import json
import os
import pathlib
import time
from collections import defaultdict

DEFAULT_DIR = pathlib.Path(__file__).resolve().parents[1] / ".ledger"


def ledger_dir() -> pathlib.Path:
    return pathlib.Path(os.environ.get("AIOS_LEDGER_DIR", str(DEFAULT_DIR)))


class Ledger:
    def __init__(self, directory: pathlib.Path | None = None) -> None:
        self.dir = directory or ledger_dir()
        self.path = self.dir / "ledger.jsonl"

    def append(self, *, tier: str, provider: str, variant: str, data_class: str, exit_code: int,
               duration_s: float, prompt: str, fallback_from: str = "", ts: float | None = None) -> None:
        self.dir.mkdir(parents=True, exist_ok=True)
        entry = {
            "ts": ts if ts is not None else time.time(),
            "tier": tier,
            "provider": provider,
            "variant": variant,
            "data_class": data_class,
            "exit_code": exit_code,
            "duration_s": round(duration_s, 3),
            "prompt_sha256": hashlib.sha256(prompt.encode("utf-8")).hexdigest()[:16],
            "fallback_from": fallback_from,
        }
        with self.path.open("a", encoding="utf-8") as fh:
            fh.write(json.dumps(entry, ensure_ascii=False) + "\n")

    def entries(self, since_ts: float = 0.0) -> list[dict[str, object]]:
        if not self.path.exists():
            return []
        out = []
        for line in self.path.read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            e = json.loads(line)
            if float(e.get("ts", 0)) >= since_ts:
                out.append(e)
        return out

    def is_open(self, provider: str, failures: int, cooldown_s: int) -> bool:
        """Circuit breaker: az utolso N bejegyzes hibas es a cooldownon belul van."""
        recent = [e for e in self.entries(time.time() - cooldown_s) if e["provider"] == provider]
        tail = recent[-failures:]
        return len(tail) >= failures and all(int(e["exit_code"]) != 0 for e in tail)

    def summary(self, since_ts: float) -> dict[str, dict[str, float]]:
        agg: dict[str, dict[str, float]] = defaultdict(lambda: {"runs": 0, "failures": 0, "duration_s": 0.0})
        for e in self.entries(since_ts):
            key = f"{e['tier']} / {e['provider']}"
            agg[key]["runs"] += 1
            agg[key]["failures"] += int(int(e["exit_code"]) != 0)
            agg[key]["duration_s"] += float(e["duration_s"])
        return dict(agg)

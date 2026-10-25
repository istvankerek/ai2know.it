"""Vegrehajtas: lanc menti fallback, timeout, circuit breaker, naplozas."""

from __future__ import annotations

import json
import subprocess
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from typing import Callable

from .ledger import Ledger
from .policy import Policy
from .providers import probe
from .route import Decision, Step

EXIT_TIMEOUT = 124


@dataclass
class DispatchResult:
    step: Step | None
    exit_code: int
    output: str


Runner = Callable[[Step, str, int], DispatchResult]


def build_command(step: Step, prompt: str, policy: Policy) -> list[str]:
    """CLI parancs osszeallitasa (nem fut le). Csak dokumentalt, stabil kapcsolok."""
    binary = policy.providers[step.provider].binary
    if step.provider == "claude":
        return [binary, "-p", prompt, "--model", step.model]
    if step.provider == "codex":
        return [binary, "exec", "--profile", step.profile or "balanced", prompt]
    if step.provider == "gemini":
        model_args = [] if step.model == "auto" else ["-m", step.model]
        return [binary, *model_args, "-p", prompt]
    raise ValueError(f"nem cli provider: {step.provider}")


def _run_cli(step: Step, prompt: str, timeout_s: int, policy: Policy) -> DispatchResult:
    cmd = build_command(step, prompt, policy)
    try:
        proc = subprocess.run(cmd, timeout=timeout_s, capture_output=True, text=True)
    except subprocess.TimeoutExpired:
        return DispatchResult(step, EXIT_TIMEOUT, f"timeout {timeout_s}s")
    except FileNotFoundError:
        return DispatchResult(step, 127, f"nem talalhato: {cmd[0]}")
    return DispatchResult(step, proc.returncode, proc.stdout if proc.returncode == 0 else proc.stderr)


def _run_local(step: Step, prompt: str, timeout_s: int, policy: Policy) -> DispatchResult:
    url = policy.providers[step.provider].url.rstrip("/") + "/chat/completions"
    payload = json.dumps({
        "model": step.model,
        "messages": [{"role": "user", "content": prompt}],
        "stream": False,
    }).encode("utf-8")
    req = urllib.request.Request(url, data=payload, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=timeout_s) as resp:
            body = json.loads(resp.read().decode("utf-8"))
        return DispatchResult(step, 0, body["choices"][0]["message"]["content"])
    except (urllib.error.URLError, TimeoutError, ConnectionError, KeyError, ValueError) as exc:
        return DispatchResult(step, 1, f"{url}: {exc.__class__.__name__}")


def default_runner(policy: Policy) -> Runner:
    def run(step: Step, prompt: str, timeout_s: int) -> DispatchResult:
        if policy.providers[step.provider].kind == "local":
            return _run_local(step, prompt, timeout_s, policy)
        return _run_cli(step, prompt, timeout_s, policy)
    return run


def default_available(policy: Policy) -> Callable[[Step], bool]:
    cache: dict[str, bool] = {}

    def available(step: Step) -> bool:
        if step.provider not in cache:
            cache[step.provider] = probe(policy.providers[step.provider]).available
        return cache[step.provider]
    return available


def _log(msg: str) -> None:
    sys.stderr.write(f"[aios] {msg}\n")


def dispatch(decision: Decision, prompt: str, *, policy: Policy, ledger: Ledger,
             runner: Runner | None = None, available: Callable[[Step], bool] | None = None) -> DispatchResult:
    """Sorban probalja a lanc elemeit; minden valtast kiir es naplo-z (nincs csendes fallback)."""
    runner = runner or default_runner(policy)
    available = available or default_available(policy)
    last = DispatchResult(None, 2, "nincs futtathato provider a lancban")
    previous = ""

    for step in decision.chain:
        label = f"{step.provider}:{step.variant}"
        if ledger.is_open(step.provider, policy.breaker_failures, policy.breaker_cooldown_s):
            _log(f"kihagyva {label}: circuit breaker nyitva")
            continue
        if not available(step):
            _log(f"kihagyva {label}: nem elerheto")
            continue
        if previous:
            _log(f"fallback: {previous} -> {label}")
        started = time.monotonic()
        result = runner(step, prompt, policy.providers[step.provider].timeout_s)
        ledger.append(tier=decision.tier, provider=step.provider, variant=step.variant,
                      data_class=decision.data_class, exit_code=result.exit_code,
                      duration_s=time.monotonic() - started, prompt=prompt, fallback_from=previous)
        if result.exit_code == 0:
            return result
        _log(f"hiba {label}: exit {result.exit_code}")
        last = result
        previous = label
    return last

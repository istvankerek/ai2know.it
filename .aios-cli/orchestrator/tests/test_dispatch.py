"""Dispatch tesztek: fallback lanc, circuit breaker, ledger adatvedelem."""

import json
import pathlib
import sys
import tempfile
import time
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from aios.dispatch import DispatchResult, dispatch  # noqa: E402
from aios.ledger import Ledger  # noqa: E402
from aios.policy import load_policy  # noqa: E402
from aios.route import route  # noqa: E402

POLICY = load_policy()


class FakeRunner:
    """Provider futtatas szimulacio: provider nev -> exit kod."""

    def __init__(self, outcomes):
        self.outcomes = outcomes
        self.calls = []

    def __call__(self, step, prompt, timeout_s):
        self.calls.append(step.provider)
        return DispatchResult(step=step, exit_code=self.outcomes.get(step.provider, 0), output="ok")


class FallbackTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.ledger = Ledger(pathlib.Path(self.tmp.name))

    def tearDown(self):
        self.tmp.cleanup()

    def test_hibas_provider_utan_a_kovetkezo_jon(self):
        decision = route("nevezd at a valtozot", policy=POLICY)
        runner = FakeRunner({"mlx": 1, "lmstudio": 0})
        result = dispatch(decision, "nevezd at", policy=POLICY, ledger=self.ledger,
                          runner=runner, available=lambda s: True)
        self.assertEqual(runner.calls, ["mlx", "lmstudio"])
        self.assertEqual(result.step.provider, "lmstudio")
        self.assertEqual(result.exit_code, 0)

    def test_elerhetetlen_provider_kimarad(self):
        decision = route("nevezd at a valtozot", policy=POLICY)
        runner = FakeRunner({})
        dispatch(decision, "nevezd at", policy=POLICY, ledger=self.ledger, runner=runner,
                 available=lambda s: s.provider not in {"mlx", "lmstudio"})
        self.assertEqual(runner.calls, ["llamacpp"])

    def test_minden_hibas_eseten_nem_nulla_exit(self):
        decision = route("nevezd at a valtozot", policy=POLICY)
        runner = FakeRunner({p.provider: 1 for p in decision.chain})
        result = dispatch(decision, "x", policy=POLICY, ledger=self.ledger,
                          runner=runner, available=lambda s: True)
        self.assertNotEqual(result.exit_code, 0)
        self.assertEqual(len(runner.calls), len(decision.chain))

    def test_circuit_breaker_kihagyja_a_sokat_hibazo_providert(self):
        for _ in range(POLICY.breaker_failures):
            self.ledger.append(tier="MECHANICAL", provider="mlx", variant="", data_class="internal",
                               exit_code=1, duration_s=0.1, prompt="x")
        decision = route("nevezd at a valtozot", policy=POLICY)
        runner = FakeRunner({})
        dispatch(decision, "x", policy=POLICY, ledger=self.ledger, runner=runner,
                 available=lambda s: True)
        self.assertEqual(runner.calls[0], "lmstudio")

    def test_circuit_breaker_lejar(self):
        old = time.time() - POLICY.breaker_cooldown_s - 5
        for _ in range(POLICY.breaker_failures):
            self.ledger.append(tier="MECHANICAL", provider="mlx", variant="", data_class="internal",
                               exit_code=1, duration_s=0.1, prompt="x", ts=old)
        self.assertFalse(self.ledger.is_open("mlx", POLICY.breaker_failures, POLICY.breaker_cooldown_s))


class LedgerAdatvedelemTest(unittest.TestCase):
    def test_ledger_nem_tarolja_a_promptot(self):
        with tempfile.TemporaryDirectory() as tmp:
            ledger = Ledger(pathlib.Path(tmp))
            ledger.append(tier="STANDARD", provider="claude", variant="standard", data_class="internal",
                          exit_code=0, duration_s=1.0, prompt="titkos ugyfel nev: Kovacs Bela")
            raw = (pathlib.Path(tmp) / "ledger.jsonl").read_text()
        self.assertNotIn("Kovacs", raw)
        entry = json.loads(raw.strip())
        self.assertIn("prompt_sha256", entry)


if __name__ == "__main__":
    unittest.main()

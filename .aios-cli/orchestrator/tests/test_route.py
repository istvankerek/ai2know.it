"""Router tesztek: feladat -> tier -> provider lanc, biztonsagi kapuk."""

import json
import os
import pathlib
import subprocess
import sys
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from aios.classify import classify  # noqa: E402
from aios.policy import PolicyError, load_policy, validate_policy  # noqa: E402
from aios.route import route  # noqa: E402
from aios.secrets import find_secrets  # noqa: E402

POLICY = load_policy()

# NOTE: a minta-titkok darabokbol allnak ossze, hogy a forrasban ne legyen
# titoknak latszo literal (a check-injection hook joggal blokkolna).
FAKE_ANTHROPIC = "sk-" + "ant-api03-" + "abcdefghijklmnopqrstuvwxyz0123456789"
FAKE_SECRETS = [
    "AK" + "IA" + "IOSFODNN7EXAMPLE",
    FAKE_ANTHROPIC,
    "gh" + "p_" + "abcdefghijklmnopqrstuvwxyz0123456789",
    "postgres://admin:" + "hunter2" + "@db.internal:5432/app",
    "-----BEGIN RSA " + "PRIVATE KEY-----",
    "aibs" + "_live_" + "0123456789abcdef0123456789",
]


def providers_of(decision):
    return [step.provider for step in decision.chain]


class TierValasztasTest(unittest.TestCase):
    def test_atnevezes_mechanikus_es_helyi_modellel_indul(self):
        d = route("nevezd at a userId valtozot customerId-re", policy=POLICY)
        self.assertEqual(d.tier, "MECHANICAL")
        self.assertEqual(providers_of(d)[:3], ["mlx", "lmstudio", "llamacpp"])

    def test_prod_migracio_kritikus_es_megerositest_ker(self):
        d = route("prod migráció a users táblán", policy=POLICY)
        self.assertEqual(d.tier, "CRITICAL")
        self.assertTrue(d.requires_confirm)
        self.assertEqual(d.chain[0].provider, "claude")
        self.assertEqual(d.chain[0].model, "claude-opus-5-5")

    def test_architektura_terv_fable_modellel(self):
        d = route("tervezd meg az új modul architektúráját, plan-v16", policy=POLICY)
        self.assertEqual(d.tier, "PLAN")
        self.assertEqual(d.chain[0].model, "claude-fable-5-1")

    def test_review_sonnet(self):
        d = route("nézd át a PR-t és review-zd a változásokat", policy=POLICY)
        self.assertEqual(d.tier, "REVIEW")
        self.assertEqual(d.chain[0].model, "claude-sonnet-5-5")

    def test_altalanos_feature_standard(self):
        d = route("add hozzá az email validációt a regisztrációs formhoz", policy=POLICY)
        self.assertEqual(d.tier, "STANDARD")

    def test_korulhatarolt_implementacio_codexre_megy(self):
        d = route("generálj boilerplate CRUD endpointot a courses modulhoz", policy=POLICY)
        self.assertEqual(d.tier, "SCOPED")
        self.assertEqual(d.chain[0].provider, "codex")

    def test_web_kutatas_gemini(self):
        d = route("web kutatás: milyen OIDC könyvtárak vannak Rusthoz", policy=POLICY)
        self.assertEqual(d.tier, "LARGE_CONTEXT")
        self.assertEqual(d.chain[0].provider, "gemini")

    def test_konszenzus_kulcsszo(self):
        d = route("kritikus döntés, kérek konszenzust: Postgres vagy Mongo", policy=POLICY)
        self.assertEqual(d.tier, "CONSENSUS")

    def test_nagy_fajlmeret_nagy_kontextusra_valt(self):
        with tempfile.TemporaryDirectory() as tmp:
            big = pathlib.Path(tmp, "big.txt")
            big.write_text("x" * (POLICY.large_context_bytes + 1))
            d = route("elemezd ezt a fájlt", files=[str(big)], policy=POLICY)
        self.assertEqual(d.tier, "LARGE_CONTEXT")

    def test_dontes_indoklassal_jar(self):
        d = route("nevezd at a fajlt", policy=POLICY)
        self.assertTrue(d.reasons)


class AdatvedelmiKapuTest(unittest.TestCase):
    def test_erzekeny_adat_nem_mehet_geminire_es_codexre(self):
        for task in [
            "elemezd az ügyfél email listát és szegmentáld",
            "web kutatás a személyes adatok alapján",
            "generálj boilerplate-et a jelszó tárolóhoz",
        ]:
            d = route(task, policy=POLICY)
            self.assertEqual(d.data_class, "sensitive", task)
            self.assertNotIn("gemini", providers_of(d), task)
            self.assertNotIn("codex", providers_of(d), task)
            self.assertTrue(d.chain, task)

    def test_env_fajl_erzekenynek_szamit(self):
        d = route("nézd meg ezt", files=["environments/.env.local"], policy=POLICY)
        self.assertEqual(d.data_class, "sensitive")
        self.assertNotIn("gemini", providers_of(d))

    def test_alapertelmezett_osztaly_belso(self):
        self.assertEqual(classify("formázd a kódot", policy=POLICY).data_class, "internal")


class TitokSzuresTest(unittest.TestCase):
    def test_felismeri_a_tipikus_titkokat(self):
        for s in FAKE_SECRETS:
            self.assertTrue(find_secrets(f"itt van: {s}"), s)

    def test_artalmas_szoveg_nem_titok(self):
        self.assertEqual(find_secrets("nevezd at a userId valtozot"), [])


class PolicyValidacioTest(unittest.TestCase):
    def test_a_szallitott_policy_ervenyes(self):
        validate_policy(POLICY)

    def test_helyi_provider_csak_localhost_lehet(self):
        with self.assertRaises(PolicyError):
            load_policy(env={"AIOS_LOCAL_MLX_URL": "http://10.0.0.5:8080/v1"})

    def test_localhost_felulirhato(self):
        p = load_policy(env={"AIOS_LOCAL_MLX_URL": "http://localhost:9999/v1"})
        self.assertEqual(p.providers["mlx"].url, "http://localhost:9999/v1")

    def test_modell_env_felulirhato(self):
        p = load_policy(env={"AIOS_MODEL_CLAUDE_CRITICAL": "claude-opus-5-5-custom"})
        d = route("prod migráció", policy=p)
        self.assertEqual(d.chain[0].model, "claude-opus-5-5-custom")


class CliTest(unittest.TestCase):
    def run_cli(self, *args, env_extra=None):
        env = dict(os.environ, PYTHONPATH=str(ROOT))
        env.update(env_extra or {})
        return subprocess.run(
            [sys.executable, "-m", "aios", *args],
            capture_output=True, text=True, env=env, cwd=str(ROOT),
        )

    def test_route_json_kimenet(self):
        r = self.run_cli("route", "nevezd at a valtozot", "--json")
        self.assertEqual(r.returncode, 0, r.stderr)
        data = json.loads(r.stdout)
        for key in ("tier", "data_class", "requires_confirm", "chain", "reasons"):
            self.assertIn(key, data)
        self.assertEqual(data["chain"][0]["provider"], "mlx")

    def test_run_titokkal_megall_3_as_koddal(self):
        with tempfile.TemporaryDirectory() as tmp:
            r = self.run_cli("run", f"deploy ezzel: {FAKE_ANTHROPIC}", "--dry-run",
                             env_extra={"AIOS_LEDGER_DIR": tmp})
        self.assertEqual(r.returncode, 3, r.stdout + r.stderr)

    def test_kritikus_run_megerosites_nelkul_megall(self):
        with tempfile.TemporaryDirectory() as tmp:
            r = self.run_cli("run", "prod migráció", "--dry-run", env_extra={"AIOS_LEDGER_DIR": tmp})
        self.assertEqual(r.returncode, 4, r.stdout + r.stderr)

    def test_explain_kiirja_a_lancot(self):
        r = self.run_cli("explain", "MECHANICAL")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("mlx", r.stdout)


if __name__ == "__main__":
    unittest.main()

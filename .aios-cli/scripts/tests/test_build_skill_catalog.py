"""Skill katalogus (menufa) validator tesztek – plan-v15 F3."""

import importlib.util
import json
import pathlib
import subprocess
import sys
import tempfile
import unittest

SCRIPTS = pathlib.Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("build_skill_catalog", SCRIPTS / "build-skill-catalog.py")
bsc = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(bsc)


def manifest(*apps):
    return {"version": 1, "apps": list(apps)}


def app(app_id, *sections, paths=None):
    return {
        "app_id": app_id,
        "name": {"hu": app_id, "en": app_id},
        "icon": "box",
        "paths": paths or [],
        "nav": [{"label": {"hu": "S", "en": "S"}, "items": list(items)} for items in sections],
    }


class ValidacioTest(unittest.TestCase):
    def test_ervenyes_katalogus_nem_ad_hibat(self):
        m = manifest(app("identity", ["skillpass-auth"]), app("ai", ["local-models"]))
        self.assertEqual(bsc.validate(m, {"skillpass-auth", "local-models"}), [])

    def test_hianyzo_skill_hiba(self):
        m = manifest(app("identity", ["skillpass-auth"]))
        errors = bsc.validate(m, {"skillpass-auth", "local-models"})
        self.assertTrue(any("local-models" in e and "nincs" in e for e in errors), errors)

    def test_duplikalt_skill_hiba(self):
        m = manifest(app("identity", ["skillpass-auth"]), app("ai", ["skillpass-auth"]))
        errors = bsc.validate(m, {"skillpass-auth"})
        self.assertTrue(any("tobbszor" in e for e in errors), errors)

    def test_ismeretlen_skill_hiba(self):
        m = manifest(app("identity", ["skillpass-auth", "nem-letezo"]))
        errors = bsc.validate(m, {"skillpass-auth"})
        self.assertTrue(any("nem-letezo" in e for e in errors), errors)

    def test_hianyos_app_szerkezet_hiba(self):
        m = {"version": 1, "apps": [{"app_id": "x", "nav": []}]}
        errors = bsc.validate(m, set())
        self.assertTrue(any("name" in e for e in errors), errors)

    def test_duplikalt_app_id_hiba(self):
        m = manifest(app("ai", ["a"]), app("ai", ["b"]))
        errors = bsc.validate(m, {"a", "b"})
        self.assertTrue(any("app_id" in e for e in errors), errors)

    def test_objektum_item_is_elfogadott(self):
        m = manifest(app("identity", [{"id": "skillpass-auth", "badge": "P0"}]))
        self.assertEqual(bsc.validate(m, {"skillpass-auth"}), [])


class UtvonalTest(unittest.TestCase):
    def test_fajl_utvonalbol_app_skillek(self):
        m = manifest(
            app("identity", ["skillpass-auth"], paths=["**/auth/**"]),
            app("admin", ["aibos-admin-contract"], paths=["contracts/admin/**"]),
        )
        self.assertEqual(bsc.skills_for_path(m, "apps/web/lib/auth/session.ts"), ("identity", ["skillpass-auth"]))
        self.assertEqual(bsc.skills_for_path(m, "contracts/admin/x.yaml"), ("admin", ["aibos-admin-contract"]))
        self.assertEqual(bsc.skills_for_path(m, "README.md"), (None, []))


class ValosKatalogusTest(unittest.TestCase):
    def test_a_szallitott_katalogus_ervenyes(self):
        result = subprocess.run([sys.executable, str(SCRIPTS / "build-skill-catalog.py"), "--check"],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_markdown_tartalmazza_az_appokat(self):
        m = manifest(app("identity", ["skillpass-auth"]))
        md = bsc.render_markdown(m, {"skillpass-auth": "OIDC belepes"})
        self.assertIn("identity", md)
        self.assertIn("`skillpass-auth`", md)
        self.assertIn("OIDC belepes", md)

    def test_check_hibas_manifesttel_nem_nulla(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = pathlib.Path(tmp, "m.json")
            p.write_text(json.dumps(manifest(app("x", ["nem-letezo-skill"]))))
            result = subprocess.run([sys.executable, str(SCRIPTS / "build-skill-catalog.py"), "--check",
                                     "--manifest", str(p)], capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()

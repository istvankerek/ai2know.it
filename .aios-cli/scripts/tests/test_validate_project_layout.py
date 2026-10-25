"""Projekt-szerkezet validator tesztek – plan-v16 F2 (worktrees/, subprojects/)."""

import importlib.util
import pathlib
import subprocess
import tempfile
import unittest

SCRIPTS = pathlib.Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("validate_project_layout", SCRIPTS / "validate-project-layout.py")
vpl = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(vpl)

SUBPROJECT_MD = """# services

- role: Közös üzleti szolgáltatások (invoice, pay, delivery)
- type: nested
- deploy: külön compose, *.aibos.space
- toolchain: Rust 1.88, edition 2021
- contract: contracts/openapi/
"""


def make_repo(tmp: pathlib.Path) -> pathlib.Path:
    root = tmp / "proj"
    root.mkdir()
    subprocess.run(["git", "init", "-q", "-b", "main", str(root)], check=True)
    subprocess.run(["git", "-C", str(root), "config", "user.email", "t@t"], check=True)
    subprocess.run(["git", "-C", str(root), "config", "user.name", "t"], check=True)
    (root / "README.md").write_text("x")
    (root / ".gitignore").write_text("worktrees/\nsubprojects/*/\n!subprojects/*.md\n")
    subprocess.run(["git", "-C", str(root), "add", "-A"], check=True)
    subprocess.run(["git", "-C", str(root), "commit", "-q", "-m", "init"], check=True)
    return root


class SubprojectTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = make_repo(pathlib.Path(self.tmp.name))

    def tearDown(self):
        self.tmp.cleanup()

    def test_subprojekt_nelkul_ervenyes(self):
        self.assertEqual(vpl.validate(self.root), [])

    def test_ervenyes_subprojekt(self):
        (self.root / "subprojects.toml").write_text('[subprojects.services]\ntype = "nested"\npath = "subprojects/services"\n')
        (self.root / "subprojects/services").mkdir(parents=True)
        (self.root / "subprojects/services/SUBPROJECT.md").write_text(SUBPROJECT_MD)
        self.assertEqual(vpl.validate(self.root), [])

    def test_toml_ban_nem_letezo_mappa_hiba(self):
        (self.root / "subprojects.toml").write_text('[subprojects.ghost]\ntype = "nested"\npath = "subprojects/ghost"\n')
        errors = vpl.validate(self.root)
        self.assertTrue(any("ghost" in e and "nem letezik" in e for e in errors), errors)

    def test_mappa_toml_nelkul_hiba(self):
        (self.root / "subprojects/orphan").mkdir(parents=True)
        errors = vpl.validate(self.root)
        self.assertTrue(any("orphan" in e and "subprojects.toml" in e for e in errors), errors)

    def test_hianyzo_subproject_md_mezo_hiba(self):
        (self.root / "subprojects.toml").write_text('[subprojects.services]\ntype = "nested"\npath = "subprojects/services"\n')
        (self.root / "subprojects/services").mkdir(parents=True)
        (self.root / "subprojects/services/SUBPROJECT.md").write_text("# services\n- role: x\n")
        errors = vpl.validate(self.root)
        self.assertTrue(any("toolchain" in e for e in errors), errors)

    def test_nested_subprojekt_gitignore_nelkul_hiba(self):
        (self.root / ".gitignore").write_text("worktrees/\n")
        (self.root / "subprojects.toml").write_text('[subprojects.services]\ntype = "nested"\npath = "subprojects/services"\n')
        (self.root / "subprojects/services").mkdir(parents=True)
        (self.root / "subprojects/services/SUBPROJECT.md").write_text(SUBPROJECT_MD)
        errors = vpl.validate(self.root)
        self.assertTrue(any("gitignore" in e for e in errors), errors)


class WorktreeTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = make_repo(pathlib.Path(self.tmp.name))

    def tearDown(self):
        self.tmp.cleanup()

    def test_belso_worktree_rendben(self):
        subprocess.run(["git", "-C", str(self.root), "worktree", "add", "-q", "-b", "feature/x",
                        str(self.root / "worktrees/feature-x")], check=True)
        self.assertEqual([e for e in vpl.validate(self.root) if "worktree" in e], [])

    def test_kulso_worktree_hiba(self):
        outside = pathlib.Path(self.tmp.name) / "proj-feature-y"
        subprocess.run(["git", "-C", str(self.root), "worktree", "add", "-q", "-b", "feature/y", str(outside)], check=True)
        errors = vpl.validate(self.root)
        self.assertTrue(any("worktree" in e and "proj-feature-y" in e for e in errors), errors)

    def test_sok_agent_worktree_figyelmeztetes(self):
        for i in range(4):
            subprocess.run(["git", "-C", str(self.root), "worktree", "add", "-q", "-b", f"worktree-agent-{i}",
                            str(self.root / f".claude/worktrees/agent-{i}")], check=True)
        warnings = vpl.warnings(self.root)
        self.assertTrue(any("agent" in w for w in warnings), warnings)

    def test_worktrees_mappa_gitignore_nelkul_hiba(self):
        (self.root / ".gitignore").write_text("")
        (self.root / "worktrees").mkdir()
        errors = vpl.validate(self.root)
        self.assertTrue(any("worktrees" in e and "gitignore" in e for e in errors), errors)


class CliTest(unittest.TestCase):
    def test_skeleton_sajat_szerkezete_ervenyes(self):
        r = subprocess.run(["python3", str(SCRIPTS / "validate-project-layout.py"), str(SCRIPTS.parents[1])],
                           capture_output=True, text=True)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)


if __name__ == "__main__":
    unittest.main()

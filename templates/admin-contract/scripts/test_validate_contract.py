"""
Admin contract validator tesztjei.

Futtatás a skeleton gyökeréből:
    python3 -m unittest discover -s templates/admin-contract/scripts -p 'test_*.py'
"""

import json
import os
import sys
import tempfile
import unittest

# A validate_contract modul importálása — az aktuális könyvtárból
sys.path.insert(0, os.path.dirname(__file__))
import validate_contract as vc


def _write_tmp(data: dict, suffix: str = ".json") -> str:
    """Ideiglenes JSON fájlt ír és visszaadja az útvonalát."""
    f = tempfile.NamedTemporaryFile(
        mode="w", suffix=suffix, delete=False, encoding="utf-8"
    )
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.close()
    return f.name


def _minimal_permissions() -> dict:
    """Minimálisan érvényes permissions.json."""
    return {
        "schema_version": "1.0.0",
        "realm": "testproject",
        "prefix": "testproject.",
        "separator": ".",
        "implicit_default": "DENY",
        "wildcards_allowed": False,
        "missing_permission_behavior": "DENY",
        "groups": [
            {
                "key": "items",
                "name": "Tárgyak",
                "permissions": [
                    {"code": "testproject.items.list",   "description": "Lista"},
                    {"code": "testproject.items.view",   "description": "Nézet"},
                    {"code": "testproject.items.create", "description": "Létrehozás"},
                ],
            }
        ],
        "roles": [
            {"code": "superadmin", "name": "Szuperadmin", "grant_rule": "ALL"},
            {"code": "viewer",     "name": "Néző",        "grant_rule": "EXPLICIT"},
        ],
    }


def _minimal_openapi(permissions: list[str] | None = None) -> dict:
    """Minimálisan érvényes OpenAPI JSON.

    permissions: az x-permission értékek listája az operációkban.
    Ha None, az alapértelmezett értékeket használja.
    """
    if permissions is None:
        permissions = ["items.list", "items.create"]
    ops_list_perm, ops_create_perm = (
        (permissions[0], permissions[1]) if len(permissions) >= 2
        else (permissions[0], permissions[0])
    )
    return {
        "openapi": "3.1.0",
        "info": {"title": "Test API", "version": "1.0.0"},
        "paths": {
            "/api/admin/v1/items": {
                "get": {
                    "operationId": "listItems",
                    "x-permission": ops_list_perm,
                    "responses": {
                        "200": {"description": "ok"},
                        "401": {"$ref": "#/components/responses/Unauthenticated"},
                        "403": {"$ref": "#/components/responses/Forbidden"},
                    },
                },
                "post": {
                    "operationId": "createItem",
                    "x-permission": ops_create_perm,
                    "responses": {
                        "201": {"description": "létrehozva"},
                        "401": {"$ref": "#/components/responses/Unauthenticated"},
                        "403": {"$ref": "#/components/responses/Forbidden"},
                        "422": {"$ref": "#/components/responses/UnprocessableEntity"},
                    },
                },
            }
        },
        "components": {
            "responses": {
                "Unauthenticated": {
                    "description": "401",
                    "content": {
                        "application/problem+json": {
                            "schema": {"$ref": "#/components/schemas/Problem"}
                        }
                    },
                },
                "Forbidden": {
                    "description": "403",
                    "content": {
                        "application/problem+json": {
                            "schema": {"$ref": "#/components/schemas/Problem"}
                        }
                    },
                },
                "UnprocessableEntity": {
                    "description": "422",
                    "content": {
                        "application/problem+json": {
                            "schema": {"$ref": "#/components/schemas/Problem"}
                        }
                    },
                },
            },
            "schemas": {
                "Problem": {
                    "type": "object",
                    "required": ["type", "title", "status"],
                    "properties": {
                        "type": {"type": "string"},
                        "title": {"type": "string"},
                        "status": {"type": "integer"},
                    },
                }
            },
        },
    }


class TestPermissionFormatValidation(unittest.TestCase):
    """Permission kód formátum ellenőrzése."""

    def test_ervenyes_kod_elfogadott(self):
        """Érvényes {realm}.{modul}.{akció} kódot elfogad."""
        errors = vc.validate_permission_code("aibootcamp.courses.list")
        self.assertEqual(errors, [])

    def test_ervenyes_kod_alahuzonassal(self):
        """Aláhúzást tartalmazó érvényes kódot elfogad."""
        errors = vc.validate_permission_code("my_project.my_module.my_action")
        self.assertEqual(errors, [])

    def test_wildcard_elutasitva(self):
        """Wildcard (*) tartalmú kódot visszautasít."""
        errors = vc.validate_permission_code("aibootcamp.*.list")
        self.assertGreater(len(errors), 0)

    def test_ket_szegmens_elutasitva(self):
        """Csak két szegmenst tartalmazó kódot visszautasít."""
        errors = vc.validate_permission_code("aibootcamp.courses")
        self.assertGreater(len(errors), 0)

    def test_negy_szegmens_elutasitva(self):
        """Négy szegmenst tartalmazó kódot visszautasít."""
        errors = vc.validate_permission_code("aibootcamp.courses.list.extra")
        self.assertGreater(len(errors), 0)

    def test_nagybetu_elutasitva(self):
        """Nagybetűt tartalmazó kódot visszautasít."""
        errors = vc.validate_permission_code("Aibootcamp.courses.list")
        self.assertGreater(len(errors), 0)

    def test_kotojel_elutasitva(self):
        """Kötőjelet tartalmazó kódot visszautasít (csak alulvonás megengedett)."""
        errors = vc.validate_permission_code("ai-bootcamp.courses.list")
        self.assertGreater(len(errors), 0)

    def test_ures_string_elutasitva(self):
        """Üres stringet visszautasít."""
        errors = vc.validate_permission_code("")
        self.assertGreater(len(errors), 0)


class TestPermissionsJsonValidation(unittest.TestCase):
    """permissions.json tartalom validáció."""

    def test_ervenyes_permissions_elfogadott(self):
        """Érvényes permissions.json-t elfogad."""
        path = _write_tmp(_minimal_permissions())
        try:
            errors = vc.validate_permissions_file(path)
            self.assertEqual(errors, [], f"Váratlan hibák: {errors}")
        finally:
            os.unlink(path)

    def test_duplikat_permission_kod_elutasitva(self):
        """Duplikált permission kódot visszautasít."""
        data = _minimal_permissions()
        data["groups"][0]["permissions"].append(
            {"code": "testproject.items.list", "description": "Duplikált"}
        )
        path = _write_tmp(data)
        try:
            errors = vc.validate_permissions_file(path)
            self.assertTrue(
                any("duplikált" in e.lower() or "duplicate" in e.lower() for e in errors),
                f"Duplikát hibát vártam, kaptam: {errors}",
            )
        finally:
            os.unlink(path)

    def test_wildcard_permission_elutasitva(self):
        """Wildcard permission kódot visszautasít."""
        data = _minimal_permissions()
        data["groups"][0]["permissions"].append(
            {"code": "testproject.items.*", "description": "Wildcard"}
        )
        path = _write_tmp(data)
        try:
            errors = vc.validate_permissions_file(path)
            self.assertGreater(len(errors), 0, "Wildcard hibát vártam")
        finally:
            os.unlink(path)

    def test_implicit_default_deny_kotelező(self):
        """implicit_default != DENY esetén hibát jelez."""
        data = _minimal_permissions()
        data["implicit_default"] = "ALLOW"
        path = _write_tmp(data)
        try:
            errors = vc.validate_permissions_file(path)
            self.assertGreater(len(errors), 0, "DENY-tól eltérő default hibát vártam")
        finally:
            os.unlink(path)

    def test_wildcards_allowed_false_kotelező(self):
        """wildcards_allowed=true esetén hibát jelez."""
        data = _minimal_permissions()
        data["wildcards_allowed"] = True
        path = _write_tmp(data)
        try:
            errors = vc.validate_permissions_file(path)
            self.assertGreater(len(errors), 0, "wildcards_allowed=true hibát vártam")
        finally:
            os.unlink(path)


class TestRoleMatrixValidation(unittest.TestCase):
    """role-matrix.csv validáció."""

    def _write_csv(self, rows: list[str]) -> str:
        f = tempfile.NamedTemporaryFile(
            mode="w", suffix=".csv", delete=False, encoding="utf-8"
        )
        f.write("role_code,role_name,permission_code,effect\n")
        for row in rows:
            f.write(row + "\n")
        f.close()
        return f.name

    def test_ervenyes_matrix_elfogadott(self):
        """Érvényes role-matrix.csv-t elfogad."""
        known_permissions = {
            "testproject.items.list",
            "testproject.items.view",
            "testproject.items.create",
        }
        known_roles = {"superadmin", "viewer"}
        path = self._write_csv([
            "superadmin,Szuperadmin,testproject.items.list,ALLOW",
            "viewer,Néző,testproject.items.list,ALLOW",
            "viewer,Néző,testproject.items.view,ALLOW",
        ])
        try:
            errors = vc.validate_role_matrix(path, known_permissions, known_roles)
            self.assertEqual(errors, [], f"Váratlan hibák: {errors}")
        finally:
            os.unlink(path)

    def test_ismeretlen_permission_elutasitva(self):
        """Ismeretlen permission kódot a matrix-ban visszautasít."""
        known_permissions = {"testproject.items.list"}
        known_roles = {"viewer"}
        path = self._write_csv([
            "viewer,Néző,testproject.items.ISMERETLEN,ALLOW",
        ])
        try:
            errors = vc.validate_role_matrix(path, known_permissions, known_roles)
            self.assertGreater(len(errors), 0, "Ismeretlen permission hibát vártam")
        finally:
            os.unlink(path)

    def test_deny_effect_elutasitva(self):
        """DENY effect a matrix-ban visszautasít (csak ALLOW megengedett)."""
        known_permissions = {"testproject.items.list"}
        known_roles = {"viewer"}
        path = self._write_csv([
            "viewer,Néző,testproject.items.list,DENY",
        ])
        try:
            errors = vc.validate_role_matrix(path, known_permissions, known_roles)
            self.assertGreater(len(errors), 0, "DENY effect hibát vártam")
        finally:
            os.unlink(path)

    def test_ismeretlen_role_elutasitva(self):
        """Ismeretlen role kódot a matrix-ban visszautasít."""
        known_permissions = {"testproject.items.list"}
        known_roles = {"viewer"}
        path = self._write_csv([
            "ismeretlen_role,Ismeretlen,testproject.items.list,ALLOW",
        ])
        try:
            errors = vc.validate_role_matrix(path, known_permissions, known_roles)
            self.assertGreater(len(errors), 0, "Ismeretlen role hibát vártam")
        finally:
            os.unlink(path)


class TestOpenapiValidation(unittest.TestCase):
    """OpenAPI JSON validáció."""

    def test_ervenyes_openapi_elfogadott(self):
        """Érvényes OpenAPI JSON-t, ismert permission kódokkal elfogad."""
        known_permissions = {"testproject.items.list", "testproject.items.create"}
        path = _write_tmp(_minimal_openapi(["items.list", "items.create"]))
        # A validator a rövidített kódot kapja és ellenőrzi, hogy <realm>.<code> ismert-e.
        # Ehhez realm-et is át kell adni.
        try:
            errors = vc.validate_openapi_file(
                path, known_permissions, realm="testproject"
            )
            self.assertEqual(errors, [], f"Váratlan hibák: {errors}")
        finally:
            os.unlink(path)

    def test_hianyzó_x_permission_elutasitva(self):
        """Operáció x-permission nélkül visszautasítva."""
        data = _minimal_openapi()
        # Töröljük az x-permission-t az egyik operációból
        del data["paths"]["/api/admin/v1/items"]["get"]["x-permission"]
        known_permissions = {"testproject.items.list", "testproject.items.create"}
        path = _write_tmp(data)
        try:
            errors = vc.validate_openapi_file(
                path, known_permissions, realm="testproject"
            )
            self.assertGreater(len(errors), 0, "Hiányzó x-permission hibát vártam")
        finally:
            os.unlink(path)

    def test_ismeretlen_x_permission_elutasitva(self):
        """Ismeretlen x-permission értéket visszautasít."""
        known_permissions = {"testproject.items.list"}
        data = _minimal_openapi(["items.list", "items.ISMERETLEN"])
        path = _write_tmp(data)
        try:
            errors = vc.validate_openapi_file(
                path, known_permissions, realm="testproject"
            )
            self.assertGreater(
                len(errors), 0, "Ismeretlen x-permission hibát vártam"
            )
        finally:
            os.unlink(path)

    def test_nem_2xx_valasz_problem_hivatkozas_nelkul_elutasitva(self):
        """Nem-2xx válasz problem schema hivatkozás nélkül visszautasítva."""
        data = _minimal_openapi()
        # Töröljük a components.responses-t — így nem lesz Problem hivatkozás
        data["components"]["responses"] = {}
        # A 401-es válasz mostantól nincs definiálva Problem-mel
        data["paths"]["/api/admin/v1/items"]["get"]["responses"]["401"] = {
            "description": "Nincs hitelesítés"
            # Szándékosan nincs Problem schema hivatkozás
        }
        known_permissions = {"testproject.items.list", "testproject.items.create"}
        path = _write_tmp(data)
        try:
            errors = vc.validate_openapi_file(
                path, known_permissions, realm="testproject"
            )
            self.assertGreater(
                len(errors), 0, "Hiányzó Problem schema hivatkozás hibát vártam"
            )
        finally:
            os.unlink(path)

    def test_health_endpoint_kimarad_x_permission_ellenorzesbol(self):
        """A health/ endpointok x-permission nélkül is elfogadottak."""
        data = _minimal_openapi()
        data["paths"]["/health/live"] = {
            "get": {
                "operationId": "healthLive",
                "security": [],
                # Szándékosan nincs x-permission — health endpoint
                "responses": {"200": {"description": "ok"}},
            }
        }
        known_permissions = {"testproject.items.list", "testproject.items.create"}
        path = _write_tmp(data)
        try:
            errors = vc.validate_openapi_file(
                path, known_permissions, realm="testproject"
            )
            self.assertEqual(errors, [], f"Health endpoint hibát okozott: {errors}")
        finally:
            os.unlink(path)


class TestIntegration(unittest.TestCase):
    """Integrációs teszt: a sablon könyvtár validál."""

    def test_sablon_konyvtar_validal(self):
        """A templates/admin-contract/ könyvtár hibamentesen átmegy a validátoron."""
        script_dir = os.path.dirname(__file__)
        contract_dir = os.path.normpath(
            os.path.join(script_dir, "..", )
        )
        errors = vc.validate_directory(contract_dir)
        self.assertEqual(
            errors,
            [],
            f"A sablon könyvtár validációs hibákat tartalmaz:\n"
            + "\n".join(f"  - {e}" for e in errors),
        )


if __name__ == "__main__":
    unittest.main()

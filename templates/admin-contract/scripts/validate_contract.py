"""
Admin contract validator — Python 3 stdlib only, no external dependencies.

Ellenőrzi:
  1. permissions.json: formátum regex, nincs wildcard, egyedi kódok, implicit_default=DENY
  2. role-matrix.csv: csak ismert permission kódok, csak ALLOW effect, ismert role kódok
  3. OpenAPI JSON: x-permission minden operáción, ismert kódok, nem-2xx → Problem schema

Futtatás a skeleton gyökeréből:
    python3 templates/admin-contract/scripts/validate-contract.py templates/admin-contract

A modul függvényei közvetlenül importálhatók tesztekhez.
"""

import csv
import json
import os
import re
import sys
from typing import Any

# Permission kód regex: {realm}.{modul}.{akció}
# Kisbetű, szám, alulvonás; ponttal elválasztva; pontosan 3 szegmens
_PERMISSION_RE = re.compile(r"^[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*$")

# HTTP metódusok, amelyekre az x-permission ellenőrzés vonatkozik
_CHECKED_METHODS = {"get", "post", "put", "patch", "delete"}

# Útvonal prefix, amelyekre NEM vonatkozik az x-permission ellenőrzés
_EXEMPT_PATH_PREFIXES = ("/health/", "/metrics/", "/ready", "/live")


# ── Alacsony szintű segédfüggvények ───────────────────────────────────────────


def validate_permission_code(code: str) -> list[str]:
    """Egy permission kódot validál. Visszaad egy hibalistát (üres = OK)."""
    errors: list[str] = []
    if not code:
        errors.append("Üres permission kód")
        return errors
    if "*" in code:
        errors.append(f"Wildcard (*) nem megengedett a permission kódban: {code!r}")
    if not _PERMISSION_RE.match(code):
        errors.append(
            f"Érvénytelen permission kód formátum (várható: {{realm}}.{{modul}}.{{akció}}): {code!r}"
        )
    return errors


def _collect_permission_codes(data: dict) -> list[str]:
    """Összegyűjti az összes permission kódot a groups-ból."""
    codes: list[str] = []
    for group in data.get("groups", []):
        for perm in group.get("permissions", []):
            codes.append(perm.get("code", ""))
    return codes


def _collect_role_codes(data: dict) -> list[str]:
    """Összegyűjti a role kódokat."""
    return [r.get("code", "") for r in data.get("roles", [])]


# ── Permissions.json validáció ─────────────────────────────────────────────────


def validate_permissions_file(path: str) -> list[str]:
    """permissions.json fájl validációja. Visszaad egy hibalistát."""
    errors: list[str] = []

    try:
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
    except (OSError, json.JSONDecodeError) as exc:
        return [f"Nem olvasható permissions.json ({path}): {exc}"]

    # Kötelező metaadat ellenőrzések
    if data.get("implicit_default") != "DENY":
        errors.append(
            f"implicit_default értéke nem DENY: {data.get('implicit_default')!r}"
        )
    if data.get("wildcards_allowed") is not False:
        errors.append(
            f"wildcards_allowed értéke nem false: {data.get('wildcards_allowed')!r}"
        )
    if data.get("separator") != ".":
        errors.append(
            f"separator értéke nem '.': {data.get('separator')!r}"
        )
    if data.get("missing_permission_behavior") != "DENY":
        errors.append(
            f"missing_permission_behavior értéke nem DENY: "
            f"{data.get('missing_permission_behavior')!r}"
        )

    # Permission kód validáció és egyediség
    codes = _collect_permission_codes(data)
    seen: set[str] = set()
    for code in codes:
        errors.extend(validate_permission_code(code))
        if code in seen:
            errors.append(f"Duplikált permission kód: {code!r}")
        seen.add(code)

    # Legalább egy csoport és egy jogosultság
    if not data.get("groups"):
        errors.append("Legalább egy csoport (groups) szükséges")

    # Legalább egy szerepkör
    if not data.get("roles"):
        errors.append("Legalább egy szerepkör (roles) szükséges")

    return errors


# ── Role matrix validáció ──────────────────────────────────────────────────────


def validate_role_matrix(
    path: str,
    known_permissions: set[str],
    known_roles: set[str],
) -> list[str]:
    """role-matrix.csv validációja. Visszaad egy hibalistát."""
    errors: list[str] = []

    try:
        with open(path, encoding="utf-8", newline="") as fh:
            reader = csv.DictReader(fh)
            required_cols = {"role_code", "permission_code", "effect"}
            if not reader.fieldnames or not required_cols.issubset(reader.fieldnames):
                return [
                    f"A CSV fejlécből hiányzik: {required_cols - set(reader.fieldnames or [])}"
                ]
            rows = list(reader)
    except OSError as exc:
        return [f"Nem olvasható role-matrix.csv ({path}): {exc}"]

    for i, row in enumerate(rows, start=2):
        role = row.get("role_code", "").strip()
        perm = row.get("permission_code", "").strip()
        effect = row.get("effect", "").strip()

        if role not in known_roles:
            errors.append(f"Sor {i}: ismeretlen role_code: {role!r}")
        if perm not in known_permissions:
            errors.append(f"Sor {i}: ismeretlen permission_code: {perm!r}")
        if effect != "ALLOW":
            errors.append(
                f"Sor {i}: csak ALLOW effect megengedett (kapott: {effect!r})"
            )

    return errors


# ── OpenAPI JSON validáció ─────────────────────────────────────────────────────


def _is_problem_response(response_value: Any, components: dict) -> bool:
    """Megvizsgálja, hogy a response értéke hivatkozza-e a Problem sémát."""
    if not isinstance(response_value, dict):
        return False

    # $ref a responses-re (pl. {"$ref": "#/components/responses/Unauthenticated"})
    ref = response_value.get("$ref", "")
    if ref.startswith("#/components/responses/"):
        resp_name = ref.split("/")[-1]
        resolved = components.get("responses", {}).get(resp_name, {})
        return _response_has_problem_content(resolved)

    # Közvetlen response objektum
    return _response_has_problem_content(response_value)


def _response_has_problem_content(response_obj: dict) -> bool:
    """Ellenőrzi, hogy a response tartalmaz-e application/problem+json tartalmat."""
    content = response_obj.get("content", {})
    if "application/problem+json" in content:
        return True
    # Elfogadjuk, ha bármilyen content-ben szerepel Problem schema ref
    for media in content.values():
        schema = media.get("schema", {})
        ref = schema.get("$ref", "")
        if "Problem" in ref or "problem" in ref.lower():
            return True
    return False


def _is_exempt_path(path: str) -> bool:
    """Ellenőrzi, hogy az útvonal mentes-e az x-permission kötelezettség alól."""
    for prefix in _EXEMPT_PATH_PREFIXES:
        if path.startswith(prefix):
            return True
    return False


def validate_openapi_file(
    path: str,
    known_permissions: set[str],
    realm: str,
) -> list[str]:
    """OpenAPI JSON fájl validációja. Visszaad egy hibalistát.

    known_permissions: teljes kódok halmaza (pl. {"testproject.items.list"})
    realm: a projekt realm neve (pl. "testproject") — az x-permission
           rövidített kódok kiegészítéséhez
    """
    errors: list[str] = []

    try:
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
    except (OSError, json.JSONDecodeError) as exc:
        return [f"Nem olvasható OpenAPI fájl ({path}): {exc}"]

    components = data.get("components", {})
    paths = data.get("paths", {})

    for path_str, path_item in paths.items():
        if not isinstance(path_item, dict):
            continue
        exempt = _is_exempt_path(path_str)
        # Path-szintű paraméterek kihagyása
        for method, operation in path_item.items():
            if method not in _CHECKED_METHODS:
                continue
            if not isinstance(operation, dict):
                continue

            op_id = operation.get("operationId", f"{method} {path_str}")

            # x-permission ellenőrzés (health endpointok kivételével)
            if not exempt:
                x_perm = operation.get("x-permission")
                if not x_perm:
                    errors.append(
                        f"Hiányzó x-permission: {op_id} ({method.upper()} {path_str})"
                    )
                else:
                    # A rövidített kódból teljes kódot képzünk: {realm}.{x_perm}
                    full_code = f"{realm}.{x_perm}"
                    if full_code not in known_permissions:
                        errors.append(
                            f"Ismeretlen x-permission {full_code!r}: "
                            f"{op_id} ({method.upper()} {path_str})"
                        )

            # Nem-2xx válaszok ellenőrzése
            responses = operation.get("responses", {})
            for status_str, response_val in responses.items():
                try:
                    status = int(status_str)
                except (ValueError, TypeError):
                    continue
                if status < 200 or status >= 300:
                    if not _is_problem_response(response_val, components):
                        errors.append(
                            f"Nem-2xx válasz ({status}) Problem schema hivatkozás nélkül: "
                            f"{op_id} ({method.upper()} {path_str})"
                        )

    return errors


# ── Könyvtár szintű validáció ──────────────────────────────────────────────────


def validate_directory(contract_dir: str) -> list[str]:
    """Egy contract könyvtárat validál.

    Elvárja a következő struktúrát:
        contracts/
          admin/*.json        ← OpenAPI fájlok
          authorization/
            permissions.json
            role-matrix.csv
    """
    errors: list[str] = []

    auth_dir = os.path.join(contract_dir, "contracts", "authorization")
    admin_dir = os.path.join(contract_dir, "contracts", "admin")

    perm_path = os.path.join(auth_dir, "permissions.json")
    matrix_path = os.path.join(auth_dir, "role-matrix.csv")

    # 1. permissions.json validáció
    if not os.path.isfile(perm_path):
        errors.append(f"Hiányzó fájl: {perm_path}")
        return errors

    perm_errors = validate_permissions_file(perm_path)
    errors.extend([f"[permissions.json] {e}" for e in perm_errors])

    # Összegyűjtjük az ismert kódokat és role kódokat a matrix validációhoz
    try:
        with open(perm_path, encoding="utf-8") as fh:
            perm_data = json.load(fh)
    except (OSError, json.JSONDecodeError):
        return errors  # Már jeleztük a hibát

    known_permissions = set(_collect_permission_codes(perm_data))
    known_roles = set(_collect_role_codes(perm_data))
    realm = perm_data.get("realm", "")

    # 2. role-matrix.csv validáció
    if not os.path.isfile(matrix_path):
        errors.append(f"Hiányzó fájl: {matrix_path}")
    else:
        matrix_errors = validate_role_matrix(matrix_path, known_permissions, known_roles)
        errors.extend([f"[role-matrix.csv] {e}" for e in matrix_errors])

    # 3. OpenAPI JSON fájlok validációja
    if not os.path.isdir(admin_dir):
        errors.append(f"Hiányzó könyvtár: {admin_dir}")
    else:
        json_files = [f for f in os.listdir(admin_dir) if f.endswith(".json")]
        if not json_files:
            errors.append(f"Nincs OpenAPI JSON fájl: {admin_dir}")
        for fname in json_files:
            fpath = os.path.join(admin_dir, fname)
            api_errors = validate_openapi_file(fpath, known_permissions, realm)
            errors.extend([f"[{fname}] {e}" for e in api_errors])

    return errors


# ── CLI belépési pont ──────────────────────────────────────────────────────────


def main(argv: list[str] | None = None) -> int:
    """CLI belépési pont. Visszaad 0-t sikerkor, 1-et hibák esetén."""
    args = argv if argv is not None else sys.argv[1:]

    if not args:
        print("Használat: validate-contract.py <contract_dir>", file=sys.stderr)
        print("Példa: python3 validate-contract.py templates/admin-contract", file=sys.stderr)
        return 2

    contract_dir = args[0]
    if not os.path.isdir(contract_dir):
        print(f"Hiba: nem könyvtár: {contract_dir}", file=sys.stderr)
        return 2

    print(f"Validálás: {os.path.abspath(contract_dir)}")
    errors = validate_directory(contract_dir)

    if errors:
        print(f"\n{len(errors)} hiba:")
        for err in errors:
            print(f"  ✗ {err}")
        return 1

    print("  ✓ Minden ellenőrzés sikeres")
    return 0


if __name__ == "__main__":
    sys.exit(main())

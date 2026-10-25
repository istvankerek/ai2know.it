#!/usr/bin/env python3
"""
Admin contract validator — belépési pont.

Futtatás a skeleton gyökeréből:
    python3 templates/admin-contract/scripts/validate-contract.py templates/admin-contract

A tényleges implementáció a validate_contract.py modulban van (alulvonással),
amelyet a tesztek közvetlenül importálnak.
"""

import os
import sys

# A validate_contract modul megkeresése az aktuális könyvtárból
sys.path.insert(0, os.path.dirname(__file__))
from validate_contract import main  # noqa: E402

if __name__ == "__main__":
    sys.exit(main())

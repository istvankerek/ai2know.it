"""Titok-mintak a promptban: talalatnal a run megall, semmi nem hagyja el a gepet."""

from __future__ import annotations

import re

# Forras: secret-detection skill mintai + okoszisztema specifikus prefixek (plan-v15 F5).
SECRET_PATTERNS: dict[str, re.Pattern[str]] = {
    "aws_access_key": re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    "anthropic_key": re.compile(r"\bsk-ant-[A-Za-z0-9_\-]{20,}"),
    "openai_key": re.compile(r"\bsk-(?:proj-)?[A-Za-z0-9]{32,}"),
    "github_token": re.compile(r"\bgh[pousr]_[A-Za-z0-9]{30,}"),
    "slack_token": re.compile(r"\bxox[abpr]-[A-Za-z0-9\-]{10,}"),
    "google_api_key": re.compile(r"\bAIza[0-9A-Za-z_\-]{35}\b"),
    "private_key": re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"),
    "db_url_with_password": re.compile(r"\b(?:postgres(?:ql)?|mysql|mongodb(?:\+srv)?|redis)://[^\s:/@]+:[^\s@/]+@"),
    "aibos_service_key": re.compile(r"\baibs_[A-Za-z0-9_]{16,}"),
    "everengine_api_key": re.compile(r"\bek_(?:live|test)_[A-Za-z0-9]{16,}"),
    "jwt": re.compile(r"\beyJ[A-Za-z0-9_\-]{10,}\.eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}"),
}


def find_secrets(text: str) -> list[str]:
    """Visszaadja a talalt titok-tipusok neveit (az erteket soha)."""
    return [name for name, pattern in SECRET_PATTERNS.items() if pattern.search(text)]

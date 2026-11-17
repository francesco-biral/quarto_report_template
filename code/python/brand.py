"""Read the report's brand colours from the Quarto configuration.

Merges `org:` from `_quarto.yaml` with any active profile file
(`_quarto-<profile>.yml`, profile taken from the QUARTO_PROFILE environment
variable that Quarto sets while executing code). Falls back to neutral
defaults if PyYAML or the files are unavailable, so plots always render.

Usage in a code cell:

    import sys; sys.path.insert(0, "code/python")
    from brand import brand
    b = brand()          # dict with primary, accent, ink, muted, line
"""

from __future__ import annotations

import os
from pathlib import Path

DEFAULTS = {
    "primary": "#004d80",
    "accent": "#d07a02",
    "ink": "#1b2530",
    "muted": "#647381",
    "line": "#d9e2e8",
}


def _hex(value: str | None, fallback: str) -> str:
    if not value:
        return fallback
    value = str(value).strip().lstrip("#")
    return f"#{value}"


def brand(root: str | os.PathLike = ".") -> dict:
    root = Path(root)
    org: dict = {}
    try:
        import yaml  # PyYAML

        files = [root / "_quarto.yaml", root / "_quarto.yml"]
        for prof in filter(None, os.environ.get("QUARTO_PROFILE", "").split(",")):
            files += [root / f"_quarto-{prof.strip()}.yml", root / f"_quarto-{prof.strip()}.yaml"]
        for f in files:
            if f.exists():
                data = yaml.safe_load(f.read_text(encoding="utf-8")) or {}
                org.update(data.get("org") or {})
    except Exception:
        pass

    colors = dict(DEFAULTS)
    colors["primary"] = _hex(org.get("primary-color"), DEFAULTS["primary"])
    colors["accent"] = _hex(org.get("accent-color"), DEFAULTS["accent"])
    return colors

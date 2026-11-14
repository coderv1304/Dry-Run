"""INTERNAL classifier evaluation.  Never publish these numbers as accuracy.

Run from the repository root: ``python scripts/eval_classifier.py``.
"""

from __future__ import annotations

import sys
from collections import Counter
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "backend"))

from app.engine.classifier import classify  # noqa: E402

LABELS = ["P1", "P2", "P3", "P4", "C1", "C2", "C3", "C4"]
FILES = {
    "en": ROOT / "tests" / "fixtures" / "utterances_en.yaml",
    "hi": ROOT / "tests" / "fixtures" / "utterances_hi.yaml",
    "hinglish": ROOT / "tests" / "fixtures" / "utterances_hinglish.yaml",
}


def evaluate(language: str, path: Path) -> tuple[dict[str, Counter[str]], int, int]:
    """Return a confusion table and hit/total counts for one fixture file."""
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    table: dict[str, Counter[str]] = {label: Counter() for label in LABELS}
    hits = total = 0
    for expected, rows in data["utterances"].items():
        for row in rows:
            result = classify(row["text"], language)
            predicted = result.label.value if result.label else "neutral"
            table[expected][predicted] += 1
            total += 1
            hits += int(predicted == expected)
    return table, hits, total


def main() -> None:
    """Print one confusion table per language for internal debugging."""
    columns = LABELS + ["neutral"]
    for language, path in FILES.items():
        table, hits, total = evaluate(language, path)
        print(f"\n=== {language} (internal only) ===")
        print("true\\pred".ljust(10) + "".join(column.rjust(8) for column in columns))
        for label in LABELS:
            row = "".join(str(table[label][column]).rjust(8) for column in columns)
            print(label.ljust(10) + row)
        print(f"fixture matches: {hits}/{total} (development signal, not an accuracy claim)")


if __name__ == "__main__":
    main()

"""Fails the build when copy promises more than the product can prove.

Scope: every string a participant, volunteer or judge can read. A phrase about
how the drill works is fine; a claim that it prevents fraud, protects a person,
is proven, or is the first of its kind is not. The disclaimer form is allowed
on purpose: "practice, not protection" is the required wording, so the word
protection passes only when it is negated nearby.

Run directly or through `make claims-lint`.
"""

from __future__ import annotations

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent

COPY_FILES = (
    "app/lib/l10n/app_en.arb",
    "app/lib/l10n/app_hi.arb",
    "app/lib/features/demo/demo_mode.dart",
    "backend/app/scenarios/digital_arrest.yaml",
    "landing/content.json",
    "landing/index.html",
    "landing/privacy.html",
    "landing/terms.html",
    "landing/404.html",
    "README.md",
    "docs/WHAT_EXISTS.md",
    "docs/ETHICS_AND_LIMITS.md",
    "docs/VOLUNTEER_PROTOCOL.md",
    "docs/RUNBOOK.md",
    "docs/PITCH.md",
)

# (pattern, label, negation allowed). Negation is allowed for the promise
# families only, because "does not prevent fraud" is the honest disclaimer.
BANNED_PATTERNS: tuple[tuple[str, str, bool], ...] = (
    (r"\bprevents? (fraud|scams?|losses?)\b", "a prevention promise", True),
    (r"\bprotects? (you|your|people|families)\b", "a protection promise", True),
    (r"\bprotects? you from\b", "a protection promise", True),
    (r"\bstops? scams?\b", "a prevention promise", True),
    (r"\bfirst of its kind\b", "an unprovable novelty claim", False),
    (r"\bnothing like this exists\b", "an unprovable novelty claim", False),
    (r"\baccuracy\b", "a number the classifier cannot support", False),
    (r"\b(proven|validated|guaranteed)\b", "a claim of proof or guarantee", True),
    (r"\b\d+(\.\d+)? ?% (accurate|success|effective)\b", "an unmeasured percentage", False),
    (r"\bprotects? against fraud\b", "a protection promise", True),
)

# A disclaimer is allowed to use the word, a promise is not.
PROTECTION = re.compile(r"\bprotection\b", re.IGNORECASE)
NEGATIONS = ("not ", "no ", "never ", "cannot ", "n t ")

REQUIRED = (
    ("practice", ("app/lib/l10n/app_en.arb", "landing/content.json", "README.md", "docs/ETHICS_AND_LIMITS.md")),
    (
        "as far as we could find",
        ("README.md", "docs/WHAT_EXISTS.md", "docs/ETHICS_AND_LIMITS.md"),
    ),
    ("not legal advice", ("docs/ETHICS_AND_LIMITS.md",)),
)


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def line_of(text: str, index: int) -> int:
    return text.count("\n", 0, index) + 1


def main() -> int:
    failures: list[str] = []
    for relative in COPY_FILES:
        text = read(relative)
        if not text:
            continue
        for pattern, label, allow_negation in BANNED_PATTERNS:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                if allow_negation:
                    window = text[max(0, match.start() - 18) : match.start()].lower()
                    if any(negation in window for negation in NEGATIONS):
                        continue
                failures.append(
                    f"{relative}:{line_of(text, match.start())} {label}: {match.group(0)!r}"
                )
        for match in PROTECTION.finditer(text):
            window = text[max(0, match.start() - 14) : match.start()].lower()
            if not any(negation in window for negation in NEGATIONS):
                failures.append(
                    f"{relative}:{line_of(text, match.start())} protection used as a promise: "
                    f"{text[max(0, match.start() - 20) : match.end() + 20]!r}"
                )

    for phrase, files in REQUIRED:
        for relative in files:
            text = read(relative)
            if not text:
                failures.append(f"{relative}: required wording check skipped, file missing")
            elif phrase not in text.lower():
                failures.append(f"{relative}: missing required wording {phrase!r}")

    json_path = ROOT / "landing" / "content.json"
    if json_path.exists():
        payload = json.loads(json_path.read_text(encoding="utf-8"))
        body = json.dumps(payload, ensure_ascii=False).lower()
        if "practice" not in body:
            failures.append("landing/content.json: the word practice is missing")

    if failures:
        print("CLAIMS LINT FAILED")
        for failure in failures:
            print("  " + failure)
        return 1
    print(
        "CLAIMS LINT PASSED: no prevention, protection, novelty, accuracy or proof claims "
        f"across {sum(1 for name in COPY_FILES if (ROOT / name).exists())} copy files"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())

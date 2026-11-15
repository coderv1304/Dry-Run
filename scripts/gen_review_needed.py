"""Generate docs/REVIEW_NEEDED.md from every Hindi line we can ship.

Sources:
  * ``backend/app/scenarios/digital_arrest.yaml`` (spoken and displayed lines)
  * ``app/lib/l10n/app_hi.arb`` (every Hindi interface string)

Run from the repository root: ``python scripts/gen_review_needed.py``.
Every line that can be shown or spoken to a participant must be reviewed by a
native Hindi speaker before production use.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "backend"))

from app.engine.scenario import DEFAULT_SCENARIO, Scenario  # noqa: E402

HEADER = """# Translations and Phrases Awaiting Human Review

Every Hindi and Hinglish line that the drill can show or speak must be reviewed
by a native Hindi speaker before production. This file is generated from
`backend/app/scenarios/digital_arrest.yaml` and `app/lib/l10n/app_hi.arb` by
`scripts/gen_review_needed.py`. Do not hand-edit the table: change the source
and regenerate.

Status meanings: `pending` means not yet approved for production. A reviewer
must record a name and date before the status becomes `approved`.

## Scenario Dialogues (Hindi & Hinglish)

| ID | Language | Context | Display text | Spoken text | Reviewer | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
"""

ARB_HEADER = """
## Interface Copy (Hindi ARB)

Every Hindi string the interface can render, including consent, drill, debrief,
share, delete, error, and About copy. Hinglish and English labels that appear in
the Hindi catalog are listed too, so a reviewer sees the whole file at once.

| Key | Proposed Hindi text | Reviewer | Status |
| :--- | :--- | :--- | :--- |
"""


def _cell(value: object) -> str:
    """Escape a value for a Markdown table cell."""
    return str(value).replace("|", "\\|").replace("\n", " ").strip()


def _scenario_rows() -> list[str]:
    scenario = Scenario.load(DEFAULT_SCENARIO, max_turns=12)
    rows: list[str] = []
    for entry in scenario.review_entries():
        stage, purpose, language = entry["id"].split(".", 2)
        rows.append(
            "| {id} | {language} | {context} | {display} | {speak} | Pending | pending |".format(
                id=entry["id"],
                language=entry["language"],
                context=f"{stage}/{purpose}",
                display=_cell(entry["display"]),
                speak=_cell(entry["speak"]),
            )
        )
    return rows


def _arb_rows() -> list[str]:
    path = ROOT / "app" / "lib" / "l10n" / "app_hi.arb"
    catalog = json.loads(path.read_text(encoding="utf-8"))
    rows: list[str] = []
    for key, value in catalog.items():
        if key.startswith("@"):
            continue
        if not isinstance(value, str):
            continue
        rows.append(
            "| {key} | {text} | Pending | pending |".format(
                key=key,
                text=_cell(value),
            )
        )
    return rows


def main() -> None:
    """Write the deterministic review catalog."""
    scenario_rows = _scenario_rows()
    arb_rows = _arb_rows()
    output = (
        HEADER
        + "\n".join(scenario_rows)
        + "\n"
        + ARB_HEADER
        + "\n".join(arb_rows)
        + "\n"
    )
    (ROOT / "docs" / "REVIEW_NEEDED.md").write_text(output, encoding="utf-8")
    print(
        "wrote %d scenario lines and %d interface strings to docs/REVIEW_NEEDED.md"
        % (len(scenario_rows), len(arb_rows))
    )


if __name__ == "__main__":
    main()

"""Generate docs/REVIEW_NEEDED.md from every Hindi/Hinglish scenario line.

Run from the repository root: ``python scripts/gen_review_needed.py``.
Every line that can be shown or spoken to a participant must be reviewed by a
native Hindi speaker before production use.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "backend"))

from app.engine.scenario import DEFAULT_SCENARIO, Scenario  # noqa: E402

HEADER = """# Translations and Phrases Awaiting Human Review

Every Hindi and Hinglish line that the drill can show or speak must be reviewed
by a native Hindi speaker before production. This file is generated from
`backend/app/scenarios/digital_arrest.yaml` by `scripts/gen_review_needed.py`.
Do not hand-edit the table: change the scenario and regenerate.

Status meanings: `pending` means not yet approved for production. A reviewer
must record a name and date before the status becomes `approved`.

## Scenario Dialogues (Hindi & Hinglish)

| ID | Language | Context | Display text | Spoken text | Reviewer | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
"""

FOOTER = """
## Consent and Debrief Copy

The client renders consent, share, and debrief copy from reviewed catalogs. Any
future Hindi or Hinglish copy must be added here with the same reviewer gate
before it ships. No real agency, bank, phone number, account, IFSC, or UPI
identifier may appear in this file.

| ID | Language | Context | Proposed text | Reviewer | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| CNS-001 | hi | Practice-call consent | यह केवल एक अभ्यास ड्रिल है, कोई वास्तविक एजेंसी नहीं। | Pending | pending |
| CNS-002 | hinglish | Practice-call consent | Yeh sirf ek practice drill hai, koi asli agency nahi. | Pending | pending |
| HBT-001 | hi | Debrief habit: hang up | फोन तुरंत बंद करें और किसी को भी पैसे न भेजें। | Pending | pending |
| HBT-002 | hinglish | Debrief habit: verify | Sirf sarkari official channel se hi verify karein. | Pending | pending |
"""


def main() -> None:
    """Write the deterministic review catalog."""
    scenario = Scenario.load(DEFAULT_SCENARIO, max_turns=12)
    rows = []
    for entry in scenario.review_entries():
        stage, purpose, language = entry["id"].split(".", 2)
        rows.append(
            "| {id} | {language} | {context} | {display} | {speak} | Pending | pending |".format(
                id=entry["id"],
                language=entry["language"],
                context=f"{stage}/{purpose}",
                display=entry["display"].replace("|", "\\|"),
                speak=entry["speak"].replace("|", "\\|"),
            )
        )
    output = HEADER + "\n".join(rows) + "\n" + FOOTER
    (ROOT / "docs" / "REVIEW_NEEDED.md").write_text(output, encoding="utf-8")
    print(f"wrote {len(rows)} scenario lines to docs/REVIEW_NEEDED.md")


if __name__ == "__main__":
    main()

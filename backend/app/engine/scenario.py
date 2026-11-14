"""Scenario YAML loading and deterministic line selection."""

from __future__ import annotations

from pathlib import Path
from random import Random
from typing import Literal

import yaml
from pydantic import BaseModel, ConfigDict, Field

Language = Literal["en", "hi", "hinglish"]
LANGUAGES: tuple[Language, ...] = ("en", "hi", "hinglish")
GLOBAL_PURPOSES = (
    "verify_deflect",
    "verify_escalate",
    "family_push",
    "hesitation",
    "reframe",
    "pii_warning",
)
DEFAULT_SCENARIO = Path(__file__).resolve().parent.parent / "scenarios" / "digital_arrest.yaml"


class BilingualLine(BaseModel):
    """One reviewed line with display and speech forms."""

    model_config = ConfigDict(extra="forbid")

    display: str = Field(min_length=1, max_length=400)
    speak: str = Field(min_length=1, max_length=400)


class LanguageLine(BaseModel):
    """The same line in all supported languages."""

    model_config = ConfigDict(extra="forbid")

    en: BilingualLine
    hi: BilingualLine
    hinglish: BilingualLine

    def for_language(self, language: Language) -> BilingualLine:
        """Return the chosen language form."""
        if language == "hi":
            return self.hi
        if language == "hinglish":
            return self.hinglish
        return self.en


class StageContent(BaseModel):
    """Lines belonging to one of the five stages."""

    model_config = ConfigDict(extra="forbid")

    label_en: str
    label_hi: str
    opening: LanguageLine
    default: LanguageLine


class ScenarioFile(BaseModel):
    """Validated shape of the scenario YAML file."""

    model_config = ConfigDict(extra="forbid")

    id: str
    version: int
    fictional: bool
    agency: dict[str, str]
    languages: list[str]
    stages: dict[str, StageContent]
    global_lines: dict[str, LanguageLine]


class Scenario:
    """Runtime scenario with selection helpers used by the service layer."""

    def __init__(self, data: ScenarioFile, max_turns: int) -> None:
        self.data = data
        self.max_turns = max_turns

    @classmethod
    def load(cls, path: Path | str | None, max_turns: int) -> Scenario:
        """Load and validate a scenario file."""
        target = Path(path) if path else DEFAULT_SCENARIO
        with target.open("r", encoding="utf-8") as handle:
            raw = yaml.safe_load(handle)
        return cls(ScenarioFile.model_validate(raw), max_turns=max_turns)

    @property
    def stage_ids(self) -> list[str]:
        """Return stage identifiers only, never script text."""
        return list(self.data.stages)

    def line_for(
        self,
        stage: str,
        pressure: int,
        language: Language,
        purpose: str,
        rng: Random,
        pii_warning: bool = False,
    ) -> dict[str, str]:
        """Choose the current officer line.

        The RNG is used only to pick among equivalent scripted variants; it
        never changes state.  There is currently one variant per purpose.
        """
        del pressure, rng
        if pii_warning:
            chosen = self.data.global_lines["pii_warning"]
        elif purpose in GLOBAL_PURPOSES:
            chosen = self.data.global_lines.get(purpose, self.data.stages[stage].default)
        elif purpose == "opening" and stage == "contact":
            chosen = self.data.stages[stage].opening
        else:
            stage_content = self.data.stages.get(stage)
            if stage_content is None:
                raise KeyError(f"unknown stage: {stage}")
            chosen = stage_content.default
        line = chosen.for_language(language)
        return {"display": line.display, "speak": line.speak, "language": language}

    def review_entries(self) -> list[dict[str, str]]:
        """Yield every Hindi and Hinglish line for the human review catalog."""
        entries: list[dict[str, str]] = []
        for stage_id, stage in self.data.stages.items():
            for purpose, line in (("opening", stage.opening), ("default", stage.default)):
                for language in ("hi", "hinglish"):
                    form = line.for_language(language)  # type: ignore[arg-type]
                    entries.append(
                        {
                            "id": f"{stage_id}.{purpose}.{language}",
                            "language": language,
                            "display": form.display,
                            "speak": form.speak,
                        }
                    )
        for purpose, line in self.data.global_lines.items():
            for language in ("hi", "hinglish"):
                form = line.for_language(language)  # type: ignore[arg-type]
                entries.append(
                    {
                        "id": f"global.{purpose}.{language}",
                        "language": language,
                        "display": form.display,
                        "speak": form.speak,
                    }
                )
        return entries


__all__ = ["LANGUAGES", "Language", "Scenario", "ScenarioFile"]

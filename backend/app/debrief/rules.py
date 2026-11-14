"""Deterministic debrief derivation from rule labels."""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass

from app.schemas import (
    DebriefContent,
    DebriefEvent,
    FirstCompliance,
    QuoteReference,
    StatePathItem,
)


@dataclass(frozen=True, slots=True)
class TurnView:
    """Debrief projection of one persisted turn."""

    turn_index: int
    label: str | None
    confidence: float
    stage_id: str
    text: str
    quote_text: str | None = None
    quote_start: int | None = None
    quote_end: int | None = None


def _quote(turn: TurnView) -> QuoteReference | None:
    if turn.quote_text is None or turn.quote_start is None or turn.quote_end is None:
        return None
    if turn.text[turn.quote_start : turn.quote_end] != turn.quote_text:
        return None
    return QuoteReference(text=turn.quote_text, start=turn.quote_start, end=turn.quote_end)


def did_well_ids(labels: Sequence[str]) -> list[str]:
    """Map protective labels to the reviewed did-well catalog."""
    found: list[str] = []
    if "P1" in labels:
        found.append("refused_private_call")
    if "P2" in labels:
        found.append("asked_badge_number")
    if "P4" in labels:
        found.append("recognized_urgency_tactic")
    if labels and "C4" not in labels:
        found.append("refused_money_transfer")
    return found


def habit_id(labels: Sequence[str]) -> str:
    """Choose exactly one reviewed habit suggestion."""
    if "P3" in labels:
        return "tell_family"
    if "P2" in labels:
        return "call_back_official"
    return "hang_up"


def first_compliance(turns: Sequence[TurnView]) -> FirstCompliance | None:
    """Return the first C-labelled turn, if any."""
    for turn in turns:
        if turn.label and turn.label.startswith("C"):
            return FirstCompliance(
                turn_index=turn.turn_index,
                stage_id=turn.stage_id,  # type: ignore[arg-type]
                label=turn.label,  # type: ignore[arg-type]
            )
    return None


def build_content(
    turns: Sequence[TurnView],
    quality: str,
    low_confidence: bool = False,
    overrides: dict[int, DebriefEvent] | None = None,
) -> DebriefContent:
    """Build debrief content from turns and optional reconciled overrides."""
    labelled = [turn for turn in turns if turn.label]
    events: list[DebriefEvent] = []
    for turn in labelled:
        override = (overrides or {}).get(turn.turn_index)
        if override is not None:
            events.append(override)
            continue
        events.append(
            DebriefEvent(
                turn_index=turn.turn_index,
                label=turn.label,  # type: ignore[arg-type]
                confidence=max(0.0, min(1.0, turn.confidence)),
                quote=_quote(turn),
            )
        )
    labels = [event.label for event in events]
    state_path = [
        StatePathItem(stage_id=turn.stage_id, turn_index=turn.turn_index)  # type: ignore[arg-type]
        for turn in turns
    ]
    return DebriefContent(
        quality="full" if quality == "full" else "quick",
        low_confidence=low_confidence,
        state_path=state_path,
        events=events,
        first_compliance=first_compliance(labelled),
        did_well_ids=did_well_ids(labels),
        habit_id=habit_id(labels),  # type: ignore[arg-type]
    )


__all__ = ["TurnView", "build_content", "did_well_ids", "first_compliance", "habit_id"]

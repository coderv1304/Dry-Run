"""Immutable engine value objects and transition constants."""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Literal, Protocol


class Stage(str, Enum):
    """The five escalation stages of the fictional drill."""

    CONTACT = "contact"
    ACCUSATION = "accusation"
    ISOLATION = "isolation"
    URGENCY = "urgency"
    TRANSFER = "transfer"


STAGE_ORDER: tuple[Stage, ...] = (
    Stage.CONTACT,
    Stage.ACCUSATION,
    Stage.ISOLATION,
    Stage.URGENCY,
    Stage.TRANSFER,
)

# Explicit transition table.  The final stage is absorbing; only the turn cap
# or a terminal event leaves it.
STAGE_TRANSITIONS: dict[Stage, Stage] = {
    Stage.CONTACT: Stage.ACCUSATION,
    Stage.ACCUSATION: Stage.ISOLATION,
    Stage.ISOLATION: Stage.URGENCY,
    Stage.URGENCY: Stage.TRANSFER,
    Stage.TRANSFER: Stage.TRANSFER,
}


class Label(str, Enum):
    """Deterministic participant labels.  P = protective, C = compliance."""

    P1 = "P1"
    P2 = "P2"
    P3 = "P3"
    P4 = "P4"
    C1 = "C1"
    C2 = "C2"
    C3 = "C3"
    C4 = "C4"


PROTECTIVE_LABELS: frozenset[Label] = frozenset(
    {Label.P1, Label.P2, Label.P3, Label.P4}
)
COMPLIANCE_LABELS: frozenset[Label] = frozenset(
    {Label.C1, Label.C2, Label.C3, Label.C4}
)
ALL_LABELS: tuple[Label, ...] = tuple(Label)


class EndReason(str, Enum):
    """Every way a drill can terminate."""

    HUNG_UP = "hung_up"
    VERIFIED_CALLBACK = "verified_callback"
    COMPLIED_TRANSFER = "complied_transfer"
    TURN_CAP = "turn_cap"
    TIMEOUT = "timeout"
    PARTICIPANT_ENDED = "participant_ended"


class EventKind(str, Enum):
    """Kinds of input accepted by the pure reducer."""

    START = "start"
    PARTICIPANT = "participant"
    END = "end"
    TIMEOUT = "timeout"


class ScenarioLike(Protocol):
    """Minimal scenario contract needed by the reducer."""

    max_turns: int


@dataclass(frozen=True, slots=True)
class EngineState:
    """Complete deterministic state of one drill."""

    stage: Stage = Stage.CONTACT
    pressure: int = 0
    turn_index: int = 0
    status: Literal["active", "ended"] = "active"
    end_reason: EndReason | None = None
    complied_once: bool = False
    verification_count: int = 0
    family_count: int = 0
    hesitation_count: int = 0
    last_label: str | None = None
    purpose: str = "opening"

    @property
    def active(self) -> bool:
        """Return whether the drill still accepts participant turns."""
        return self.status == "active"


@dataclass(frozen=True, slots=True)
class EngineEvent:
    """An input event.  Participant text never reaches the reducer."""

    kind: EventKind
    label: Label | None = None
    reason: EndReason | None = None


@dataclass(frozen=True, slots=True)
class Effect:
    """A declarative instruction for the service layer."""

    kind: Literal["request_line", "record_event"]
    payload: dict[str, object] = field(default_factory=dict)

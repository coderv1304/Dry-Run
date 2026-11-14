"""Exact replay of recorded events without providers or line generation."""

from __future__ import annotations

from collections.abc import Sequence
from random import Random

from app.engine.engine import create_initial_state, step
from app.engine.types import Effect, EngineEvent, EngineState, ScenarioLike


def replay(
    events: Sequence[EngineEvent],
    scenario: ScenarioLike,
    seed: int,
) -> list[tuple[EngineState, list[Effect]]]:
    """Replay events and return every intermediate state and effect."""
    state = create_initial_state()
    rng = Random(seed)  # nosec B311
    frames: list[tuple[EngineState, list[Effect]]] = []
    for event in events:
        state, effects = step(state, event, scenario, rng)
        frames.append((state, effects))
    return frames


__all__ = ["replay"]

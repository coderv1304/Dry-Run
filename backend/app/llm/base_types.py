"""Shared LLM value types."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class LlmResult:
    """Raw provider completion with token accounting."""

    text: str
    input_tokens: int = 0
    output_tokens: int = 0


__all__ = ["LlmResult"]

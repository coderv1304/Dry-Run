"""LLM provider interface and result types."""

from __future__ import annotations

from typing import Protocol

from app.llm.base_types import LlmResult


class LlmProvider(Protocol):
    """Minimal async completion interface used by all tiers."""

    async def complete(
        self,
        model: str,
        system: str,
        user: str,
        max_tokens: int,
        timeout: float,
    ) -> LlmResult:
        """Return a raw completion or raise on any provider failure."""


__all__ = ["LlmProvider", "LlmResult"]

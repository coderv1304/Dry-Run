"""HTTP adapters for OpenAI-compatible and Anthropic message APIs."""

from __future__ import annotations

import logging

import httpx

from app.config import Settings
from app.llm.base_types import LlmResult

logger = logging.getLogger("dryrun.llm")


class ProviderError(RuntimeError):
    """Raised when a provider cannot produce a completion."""


class OpenAICompatibleProvider:
    """Adapter for the OpenAI chat completions shape."""

    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    async def complete(
        self,
        model: str,
        system: str,
        user: str,
        max_tokens: int,
        timeout: float,
    ) -> LlmResult:
        """POST a chat completion and parse usage."""
        url = f"{self._settings.llm_base_url.rstrip('/')}/chat/completions"
        payload = {
            "model": model,
            "messages": [
                {"role": "system", "content": system},
                {"role": "user", "content": user},
            ],
            "max_tokens": max_tokens,
            "temperature": 0.6,
        }
        headers = {"Authorization": f"Bearer {self._settings.llm_api_key or ''}"}
        try:
            async with httpx.AsyncClient(timeout=timeout) as client:
                response = await client.post(url, json=payload, headers=headers)
                response.raise_for_status()
                body = response.json()
            text = body["choices"][0]["message"]["content"]
            usage = body.get("usage", {})
            return LlmResult(
                text=text,
                input_tokens=int(usage.get("prompt_tokens", 0)),
                output_tokens=int(usage.get("completion_tokens", 0)),
            )
        except (httpx.HTTPError, KeyError, IndexError, TypeError, ValueError) as exc:
            logger.warning("llm_provider_failure", extra={"provider": "openai_compatible"})
            raise ProviderError("provider request failed") from exc


class AnthropicProvider:
    """Adapter for the Anthropic messages API."""

    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    async def complete(
        self,
        model: str,
        system: str,
        user: str,
        max_tokens: int,
        timeout: float,
    ) -> LlmResult:
        """POST a messages request and parse usage."""
        url = f"{self._settings.llm_base_url.rstrip('/')}/v1/messages"
        payload = {
            "model": model,
            "system": system,
            "messages": [{"role": "user", "content": user}],
            "max_tokens": max_tokens,
            "temperature": 0.6,
        }
        headers = {
            "x-api-key": self._settings.llm_api_key or "",
            "anthropic-version": "2023-06-01",
        }
        try:
            async with httpx.AsyncClient(timeout=timeout) as client:
                response = await client.post(url, json=payload, headers=headers)
                response.raise_for_status()
                body = response.json()
            text = body["content"][0]["text"]
            usage = body.get("usage", {})
            return LlmResult(
                text=text,
                input_tokens=int(usage.get("input_tokens", 0)),
                output_tokens=int(usage.get("output_tokens", 0)),
            )
        except (httpx.HTTPError, KeyError, IndexError, TypeError, ValueError) as exc:
            logger.warning("llm_provider_failure", extra={"provider": "anthropic"})
            raise ProviderError("provider request failed") from exc


def build_provider(settings: Settings) -> OpenAICompatibleProvider | AnthropicProvider:
    """Select the provider adapter from environment configuration."""
    if settings.llm_provider == "anthropic":
        return AnthropicProvider(settings)
    return OpenAICompatibleProvider(settings)


__all__ = ["AnthropicProvider", "OpenAICompatibleProvider", "ProviderError", "build_provider"]

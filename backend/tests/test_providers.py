"""Provider adapter success and failure tests using a fake HTTP transport."""

from __future__ import annotations

import asyncio

import httpx
import pytest

from app.config import Settings
from app.llm.providers import (
    AnthropicProvider,
    OpenAICompatibleProvider,
    ProviderError,
    build_provider,
)


class _Response:
    def __init__(self, body: dict) -> None:
        self._body = body

    def raise_for_status(self) -> None:
        return None

    def json(self) -> dict:
        return self._body


class _Client:
    def __init__(self, response: object) -> None:
        self.response = response
        self.posts: list[dict] = []

    async def __aenter__(self):
        return self

    async def __aexit__(self, *exc) -> None:
        return None

    async def post(self, url, json=None, headers=None):
        self.posts.append({"url": url, "json": json, "headers": headers})
        if isinstance(self.response, Exception):
            raise self.response
        return self.response


def _settings(**overrides: object) -> Settings:
    return Settings(env="test", llm_api_key="key", llm_base_url="https://llm.example/v1").model_copy(
        update=overrides
    )


def _patch(monkeypatch, response: object) -> _Client:
    client = _Client(response)
    monkeypatch.setattr("app.llm.providers.httpx.AsyncClient", lambda **kwargs: client)
    return client


def test_openai_compatible_success(monkeypatch) -> None:
    client = _patch(
        monkeypatch,
        _Response(
            {
                "choices": [{"message": {"content": "hello"}}],
                "usage": {"prompt_tokens": 7, "completion_tokens": 3},
            }
        ),
    )
    provider = OpenAICompatibleProvider(_settings())
    result = asyncio.run(
        provider.complete(model="m", system="s", user="u", max_tokens=10, timeout=1.0)
    )
    assert result.text == "hello"
    assert result.input_tokens == 7
    assert result.output_tokens == 3
    assert client.posts[0]["url"] == "https://llm.example/v1/chat/completions"
    assert client.posts[0]["headers"]["Authorization"] == "Bearer key"


def test_anthropic_success(monkeypatch) -> None:
    client = _patch(
        monkeypatch,
        _Response(
            {
                "content": [{"text": "hello"}],
                "usage": {"input_tokens": 4, "output_tokens": 2},
            }
        ),
    )
    provider = AnthropicProvider(_settings())
    result = asyncio.run(
        provider.complete(model="m", system="s", user="u", max_tokens=10, timeout=1.0)
    )
    assert result.text == "hello"
    assert result.input_tokens == 4
    assert client.posts[0]["url"] == "https://llm.example/v1/v1/messages"


@pytest.mark.parametrize("provider_class", [OpenAICompatibleProvider, AnthropicProvider])
def test_provider_failures_raise_provider_error(monkeypatch, provider_class) -> None:
    _patch(monkeypatch, httpx.ConnectError("network down"))
    provider = provider_class(_settings())
    with pytest.raises(ProviderError):
        asyncio.run(provider.complete(model="m", system="s", user="u", max_tokens=1, timeout=1.0))


@pytest.mark.parametrize("provider_class", [OpenAICompatibleProvider, AnthropicProvider])
def test_malformed_provider_payload_raises_provider_error(monkeypatch, provider_class) -> None:
    _patch(monkeypatch, _Response({"unexpected": True}))
    with pytest.raises(ProviderError):
        asyncio.run(
            provider_class(_settings()).complete(
                model="m", system="s", user="u", max_tokens=1, timeout=1.0
            )
        )


def test_build_provider_selects_anthropic() -> None:
    assert isinstance(build_provider(_settings(llm_provider="anthropic")), AnthropicProvider)
    assert isinstance(
        build_provider(_settings(llm_provider="openai_compatible")),
        OpenAICompatibleProvider,
    )

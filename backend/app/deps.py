"""Request-scoped helpers for state, client IP, and rate limits."""

from __future__ import annotations

from fastapi import Request

from app.config import Settings
from app.errors import ApiProblem
from app.security import RateLimiter, client_ip, hash_token


def settings_of(request: Request) -> Settings:
    """Return the app settings."""
    return request.app.state.settings


def limiter_of(request: Request) -> RateLimiter:
    """Return the in-memory limiter."""
    return request.app.state.rate_limiter


def ip_of(request: Request) -> str:
    """Resolve the client IP through trusted proxies."""
    return client_ip(request, settings_of(request).trusted_proxy_count)


def _reject(retry_after: int) -> None:
    raise ApiProblem(
        429,
        "rate_limited",
        "Rate limited",
        "Too many requests. Try again later.",
        headers={"Retry-After": str(retry_after)},
    )


def enforce_invite_limits(request: Request) -> None:
    """Apply per-IP invite and global daily invite caps."""
    settings = settings_of(request)
    limiter = limiter_of(request)
    ip = ip_of(request)
    allowed, retry = limiter.allow(
        f"invite:ip:{ip}", settings.invite_per_ip_per_hour, 3600
    )
    if not allowed:
        _reject(retry)
    allowed, retry = limiter.allow(
        "invite:global", settings.invite_global_daily_cap, 86400
    )
    if not allowed:
        _reject(retry)


def enforce_turn_limits(request: Request, raw_token: str) -> None:
    """Apply per-IP and per-token turn limits."""
    settings = settings_of(request)
    limiter = limiter_of(request)
    ip = ip_of(request)
    allowed, retry = limiter.allow(
        f"turn:ip:{ip}", settings.turn_per_ip_per_minute, 60
    )
    if not allowed:
        _reject(retry)
    token_key = hash_token(raw_token, settings.token_pepper)
    allowed, retry = limiter.allow(
        f"turn:token:{token_key}", settings.turn_per_token_per_minute, 60
    )
    if not allowed:
        _reject(retry)


def enforce_ip_limit(request: Request, name: str, limit: int = 120) -> None:
    """Apply a generic per-IP limit to a session endpoint."""
    allowed, retry = limiter_of(request).allow(
        f"{name}:ip:{ip_of(request)}", limit, 60
    )
    if not allowed:
        _reject(retry)


__all__ = [
    "enforce_invite_limits",
    "enforce_ip_limit",
    "enforce_turn_limits",
    "ip_of",
    "limiter_of",
    "settings_of",
]

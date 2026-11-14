"""Token generation, hashing, client-IP parsing, and in-memory limits."""

from __future__ import annotations

import hashlib
import hmac
import secrets
import threading
import time
from collections import defaultdict, deque
from collections.abc import Callable

from fastapi import Request


def hash_token(token: str, pepper: str) -> str:
    """Hash a bearer token at rest with the deployment pepper."""
    return hashlib.sha256(f"{pepper}:{token}".encode()).hexdigest()


def token_matches(raw: str, stored_hash: str, pepper: str) -> bool:
    """Constant-time token comparison."""
    return hmac.compare_digest(hash_token(raw, pepper), stored_hash)


def new_token(prefix: str) -> str:
    """Create a 128-bit random token with a human-readable prefix."""
    return f"{prefix}_{secrets.token_urlsafe(16)}"


def new_session_id() -> str:
    """Create a non-secret session identifier."""
    return f"ses_{secrets.token_urlsafe(12).replace('-', '').replace('_', '')[:20]}"


def client_ip(request: Request, trusted_proxy_count: int) -> str:
    """Resolve client IP using the configured number of trusted proxies."""
    peer = request.client.host if request.client else "unknown"
    if trusted_proxy_count <= 0:
        return peer
    forwarded = request.headers.get("x-forwarded-for", "")
    chain = [part.strip() for part in forwarded.split(",") if part.strip()]
    chain.append(peer)
    index = max(0, len(chain) - 1 - trusted_proxy_count)
    return chain[index]


class RateLimiter:
    """Thread-safe sliding-window limiter for a single instance."""

    def __init__(self, clock: Callable[[], float] = time.monotonic) -> None:
        self._clock = clock
        self._events: dict[str, deque[float]] = defaultdict(deque)
        self._lock = threading.Lock()

    def allow(self, key: str, limit: int, window_seconds: int) -> tuple[bool, int]:
        """Record a hit and return (allowed, retry_after_seconds)."""
        if limit <= 0:
            return False, window_seconds
        now = self._clock()
        cutoff = now - window_seconds
        with self._lock:
            bucket = self._events[key]
            while bucket and bucket[0] <= cutoff:
                bucket.popleft()
            if len(bucket) >= limit:
                retry = max(1, int(window_seconds - (now - bucket[0])))
                return False, retry
            bucket.append(now)
            return True, 0

    def reset(self, prefix: str | None = None) -> None:
        """Clear counters, primarily for tests."""
        with self._lock:
            if prefix is None:
                self._events.clear()
                return
            for key in [item for item in self._events if item.startswith(prefix)]:
                del self._events[key]


__all__ = [
    "RateLimiter",
    "client_ip",
    "hash_token",
    "new_session_id",
    "new_token",
    "token_matches",
]

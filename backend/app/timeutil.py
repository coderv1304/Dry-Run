"""Small time helpers that keep UTC handling consistent."""

from __future__ import annotations

from datetime import UTC, datetime


def utcnow() -> datetime:
    """Return the current timezone-aware UTC time."""
    return datetime.now(UTC)


def ensure_utc(value: datetime) -> datetime:
    """Attach UTC to naive datetimes read back from SQLite."""
    if value.tzinfo is None:
        return value.replace(tzinfo=UTC)
    return value.astimezone(UTC)


def isoformat(value: datetime) -> str:
    """Render an ISO-8601 UTC timestamp with a trailing Z."""
    return ensure_utc(value).isoformat().replace("+00:00", "Z")


__all__ = ["ensure_utc", "isoformat", "utcnow"]

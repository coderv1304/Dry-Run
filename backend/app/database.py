"""Database engine construction and short-lived session helpers."""

from __future__ import annotations

from collections.abc import Generator
from contextlib import contextmanager

from sqlalchemy import Engine, create_engine, event, text
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.models import Base


def _enable_sqlite_foreign_keys(dbapi_connection: object, connection_record: object) -> None:
    """SQLite needs an explicit pragma for cascading deletes."""
    del connection_record
    cursor = dbapi_connection.cursor()  # type: ignore[attr-defined]
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.close()


class Database:
    """Owns one engine and creates short transactions per request."""

    def __init__(self, url: str) -> None:
        kwargs: dict[str, object] = {"pool_pre_ping": True, "future": True}
        if url.startswith("sqlite"):
            kwargs["connect_args"] = {"check_same_thread": False, "timeout": 5}
            if ":memory:" in url:
                kwargs["poolclass"] = StaticPool
        self.engine: Engine = create_engine(url, **kwargs)
        if url.startswith("sqlite"):
            event.listen(self.engine, "connect", _enable_sqlite_foreign_keys)
        self.session_factory = sessionmaker(
            bind=self.engine,
            autoflush=False,
            expire_on_commit=False,
            class_=Session,
        )

    def create_all(self) -> None:
        """Create the schema.  Production uses Alembic instead."""
        Base.metadata.create_all(self.engine)

    def drop_all(self) -> None:
        """Drop the schema, used only by tests."""
        Base.metadata.drop_all(self.engine)

    def check(self) -> bool:
        """Run a cheap readiness query."""
        with self.engine.connect() as connection:
            connection.execute(text("SELECT 1"))
        return True

    @contextmanager
    def transaction(self) -> Generator[Session, None, None]:
        """Yield a session and commit or roll back atomically."""
        session = self.session_factory()
        try:
            yield session
            session.commit()
        except Exception:
            session.rollback()
            raise
        finally:
            session.close()

    def dispose(self) -> None:
        """Dispose pooled connections."""
        self.engine.dispose()


__all__ = ["Database"]

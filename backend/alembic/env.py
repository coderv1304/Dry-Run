"""Alembic environment for Dry Run."""

from __future__ import annotations

import os
from logging.config import fileConfig

from alembic import context
from app.config import Settings
from app.database import Database
from app.models import Base

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

settings = Settings.from_env()
target_metadata = Base.metadata


def _url() -> str:
    """Prefer DATABASE_URL so migrations never need a checked-in URL."""
    return os.environ.get("DATABASE_URL", settings.database_url)


def run_migrations_offline() -> None:
    """Emit SQL without a database connection."""
    context.configure(
        url=_url(),
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
    )
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Run migrations against the configured database."""
    database = Database(_url())
    with database.engine.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
        )
        with context.begin_transaction():
            context.run_migrations()
    database.dispose()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()

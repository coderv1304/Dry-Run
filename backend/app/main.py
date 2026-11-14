"""FastAPI application factory and contract-first OpenAPI document."""

from __future__ import annotations

import asyncio
import contextlib
import os
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from pathlib import Path

import yaml
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.utils import get_openapi

from app.config import Settings
from app.database import Database
from app.engine.scenario import Scenario
from app.errors import install_error_handlers
from app.llm.budget import BudgetTracker
from app.llm.line_writer import LineWriter
from app.llm.providers import build_provider
from app.middleware import (
    BodyLimitMiddleware,
    ObservabilityMiddleware,
    SecurityHeadersMiddleware,
)
from app.observability import configure_logging
from app.purge import purge_loop
from app.routes import invites, meta, reports, sessions
from app.security import RateLimiter


def _contract_path() -> Path | None:
    """Find the reviewed OpenAPI contract across dev and container layouts."""
    candidates = [
        Path(value)
        for value in (
            os.getenv("CONTRACT_PATH", ""),
            str(Path(__file__).resolve().parents[2] / "contracts" / "openapi.yaml"),
            str(Path.cwd() / "contracts" / "openapi.yaml"),
        )
        if value
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def create_app(settings: Settings | None = None) -> FastAPI:
    """Build an application with all state attached for testability."""
    resolved = settings or Settings.from_env()
    database = Database(resolved.database_url)
    scenario = Scenario.load(resolved.scenario_path, max_turns=resolved.max_turns)
    budget = BudgetTracker(database, resolved)
    provider = build_provider(resolved) if resolved.llm_enabled else None
    writer = LineWriter(resolved, scenario, budget, provider)

    @asynccontextmanager
    async def lifespan(app: FastAPI) -> AsyncIterator[None]:
        configure_logging(resolved.log_level)
        if resolved.env in {"test", "development"} or resolved.auto_create_schema:
            database.create_all()
        task: asyncio.Task[None] | None = None
        if resolved.env != "test" and resolved.purge_interval_seconds > 0:
            task = asyncio.create_task(purge_loop(database, resolved))
        yield
        if task is not None:
            task.cancel()
            with contextlib.suppress(asyncio.CancelledError):
                await task
        database.dispose()

    application = FastAPI(
        title="Dry Run API",
        version="1.0.0",
        description="Backend service for the Dry Run digital arrest scam practice drill.",
        lifespan=lifespan,
    )
    application.state.settings = resolved
    application.state.db = database
    application.state.scenario = scenario
    application.state.budget = budget
    application.state.provider = provider
    application.state.line_writer = writer
    application.state.rate_limiter = RateLimiter()

    install_error_handlers(application)
    application.add_middleware(BodyLimitMiddleware, settings=resolved)
    application.add_middleware(ObservabilityMiddleware)
    application.add_middleware(SecurityHeadersMiddleware)
    application.add_middleware(
        CORSMiddleware,
        allow_origins=list(resolved.cors_origins),
        allow_credentials=False,
        allow_methods=["GET", "POST", "DELETE", "OPTIONS"],
        allow_headers=[
            "Content-Type",
            "X-Invite-Token",
            "X-Session-Token",
            "X-Report-Token",
            "X-Request-ID",
        ],
        expose_headers=["Server-Timing", "X-Request-ID", "Retry-After"],
        max_age=600,
    )

    for router in (meta.router, invites.router, sessions.router, reports.router):
        application.include_router(router)

    def custom_openapi() -> dict[str, object]:
        if application.openapi_schema:
            return application.openapi_schema
        contract = _contract_path()
        if contract is not None:
            with contract.open("r", encoding="utf-8") as handle:
                application.openapi_schema = yaml.safe_load(handle)
            return application.openapi_schema
        application.openapi_schema = get_openapi(
            title=application.title,
            version=application.version,
            routes=application.routes,
        )
        return application.openapi_schema

    application.openapi = custom_openapi  # type: ignore[method-assign]
    return application


app = create_app()

__all__ = ["app", "create_app"]

"""Public health, configuration, and scenario-graph endpoints."""

from __future__ import annotations

from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse

from app.engine.types import ALL_LABELS
from app.schemas import (
    ConfigFlags,
    ConfigLimits,
    ConfigResponse,
    HealthResponse,
    ScenarioGraphResponse,
)

router = APIRouter()


@router.get("/healthz", response_model=HealthResponse)
def healthz() -> HealthResponse:
    """Cheap liveness probe that performs no I/O."""
    return HealthResponse(status="ok")


@router.get("/readyz", response_model=HealthResponse)
def readyz(request: Request) -> HealthResponse | JSONResponse:
    """Readiness probe that verifies the database."""
    try:
        request.app.state.db.check()
    except Exception:  # noqa: BLE001 - readiness must report any database failure
        return JSONResponse(status_code=503, content={"status": "unavailable"})
    return HealthResponse(status="ready")


@router.get("/v1/config", response_model=ConfigResponse)
def get_config(request: Request) -> ConfigResponse:
    """Return feature flags and limits."""
    settings = request.app.state.settings
    return ConfigResponse(
        flags=ConfigFlags(
            llm_enabled=settings.llm_enabled,
            voice_enabled=settings.voice_enabled,
        ),
        languages=["en", "hi", "hinglish"],
        limits=ConfigLimits(
            max_turns=settings.max_turns,
            max_duration_seconds=settings.max_duration_seconds,
            idle_timeout_seconds=settings.idle_timeout_seconds,
            max_request_body_bytes=settings.max_request_body_bytes,
            retention_days=settings.retention_days,
        ),
    )


@router.get("/v1/scenario/graph", response_model=ScenarioGraphResponse)
def get_graph(request: Request) -> ScenarioGraphResponse:
    """Return stage ids and label ids only, never script text."""
    return ScenarioGraphResponse(
        stage_ids=request.app.state.scenario.stage_ids,  # type: ignore[arg-type]
        labels=[label.value for label in ALL_LABELS],  # type: ignore[list-item]
    )


__all__ = ["router"]

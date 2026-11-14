"""Shared report retrieval route."""

from __future__ import annotations

from fastapi import APIRouter, Request

from app.auth import header, resolve_report
from app.deps import enforce_ip_limit, settings_of
from app.errors import ApiProblem
from app.models import DrillSession
from app.schemas import ReportResponse
from app.services.session_lifecycle import report_response

router = APIRouter(prefix="/v1/reports", tags=["reports"])


@router.get("/current", response_model=ReportResponse)
def current_report(request: Request) -> ReportResponse:
    """Return a shared report, or 401 once the session is gone."""
    enforce_ip_limit(request, "report")
    settings = settings_of(request)
    raw = header(request, "X-Report-Token")
    with request.app.state.db.transaction() as db:
        report = resolve_report(db, raw, settings)
        session = db.get(DrillSession, report.session_id)
        if session is None:
            raise ApiProblem(401, "invalid_token", "Invalid token", "This report is no longer available.")
        return report_response(db, report, session, raw)


__all__ = ["router"]

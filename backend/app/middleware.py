"""HTTP middleware: body limits, request ids, timing, and headers."""

from __future__ import annotations

import logging
import time
import uuid

from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.requests import Request
from starlette.responses import Response

from app.config import Settings
from app.errors import ApiProblem, problem_response

logger = logging.getLogger("dryrun.http")


class BodyLimitMiddleware(BaseHTTPMiddleware):
    """Reject request bodies above the contract limit."""

    def __init__(self, app: object, settings: Settings) -> None:
        super().__init__(app)  # type: ignore[arg-type]
        self._limit = settings.max_request_body_bytes

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        if request.method in {"POST", "PUT", "PATCH"}:
            declared = request.headers.get("content-length")
            if declared and declared.isdigit() and int(declared) > self._limit:
                return problem_response(
                    ApiProblem(413, "payload_too_large", "Payload too large", "Request body is too large.")
                )
            body = await request.body()
            if len(body) > self._limit:
                return problem_response(
                    ApiProblem(413, "payload_too_large", "Payload too large", "Request body is too large.")
                )
        return await call_next(request)


class ObservabilityMiddleware(BaseHTTPMiddleware):
    """Attach request ids, Server-Timing, and one structured access log."""

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        request_id = request.headers.get("x-request-id") or uuid.uuid4().hex
        request.state.request_id = request_id
        started = time.perf_counter()
        response = await call_next(request)
        duration_ms = (time.perf_counter() - started) * 1000
        response.headers["X-Request-ID"] = request_id
        response.headers["Server-Timing"] = f"app;dur={duration_ms:.2f}"
        logger.info(
            "request",
            extra={
                "request_id": request_id,
                "method": request.method,
                "path": request.url.path,
                "status": response.status_code,
                "duration_ms": round(duration_ms, 2),
            },
        )
        return response


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Apply the hardened header set to every response."""

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        response = await call_next(request)
        response.headers["Referrer-Policy"] = "no-referrer"
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Cross-Origin-Resource-Policy"] = "same-origin"
        response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
        path = request.url.path
        if path.startswith(("/v1/reports", "/v1/sessions", "/v1/invites")):
            response.headers["Cache-Control"] = "no-store"
        return response


__all__ = ["BodyLimitMiddleware", "ObservabilityMiddleware", "SecurityHeadersMiddleware"]

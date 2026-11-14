"""Problem+json errors and exception handlers."""

from __future__ import annotations

import logging

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError

from app.schemas import ProblemCode

logger = logging.getLogger("dryrun.errors")


class ApiProblem(Exception):
    """Domain error rendered as application/problem+json."""

    def __init__(
        self,
        status_code: int,
        code: ProblemCode,
        title: str,
        detail: str,
        headers: dict[str, str] | None = None,
    ) -> None:
        super().__init__(detail)
        self.status_code = status_code
        self.code = code
        self.title = title
        self.detail = detail
        self.headers = headers or {}


def problem_response(problem: ApiProblem) -> JSONResponse:
    """Render a problem payload without leaking internals."""
    return JSONResponse(
        status_code=problem.status_code,
        content={
            "type": f"https://dryrun.example/errors/{problem.code}",
            "title": problem.title,
            "status": problem.status_code,
            "detail": problem.detail,
            "code": problem.code,
        },
        media_type="application/problem+json",
        headers=problem.headers,
    )


def install_error_handlers(app: FastAPI) -> None:
    """Register problem handlers on the application."""

    @app.exception_handler(ApiProblem)
    async def handle_problem(request: Request, exc: ApiProblem) -> JSONResponse:
        del request
        return problem_response(exc)

    @app.exception_handler(RequestValidationError)
    async def handle_validation(request: Request, exc: RequestValidationError) -> JSONResponse:
        del request, exc
        return problem_response(
            ApiProblem(
                400,
                "validation_error",
                "Invalid request",
                "Request body or parameters failed validation.",
            )
        )

    @app.exception_handler(SQLAlchemyError)
    async def handle_database(request: Request, exc: SQLAlchemyError) -> JSONResponse:
        logger.error(
            "database_error",
            extra={"request_id": getattr(request.state, "request_id", None)},
        )
        del exc
        return problem_response(
            ApiProblem(503, "internal", "Service unavailable", "The database is unavailable.")
        )

    @app.exception_handler(Exception)
    async def handle_unexpected(request: Request, exc: Exception) -> JSONResponse:
        logger.error(
            "unhandled_error",
            extra={
                "request_id": getattr(request.state, "request_id", None),
                "error_type": type(exc).__name__,
            },
        )
        return problem_response(
            ApiProblem(500, "internal", "Internal error", "An unexpected error occurred.")
        )


__all__ = ["ApiProblem", "install_error_handlers", "problem_response"]

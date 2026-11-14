"""Database-backed daily LLM budget and kill switch."""

from __future__ import annotations

import logging
from datetime import date

from sqlalchemy import select

from app.config import Settings
from app.database import Database
from app.models import LlmBudget
from app.timeutil import utcnow

logger = logging.getLogger("dryrun.budget")


class BudgetTracker:
    """Tracks spend in the database so restarts cannot bypass the cap."""

    def __init__(self, database: Database, settings: Settings) -> None:
        self._database = database
        self._settings = settings
        self._logged_exhausted = False

    def available(self) -> bool:
        """Return whether an LLM call may be made right now."""
        if not self._settings.llm_enabled or self._settings.llm_kill_switch:
            return False
        with self._database.transaction() as db:
            row = db.get(LlmBudget, utcnow().date())
            if row is None:
                return True
            if row.spent_usd >= self._settings.daily_llm_budget_usd:
                if not self._logged_exhausted:
                    logger.warning("llm_budget_exhausted")
                    self._logged_exhausted = True
                return False
            return True

    def record(self, input_tokens: int, output_tokens: int) -> float:
        """Record estimated spend and return the cost in USD."""
        cost = (
            input_tokens / 1_000_000 * self._settings.llm_input_cost_per_mtok
            + output_tokens / 1_000_000 * self._settings.llm_output_cost_per_mtok
        )
        day: date = utcnow().date()
        with self._database.transaction() as db:
            row = db.scalar(
                select(LlmBudget)
                .where(LlmBudget.day == day)
                .with_for_update()
                .execution_options(populate_existing=True)
            )
            if row is None:
                row = LlmBudget(day=day, spent_usd=0.0, calls=0)
                db.add(row)
                db.flush()
            row.spent_usd = float(row.spent_usd) + cost
            row.calls = int(row.calls) + 1
            row.updated_at = utcnow()
        return cost

    def snapshot(self) -> dict[str, float | int]:
        """Return today's spend for internal health output."""
        with self._database.transaction() as db:
            row = db.get(LlmBudget, utcnow().date())
            if row is None:
                return {"spent_usd": 0.0, "calls": 0, "budget_usd": self._settings.daily_llm_budget_usd}
            return {
                "spent_usd": float(row.spent_usd),
                "calls": int(row.calls),
                "budget_usd": self._settings.daily_llm_budget_usd,
            }


__all__ = ["BudgetTracker"]

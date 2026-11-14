"""Retention purge executed by CLI and by an in-process periodic task."""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
from datetime import datetime, timedelta

from sqlalchemy import delete, or_

from app.config import Settings
from app.database import Database
from app.models import DrillSession, Invite, LlmBudget, ReportToken
from app.timeutil import utcnow

logger = logging.getLogger("dryrun.purge")


def purge_expired(database: Database, settings: Settings, now: datetime | None = None) -> dict[str, int]:
    """Delete expired reports, sessions, invites, and old budget rows."""
    moment = now or utcnow()
    retention_cutoff = moment - timedelta(days=settings.retention_days)
    budget_cutoff = (moment - timedelta(days=30)).date()
    counts: dict[str, int] = {}
    with database.transaction() as db:
        counts["reports"] = int(
            getattr(
                db.execute(delete(ReportToken).where(ReportToken.expires_at <= moment)),
                "rowcount",
                0,
            )
            or 0
        )
        counts["sessions"] = int(
            getattr(
                db.execute(
                    delete(DrillSession).where(
                        or_(
                            DrillSession.expires_at <= moment,
                            DrillSession.ended_at <= retention_cutoff,
                            DrillSession.created_at <= retention_cutoff,
                        )
                    )
                ),
                "rowcount",
                0,
            )
            or 0
        )
        counts["invites"] = int(
            getattr(
                db.execute(delete(Invite).where(Invite.expires_at <= moment)),
                "rowcount",
                0,
            )
            or 0
        )
        counts["budget_rows"] = int(
            getattr(
                db.execute(delete(LlmBudget).where(LlmBudget.day < budget_cutoff)),
                "rowcount",
                0,
            )
            or 0
        )
    return counts


async def purge_loop(database: Database, settings: Settings) -> None:
    """Run the purge forever at the configured interval."""
    while True:
        await asyncio.sleep(settings.purge_interval_seconds)
        try:
            counts = await asyncio.to_thread(purge_expired, database, settings)
            logger.info("purge_complete", extra={"event": json.dumps(counts)})
        except Exception as exc:  # noqa: BLE001 - a purge failure must not kill the process
            logger.warning("purge_failed", extra={"error_type": type(exc).__name__})


def main() -> None:
    """Run one purge from the command line."""
    parser = argparse.ArgumentParser(description="Purge expired Dry Run data")
    parser.parse_args()
    settings = Settings.from_env()
    database = Database(settings.database_url)
    counts = purge_expired(database, settings)
    database.dispose()
    print(json.dumps({"purged": counts}, sort_keys=True))


if __name__ == "__main__":
    main()

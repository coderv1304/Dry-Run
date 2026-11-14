"""Alembic script template."""

from __future__ import annotations

import sqlalchemy as sa
from alembic import op

revision = "${up_revision}"
down_revision = "${down_revision}"
branch_labels = ${branch_labels}
depends_on = ${depends_on}


def upgrade() -> None:
    """Apply this revision."""
    ${upgrades if upgrades else "pass"}


def downgrade() -> None:
    """Revert this revision."""
    ${downgrades if downgrades else "pass"}

#!/usr/bin/env bash
# Verifies that gate <id> has passed.
# Exits non-zero printing "Run Prompt <id> first" unless:
# 1. .gates/<id> exists
# 2. git tag gate-<id> exists
# 3. HEAD descends from gate-<id>

set -e

GATE_ID="$1"

if [ -z "$GATE_ID" ]; then
  echo "Usage: $0 <gate-id>"
  exit 1
fi

case "$GATE_ID" in
  0|1|2|3|3b|4|4b|5) ;;
  *)
    echo "Invalid gate id: $GATE_ID. Must be one of: 0, 1, 2, 3, 3b, 4, 4b, 5."
    exit 1
    ;;
esac

FAIL_MSG="Run Prompt $GATE_ID first"

# Check 1: .gates/<id> exists
if [ ! -f ".gates/$GATE_ID" ]; then
  echo "$FAIL_MSG"
  exit 1
fi

# Check 2: git tag gate-<id> exists
TAG_NAME="gate-$GATE_ID"
if ! git rev-parse "$TAG_NAME" &>/dev/null; then
  echo "$FAIL_MSG"
  exit 1
fi

# Check 3: HEAD descends from gate-<id>
if ! git merge-base --is-ancestor "$TAG_NAME" HEAD &>/dev/null; then
  echo "$FAIL_MSG"
  exit 1
fi

echo "Gate $GATE_ID verified."
exit 0

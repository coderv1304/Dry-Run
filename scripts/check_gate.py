"""Gate verification script.
Exits non-zero printing 'Run Prompt <id> first' unless:
1. .gates/<id> exists
2. git tag gate-<id> exists
3. HEAD descends from gate-<id>
"""

import os
import subprocess
import sys

VALID_GATES = {"0", "1", "2", "3", "3b", "4", "4b", "5"}

if len(sys.argv) < 2:
    print("Usage: python check_gate.py <gate-id>")
    sys.exit(1)

gate_id = sys.argv[1]
if gate_id not in VALID_GATES:
    print(f"Invalid gate id: {gate_id}. Must be one of: {', '.join(sorted(VALID_GATES))}")
    sys.exit(1)

fail_msg = f"Run Prompt {gate_id} first"

# Check 1: .gates/<id> exists
gate_file = os.path.join(".gates", gate_id)
if not os.path.isfile(gate_file):
    print(fail_msg)
    sys.exit(1)

# Check 2: git tag gate-<id> exists
tag_name = f"gate-{gate_id}"
res = subprocess.run(["git", "rev-parse", tag_name], capture_output=True, text=True)
if res.returncode != 0:
    print(fail_msg)
    sys.exit(1)

# Check 3: HEAD descends from gate-<id>
res = subprocess.run(["git", "merge-base", "--is-ancestor", tag_name, "HEAD"], capture_output=True, text=True)
if res.returncode != 0:
    print(fail_msg)
    sys.exit(1)

print(f"Gate {gate_id} verified.")
sys.exit(0)

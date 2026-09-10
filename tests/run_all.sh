#!/usr/bin/env bash
# Runs every headless regression test in this directory and reports overall
# pass/fail. Each test_*.tscn is a self-contained scene (Node + script) that
# exercises real game code through the actual Godot autoloads (SaveManager,
# InventoryManager, ...), prints PASS/FAIL lines, and exits 0 on success or
# 1 if anything failed - see any test_*.gd for the pattern to extend.
#
# Usage: tests/run_all.sh [path-to-godot-binary]
# Defaults to "godot" on PATH; override with an explicit path or GODOT=...

set -uo pipefail

GODOT_BIN="${1:-${GODOT:-godot}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1 && [ ! -x "$GODOT_BIN" ]; then
	echo "Godot binary not found: '$GODOT_BIN'"
	echo "Pass the path explicitly: tests/run_all.sh /path/to/Godot_v4.3-stable"
	echo "or set GODOT=/path/to/Godot_v4.3-stable"
	exit 2
fi

failures=0
for scene in "$SCRIPT_DIR"/test_*.tscn; do
	name="$(basename "$scene" .tscn)"
	echo "### $name ###"
	if ! "$GODOT_BIN" --headless --path "$PROJECT_DIR" "tests/$name.tscn" 2>&1 | tee /tmp/pokerpg_test_output.txt | grep -E "^(PASS|FAIL|===)"; then
		:
	fi
	if grep -q "^FAIL" /tmp/pokerpg_test_output.txt; then
		failures=$((failures + 1))
	fi
	echo
done

rm -f /tmp/pokerpg_test_output.txt

if [ "$failures" -gt 0 ]; then
	echo "$failures test suite(s) had failures."
	exit 1
fi
echo "All test suites passed."
exit 0

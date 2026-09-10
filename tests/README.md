# Regression tests

Headless Godot tests for the systems that have broken silently before:
evolution (duplication/data loss), save/load (JSON round-trip integrity),
the per-trainer battle AI, the Cup tournament system, and the
queue_free()-without-remove_child() popup/panel-stacking bug class.

Each `test_*.tscn` is self-contained: a `Node` with a script that runs on
`_ready()`, exercises real game code through the actual autoloads
(SaveManager, InventoryManager, ...), prints `PASS`/`FAIL` lines per check,
and exits with code 0 (all passed) or 1 (something failed).

## Running

```
tests/run_all.sh /path/to/Godot_v4.3-stable_linux.x86_64
```

Or set `GODOT` in the environment and just run `tests/run_all.sh`. A single
suite can also be run directly:

```
godot --headless --path . tests/test_evolution.tscn
```

## Adding a test

Copy the shape of any existing `test_*.gd`/`.tscn` pair: `_ready()` calls
`call_deferred("_run")`, `_run()` awaits a couple of `process_frame`s (so
autoloads and the scene tree are fully ready), does its checks through a
`_check(label, condition, detail)` helper, prints a summary, and calls
`get_tree().quit(1 if not failures.is_empty() else 0)`.

These are deliberately plain Godot scenes, not a testing framework
(GUT/etc.) - the project doesn't depend on one, and this keeps each test a
single self-contained file.

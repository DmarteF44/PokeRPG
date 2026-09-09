#!/usr/bin/env python3
"""Find and adapt Pokemon evolution entries that use a mechanic PokeRPG
doesn't have (trade, a friendship stat nothing ever increments, real-world
time of day, a specific overworld location) and prune any evolution whose
target species isn't playable yet (no sprites extracted for it).

Run this EVERY TIME a new generation's data/sprites are added (see
extract_generation_sprites.py) - it re-scans every species currently
available (per the asset manifest, the same source PokemonHelpers.
is_asset_complete() checks) across all four data files PokemonHelpers
reads from, so newly-available evolution targets are picked back up
automatically and nothing needs to be re-typed by hand.

Auto-adaptation rules (deliberately conservative - anything it can't turn
into a clean, coherent condition is pruned and flagged for a manual design
decision instead of guessing):
  - trade (with a held_item hint)  -> item + level, reusing that item as
    the required evolution item (add it to data/items.json if missing)
  - trade (no held_item hint)      -> plain level
  - friendship                     -> plain level (friendship is tracked
    per-Pokemon but nothing in the game ever raises it, so any
    min_happiness gate is unreachable as-is)
  - time_of_day only                -> drop the time requirement, keep
    the rest (real-world clock time is a confusing mobile UX)
  - location, when the same target also has a working stone/item entry
    -> drop the location entries as redundant
  - location with no alternative, known_move, shed, and other narrow
    mechanics (three-critical-hits, style-moves, etc.) -> pruned, and
    listed under NEEDS MANUAL DESIGN in the report - these need a human
    to pick a coherent replacement (see PLAYER_PROGRESS_METHODS below
    for battle/trainer/tournament/badge options), not an auto-generated
    guess.

This intentionally does NOT try to invent trainer/tournament conditions -
those need real game-design judgement (which trainer, which tournament,
does it fit the story) that a script can't make responsibly.

Usage: python3 adapt_evolution_methods.py [--apply]
  Without --apply, only prints the report (dry run). With --apply, writes
  the adapted data back to all four files.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_PATH = ROOT / "data" / "pokemon_assets_manifest.json"
ITEMS_PATH = ROOT / "data" / "items.json"
SPECIES_PATH = ROOT / "data" / "pokemon_species.json"
GEN_PATHS = sorted((ROOT / "data" / "pokemon").glob("gen*/pokemon.json"))

# See PokemonHelpers.PLAYER_PROGRESS_METHODS (scripts/pokemon_helpers.gd) -
# these are already wired into the evolution-matching code and available
# for a human to hand-pick for a specific species; this script never
# assigns them automatically.
PLAYER_PROGRESS_METHODS = ["badge", "battle_pokemon", "defeat_pokemon", "battle_trainer", "defeat_trainer", "participate_tournament", "win_tournament"]

TRADE_ITEM_DEFAULT_LEVEL = 30
TRADE_NO_ITEM_DEFAULT_LEVEL = 32
FRIENDSHIP_DEFAULT_LEVEL = 20
NARROW_METHODS = {"shed", "three-critical-hits", "strong-style-move", "use-move", "agile-style-move", "known_move"}


def load_json(path: Path):
    with open(path) as f:
        return json.load(f)


def save_json(path: Path, data) -> None:
    with open(path, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")


def available_ids() -> set[str]:
    manifest = load_json(MANIFEST_PATH)
    return {pid for pid, assets in manifest.items() if isinstance(assets, dict) and assets.get("has_animation")}


def slugify_item_name(item_id: str) -> tuple[str, str]:
    words = item_id.replace("_", " ").split()
    name_en = " ".join(w.capitalize() for w in words)
    return name_en, name_en  # pt name left same as en; a human should localize it


def ensure_item_exists(items: list, item_id: str) -> bool:
    """Adds a minimal evolution-category item if it's missing. Returns True
    if it had to be created (so the caller knows to flag it for an icon)."""
    if any(it.get("id") == item_id for it in items):
        return False
    name_en, name_pt = slugify_item_name(item_id)
    items.append({
        "id": item_id, "name_en": name_en, "name_pt": name_pt,
        "category": "evolution", "price": 2000, "min_level": 15, "min_badges": 2,
        "effect_type": "evolve_stone", "use_contexts": ["field", "pokemon_selection"],
        "description_en": f"A rare item used for certain evolutions.",
        "description_pt": f"Um item raro usado em certas evolucoes.",
        "icon_path": f"res://assets/items/evolution/{item_id}.png",
    })
    return True


def adapt_species_evolutions(evolutions: list, available: set[str], report: list, species_id: str) -> list:
    new_evolutions = []
    seen_targets_this_pass = {}
    for e in evolutions:
        target = e.get("target")
        method = str(e.get("method", e.get("trigger", "")))
        if target not in available:
            report.append(("PRUNED (target not playable yet)", species_id, target, method))
            continue

        if method == "trade":
            held_item = e.get("held_item_id", e.get("held_item"))
            if held_item:
                level = TRADE_ITEM_DEFAULT_LEVEL
                new_entry = dict(e, method="item", trigger="level-up", item_id=held_item, min_level=level)
                for stale in ("held_item", "held_item_id"):
                    new_entry.pop(stale, None)
                report.append((f"ADAPTED trade -> item+level({level})", species_id, target, "NEW_ITEM:" + held_item))
            else:
                level = TRADE_NO_ITEM_DEFAULT_LEVEL
                new_entry = dict(e, method="level", trigger="level-up", level=level, min_level=level)
                report.append((f"ADAPTED trade -> level({level})", species_id, target, ""))
            key = (target, new_entry["method"])
            if key not in seen_targets_this_pass:
                new_evolutions.append(new_entry)
                seen_targets_this_pass[key] = True
            continue

        if method == "friendship":
            level = FRIENDSHIP_DEFAULT_LEVEL
            new_entry = dict(e, method="level", trigger="level-up", level=level, min_level=level)
            for stale in ("min_happiness",):
                new_entry.pop(stale, None)
            key = (target, "level")
            if key not in seen_targets_this_pass:
                new_evolutions.append(new_entry)
                seen_targets_this_pass[key] = True
                report.append((f"ADAPTED friendship -> level({level})", species_id, target, ""))
            continue

        if method == "location":
            has_alt = any(
                o.get("target") == target and o is not e and str(o.get("method", "")) in ("stone", "item", "level")
                for o in evolutions
            )
            if has_alt:
                report.append(("PRUNED location (redundant with stone/item entry)", species_id, target, ""))
            else:
                report.append(("NEEDS MANUAL DESIGN (location, no alternative)", species_id, target, ""))
            continue

        if method in NARROW_METHODS:
            report.append((f"NEEDS MANUAL DESIGN ({method})", species_id, target, ""))
            continue

        if "time_of_day" in e and method not in ("friendship",):
            new_entry = dict(e)
            new_entry.pop("time_of_day", None)
            new_evolutions.append(new_entry)
            report.append(("ADAPTED (dropped real-clock time_of_day requirement)", species_id, target, ""))
            continue

        new_evolutions.append(e)
    return new_evolutions


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="write changes back to disk (default: dry run)")
    args = parser.parse_args()

    available = available_ids()
    print(f"{len(available)} species currently playable (has_animation in the asset manifest)")

    items = load_json(ITEMS_PATH)
    new_items_needed = []
    report: list[tuple[str, str, str, str]] = []

    paths = [SPECIES_PATH] + GEN_PATHS
    file_snapshots = {}
    for path in paths:
        species_list = load_json(path)
        for s in species_list:
            if s["id"] not in available:
                continue
            evolutions = s.get("evolutions", [])
            if not evolutions:
                continue
            s["evolutions"] = adapt_species_evolutions(evolutions, available, report, s["id"])
        file_snapshots[path] = species_list

    for _, _, _, extra in report:
        if extra.startswith("NEW_ITEM:"):
            item_hint = extra[len("NEW_ITEM:"):]
            if ensure_item_exists(items, item_hint):
                new_items_needed.append(item_hint)

    print(f"\n{len(report)} evolution entries examined and changed:")
    for line, species_id, target, extra in report:
        shown_extra = extra[len("NEW_ITEM:"):] if extra.startswith("NEW_ITEM:") else extra
        print(f"  {species_id} -> {target}: {line}" + (f" [{shown_extra}]" if shown_extra else ""))

    if new_items_needed:
        print(f"\n{len(new_items_needed)} new evolution items auto-created (need a real icon + localized text, see assets/items/evolution/):")
        for item_id in new_items_needed:
            print(f"  {item_id}")

    manual = [r for r in report if r[0].startswith("NEEDS MANUAL DESIGN")]
    if manual:
        print(f"\n{len(manual)} evolutions need a human design decision (not auto-adapted):")
        for line, species_id, target, _ in manual:
            print(f"  {species_id} -> {target}: {line}")

    if not args.apply:
        print("\nDry run - no files written. Re-run with --apply to save these changes.")
        return

    for path, species_list in file_snapshots.items():
        save_json(path, species_list)
    save_json(ITEMS_PATH, items)
    print("\nApplied.")


if __name__ == "__main__":
    main()

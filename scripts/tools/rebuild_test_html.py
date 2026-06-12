#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
HTML_PATH = ROOT / "web/test.html"


def js_json(value) -> str:
    return json.dumps(value, ensure_ascii=False, indent=6)


def int_or_default(value, default: int) -> int:
    return default if value is None else int(value)


def asset_path(res_path: str) -> str:
    prefix = "res://assets/"
    return res_path[len(prefix):] if isinstance(res_path, str) and res_path.startswith(prefix) else res_path


def frame_count(folder: Path) -> int:
    if not folder.exists():
        return 0
    return len([path for path in folder.glob("*.png") if path.stem.isdigit()])


def html_species_record(entry: dict) -> dict:
    pokemon_id = str(entry.get("id", ""))
    generation = int(entry.get("generation") or 1)
    base_stats = entry.get("base_stats") or {}
    front_dir = ROOT / f"assets/pokemon/battle/animated/gen_{generation}/front/{pokemon_id}"
    back_dir = ROOT / f"assets/pokemon/battle/animated/gen_{generation}/back/{pokemon_id}"
    evolutions = []
    for evolution in entry.get("evolutions") or []:
        target = str(evolution.get("target") or "")
        if not target:
            continue
        row = {
            key: value
            for key, value in evolution.items()
            if value is not None and value != ""
        }
        row["target"] = target
        if row.get("level") or row.get("min_level"):
            row["level"] = int(row.get("level") or row.get("min_level"))
        if row.get("target_dex_number") is not None:
            row["target_dex_number"] = int(row["target_dex_number"])
        if row.get("min_level") is not None:
            row["min_level"] = int(row["min_level"])
        evolutions.append(row)

    return {
        "id": pokemon_id,
        "dex_number": int(entry.get("dex_number") or 0),
        "name": entry.get("name") or entry.get("species") or pokemon_id,
        "generation": generation,
        "baseLevel": int(entry.get("base_level") or 5),
        "baseStats": {
            "max_hp": int(base_stats.get("hp") or base_stats.get("max_hp") or 1),
            "attack": int(base_stats.get("attack") or 1),
            "defense": int(base_stats.get("defense") or 1),
            "sp_attack": int(base_stats.get("sp_attack") or 1),
            "sp_defense": int(base_stats.get("sp_defense") or 1),
            "speed": int(base_stats.get("speed") or 1),
        },
        "ability": entry.get("ability") or (entry.get("abilities") or ["Unknown"])[0],
        "abilities": entry.get("abilities") or [],
        "hiddenAbility": entry.get("hidden_ability") or "",
        "hidden_ability": entry.get("hidden_ability") or "",
        "friendship": int(entry.get("friendship") or 70),
        "gender": entry.get("gender") or "Unknown",
        "gender_rate": int(entry.get("gender_rate") if entry.get("gender_rate") is not None else -1),
        "capture_rate": int(entry.get("capture_rate") or entry.get("catch_rate") or 120),
        "catch_rate": int(entry.get("catch_rate") or entry.get("capture_rate") or 120),
        "growth_rate": entry.get("growth_rate") or "Medium Fast",
        "base_experience": int(entry.get("base_experience") or entry.get("xp_yield") or 0),
        "xp_yield": int(entry.get("xp_yield") or entry.get("base_experience") or 0),
        "weight": int(entry.get("weight") or 0),
        "height": int(entry.get("height") or 0),
        "egg_groups": entry.get("egg_groups") or [],
        "types": entry.get("types") or ["Normal"],
        "frameCount": frame_count(front_dir),
        "backFrameCount": frame_count(back_dir),
        "icon_path": asset_path(entry.get("icon_path") or ""),
        "learnset": entry.get("learnset") or {},
        "evolutions": evolutions,
        "evolves_from": entry.get("evolves_from") or "",
        "description_en": entry.get("description_en") or "",
        "description_pt": entry.get("description_pt") or entry.get("description_en") or "",
    }


def move_defs_block() -> str:
    moves = json.loads((ROOT / "data/moves.json").read_text(encoding="utf-8"))
    by_name = {}
    for move in moves:
        name = str(move.get("name") or "")
        if not name:
            continue
        by_name[name] = {
            "id": move.get("id", name.lower().replace(" ", "_")),
            "name": name,
            "type": move.get("type", "Normal"),
            "category": move.get("category", "Physical"),
            "power": int_or_default(move.get("power"), 0),
            "accuracy": int_or_default(move.get("accuracy"), 100),
            "pp": int_or_default(move.get("pp"), 35),
            "priority": int_or_default(move.get("priority"), 0),
            "target": move.get("target", "selected-pokemon"),
            "effects": move.get("effects") or [],
        }
    return f"\t    const moveDefs = {js_json(by_name)};\n{type_chart_block()}"


def type_chart_block() -> str:
    return """    const typeChart = {
\t      Normal: { Rock: 0.5, Ghost: 0, Steel: 0.5 },
\t      Fire: { Fire: 0.5, Water: 0.5, Grass: 2, Ice: 2, Bug: 2, Rock: 0.5, Dragon: 0.5, Steel: 2 },
\t      Water: { Fire: 2, Water: 0.5, Grass: 0.5, Ground: 2, Rock: 2, Dragon: 0.5 },
\t      Electric: { Water: 2, Electric: 0.5, Grass: 0.5, Ground: 0, Flying: 2, Dragon: 0.5 },
\t      Grass: { Fire: 0.5, Water: 2, Grass: 0.5, Poison: 0.5, Ground: 2, Flying: 0.5, Bug: 0.5, Rock: 2, Dragon: 0.5, Steel: 0.5 },
\t      Ice: { Fire: 0.5, Water: 0.5, Grass: 2, Ice: 0.5, Ground: 2, Flying: 2, Dragon: 2, Steel: 0.5 },
\t      Fighting: { Normal: 2, Ice: 2, Poison: 0.5, Flying: 0.5, Psychic: 0.5, Bug: 0.5, Rock: 2, Ghost: 0, Dark: 2, Steel: 2, Fairy: 0.5 },
\t      Poison: { Grass: 2, Poison: 0.5, Ground: 0.5, Rock: 0.5, Ghost: 0.5, Steel: 0, Fairy: 2 },
\t      Ground: { Fire: 2, Electric: 2, Grass: 0.5, Poison: 2, Flying: 0, Bug: 0.5, Rock: 2, Steel: 2 },
\t      Flying: { Electric: 0.5, Grass: 2, Fighting: 2, Bug: 2, Rock: 0.5, Steel: 0.5 },
\t      Psychic: { Fighting: 2, Poison: 2, Psychic: 0.5, Dark: 0, Steel: 0.5 },
\t      Bug: { Fire: 0.5, Grass: 2, Fighting: 0.5, Poison: 0.5, Flying: 0.5, Psychic: 2, Ghost: 0.5, Dark: 2, Steel: 0.5, Fairy: 0.5 },
\t      Rock: { Fire: 2, Ice: 2, Fighting: 0.5, Ground: 0.5, Flying: 2, Bug: 2, Steel: 0.5 },
\t      Ghost: { Normal: 0, Psychic: 2, Ghost: 2, Dark: 0.5 },
\t      Dragon: { Dragon: 2, Steel: 0.5, Fairy: 0 },
\t      Dark: { Fighting: 0.5, Psychic: 2, Ghost: 2, Dark: 0.5, Fairy: 0.5 },
\t      Steel: { Fire: 0.5, Water: 0.5, Electric: 0.5, Ice: 2, Rock: 2, Steel: 0.5, Fairy: 2 },
\t      Fairy: { Fire: 0.5, Fighting: 2, Poison: 0.5, Dragon: 2, Dark: 2, Steel: 0.5 }
\t    };"""


def starter_defs_block() -> str:
    species = json.loads((ROOT / "data/pokemon_species.json").read_text(encoding="utf-8"))
    by_id = {entry["id"]: html_species_record(entry) for entry in species if entry.get("id")}
    return f"\t    const starterDefs = {js_json(by_id)};"


def map_encounters_block() -> str:
    encounters = json.loads((ROOT / "data/map_encounters.json").read_text(encoding="utf-8"))
    compact = {
        map_key: [
            {
                "pokemon_id": row.get("pokemon_id"),
                "level": int(row.get("level") or 5),
                "rarity": row.get("rarity", "common"),
                "weight": int(row.get("weight") or 1),
            }
            for row in rows
            if row.get("pokemon_id")
        ]
        for map_key, rows in encounters.items()
    }
    return f"    const mapEncounterData = {js_json(compact)};\n    const encounterTables = mapEncounterData;"


def replace_between(text: str, start_marker: str, end_marker: str, replacement: str) -> str:
    start = text.find(start_marker)
    if start < 0:
        raise RuntimeError(f"Missing start marker: {start_marker}")
    end = text.find(end_marker, start)
    if end < 0:
        raise RuntimeError(f"Missing end marker: {end_marker}")
    return text[:start] + replacement + "\n" + text[end:]


def replace_boot(text: str) -> str:
    old = "    showMainMenu();\n  </script>"
    new = "    if (save) { ensureSave(); showHome(); } else { showMainMenu(); }\n  </script>"
    if new in text:
        return text
    if old not in text:
        raise RuntimeError("Missing HTML boot marker")
    return text.replace(old, new, 1)


def main() -> None:
    html = HTML_PATH.read_text(encoding="utf-8")
    html = replace_between(html, "\t    const moveDefs = {", "\t    const starterDefs = {", move_defs_block())
    html = replace_between(html, "\t    const starterDefs = {", "    const avatarPaths = [", starter_defs_block())
    html = replace_between(html, "    const mapEncounterData = {", "\n    const gymDefs = [", map_encounters_block() + "\n")
    html = replace_boot(html)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"rebuilt {HTML_PATH}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]

MAP_RULES = {
    "forest": {
        "base_level": 3,
        "primary_types": {"Grass", "Bug", "Normal", "Flying"},
        "exclude_types": {"Fire", "Ice", "Dragon"},
    },
    "fire": {
        "base_level": 6,
        "any_types": {"Fire"},
    },
    "cave": {
        "base_level": 9,
        "primary_types": {"Rock", "Ground", "Fighting", "Poison", "Dark"},
        "exclude_types": {"Grass", "Water", "Ice"},
    },
    "ice": {
        "base_level": 14,
        "any_types": {"Ice"},
    },
    "factory": {
        "base_level": 17,
        "any_types": {"Steel", "Electric"},
        "primary_types": {"Poison"},
    },
    "water": {
        "base_level": 12,
        "primary_types": {"Water"},
    },
    "electric": {
        "base_level": 19,
        "any_types": {"Electric"},
    },
    "desert": {
        "base_level": 22,
        "primary_types": {"Ground", "Rock", "Fire"},
        "exclude_types": {"Water", "Grass", "Ice"},
    },
    "ghost": {
        "base_level": 26,
        "any_types": {"Ghost"},
        "primary_types": {"Psychic", "Dark"},
    },
    "dragon": {
        "base_level": 32,
        "any_types": {"Dragon"},
    },
    "safari": {
        "base_level": 35,
        "primary_types": {"Normal", "Bug", "Grass", "Flying", "Poison", "Fairy"},
        "exclude_types": {"Dragon", "Steel", "Ghost"},
    },
}


RARITY_WEIGHT = {
    "common": 50,
    "uncommon": 20,
    "rare": 4,
    "very_rare": 1,
}


def stage_for(entry: dict) -> str:
    has_parent = bool(entry.get("evolves_from"))
    has_children = bool(entry.get("evolutions"))
    if not has_parent and has_children:
        return "base"
    if has_parent and has_children:
        return "middle"
    if has_parent and not has_children:
        return "final"
    return "single"


def rarity_for(entry: dict) -> str:
    capture_rate = int(entry.get("capture_rate") or entry.get("catch_rate") or 45)
    base_total = sum(int(value or 0) for value in entry.get("base_stats", {}).values())
    egg_groups = set(entry.get("egg_groups") or [])
    stage = stage_for(entry)
    if capture_rate <= 3 or ("No Eggs" in egg_groups and base_total >= 540):
        return "very_rare"
    if stage == "final" or base_total >= 500 or capture_rate <= 45:
        return "rare"
    if stage == "middle" or base_total >= 380:
        return "uncommon"
    return "common"


def level_for(entry: dict, base_level: int, rarity: str) -> int:
    generation = max(1, int(entry.get("generation") or 1))
    stage = stage_for(entry)
    stage_bonus = {"base": 0, "single": 2, "middle": 4, "final": 8}.get(stage, 0)
    rarity_bonus = {"common": 0, "uncommon": 2, "rare": 5, "very_rare": 8}.get(rarity, 0)
    generation_bonus = min(8, generation - 1)
    return max(1, min(70, base_level + stage_bonus + rarity_bonus + generation_bonus))


def matches(entry: dict, rule: dict) -> bool:
    types = list(entry.get("types") or [])
    if not types:
        return False
    type_set = set(types)
    primary = types[0]
    if type_set & set(rule.get("exclude_types", set())):
        return False
    any_types = set(rule.get("any_types", set()))
    primary_types = set(rule.get("primary_types", set()))
    if any_types and type_set & any_types:
        return True
    if primary_types and primary in primary_types:
        return True
    return False


def main() -> None:
    species = json.loads((ROOT / "data/pokemon_species.json").read_text(encoding="utf-8"))
    output = {}
    for map_key, rule in MAP_RULES.items():
        rows = []
        for entry in species:
            if not matches(entry, rule):
                continue
            rarity = rarity_for(entry)
            rows.append({
                "pokemon_id": entry["id"],
                "dex_number": int(entry["dex_number"]),
                "name": entry["name"],
                "generation": int(entry.get("generation", 1)),
                "types": entry.get("types", []),
                "rarity": rarity,
                "weight": RARITY_WEIGHT[rarity],
                "level": level_for(entry, int(rule["base_level"]), rarity),
            })
        rows.sort(key=lambda row: (row["generation"], row["dex_number"]))
        output[map_key] = rows

    path = ROOT / "data/map_encounters.json"
    path.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("wrote", path, {key: len(value) for key, value in output.items()})


if __name__ == "__main__":
    main()

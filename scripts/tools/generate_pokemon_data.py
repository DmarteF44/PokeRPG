#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import re
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CACHE_DIR = Path(os.environ.get("POKERPG_POKEAPI_CACHE", "/tmp/pokerpg_pokeapi_cache"))
API_BASE = "https://pokeapi.co/api/v2"
USER_AGENT = "PokeRPG data generator (https://github.com/DmarteF44/PokeRPG)"
MAX_DEX = 905

GEN_RANGES = {
    1: range(1, 152),
    2: range(152, 252),
    3: range(252, 387),
    4: range(387, 494),
    5: range(494, 650),
    6: range(650, 722),
    7: range(722, 810),
    8: range(810, 906),
}

GEN_BY_DEX = {
    dex: gen
    for gen, values in GEN_RANGES.items()
    for dex in values
}

VERSION_ORDER = [
    "red-blue",
    "yellow",
    "gold-silver",
    "crystal",
    "ruby-sapphire",
    "emerald",
    "firered-leafgreen",
    "diamond-pearl",
    "platinum",
    "heartgold-soulsilver",
    "black-white",
    "black-2-white-2",
    "x-y",
    "omega-ruby-alpha-sapphire",
    "sun-moon",
    "ultra-sun-ultra-moon",
    "lets-go-pikachu-lets-go-eevee",
    "sword-shield",
    "the-isle-of-armor",
    "the-crown-tundra",
    "brilliant-diamond-and-shining-pearl",
    "legends-arceus",
]
VERSION_RANK = {name: index for index, name in enumerate(VERSION_ORDER)}

STAT_KEY_BY_API = {
    "hp": "hp",
    "attack": "attack",
    "defense": "defense",
    "special-attack": "sp_attack",
    "special-defense": "sp_defense",
    "speed": "speed",
}

GENDER_LABELS = {
    -1: "Genderless",
    0: "100% male",
    1: "87.5% male / 12.5% female",
    2: "75% male / 25% female",
    4: "50% male / 50% female",
    6: "25% male / 75% female",
    7: "12.5% male / 87.5% female",
    8: "100% female",
}

ABILITY_GENERATION_LIMIT = {
    "generation-i": 1,
    "generation-ii": 2,
    "generation-iii": 3,
    "generation-iv": 4,
    "generation-v": 5,
    "generation-vi": 6,
    "generation-vii": 7,
    "generation-viii": 8,
}


def api_get(path_or_url: str) -> dict:
    url = path_or_url if path_or_url.startswith("http") else f"{API_BASE}/{path_or_url.strip('/')}/"
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    cache_key = re.sub(r"[^a-zA-Z0-9_.-]+", "_", url.replace(API_BASE, "").strip("/")) or "root"
    cache_path = CACHE_DIR / f"{cache_key}.json"
    if cache_path.exists():
        return json.loads(cache_path.read_text(encoding="utf-8"))

    last_error: Exception | None = None
    for attempt in range(5):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, "Accept": "application/json"})
            with urllib.request.urlopen(request, timeout=30) as response:
                data = json.loads(response.read().decode("utf-8"))
            cache_path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            return data
        except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError) as exc:
            last_error = exc
            time.sleep(0.5 + attempt * 0.8)
    raise RuntimeError(f"Failed to fetch {url}: {last_error}")


def write_json(path: Path, value) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2, sort_keys=False) + "\n", encoding="utf-8")


def safe_id(value: str) -> str:
    text = value.lower().strip()
    text = text.replace("♀", "_f").replace("♂", "_m")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return re.sub(r"_+", "_", text).strip("_")


def title_name(value: str) -> str:
    special = {
        "mr-mime": "Mr. Mime",
        "mime-jr": "Mime Jr.",
        "type-null": "Type: Null",
        "jangmo-o": "Jangmo-o",
        "hakamo-o": "Hakamo-o",
        "kommo-o": "Kommo-o",
        "tapu-koko": "Tapu Koko",
        "tapu-lele": "Tapu Lele",
        "tapu-bulu": "Tapu Bulu",
        "tapu-fini": "Tapu Fini",
        "sirfetchd": "Sirfetch'd",
        "farfetchd": "Farfetch'd",
        "nidoran-f": "Nidoran♀",
        "nidoran-m": "Nidoran♂",
    }
    if value in special:
        return special[value]
    return " ".join(part.capitalize() for part in value.replace("-", " ").split())


def english_name(entries: list[dict], fallback: str) -> str:
    for entry in entries or []:
        if entry.get("language", {}).get("name") == "en":
            return str(entry.get("name") or fallback)
    return title_name(fallback)


def english_text(entries: list[dict], *keys: str) -> str:
    for entry in entries or []:
        if entry.get("language", {}).get("name") != "en":
            continue
        for key in keys:
            text = str(entry.get(key) or "").replace("\n", " ").replace("\f", " ").strip()
            text = re.sub(r"\s+", " ", text)
            if text:
                return text
    return ""


def generation_number(name: str) -> int:
    return ABILITY_GENERATION_LIMIT.get(name, 0)


def load_moves_lookup() -> tuple[dict[str, str], set[str]]:
    raw = json.loads((ROOT / "data/moves.json").read_text(encoding="utf-8"))
    by_api_name: dict[str, str] = {}
    display_names: set[str] = set()
    for move in raw:
        move_id = str(move.get("id", ""))
        name = str(move.get("name", ""))
        if not move_id or not name:
            continue
        by_api_name[move_id.replace("_", "-")] = name
        display_names.add(name)
    return by_api_name, display_names


def frame_count(folder: Path) -> int:
    if not folder.exists():
        return 0
    return len([path for path in folder.glob("*.png") if path.stem.isdigit()])


def res_path(path: Path) -> str:
    return "res://" + path.relative_to(ROOT).as_posix()


def asset_record(pokemon_id: str, generation: int) -> dict:
    front_dir = ROOT / f"assets/pokemon/battle/animated/gen_{generation}/front/{pokemon_id}"
    back_dir = ROOT / f"assets/pokemon/battle/animated/gen_{generation}/back/{pokemon_id}"
    icon_candidates = [
        ROOT / f"assets/pokemon/icons/{pokemon_id}.png",
        ROOT / f"assets/pokemon/icons/gen_{generation}/{pokemon_id}.png",
    ]
    icon_path = next((res_path(path) for path in icon_candidates if path.exists()), "")
    front_frames = frame_count(front_dir)
    back_frames = frame_count(back_dir)
    return {
        "icon_path": icon_path,
        "front_frames_path": res_path(front_dir) + "/" if front_frames else "",
        "back_frames_path": res_path(back_dir) + "/" if back_frames else "",
        "front_frame_count": front_frames,
        "back_frame_count": back_frames,
        "has_animation": front_frames > 1 or back_frames > 1,
    }


def choose_description(species: dict) -> str:
    entries = species.get("flavor_text_entries", [])
    preferred_versions = set(VERSION_ORDER)
    for entry in reversed(entries):
        if entry.get("language", {}).get("name") == "en" and entry.get("version", {}).get("name") in preferred_versions:
            return re.sub(r"\s+", " ", str(entry.get("flavor_text", "")).replace("\n", " ").replace("\f", " ")).strip()
    return english_text(entries, "flavor_text")


def build_learnset(pokemon: dict, move_lookup: dict[str, str], known_moves: set[str]) -> tuple[dict, str, list[str]]:
    by_version: dict[str, dict[int, list[str]]] = {}
    dependencies: set[str] = set()
    for move_entry in pokemon.get("moves", []):
        api_move_name = move_entry.get("move", {}).get("name", "")
        display = move_lookup.get(api_move_name, title_name(api_move_name))
        if display not in known_moves:
            dependencies.add(display)
            continue
        for detail in move_entry.get("version_group_details", []):
            if detail.get("move_learn_method", {}).get("name") != "level-up":
                continue
            version_group = detail.get("version_group", {}).get("name", "")
            if version_group not in VERSION_RANK:
                continue
            level = max(1, int(detail.get("level_learned_at") or 1))
            by_version.setdefault(version_group, {}).setdefault(level, [])
            if display not in by_version[version_group][level]:
                by_version[version_group][level].append(display)

    if not by_version:
        return {"1": ["Tackle"]}, "fallback", sorted(dependencies)

    chosen_version = max(by_version.keys(), key=lambda name: VERSION_RANK[name])
    learnset = {
        str(level): by_version[chosen_version][level]
        for level in sorted(by_version[chosen_version])
    }
    if not learnset:
        learnset = {"1": ["Tackle"]}
    return learnset, chosen_version, sorted(dependencies)


def parse_evolution_detail(detail: dict, target_api_name: str, target_dex: int) -> dict:
    trigger = str(detail.get("trigger", {}).get("name", "") or "unknown")
    item = detail.get("item") or {}
    held_item = detail.get("held_item") or {}
    location = detail.get("location") or {}
    known_move = detail.get("known_move") or {}
    known_move_type = detail.get("known_move_type") or {}
    party_species = detail.get("party_species") or {}
    party_type = detail.get("party_type") or {}
    trade_species = detail.get("trade_species") or {}
    method = trigger
    if trigger == "use-item":
        item_name = str(item.get("name", ""))
        method = "stone" if item_name.endswith("-stone") else "item"
    elif trigger == "level-up":
        if detail.get("min_happiness") is not None:
            method = "friendship"
        elif detail.get("min_affection") is not None:
            method = "affection"
        elif known_move:
            method = "known_move"
        elif location:
            method = "location"
        elif detail.get("time_of_day"):
            method = "time"
        else:
            method = "level"
    elif trigger == "trade":
        method = "trade"

    evolution = {
        "target": safe_id(target_api_name),
        "target_dex_number": target_dex,
        "method": method,
        "trigger": trigger,
    }
    optional_fields = {
        "level": detail.get("min_level"),
        "min_level": detail.get("min_level"),
        "item": title_name(str(item.get("name", ""))) if item else "",
        "item_id": safe_id(str(item.get("name", ""))) if item else "",
        "held_item": title_name(str(held_item.get("name", ""))) if held_item else "",
        "held_item_id": safe_id(str(held_item.get("name", ""))) if held_item else "",
        "min_happiness": detail.get("min_happiness"),
        "min_beauty": detail.get("min_beauty"),
        "min_affection": detail.get("min_affection"),
        "time_of_day": detail.get("time_of_day"),
        "location": title_name(str(location.get("name", ""))) if location else "",
        "location_id": safe_id(str(location.get("name", ""))) if location else "",
        "gender": {1: "female", 2: "male"}.get(detail.get("gender"), ""),
        "known_move": title_name(str(known_move.get("name", ""))) if known_move else "",
        "known_move_id": safe_id(str(known_move.get("name", ""))) if known_move else "",
        "known_move_type": title_name(str(known_move_type.get("name", ""))) if known_move_type else "",
        "party_species": safe_id(str(party_species.get("name", ""))) if party_species else "",
        "party_type": title_name(str(party_type.get("name", ""))) if party_type else "",
        "trade_species": safe_id(str(trade_species.get("name", ""))) if trade_species else "",
        "relative_physical_stats": detail.get("relative_physical_stats"),
        "needs_overworld_rain": detail.get("needs_overworld_rain"),
        "turn_upside_down": detail.get("turn_upside_down"),
    }
    for key, value in optional_fields.items():
        if value not in ("", None, False):
            evolution[key] = value
    return evolution


def collect_evolutions(node: dict, evolutions: dict[str, list[dict]], evolves_from: dict[str, str]) -> None:
    source_api_name = str(node.get("species", {}).get("name", ""))
    source_id = safe_id(source_api_name)
    for child in node.get("evolves_to", []):
        target_api_name = str(child.get("species", {}).get("name", ""))
        target_id = safe_id(target_api_name)
        target_dex = dex_from_url(str(child.get("species", {}).get("url", "")))
        evolves_from[target_id] = source_id
        details = child.get("evolution_details") or [{}]
        for detail in details:
            evolutions.setdefault(source_id, []).append(parse_evolution_detail(detail, target_api_name, target_dex))
        collect_evolutions(child, evolutions, evolves_from)


def dex_from_url(url: str) -> int:
    match = re.search(r"/(\d+)/?$", url)
    return int(match.group(1)) if match else 0


def fetch_pokemon_bundle(dex_number: int) -> tuple[int, dict, dict]:
    return dex_number, api_get(f"pokemon/{dex_number}"), api_get(f"pokemon-species/{dex_number}")


def build_species_entry(dex_number: int, pokemon: dict, species: dict, existing: dict | None, move_lookup: dict[str, str], known_moves: set[str], evolutions: dict[str, list[dict]], evolves_from: dict[str, str]) -> dict:
    api_name = str(pokemon.get("name", ""))
    species_api_name = str(species.get("name", api_name))
    pokemon_id = safe_id(species_api_name)
    generation = GEN_BY_DEX[dex_number]
    species_name = english_name(species.get("names", []), api_name)
    base_stats = {"hp": 1, "attack": 1, "defense": 1, "sp_attack": 1, "sp_defense": 1, "speed": 1}
    for stat in pokemon.get("stats", []):
        key = STAT_KEY_BY_API.get(stat.get("stat", {}).get("name", ""))
        if key:
            base_stats[key] = int(stat.get("base_stat", 1))

    abilities = []
    hidden_ability = ""
    for ability in sorted(pokemon.get("abilities", []), key=lambda item: item.get("slot", 0)):
        name = title_name(str(ability.get("ability", {}).get("name", "")))
        if ability.get("is_hidden"):
            hidden_ability = name
        elif name:
            abilities.append(name)
    ability = abilities[0] if abilities else hidden_ability or "Unknown"
    types = [title_name(slot.get("type", {}).get("name", "")) for slot in sorted(pokemon.get("types", []), key=lambda item: item.get("slot", 0))]
    types = [item for item in types if item] or ["Normal"]

    learnset, source_version, dependencies = build_learnset(pokemon, move_lookup, known_moves)
    assets = asset_record(pokemon_id, generation)
    description = choose_description(species)
    entry = {
        "id": pokemon_id,
        "dex_number": dex_number,
        "species": species_name,
        "name": species_name,
        "generation": generation,
        "types": types,
        "ability": ability,
        "abilities": abilities,
        "hidden_ability": hidden_ability,
        "gender": GENDER_LABELS.get(int(species.get("gender_rate", -1)), "Unknown"),
        "gender_rate": int(species.get("gender_rate", -1)),
        "capture_rate": int(species.get("capture_rate", 45)),
        "catch_rate": int(species.get("capture_rate", 45)),
        "growth_rate": title_name(str(species.get("growth_rate", {}).get("name", "medium-fast"))),
        "base_experience": int(pokemon.get("base_experience") or 0),
        "xp_yield": int(pokemon.get("base_experience") or 0),
        "weight": int(pokemon.get("weight") or 0),
        "height": int(pokemon.get("height") or 0),
        "egg_groups": [title_name(group.get("name", "")) for group in species.get("egg_groups", [])],
        "friendship": int(species.get("base_happiness") if species.get("base_happiness") is not None else 70),
        "base_level": 5,
        "base_stats": base_stats,
        "learnset": learnset,
        "learnset_source_version_group": source_version,
        "learnset_dependencies": dependencies,
        "evolutions": evolutions.get(pokemon_id, []),
        "evolves_from": evolves_from.get(pokemon_id, safe_id(str((species.get("evolves_from_species") or {}).get("name", "")))),
        "description_en": description,
        "description_pt": description,
        "description_source": "pokeapi_flavor_text",
        "sprite_front": f"{assets['front_frames_path']}000.png" if assets["front_frames_path"] else "",
        "sprite_back": f"{assets['back_frames_path']}000.png" if assets["back_frames_path"] else "",
        "front_frames_path": assets["front_frames_path"],
        "back_frames_path": assets["back_frames_path"],
        "icon_path": assets["icon_path"],
        "front_gif_source": "",
        "back_gif_source": "",
        "has_animation": bool(assets["has_animation"]),
    }

    if existing:
        preserved = dict(existing)
        preserved.update({key: value for key, value in entry.items() if key not in preserved or preserved[key] in ("", [], {}, None)})
        for key in ["weight", "height", "egg_groups", "abilities", "hidden_ability", "gender", "gender_rate", "capture_rate", "catch_rate", "growth_rate", "base_experience", "xp_yield", "evolutions", "evolves_from"]:
            preserved[key] = entry[key]
        return preserved
    return entry


def split_supported_evolutions(entry: dict) -> None:
    supported: list[dict] = []
    future_dependencies: list[dict] = []
    for evolution in entry.get("evolutions", []):
        target_dex = int(evolution.get("target_dex_number") or 0)
        if target_dex > MAX_DEX:
            dependency = dict(evolution)
            dependency["reason"] = "target_outside_supported_dex"
            dependency["implemented"] = False
            future_dependencies.append(dependency)
        else:
            supported.append(evolution)
    entry["evolutions"] = supported
    if future_dependencies:
        entry["future_evolution_dependencies"] = future_dependencies
    else:
        entry.pop("future_evolution_dependencies", None)


def build_abilities() -> list[dict]:
    listing = api_get("ability?limit=1000")
    urls = [item["url"] for item in listing.get("results", [])]
    abilities = []
    with ThreadPoolExecutor(max_workers=8) as pool:
        futures = {pool.submit(api_get, url): url for url in urls}
        for future in as_completed(futures):
            data = future.result()
            if not bool(data.get("is_main_series", False)):
                continue
            generation = generation_number(data.get("generation", {}).get("name", ""))
            if generation <= 0 or generation > 8:
                continue
            name = english_name(data.get("names", []), data.get("name", ""))
            description = english_text(data.get("effect_entries", []), "short_effect", "effect") or english_text(data.get("flavor_text_entries", []), "flavor_text")
            abilities.append({
                "id": safe_id(data.get("name", "")),
                "api_id": int(data.get("id", 0)),
                "name": name,
                "generation": generation,
                "description": description,
                "triggers": [],
                "effects": [{
                    "type": "future_dependency",
                    "target": "battle",
                    "implemented": False,
                    "description": description,
                }],
            })
    abilities.sort(key=lambda entry: entry["api_id"])
    return abilities


def main() -> None:
    move_lookup, known_moves = load_moves_lookup()
    existing_entries = {
        str(entry.get("id", "")): entry
        for entry in json.loads((ROOT / "data/pokemon_species.json").read_text(encoding="utf-8"))
        if isinstance(entry, dict)
    }

    print("Fetching Pokemon and species resources...")
    bundles: dict[int, tuple[dict, dict]] = {}
    with ThreadPoolExecutor(max_workers=10) as pool:
        futures = {pool.submit(fetch_pokemon_bundle, dex): dex for dex in range(1, MAX_DEX + 1)}
        for index, future in enumerate(as_completed(futures), start=1):
            dex, pokemon, species = future.result()
            bundles[dex] = (pokemon, species)
            if index % 50 == 0 or index == MAX_DEX:
                print(f"  {index}/{MAX_DEX} Pokemon cached")

    print("Fetching evolution chains...")
    chain_urls = sorted({species.get("evolution_chain", {}).get("url", "") for _, species in bundles.values() if species.get("evolution_chain")})
    chain_urls = [url for url in chain_urls if url]
    evolutions: dict[str, list[dict]] = {}
    evolves_from: dict[str, str] = {}
    with ThreadPoolExecutor(max_workers=8) as pool:
        futures = {pool.submit(api_get, url): url for url in chain_urls}
        for index, future in enumerate(as_completed(futures), start=1):
            chain = future.result()
            collect_evolutions(chain.get("chain", {}), evolutions, evolves_from)
            if index % 50 == 0 or index == len(chain_urls):
                print(f"  {index}/{len(chain_urls)} chains cached")

    print("Building species JSON...")
    all_entries = []
    missing_moves: dict[str, list[str]] = {}
    for dex in range(1, MAX_DEX + 1):
        pokemon, species = bundles[dex]
        existing = existing_entries.get(safe_id(species.get("name", pokemon.get("name", ""))))
        entry = build_species_entry(dex, pokemon, species, existing, move_lookup, known_moves, evolutions, evolves_from)
        split_supported_evolutions(entry)
        all_entries.append(entry)
        if entry.get("learnset_dependencies"):
            missing_moves[entry["id"]] = entry["learnset_dependencies"]

    all_entries.sort(key=lambda entry: int(entry["dex_number"]))
    write_json(ROOT / "data/pokemon_species.json", all_entries)

    index = {}
    manifest = {}
    for entry in all_entries:
        generation = int(entry["generation"])
        pokemon_id = str(entry["id"])
        index[pokemon_id] = {
            "id": pokemon_id,
            "dex_number": int(entry["dex_number"]),
            "name": str(entry["name"]),
            "generation": generation,
            "file": f"res://data/pokemon/gen{generation}/pokemon.json",
        }
        manifest[pokemon_id] = asset_record(pokemon_id, generation)

    for generation, values in GEN_RANGES.items():
        generation_entries = [entry for entry in all_entries if int(entry["dex_number"]) in values]
        write_json(ROOT / f"data/pokemon/gen{generation}/pokemon.json", generation_entries)

    write_json(ROOT / "data/pokemon/pokemon_index.json", index)
    write_json(ROOT / "data/evolutions/evolutions.json", {entry["id"]: entry.get("evolutions", []) for entry in all_entries})
    write_json(ROOT / "data/evolutions/future_evolution_dependencies.json", {
        entry["id"]: entry.get("future_evolution_dependencies", [])
        for entry in all_entries
        if entry.get("future_evolution_dependencies")
    })
    write_json(ROOT / "data/pokedex/pokedex.json", [
        {
            "id": entry["id"],
            "dex_number": entry["dex_number"],
            "name": entry["name"],
            "generation": entry["generation"],
            "description_en": entry.get("description_en", ""),
            "description_pt": entry.get("description_pt", entry.get("description_en", "")),
        }
        for entry in all_entries
    ])
    write_json(ROOT / "data/pokemon_assets_manifest.json", manifest)
    write_json(ROOT / "data/pokemon/learnset_missing_moves.json", missing_moves)
    write_json(ROOT / "data/pokemon_learnset_missing_moves.json", missing_moves)

    print("Fetching abilities...")
    write_json(ROOT / "data/abilities/abilities.json", build_abilities())
    print(f"Done. Wrote {len(all_entries)} Pokemon, {len(missing_moves)} species with missing moves.")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Extract battle-animation sprites + real-game type/ability/Mega Stone data
for Mega Evolutions from the bundled "3D Models_ Generation N Pokemon"
archives - each archive is keyed by the BASE species' own generation (e.g.
Mega Charizard's GIFs live in the Gen 1 archive, Mega Diancie's in Gen 6),
same discovery method used for extract_form_sprites.py.

Writes data/pokemon_megas.json: one entry per mega id, combining hand
-authored real-game metadata (base species, display names, official
type/ability, held Mega Stone item id - see MEGAS) with extracted asset
paths, in the manifest shape PokemonHelpers already knows how to merge.

Usage: python3 extract_mega_sprites.py
"""

from __future__ import annotations

import json
import sys
import zipfile
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from extract_generation_sprites import (  # noqa: E402
    ROOT, MAX_FRAMES, detect_offset, gif_frames, load_groups, make_icon,
    normalize, save_frames, zip_path_for,
)

# (mega_id, base_species, source_gen, archive_slug, types, ability, item_id, name_en, name_pt)
# Types/abilities/Mega Stone names are real official game data (Bulbapedia) -
# never invented, per the expansion request's "nao criar dados ficticios
# quando houver dados oficiais" rule. Mega Rayquaza is the one documented
# exception (see the comment below it) - real-game Rayquaza mega-evolves
# via the move Dragon Ascent with no held item, which this project adapts
# to the same stone-holding mechanic as every other Mega for consistency.
MEGAS = [
    ("venusaur-mega", "venusaur", 1, "venusaur-mega", ["Grass", "Poison"], "Thick Fat", "venusaurite", "Mega Venusaur", "Mega Venusaur"),
    ("charizard-mega-x", "charizard", 1, "charizard-megax", ["Fire", "Dragon"], "Tough Claws", "charizardite_x", "Mega Charizard X", "Mega Charizard X"),
    ("charizard-mega-y", "charizard", 1, "charizard-megay", ["Fire", "Flying"], "Drought", "charizardite_y", "Mega Charizard Y", "Mega Charizard Y"),
    ("blastoise-mega", "blastoise", 1, "blastoise-mega", ["Water"], "Mega Launcher", "blastoisinite", "Mega Blastoise", "Mega Blastoise"),
    ("beedrill-mega", "beedrill", 1, "beedrill-mega", ["Bug", "Poison"], "Adaptability", "beedrillite", "Mega Beedrill", "Mega Beedrill"),
    ("alakazam-mega", "alakazam", 1, "alakazam-mega", ["Psychic"], "Trace", "alakazite", "Mega Alakazam", "Mega Alakazam"),
    ("slowbro-mega", "slowbro", 1, "slowbro-mega", ["Water", "Psychic"], "Shell Armor", "slowbronite", "Mega Slowbro", "Mega Slowbro"),
    ("gengar-mega", "gengar", 1, "gengar-mega", ["Ghost", "Poison"], "Shadow Tag", "gengarite", "Mega Gengar", "Mega Gengar"),
    ("kangaskhan-mega", "kangaskhan", 1, "kangaskhan-mega", ["Normal"], "Parental Bond", "kangaskhanite", "Mega Kangaskhan", "Mega Kangaskhan"),
    ("pinsir-mega", "pinsir", 1, "pinsir-mega", ["Bug", "Flying"], "Aerilate", "pinsirite", "Mega Pinsir", "Mega Pinsir"),
    ("gyarados-mega", "gyarados", 1, "gyarados-mega", ["Water", "Dark"], "Mold Breaker", "gyaradosite", "Mega Gyarados", "Mega Gyarados"),
    ("aerodactyl-mega", "aerodactyl", 1, "aerodactyl-mega", ["Rock", "Flying"], "Tough Claws", "aerodactylite", "Mega Aerodactyl", "Mega Aerodactyl"),
    ("mewtwo-mega-x", "mewtwo", 1, "mewtwo-megax", ["Psychic", "Fighting"], "Steadfast", "mewtwonite_x", "Mega Mewtwo X", "Mega Mewtwo X"),
    ("mewtwo-mega-y", "mewtwo", 1, "mewtwo-megay", ["Psychic"], "Insomnia", "mewtwonite_y", "Mega Mewtwo Y", "Mega Mewtwo Y"),
    ("steelix-mega", "steelix", 2, "steelix-mega", ["Steel", "Ground"], "Sand Force", "steelixite", "Mega Steelix", "Mega Steelix"),
    ("scizor-mega", "scizor", 2, "scizor-mega", ["Bug", "Steel"], "Technician", "scizorite", "Mega Scizor", "Mega Scizor"),
    ("heracross-mega", "heracross", 2, "heracross-mega", ["Bug", "Fighting"], "Skill Link", "heracronite", "Mega Heracross", "Mega Heracross"),
    ("houndoom-mega", "houndoom", 2, "houndoom-mega", ["Dark", "Fire"], "Solar Power", "houndoominite", "Mega Houndoom", "Mega Houndoom"),
    ("tyranitar-mega", "tyranitar", 2, "tyranitar-mega", ["Rock", "Dark"], "Sand Stream", "tyranitarite", "Mega Tyranitar", "Mega Tyranitar"),
    ("ampharos-mega", "ampharos", 2, "ampharos-mega", ["Electric", "Dragon"], "Mold Breaker", "ampharosite", "Mega Ampharos", "Mega Ampharos"),
    ("sceptile-mega", "sceptile", 3, "sceptile-mega", ["Grass", "Dragon"], "Lightning Rod", "sceptilite", "Mega Sceptile", "Mega Sceptile"),
    ("sableye-mega", "sableye", 3, "sableye-mega", ["Dark", "Ghost"], "Magic Bounce", "sablenite", "Mega Sableye", "Mega Sableye"),
    ("mawile-mega", "mawile", 3, "mawile-mega", ["Steel", "Fairy"], "Huge Power", "mawilite", "Mega Mawile", "Mega Mawile"),
    ("aggron-mega", "aggron", 3, "aggron-mega", ["Steel"], "Filter", "aggronite", "Mega Aggron", "Mega Aggron"),
    ("medicham-mega", "medicham", 3, "medicham-mega", ["Fighting", "Psychic"], "Pure Power", "medichamite", "Mega Medicham", "Mega Medicham"),
    ("manectric-mega", "manectric", 3, "manectric-mega", ["Electric"], "Intimidate", "manectite", "Mega Manectric", "Mega Manectric"),
    ("sharpedo-mega", "sharpedo", 3, "sharpedo-mega", ["Water", "Dark"], "Strong Jaw", "sharpedonite", "Mega Sharpedo", "Mega Sharpedo"),
    ("camerupt-mega", "camerupt", 3, "camerupt-mega", ["Fire", "Ground"], "Sheer Force", "cameruptite", "Mega Camerupt", "Mega Camerupt"),
    ("altaria-mega", "altaria", 3, "altaria-mega", ["Dragon", "Fairy"], "Pixilate", "altarianite", "Mega Altaria", "Mega Altaria"),
    ("blaziken-mega", "blaziken", 3, "blaziken-mega", ["Fire", "Fighting"], "Speed Boost", "blazikenite", "Mega Blaziken", "Mega Blaziken"),
    ("banette-mega", "banette", 3, "banette-mega", ["Ghost"], "Prankster", "banettite", "Mega Banette", "Mega Banette"),
    ("absol-mega", "absol", 3, "absol-mega", ["Dark"], "Magic Bounce", "absolite", "Mega Absol", "Mega Absol"),
    ("glalie-mega", "glalie", 3, "glalie-mega", ["Ice"], "Refrigerate", "glalitite", "Mega Glalie", "Mega Glalie"),
    ("salamence-mega", "salamence", 3, "salamence-mega", ["Dragon", "Flying"], "Aerilate", "salamencite", "Mega Salamence", "Mega Salamence"),
    ("metagross-mega", "metagross", 3, "metagross-mega", ["Steel", "Psychic"], "Tough Claws", "metagrossite", "Mega Metagross", "Mega Metagross"),
    ("latias-mega", "latias", 3, "latias-mega", ["Dragon", "Psychic"], "Levitate", "latiasite", "Mega Latias", "Mega Latias"),
    ("latios-mega", "latios", 3, "latios-mega", ["Dragon", "Psychic"], "Levitate", "latiosite", "Mega Latios", "Mega Latios"),
    # Real-game Mega Rayquaza needs no held item (Dragon Ascent triggers it) -
    # adapted here to use a stone like every other Mega for a consistent
    # in-battle trigger (see PokemonHelpers.MEGA_STONE constants).
    ("rayquaza-mega", "rayquaza", 3, "rayquaza-mega", ["Dragon", "Flying"], "Delta Stream", "rayquazite", "Mega Rayquaza", "Mega Rayquaza"),
    ("gardevoir-mega", "gardevoir", 3, "gardevoir-mega", ["Psychic", "Fairy"], "Pixilate", "gardevoirite", "Mega Gardevoir", "Mega Gardevoir"),
    ("swampert-mega", "swampert", 3, "swampert-mega", ["Water", "Ground"], "Swift Swim", "swampertite", "Mega Swampert", "Mega Swampert"),
    ("lopunny-mega", "lopunny", 4, "lopunny-mega", ["Normal", "Fighting"], "Scrappy", "lopunnite", "Mega Lopunny", "Mega Lopunny"),
    ("garchomp-mega", "garchomp", 4, "garchomp-mega", ["Dragon", "Ground"], "Sand Force", "garchompite", "Mega Garchomp", "Mega Garchomp"),
    ("lucario-mega", "lucario", 4, "lucario-mega", ["Fighting", "Steel"], "Adaptability", "lucarionite", "Mega Lucario", "Mega Lucario"),
    ("abomasnow-mega", "abomasnow", 4, "abomasnow-mega", ["Grass", "Ice"], "Snow Warning", "abomasite", "Mega Abomasnow", "Mega Abomasnow"),
    ("audino-mega", "audino", 5, "audino-mega", ["Normal", "Fairy"], "Healer", "audinite", "Mega Audino", "Mega Audino"),
    ("diancie-mega", "diancie", 6, "diancie-mega", ["Rock", "Fairy"], "Magic Bounce", "diancite", "Mega Diancie", "Mega Diancie"),
]


def main() -> None:
    megas_path = ROOT / "data" / "pokemon_megas.json"
    megas_data: dict = json.loads(megas_path.read_text(encoding="utf-8")) if megas_path.exists() else {}

    by_gen: dict[int, list] = defaultdict(list)
    for entry in MEGAS:
        by_gen[entry[2]].append(entry)

    done = []
    skipped = []
    for gen, entries in sorted(by_gen.items()):
        zpath = zip_path_for(gen)
        if not zpath.exists():
            skipped.extend(e[0] for e in entries)
            continue
        with zipfile.ZipFile(zpath) as zf:
            groups = load_groups(zf)
            offset = detect_offset(groups)
            print(f"Gen {gen} archive: offset={offset}, {len(groups)} slug groups")
            for mega_id, base_species, _gen, slug_raw, types, ability, item_id, name_en, name_pt in entries:
                slug = normalize(slug_raw)
                nums = groups.get(slug) or groups.get(slug.replace("-", ""))
                if not nums:
                    skipped.append(mega_id)
                    continue
                nums = sorted(nums)
                front_num = nums[0]
                back_candidates = [n for n in nums if n - front_num >= offset * 0.5]
                if not back_candidates:
                    skipped.append(mega_id)
                    continue
                back_num = min(back_candidates)

                front_name = next(n for n in zf.namelist() if n.startswith(f"imgi_{front_num}_"))
                back_name = next(n for n in zf.namelist() if n.startswith(f"imgi_{back_num}_"))

                try:
                    front_frames = gif_frames(zf.read(front_name), MAX_FRAMES)
                    back_frames = gif_frames(zf.read(back_name), MAX_FRAMES)
                    if not front_frames or not back_frames:
                        raise ValueError("no decodable frames")
                except Exception as exc:
                    print(f"  {mega_id}: FAILED to decode ({front_name} / {back_name}): {exc}")
                    skipped.append(mega_id)
                    continue

                front_dir = ROOT / f"assets/pokemon/megas/{mega_id}/front"
                back_dir = ROOT / f"assets/pokemon/megas/{mega_id}/back"
                front_count = save_frames(front_frames, front_dir)
                back_count = save_frames(back_frames, back_dir)

                icon_path = ROOT / f"assets/pokemon/megas/icons/{mega_id}.png"
                make_icon(front_frames[0], icon_path)

                megas_data[mega_id] = {
                    "base_species": base_species,
                    "name_en": name_en,
                    "name_pt": name_pt,
                    "types": types,
                    "ability": ability,
                    "item_id": item_id,
                    "icon_path": f"res://assets/pokemon/megas/icons/{mega_id}.png",
                    "front_frames_path": f"res://assets/pokemon/megas/{mega_id}/front/",
                    "back_frames_path": f"res://assets/pokemon/megas/{mega_id}/back/",
                    "front_frame_count": front_count,
                    "back_frame_count": back_count,
                    "has_animation": True,
                    "front_gif_source": front_name,
                    "back_gif_source": back_name,
                }
                done.append(mega_id)

    megas_path.write_text(json.dumps(megas_data, indent=2, ensure_ascii=False, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Megas: extracted {len(done)}/{len(MEGAS)}")
    if skipped:
        print(f"Megas: {len(skipped)} had no matching sprite: {skipped}")


if __name__ == "__main__":
    main()

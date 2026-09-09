#!/usr/bin/env python3
"""Extract battle-animation sprites for Gigantamax forms from the bundled
Gen 8 sprite archive - the same archive extract_form_sprites.py already
mines for Galarian/Alolan forms and Rotom's appliance forms, this time for
the "-gigantamax" slugs (33 groups covering all 32 real Gigantamax species,
Urshifu counted twice for its two styles).

Writes data/pokemon_gmax.json: one entry per gmax id (base_species, real
display name, extracted asset paths) in the manifest shape PokemonHelpers
already knows how to merge. No type/ability/stat override data here -
unlike a Mega Evolution, Gigantamax changes only appearance and (in the
real games) unlocks a signature G-Max Move this project does not model,
so a gmax entry is purely a sprite swap layered under the generic Dynamax
mechanic (see PokemonHelpers.gmax_definition / battle_scene.gd _dynamax).

Usage: python3 extract_gmax_sprites.py
"""

from __future__ import annotations

import json
import sys
import zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from extract_generation_sprites import (  # noqa: E402
    ROOT, MAX_FRAMES, detect_offset, gif_frames, load_groups, make_icon,
    normalize, save_frames,
)

ZIP_PATH = ROOT / "assets/3D Models_ Generation 8 Pokémon - Sprite Index - Project Pokemon Forums.zip"

# (gmax_id, base_species, archive_slug, name_en, name_pt)
GMAX = [
    ("venusaur-gmax", "venusaur", "venusaur-gigantamax", "Gigantamax Venusaur", "Gigantamax Venusaur"),
    ("charizard-gmax", "charizard", "charizard-gigantamax", "Gigantamax Charizard", "Gigantamax Charizard"),
    ("blastoise-gmax", "blastoise", "blastoise-gigantamax", "Gigantamax Blastoise", "Gigantamax Blastoise"),
    ("butterfree-gmax", "butterfree", "butterfree-gigantamax", "Gigantamax Butterfree", "Gigantamax Butterfree"),
    ("pikachu-gmax", "pikachu", "pikachu-gigantamax", "Gigantamax Pikachu", "Gigantamax Pikachu"),
    ("meowth-gmax", "meowth", "meowth-gigantamax", "Gigantamax Meowth", "Gigantamax Meowth"),
    ("machamp-gmax", "machamp", "machamp-gigantamax", "Gigantamax Machamp", "Gigantamax Machamp"),
    ("gengar-gmax", "gengar", "gengar-gigantamax", "Gigantamax Gengar", "Gigantamax Gengar"),
    ("kingler-gmax", "kingler", "kingler-gigantamax", "Gigantamax Kingler", "Gigantamax Kingler"),
    ("lapras-gmax", "lapras", "lapras-gigantamax", "Gigantamax Lapras", "Gigantamax Lapras"),
    ("eevee-gmax", "eevee", "eevee-gigantamax", "Gigantamax Eevee", "Gigantamax Eevee"),
    ("snorlax-gmax", "snorlax", "snorlax-gigantamax", "Gigantamax Snorlax", "Gigantamax Snorlax"),
    ("garbodor-gmax", "garbodor", "garbodor-gigantamax", "Gigantamax Garbodor", "Gigantamax Garbodor"),
    ("melmetal-gmax", "melmetal", "melmetal-gigantamax", "Gigantamax Melmetal", "Gigantamax Melmetal"),
    ("rillaboom-gmax", "rillaboom", "rillaboom-gigantamax", "Gigantamax Rillaboom", "Gigantamax Rillaboom"),
    ("cinderace-gmax", "cinderace", "cinderace-gigantamax", "Gigantamax Cinderace", "Gigantamax Cinderace"),
    ("inteleon-gmax", "inteleon", "gigantamax-inteleon", "Gigantamax Inteleon", "Gigantamax Inteleon"),
    ("urshifu-gmax", "urshifu", "urshifu-gigantamax", "Gigantamax Urshifu (Single Strike)", "Gigantamax Urshifu (Golpe Único)"),
    ("urshifu-rapid-strike-gmax", "urshifu", "urshifu-rapid-strike-gigantamax", "Gigantamax Urshifu (Rapid Strike)", "Gigantamax Urshifu (Golpes Rápidos)"),
    ("corviknight-gmax", "corviknight", "corviknight-gigantamax", "Gigantamax Corviknight", "Gigantamax Corviknight"),
    ("orbeetle-gmax", "orbeetle", "orbeetle-gigantamax", "Gigantamax Orbeetle", "Gigantamax Orbeetle"),
    ("drednaw-gmax", "drednaw", "drednaw-gigantamax", "Gigantamax Drednaw", "Gigantamax Drednaw"),
    ("coalossal-gmax", "coalossal", "coalossal-gigantamax", "Gigantamax Coalossal", "Gigantamax Coalossal"),
    ("flapple-gmax", "flapple", "flapple-gigantamax", "Gigantamax Flapple", "Gigantamax Flapple"),
    ("appletun-gmax", "appletun", "appletun-gigantamax", "Gigantamax Appletun", "Gigantamax Appletun"),
    ("sandaconda-gmax", "sandaconda", "sandaconda-gigantamax", "Gigantamax Sandaconda", "Gigantamax Sandaconda"),
    ("toxtricity-gmax", "toxtricity", "toxtricity-gigantamax", "Gigantamax Toxtricity", "Gigantamax Toxtricity"),
    ("centiskorch-gmax", "centiskorch", "centiskorch-gigantamax", "Gigantamax Centiskorch", "Gigantamax Centiskorch"),
    ("hatterene-gmax", "hatterene", "hatterene-gigantamax", "Gigantamax Hatterene", "Gigantamax Hatterene"),
    ("grimmsnarl-gmax", "grimmsnarl", "grimmsnarl-gigantamax", "Gigantamax Grimmsnarl", "Gigantamax Grimmsnarl"),
    ("alcremie-gmax", "alcremie", "alcremie-gigantamax", "Gigantamax Alcremie", "Gigantamax Alcremie"),
    ("copperajah-gmax", "copperajah", "copperajah-gigantamax", "Gigantamax Copperajah", "Gigantamax Copperajah"),
    ("duraludon-gmax", "duraludon", "duraludon-gigantamax", "Gigantamax Duraludon", "Gigantamax Duraludon"),
]


def main() -> None:
    if not ZIP_PATH.exists():
        raise SystemExit(f"Archive not found: {ZIP_PATH}")

    gmax_path = ROOT / "data" / "pokemon_gmax.json"
    gmax_data: dict = json.loads(gmax_path.read_text(encoding="utf-8")) if gmax_path.exists() else {}

    with zipfile.ZipFile(ZIP_PATH) as zf:
        groups = load_groups(zf)
        offset = detect_offset(groups)
        print(f"Gmax: detected front/back offset = {offset}, {len(groups)} slug groups in archive")

        done = []
        skipped = []
        for gmax_id, base_species, slug_raw, name_en, name_pt in GMAX:
            slug = normalize(slug_raw)
            nums = groups.get(slug) or groups.get(slug.replace("-", ""))
            if not nums:
                skipped.append(gmax_id)
                continue
            nums = sorted(nums)
            front_num = nums[0]
            back_candidates = [n for n in nums if n - front_num >= offset * 0.5]
            if not back_candidates:
                skipped.append(gmax_id)
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
                print(f"  {gmax_id}: FAILED to decode ({front_name} / {back_name}): {exc}")
                skipped.append(gmax_id)
                continue

            front_dir = ROOT / f"assets/pokemon/gmax/{gmax_id}/front"
            back_dir = ROOT / f"assets/pokemon/gmax/{gmax_id}/back"
            front_count = save_frames(front_frames, front_dir)
            back_count = save_frames(back_frames, back_dir)

            icon_path = ROOT / f"assets/pokemon/gmax/icons/{gmax_id}.png"
            make_icon(front_frames[0], icon_path)

            gmax_data[gmax_id] = {
                "base_species": base_species,
                "name_en": name_en,
                "name_pt": name_pt,
                "icon_path": f"res://assets/pokemon/gmax/icons/{gmax_id}.png",
                "front_frames_path": f"res://assets/pokemon/gmax/{gmax_id}/front/",
                "back_frames_path": f"res://assets/pokemon/gmax/{gmax_id}/back/",
                "front_frame_count": front_count,
                "back_frame_count": back_count,
                "has_animation": True,
                "front_gif_source": front_name,
                "back_gif_source": back_name,
            }
            done.append(gmax_id)

    gmax_path.write_text(json.dumps(gmax_data, indent=2, ensure_ascii=False, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Gmax: extracted {len(done)}/{len(GMAX)}")
    if skipped:
        print(f"Gmax: {len(skipped)} had no matching sprite: {skipped}")


if __name__ == "__main__":
    main()

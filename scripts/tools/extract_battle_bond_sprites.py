#!/usr/bin/env python3
"""Extract the Ash-Greninja (Battle Bond) sprite from the bundled Gen 6
archive - real games' own internal name for this form is "Active", which
is exactly the slug this archive scraped it under.

Battle Bond is the one real Pokemon mechanic that's entirely automatic
(no held item, no player button): Greninja transforms mid-battle the
instant it KOs an opposing Pokemon, for the rest of that battle. Real
Greninja keeps its pure Water type and gains a stat boost + a boosted
Water Shuriken this project doesn't model per-move (same "dont invent
exact numbers" reasoning as Dynamax/Z-Moves) - only the sprite swap and a
flat stat bonus are real here.

Writes data/pokemon_battle_bond.json.

Usage: python3 extract_battle_bond_sprites.py
"""

from __future__ import annotations

import json
import zipfile
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from extract_generation_sprites import (  # noqa: E402
    ROOT, MAX_FRAMES, detect_offset, gif_frames, load_groups, make_icon,
    normalize, save_frames, zip_path_for,
)

BASE_SPECIES = "greninja"
ARCHIVE_SLUG = "greninja-active"
GEN = 6


def main() -> None:
    zpath = zip_path_for(GEN)
    if not zpath.exists():
        raise SystemExit(f"Archive not found: {zpath}")

    out_path = ROOT / "data" / "pokemon_battle_bond.json"
    data: dict = json.loads(out_path.read_text(encoding="utf-8")) if out_path.exists() else {}

    with zipfile.ZipFile(zpath) as zf:
        groups = load_groups(zf)
        offset = detect_offset(groups)
        slug = normalize(ARCHIVE_SLUG)
        nums = sorted(groups.get(slug) or groups.get(slug.replace("-", "")) or [])
        if not nums:
            raise SystemExit(f"No sprite found for slug '{ARCHIVE_SLUG}'")
        front_num = nums[0]
        back_candidates = [n for n in nums if n - front_num >= offset * 0.5]
        if not back_candidates:
            raise SystemExit("No back sprite found")
        back_num = min(back_candidates)

        front_name = next(n for n in zf.namelist() if n.startswith(f"imgi_{front_num}_"))
        back_name = next(n for n in zf.namelist() if n.startswith(f"imgi_{back_num}_"))

        front_frames = gif_frames(zf.read(front_name), MAX_FRAMES)
        back_frames = gif_frames(zf.read(back_name), MAX_FRAMES)
        if not front_frames or not back_frames:
            raise SystemExit("No decodable frames")

        front_dir = ROOT / "assets/pokemon/battle_bond/greninja-battle-bond/front"
        back_dir = ROOT / "assets/pokemon/battle_bond/greninja-battle-bond/back"
        front_count = save_frames(front_frames, front_dir)
        back_count = save_frames(back_frames, back_dir)

        icon_path = ROOT / "assets/pokemon/battle_bond/icons/greninja-battle-bond.png"
        make_icon(front_frames[0], icon_path)

        data["greninja-battle-bond"] = {
            "base_species": BASE_SPECIES,
            "name_en": "Ash-Greninja",
            "name_pt": "Greninja de Ash",
            "ability": "Battle Bond",
            "icon_path": "res://assets/pokemon/battle_bond/icons/greninja-battle-bond.png",
            "front_frames_path": "res://assets/pokemon/battle_bond/greninja-battle-bond/front/",
            "back_frames_path": "res://assets/pokemon/battle_bond/greninja-battle-bond/back/",
            "front_frame_count": front_count,
            "back_frame_count": back_count,
            "has_animation": True,
            "front_gif_source": front_name,
            "back_gif_source": back_name,
        }

    out_path.write_text(json.dumps(data, indent=2, ensure_ascii=False, sort_keys=True) + "\n", encoding="utf-8")
    print("Battle Bond: extracted greninja-battle-bond")


if __name__ == "__main__":
    main()

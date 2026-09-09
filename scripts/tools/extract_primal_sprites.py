#!/usr/bin/env python3
"""Extract battle-animation sprites for Primal Reversion (Primal Kyogre,
Primal Groudon - the only 2 real Primal Reversions) from the bundled Gen 3
archive, merging into data/pokemon_megas.json alongside Mega Evolution.

Primal Reversion works mechanically identically to Mega Evolution in the
real games (hold a specific item - the Blue/Red Orb - to transform for the
rest of the battle, type/ability override, reverts after) so this project
reuses the exact same pokemon["mega"] field/architecture rather than a
parallel system; the only new thing is a "category": "primal" tag so
battle_scene.gd can show the correct button label/message ("Primal
Revert" instead of "Mega Evolve"). See extract_mega_sprites.py for the
full Mega Evolution set this merges into.

Usage: python3 extract_primal_sprites.py
"""

from __future__ import annotations

import json
import sys
import zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from extract_generation_sprites import (  # noqa: E402
    MAX_FRAMES, detect_offset, gif_frames, load_groups, make_icon, normalize,
    save_frames, zip_path_for, ROOT,
)

# (primal_id, base_species, gen, archive_slug, types, ability, item_id, name_en, name_pt)
PRIMALS = [
    ("kyogre-primal", "kyogre", 3, "kyogre-primal", ["Water"], "Primordial Sea", "blue_orb", "Primal Kyogre", "Primal Kyogre"),
    ("groudon-primal", "groudon", 3, "groudon-primal", ["Ground", "Fire"], "Desolate Land", "red_orb", "Primal Groudon", "Primal Groudon"),
]


def main() -> None:
    megas_path = ROOT / "data" / "pokemon_megas.json"
    megas_data: dict = json.loads(megas_path.read_text(encoding="utf-8")) if megas_path.exists() else {}

    by_gen: dict[int, list] = {}
    for entry in PRIMALS:
        by_gen.setdefault(entry[2], []).append(entry)

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
            for primal_id, base_species, _gen, slug_raw, types, ability, item_id, name_en, name_pt in entries:
                slug = normalize(slug_raw)
                nums = groups.get(slug) or groups.get(slug.replace("-", ""))
                if not nums:
                    skipped.append(primal_id)
                    continue
                nums = sorted(nums)
                front_num = nums[0]
                back_candidates = [n for n in nums if n - front_num >= offset * 0.5]
                if not back_candidates:
                    skipped.append(primal_id)
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
                    print(f"  {primal_id}: FAILED to decode ({front_name} / {back_name}): {exc}")
                    skipped.append(primal_id)
                    continue

                front_dir = ROOT / f"assets/pokemon/megas/{primal_id}/front"
                back_dir = ROOT / f"assets/pokemon/megas/{primal_id}/back"
                front_count = save_frames(front_frames, front_dir)
                back_count = save_frames(back_frames, back_dir)

                icon_path = ROOT / f"assets/pokemon/megas/icons/{primal_id}.png"
                make_icon(front_frames[0], icon_path)

                megas_data[primal_id] = {
                    "base_species": base_species,
                    "name_en": name_en,
                    "name_pt": name_pt,
                    "category": "primal",
                    "types": types,
                    "ability": ability,
                    "item_id": item_id,
                    "icon_path": f"res://assets/pokemon/megas/icons/{primal_id}.png",
                    "front_frames_path": f"res://assets/pokemon/megas/{primal_id}/front/",
                    "back_frames_path": f"res://assets/pokemon/megas/{primal_id}/back/",
                    "front_frame_count": front_count,
                    "back_frame_count": back_count,
                    "has_animation": True,
                    "front_gif_source": front_name,
                    "back_gif_source": back_name,
                }
                done.append(primal_id)

    megas_path.write_text(json.dumps(megas_data, indent=2, ensure_ascii=False, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Primal: extracted {len(done)}/{len(PRIMALS)}")
    if skipped:
        print(f"Primal: {len(skipped)} had no matching sprite: {skipped}")


if __name__ == "__main__":
    main()

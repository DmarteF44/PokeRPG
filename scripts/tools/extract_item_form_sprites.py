#!/usr/bin/env python3
"""Extract sprites for real-game Item Forms - species whose form is
determined by a currently-HELD item, reverting the instant the item is
removed or swapped (unlike Mega/Dynamax, which are battle-only, or
Regional/Conditional Forms, which persist once set regardless of held
item). Mines each species' own generation archive: Arceus/Giratina/
Shaymin are Gen 4, Genesect is Gen 5, Hoopa is Gen 6.

Real per-species mechanics differ on whether the form changes type:
- Arceus (Multitype): each of its 17 Plates changes its own type.
- Shaymin-Sky (Gracidea): gains Flying (Grass -> Grass/Flying).
- Hoopa-Unbound (Prison Bottle): Ghost becomes Dark (Psychic/Ghost ->
  Psychic/Dark).
- Genesect's 4 Drives only change its signature move Techno Blast's type,
  NOT Genesect's own type - it stays Bug/Steel regardless. Not modeled
  per-move here (same reasoning as Dynamax/Z-Moves), so these are sprite
  -only, honestly not claiming a type change that doesn't exist.
- Giratina-Origin keeps the exact same Ghost/Dragon typing as Altered
  Forme (only appearance/stat-distribution differs in the real games) -
  sprite-only here too.

Writes data/pokemon_item_forms.json.

Usage: python3 extract_item_form_sprites.py
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

# (item_form_id, base_species, gen, archive_slug, types, item_id, name_en, name_pt)
FORMS = [
    ("arceus-fighting", "arceus", 4, "arceus-fighting", ["Fighting"], "fist_plate", "Arceus (Fighting)", "Arceus (Lutador)"),
    ("arceus-flying", "arceus", 4, "arceus-flying", ["Flying"], "sky_plate", "Arceus (Flying)", "Arceus (Voador)"),
    ("arceus-poison", "arceus", 4, "arceus-poison", ["Poison"], "toxic_plate", "Arceus (Poison)", "Arceus (Veneno)"),
    ("arceus-ground", "arceus", 4, "arceus-ground", ["Ground"], "earth_plate", "Arceus (Ground)", "Arceus (Terra)"),
    ("arceus-rock", "arceus", 4, "arceus-rock", ["Rock"], "stone_plate", "Arceus (Rock)", "Arceus (Pedra)"),
    ("arceus-bug", "arceus", 4, "arceus-bug", ["Bug"], "insect_plate", "Arceus (Bug)", "Arceus (Inseto)"),
    ("arceus-ghost", "arceus", 4, "arceus-ghost", ["Ghost"], "spooky_plate", "Arceus (Ghost)", "Arceus (Fantasma)"),
    ("arceus-steel", "arceus", 4, "arceus-steel", ["Steel"], "iron_plate", "Arceus (Steel)", "Arceus (Aço)"),
    ("arceus-fire", "arceus", 4, "arceus-fire", ["Fire"], "flame_plate", "Arceus (Fire)", "Arceus (Fogo)"),
    ("arceus-water", "arceus", 4, "arceus-water", ["Water"], "splash_plate", "Arceus (Water)", "Arceus (Água)"),
    ("arceus-grass", "arceus", 4, "arceus-grass", ["Grass"], "meadow_plate", "Arceus (Grass)", "Arceus (Grama)"),
    ("arceus-electric", "arceus", 4, "arceus-electric", ["Electric"], "zap_plate", "Arceus (Electric)", "Arceus (Elétrico)"),
    ("arceus-psychic", "arceus", 4, "arceus-psychic", ["Psychic"], "mind_plate", "Arceus (Psychic)", "Arceus (Psíquico)"),
    ("arceus-ice", "arceus", 4, "arceus-ice", ["Ice"], "icicle_plate", "Arceus (Ice)", "Arceus (Gelo)"),
    ("arceus-dragon", "arceus", 4, "arceus-dragon", ["Dragon"], "draco_plate", "Arceus (Dragon)", "Arceus (Dragão)"),
    ("arceus-dark", "arceus", 4, "arceus-dark", ["Dark"], "dread_plate", "Arceus (Dark)", "Arceus (Sombrio)"),
    ("arceus-fairy", "arceus", 4, "arceus-fairy", ["Fairy"], "pixie_plate", "Arceus (Fairy)", "Arceus (Fada)"),
    ("genesect-water", "genesect", 5, "genesect-water", ["Bug", "Steel"], "douse_drive", "Genesect (Douse Drive)", "Genesect (Douse Drive)"),
    ("genesect-electric", "genesect", 5, "genesect-electric", ["Bug", "Steel"], "shock_drive", "Genesect (Shock Drive)", "Genesect (Shock Drive)"),
    ("genesect-fire", "genesect", 5, "genesect-fire", ["Bug", "Steel"], "burn_drive", "Genesect (Burn Drive)", "Genesect (Burn Drive)"),
    ("genesect-ice", "genesect", 5, "genesect-ice", ["Bug", "Steel"], "chill_drive", "Genesect (Chill Drive)", "Genesect (Chill Drive)"),
    ("giratina-origin", "giratina", 4, "giratina-origin", ["Ghost", "Dragon"], "griseous_orb", "Giratina (Origin Forme)", "Giratina (Forma Origem)"),
    ("shaymin-sky", "shaymin", 4, "shaymin-sky", ["Grass", "Flying"], "gracidea", "Shaymin (Sky Forme)", "Shaymin (Forma Celeste)"),
    ("hoopa-unbound", "hoopa", 6, "hoopa-unbound", ["Psychic", "Dark"], "prison_bottle", "Hoopa (Unbound)", "Hoopa (Desvinculado)"),
]


def main() -> None:
    out_path = ROOT / "data" / "pokemon_item_forms.json"
    data: dict = json.loads(out_path.read_text(encoding="utf-8")) if out_path.exists() else {}

    by_gen: dict[int, list] = defaultdict(list)
    for entry in FORMS:
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
            for item_form_id, base_species, _gen, slug_raw, types, item_id, name_en, name_pt in entries:
                slug = normalize(slug_raw)
                nums = groups.get(slug) or groups.get(slug.replace("-", ""))
                if not nums:
                    skipped.append(item_form_id)
                    continue
                nums = sorted(nums)
                front_num = nums[0]
                back_candidates = [n for n in nums if n - front_num >= offset * 0.5]
                if not back_candidates:
                    skipped.append(item_form_id)
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
                    print(f"  {item_form_id}: FAILED to decode ({front_name} / {back_name}): {exc}")
                    skipped.append(item_form_id)
                    continue

                front_dir = ROOT / f"assets/pokemon/item_forms/{item_form_id}/front"
                back_dir = ROOT / f"assets/pokemon/item_forms/{item_form_id}/back"
                front_count = save_frames(front_frames, front_dir)
                back_count = save_frames(back_frames, back_dir)

                icon_path = ROOT / f"assets/pokemon/item_forms/icons/{item_form_id}.png"
                make_icon(front_frames[0], icon_path)

                data[item_form_id] = {
                    "base_species": base_species,
                    "item_id": item_id,
                    "types": types,
                    "name_en": name_en,
                    "name_pt": name_pt,
                    "icon_path": f"res://assets/pokemon/item_forms/icons/{item_form_id}.png",
                    "front_frames_path": f"res://assets/pokemon/item_forms/{item_form_id}/front/",
                    "back_frames_path": f"res://assets/pokemon/item_forms/{item_form_id}/back/",
                    "front_frame_count": front_count,
                    "back_frame_count": back_count,
                    "has_animation": True,
                    "front_gif_source": front_name,
                    "back_gif_source": back_name,
                }
                done.append(item_form_id)

    out_path.write_text(json.dumps(data, indent=2, ensure_ascii=False, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Item forms: extracted {len(done)}/{len(FORMS)}")
    if skipped:
        print(f"Item forms: {len(skipped)} had no matching sprite: {skipped}")


if __name__ == "__main__":
    main()

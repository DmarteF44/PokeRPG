#!/usr/bin/env python3
"""Extract battle-animation sprites + icons for Regional/Alternate Pokemon
forms (Galarian, Alolan, Rotom's appliance forms) from the bundled Gen 8
"3D Models_ Generation 8 Pokemon - Sprite Index" archive, which - unlike the
per-generation species extraction in extract_generation_sprites.py - also
happens to carry these forms' GIFs under their own distinct slugs (e.g.
"ponyta-galar", "rotom-heat") alongside the base Gen 8 species.

Writes data/pokemon_forms.json: one entry per form id, combining the
hand-authored real-game metadata below (base species, display names,
category, region, official types - see FORMS) with the extracted asset
paths, in the same shape data/pokemon_assets_manifest.json uses for base
species so PokemonHelpers can read both with the same merge pattern.

Usage: python3 extract_form_sprites.py
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

# (form_id, base_species_id, archive_slug, category, region, types, name_en, name_pt, evolves_to_form, short_label)
# Types are real official game data (Bulbapedia) - never invented per the
# expansion request's "nao criar dados ficticios quando houver dados
# oficiais" rule. evolves_to_form lets evolve_pokemon() carry the form
# forward only when the evolved species has a matching real-game form
# (e.g. Vulpix-Alola -> Ninetales-Alola); left "" when the real evolution
# target has no form counterpart in our data (e.g. Meowth-Galar's real
# evolution, Perrserker, is a distinct species we don't have sprites for).
# short_label is the compact suffix shown next to a Pokemon's name in lists
# (see PokemonHelpers.variant_tag).
FORMS = [
    ("meowth-galar", "meowth", "meowth-galar", "regional", "galar", ["Steel"], "Meowth (Galarian)", "Meowth (De Gala)", "", "Galar"),
    ("ponyta-galar", "ponyta", "ponyta-galar", "regional", "galar", ["Psychic"], "Ponyta (Galarian)", "Ponyta (De Gala)", "rapidash-galar", "Galar"),
    ("rapidash-galar", "rapidash", "rapidash-galar", "regional", "galar", ["Psychic", "Fairy"], "Rapidash (Galarian)", "Rapidash (De Gala)", "", "Galar"),
    ("slowpoke-galar", "slowpoke", "slowpoke-galar", "regional", "galar", ["Psychic"], "Slowpoke (Galarian)", "Slowpoke (De Gala)", "slowbro-galar", "Galar"),
    ("slowbro-galar", "slowbro", "slowbro-galar", "regional", "galar", ["Poison", "Psychic"], "Slowbro (Galarian)", "Slowbro (De Gala)", "", "Galar"),
    ("farfetchd-galar", "farfetchd", "farfetchd-galar", "regional", "galar", ["Fighting"], "Farfetch'd (Galarian)", "Farfetch'd (De Gala)", "", "Galar"),
    ("weezing-galar", "weezing", "weezing-galar", "regional", "galar", ["Poison", "Fairy"], "Weezing (Galarian)", "Weezing (De Gala)", "", "Galar"),
    ("mr-mime-galar", "mr_mime", "mr.-mime-galar", "regional", "galar", ["Ice", "Psychic"], "Mr. Mime (Galarian)", "Mr. Mime (De Gala)", "", "Galar"),
    ("corsola-galar", "corsola", "corsola-galar", "regional", "galar", ["Ghost"], "Corsola (Galarian)", "Corsola (De Gala)", "", "Galar"),
    ("zigzagoon-galar", "zigzagoon", "zigzagoon-galar", "regional", "galar", ["Dark", "Normal"], "Zigzagoon (Galarian)", "Zigzagoon (De Gala)", "linoone-galar", "Galar"),
    ("linoone-galar", "linoone", "linoone-galar", "regional", "galar", ["Dark", "Normal"], "Linoone (Galarian)", "Linoone (De Gala)", "", "Galar"),
    ("darumaka-galar", "darumaka", "darumaka-galar", "regional", "galar", ["Ice"], "Darumaka (Galarian)", "Darumaka (De Gala)", "darmanitan-galar", "Galar"),
    ("darmanitan-galar", "darmanitan", "darmanitan-galar", "regional", "galar", ["Ice"], "Darmanitan (Galarian)", "Darmanitan (De Gala)", "", "Galar"),
    ("darmanitan-galar-zen", "darmanitan", "darmanitan-galar-zen", "alternate", "galar", ["Ice", "Fire"], "Darmanitan (Galarian, Zen Mode)", "Darmanitan (De Gala, Modo Zen)", "", "Galar-Zen"),
    ("yamask-galar", "yamask", "yamask-galar", "regional", "galar", ["Ground", "Ghost"], "Yamask (Galarian)", "Yamask (De Gala)", "", "Galar"),
    ("stunfisk-galar", "stunfisk", "stunfisk-galar", "regional", "galar", ["Ground", "Steel"], "Stunfisk (Galarian)", "Stunfisk (De Gala)", "", "Galar"),
    ("vulpix-alola", "vulpix", "vulpix-alola", "regional", "alola", ["Ice"], "Vulpix (Alolan)", "Vulpix (De Alola)", "ninetales-alola", "Alola"),
    ("ninetales-alola", "ninetales", "ninetales-alola", "regional", "alola", ["Ice", "Fairy"], "Ninetales (Alolan)", "Ninetales (De Alola)", "", "Alola"),
    ("diglett-alola", "diglett", "diglett-alola", "regional", "alola", ["Ground", "Steel"], "Diglett (Alolan)", "Diglett (De Alola)", "dugtrio-alola", "Alola"),
    ("dugtrio-alola", "dugtrio", "dugtrio-alola", "regional", "alola", ["Ground", "Steel"], "Dugtrio (Alolan)", "Dugtrio (De Alola)", "", "Alola"),
    ("meowth-alola", "meowth", "meowth-alola", "regional", "alola", ["Dark"], "Meowth (Alolan)", "Meowth (De Alola)", "persian-alola", "Alola"),
    ("persian-alola", "persian", "persian-alola", "regional", "alola", ["Dark"], "Persian (Alolan)", "Persian (De Alola)", "", "Alola"),
    ("raichu-alola", "raichu", "raichu-alola", "regional", "alola", ["Electric", "Psychic"], "Raichu (Alolan)", "Raichu (De Alola)", "", "Alola"),
    ("rotom-heat", "rotom", "rotom-heat", "alternate", "", ["Electric", "Fire"], "Rotom (Heat)", "Rotom (Calor)", "", "Heat"),
    ("rotom-wash", "rotom", "rotom-wash", "alternate", "", ["Electric", "Water"], "Rotom (Wash)", "Rotom (Lavagem)", "", "Wash"),
    ("rotom-frost", "rotom", "rotom-frost", "alternate", "", ["Electric", "Ice"], "Rotom (Frost)", "Rotom (Gelo)", "", "Frost"),
    ("rotom-fan", "rotom", "rotom-fan", "alternate", "", ["Electric", "Flying"], "Rotom (Fan)", "Rotom (Ventilador)", "", "Fan"),
    ("rotom-mow", "rotom", "rotom-mow", "alternate", "", ["Electric", "Grass"], "Rotom (Mow)", "Rotom (Cortador)", "", "Mow"),
]


def main() -> None:
    if not ZIP_PATH.exists():
        raise SystemExit(f"Archive not found: {ZIP_PATH}")

    forms_path = ROOT / "data" / "pokemon_forms.json"
    forms_data: dict = json.loads(forms_path.read_text(encoding="utf-8")) if forms_path.exists() else {}

    with zipfile.ZipFile(ZIP_PATH) as zf:
        groups = load_groups(zf)
        offset = detect_offset(groups)
        print(f"Forms: detected front/back offset = {offset}, {len(groups)} slug groups in archive")

        done = []
        skipped = []
        for form_id, base_species, slug_raw, category, region, types, name_en, name_pt, evolves_to, short_label in FORMS:
            slug = normalize(slug_raw)
            nums = groups.get(slug) or groups.get(slug.replace("-", ""))
            if not nums:
                skipped.append(form_id)
                continue
            nums = sorted(nums)
            front_num = nums[0]
            back_candidates = [n for n in nums if n - front_num >= offset * 0.5]
            if not back_candidates:
                skipped.append(form_id)
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
                print(f"  {form_id}: FAILED to decode ({front_name} / {back_name}): {exc}")
                skipped.append(form_id)
                continue

            front_dir = ROOT / f"assets/pokemon/forms/{form_id}/front"
            back_dir = ROOT / f"assets/pokemon/forms/{form_id}/back"
            front_count = save_frames(front_frames, front_dir)
            back_count = save_frames(back_frames, back_dir)

            icon_path = ROOT / f"assets/pokemon/forms/icons/{form_id}.png"
            make_icon(front_frames[0], icon_path)

            forms_data[form_id] = {
                "base_species": base_species,
                "name_en": name_en,
                "name_pt": name_pt,
                "category": category,
                "region": region,
                "types": types,
                "evolves_to_form": evolves_to,
                "short_label": short_label,
                "icon_path": f"res://assets/pokemon/forms/icons/{form_id}.png",
                "front_frames_path": f"res://assets/pokemon/forms/{form_id}/front/",
                "back_frames_path": f"res://assets/pokemon/forms/{form_id}/back/",
                "front_frame_count": front_count,
                "back_frame_count": back_count,
                "has_animation": True,
                "front_gif_source": front_name,
                "back_gif_source": back_name,
            }
            done.append(form_id)

    forms_path.write_text(json.dumps(forms_data, indent=2, ensure_ascii=False, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Forms: extracted {len(done)}/{len(FORMS)}")
    if skipped:
        print(f"Forms: {len(skipped)} had no matching sprite in the archive: {skipped}")


if __name__ == "__main__":
    main()

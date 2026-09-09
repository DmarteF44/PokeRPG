#!/usr/bin/env python3
"""Extract sprites for Costume Forms (purely cosmetic, no type/stat change
in the real games - Furfrou's grooming trims, Unown's letters) and a
Special Forms slice (Deoxys's 3 non-Normal Formes, Keldeo-Resolute,
Zygarde's 10%/Complete Formes - all real, all keep their base species'
type in the actual games, so no type override data is fabricated here).
Both categories reuse the same data/pokemon_forms.json Regional/
Conditional Forms already use - architecturally identical (a validated
pokemon["form"] overlay), so this needs zero new code, only new data.

Mines each species' own generation archive: Unown is Gen 2, Deoxys is
Gen 3, Keldeo is Gen 5, Furfrou/Zygarde are Gen 6.

Usage: python3 extract_costume_special_form_sprites.py
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

# (form_id, base_species, gen, archive_slug, category, types, name_en, name_pt, short_label)
UNOWN_LETTERS = [
    ("bravo", "B"), ("charlie", "C"), ("delta", "D"), ("echo", "E"), ("foxtrot", "F"),
    ("golf", "G"), ("hotel", "H"), ("india", "I"), ("juliet", "J"), ("kilo", "K"),
    ("lima", "L"), ("mike", "M"), ("november", "N"), ("oscar", "O"), ("papa", "P"),
    ("quebec", "Q"), ("romeo", "R"), ("sierra", "S"), ("tango", "T"), ("uniform", "U"),
    ("victor", "V"), ("whiskey", "W"), ("xray", "X"), ("yankee", "Y"), ("zulu", "Z"),
]
UNOWN_SPECIAL = [("interrogation", "?"), ("exclamation", "!")]

FORMS: list = []
for slug, letter in UNOWN_LETTERS + UNOWN_SPECIAL:
    FORMS.append((f"unown-{slug}", "unown", 2, f"unown-{slug}", "costume", ["Psychic"], f"Unown ({letter})", f"Unown ({letter})", letter))

FURFROU_TRIMS = [
    ("heart", "Heart Trim", "Coração"), ("star", "Star Trim", "Estrela"),
    ("diamond", "Diamond Trim", "Diamante"), ("debutante", "Debutante Trim", "Debutante"),
    ("matron", "Matron Trim", "Matrona"), ("dandy", "Dandy Trim", "Dândi"),
    ("lareine", "La Reine Trim", "La Reine"), ("kabuki", "Kabuki Trim", "Kabuki"),
    ("pharaoh", "Pharaoh Trim", "Faraó"),
]
for slug, name_en, name_pt in FURFROU_TRIMS:
    FORMS.append((f"furfrou-{slug}", "furfrou", 6, f"furfrou-{slug}", "costume", ["Normal"], f"Furfrou ({name_en})", f"Furfrou ({name_pt})", name_en.replace(" Trim", "")))

FORMS += [
    ("deoxys-attack", "deoxys", 3, "deoxys-attack", "special", ["Psychic"], "Deoxys (Attack Forme)", "Deoxys (Forma Ataque)", "Attack"),
    ("deoxys-defense", "deoxys", 3, "deoxys-defense", "special", ["Psychic"], "Deoxys (Defense Forme)", "Deoxys (Forma Defesa)", "Defense"),
    ("deoxys-speed", "deoxys", 3, "deoxys-speed", "special", ["Psychic"], "Deoxys (Speed Forme)", "Deoxys (Forma Velocidade)", "Speed"),
    ("keldeo-resolute", "keldeo", 5, "keldeo-resolute", "special", ["Water", "Fighting"], "Keldeo (Resolute Form)", "Keldeo (Forma Resoluta)", "Resolute"),
    ("zygarde-10", "zygarde", 6, "zygarde-10", "special", ["Dragon", "Ground"], "Zygarde (10% Forme)", "Zygarde (Forma 10%)", "10%"),
    ("zygarde-complete", "zygarde", 6, "zygarde-complete", "special", ["Dragon", "Ground"], "Zygarde (Complete Forme)", "Zygarde (Forma Completa)", "Complete"),
]


def main() -> None:
    forms_path = ROOT / "data" / "pokemon_forms.json"
    forms_data: dict = json.loads(forms_path.read_text(encoding="utf-8")) if forms_path.exists() else {}

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
            for form_id, base_species, _gen, slug_raw, category, types, name_en, name_pt, short_label in entries:
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
                    "region": "",
                    "types": types,
                    "evolves_to_form": "",
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
    print(f"Costume/Special forms: extracted {len(done)}/{len(FORMS)}")
    if skipped:
        print(f"Costume/Special forms: {len(skipped)} had no matching sprite: {skipped}")


if __name__ == "__main__":
    main()

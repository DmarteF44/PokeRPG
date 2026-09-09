#!/usr/bin/env python3
"""Extract sprites for real-game Conditional Forms - species whose form in
the official games is set by an environmental/encounter condition (weather,
season, location, time of day) rather than a player choice. Mines each
form's own generation archive (Castform is Gen 3, Cherrim/Shellos/Gastrodon/
Burmy/Wormadam are Gen 4, Deerling/Sawsbuck/Basculin are Gen 5, Oricorio/
Lycanroc are Gen 7), merging into the SAME data/pokemon_forms.json Regional/
Alternate Forms already use - a Conditional Form is architecturally
identical to a Regional Form here (a validated pokemon["form"] overlay with
a real type override), just with a different in-universe trigger, so no
new code is needed, only new data.

Usage: python3 extract_conditional_form_sprites.py
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

# (form_id, base_species, gen, archive_slug, category, types, name_en, name_pt, evolves_to_form, short_label)
FORMS = [
    ("castform-sunny", "castform", 3, "castform-sunny", "conditional", ["Fire"], "Castform (Sunny)", "Castform (Ensolarado)", "", "Sunny"),
    ("castform-rainy", "castform", 3, "castform-rainy", "conditional", ["Water"], "Castform (Rainy)", "Castform (Chuvoso)", "", "Rainy"),
    ("castform-snowy", "castform", 3, "castform-snowy", "conditional", ["Ice"], "Castform (Snowy)", "Castform (Nevado)", "", "Snowy"),
    ("cherrim-sunshine", "cherrim", 4, "cherrim-sunshine", "conditional", ["Grass"], "Cherrim (Sunshine)", "Cherrim (Radiante)", "", "Sunshine"),
    ("shellos-east", "shellos", 4, "shellos-east", "conditional", ["Water"], "Shellos (East Sea)", "Shellos (Mar Leste)", "gastrodon-east", "East"),
    ("gastrodon-east", "gastrodon", 4, "gastrodon-east", "conditional", ["Water", "Ground"], "Gastrodon (East Sea)", "Gastrodon (Mar Leste)", "", "East"),
    ("burmy-sandy", "burmy", 4, "burmy-sandy", "conditional", ["Bug"], "Burmy (Sandy Cloak)", "Burmy (Manto Arenoso)", "wormadam-sandy", "Sandy"),
    ("burmy-trash", "burmy", 4, "burmy-trash", "conditional", ["Bug"], "Burmy (Trash Cloak)", "Burmy (Manto de Lixo)", "wormadam-trash", "Trash"),
    ("wormadam-sandy", "wormadam", 4, "wormadam-sandy", "conditional", ["Bug", "Ground"], "Wormadam (Sandy Cloak)", "Wormadam (Manto Arenoso)", "", "Sandy"),
    ("wormadam-trash", "wormadam", 4, "wormadam-trash", "conditional", ["Bug", "Steel"], "Wormadam (Trash Cloak)", "Wormadam (Manto de Lixo)", "", "Trash"),
    ("deerling-summer", "deerling", 5, "deerling-summer", "conditional", ["Normal", "Grass"], "Deerling (Summer)", "Deerling (Verão)", "sawsbuck-summer", "Summer"),
    ("deerling-autumn", "deerling", 5, "deerling-autumn", "conditional", ["Normal", "Grass"], "Deerling (Autumn)", "Deerling (Outono)", "sawsbuck-autumn", "Autumn"),
    ("deerling-winter", "deerling", 5, "deerling-winter", "conditional", ["Normal", "Grass"], "Deerling (Winter)", "Deerling (Inverno)", "sawsbuck-winter", "Winter"),
    ("sawsbuck-summer", "sawsbuck", 5, "sawsbuck-summer", "conditional", ["Normal", "Grass"], "Sawsbuck (Summer)", "Sawsbuck (Verão)", "", "Summer"),
    ("sawsbuck-autumn", "sawsbuck", 5, "sawsbuck-autumn", "conditional", ["Normal", "Grass"], "Sawsbuck (Autumn)", "Sawsbuck (Outono)", "", "Autumn"),
    ("sawsbuck-winter", "sawsbuck", 5, "sawsbuck-winter", "conditional", ["Normal", "Grass"], "Sawsbuck (Winter)", "Sawsbuck (Inverno)", "", "Winter"),
    ("basculin-blue", "basculin", 5, "basculin-blue", "conditional", ["Water"], "Basculin (Blue-Striped)", "Basculin (Listras Azuis)", "", "Blue"),
    ("oricorio-pompom", "oricorio", 7, "oricorio-pompom", "conditional", ["Electric", "Flying"], "Oricorio (Pom-Pom Style)", "Oricorio (Estilo Pom-Pom)", "", "Pom-Pom"),
    ("oricorio-pau", "oricorio", 7, "oricorio-pau", "conditional", ["Psychic", "Flying"], "Oricorio (Pa'u Style)", "Oricorio (Estilo Pa'u)", "", "Pa'u"),
    ("oricorio-sensu", "oricorio", 7, "oricorio-sensu", "conditional", ["Ghost", "Flying"], "Oricorio (Sensu Style)", "Oricorio (Estilo Sensu)", "", "Sensu"),
    ("lycanroc-midnight", "lycanroc", 7, "lycanroc-midnight", "conditional", ["Rock"], "Lycanroc (Midnight Form)", "Lycanroc (Forma da Meia-Noite)", "", "Midnight"),
    ("lycanroc-dusk", "lycanroc", 7, "lycanroc-dusk", "conditional", ["Rock"], "Lycanroc (Dusk Form)", "Lycanroc (Forma do Crepúsculo)", "", "Dusk"),
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
            for form_id, base_species, _gen, slug_raw, category, types, name_en, name_pt, evolves_to, short_label in entries:
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
    print(f"Conditional forms: extracted {len(done)}/{len(FORMS)}")
    if skipped:
        print(f"Conditional forms: {len(skipped)} had no matching sprite: {skipped}")


if __name__ == "__main__":
    main()

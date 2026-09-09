#!/usr/bin/env python3
"""Extract battle-animation sprites + icons for a whole generation from the
bundled "3D Models_ Generation N Pokemon - Sprite Index - Project Pokemon
Forums.zip" archives, following the exact layout established for Gen 1
(assets/pokemon/battle/animated/gen_N/<front|back>/<species_id>/NNN.png).

Each archive lists two GIFs per species per direction (a near-duplicate
pair), with the "front" block and "back" block offset by a constant number
of positions within the zip - this was reverse-engineered by diffing known
Gen 1 sources (front/back gif numbers always differ by exactly 433) and
confirmed to hold for Gen 2 (310) and Gen 3 (362) with the same detection
method used here (mode of front/back index deltas per species).

Frame counts in the source GIFs run 20-90+ frames per direction; at that
density, Gen 2 + Gen 3 combined would add on the order of 30,000+ PNG files
and ~350MB, which is impractical for this pass - frames are evenly
subsampled down to MAX_FRAMES per direction, which still reads as a smooth
idle animation in-battle.

Usage: python3 extract_generation_sprites.py <gen_number>
"""

from __future__ import annotations

import io
import json
import re
import sys
import zipfile
from collections import Counter, defaultdict
from pathlib import Path

from PIL import Image, ImageFile

# A few source GIFs in these archives are truncated (scrape artifacts) - load
# whatever frames decode instead of aborting the whole species on one bad file.
ImageFile.LOAD_TRUNCATED_IMAGES = True

ROOT = Path(__file__).resolve().parents[2]
MAX_FRAMES = 16
ICON_SIZE = 96

NAME_RE = re.compile(r"^imgi_(\d+)_(.+)\.(gif|png|jpg|jpeg|svg)$", re.IGNORECASE)


def zip_path_for(gen: int) -> Path:
    return ROOT / f"assets/3D Models_ Generation {gen} Pokémon - Sprite Index - Project Pokemon Forums.zip"


def normalize(slug: str) -> str:
    return slug.lower().replace(" ", "-")


def load_groups(zf: zipfile.ZipFile) -> dict[str, list[int]]:
    groups: dict[str, list[int]] = defaultdict(list)
    for name in zf.namelist():
        m = NAME_RE.match(name)
        if not m or m.group(3).lower() != "gif":
            continue
        num, slug = int(m.group(1)), normalize(m.group(2))
        groups[slug].append(num)
    return groups


def detect_offset(groups: dict[str, list[int]]) -> int:
    diffs: Counter[int] = Counter()
    for nums in groups.values():
        nums = sorted(nums)
        if len(nums) == 2:
            diffs[nums[1] - nums[0]] += 1
        elif len(nums) == 4:
            diffs[nums[2] - nums[0]] += 1
    if not diffs:
        raise SystemExit("Could not detect a front/back offset from the archive.")
    offset, _count = diffs.most_common(1)[0]
    return offset


def species_for_generation(gen: int) -> list[dict]:
    species = json.loads((ROOT / "data" / "pokemon_species.json").read_text(encoding="utf-8"))
    return [s for s in species if s.get("generation") == gen]


def gif_frames(data: bytes, max_frames: int) -> list[Image.Image]:
    with Image.open(io.BytesIO(data)) as im:
        total = getattr(im, "n_frames", 1)
        if total <= max_frames:
            indices = range(total)
        else:
            indices = sorted({round(i * (total - 1) / (max_frames - 1)) for i in range(max_frames)})
        frames = []
        for i in indices:
            try:
                im.seek(i)
                frames.append(im.convert("RGBA").copy())
            except (OSError, EOFError):
                # A truncated source GIF - keep whatever frames decoded so far
                # instead of losing the whole species over one bad frame.
                break
        return frames


def save_frames(frames: list[Image.Image], out_dir: Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("*.png"):
        old.unlink()
    for i, frame in enumerate(frames):
        frame.save(out_dir / f"{i:03d}.png")
    return len(frames)


def make_icon(frame: Image.Image, out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    bbox = frame.getbbox()
    cropped = frame.crop(bbox) if bbox else frame
    cropped.thumbnail((ICON_SIZE, ICON_SIZE), Image.LANCZOS)
    canvas = Image.new("RGBA", (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))
    x = (ICON_SIZE - cropped.width) // 2
    y = (ICON_SIZE - cropped.height) // 2
    canvas.paste(cropped, (x, y), cropped)
    canvas.save(out_path)


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("Usage: extract_generation_sprites.py <gen_number>")
    gen = int(sys.argv[1])

    zpath = zip_path_for(gen)
    if not zpath.exists():
        raise SystemExit(f"Archive not found: {zpath}")

    species_list = species_for_generation(gen)
    if not species_list:
        raise SystemExit(f"No Gen {gen} species found in pokemon_species.json")

    with zipfile.ZipFile(zpath) as zf:
        groups = load_groups(zf)
        offset = detect_offset(groups)
        print(f"Gen {gen}: detected front/back offset = {offset}, {len(groups)} species groups in archive")

        manifest_path = ROOT / "data" / "pokemon_assets_manifest.json"
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

        done = []
        skipped = []
        for species in species_list:
            pid = species["id"]
            slug = normalize(pid.replace("_", "-"))
            nums = groups.get(slug) or groups.get(normalize(pid))
            if not nums:
                skipped.append(pid)
                continue
            nums = sorted(nums)
            front_num = nums[0]
            back_candidates = [n for n in nums if n - front_num >= offset * 0.5]
            if not back_candidates:
                # A handful of species only got a "-f" (female-labeled) group
                # scraped with a full front+back set, while their default
                # group has front only - borrow the back sprite from there.
                female_nums = sorted(groups.get(f"{slug}-f", []))
                back_candidates = [n for n in female_nums if n - front_num >= offset * 0.5]
            if not back_candidates:
                skipped.append(pid)
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
                print(f"  {pid}: FAILED to decode ({front_name} / {back_name}): {exc}")
                skipped.append(pid)
                continue

            front_dir = ROOT / f"assets/pokemon/battle/animated/gen_{gen}/front/{pid}"
            back_dir = ROOT / f"assets/pokemon/battle/animated/gen_{gen}/back/{pid}"
            front_count = save_frames(front_frames, front_dir)
            back_count = save_frames(back_frames, back_dir)

            icon_path = ROOT / f"assets/pokemon/icons/{pid}.png"
            make_icon(front_frames[0], icon_path)

            rel_front_dir = f"res://assets/pokemon/battle/animated/gen_{gen}/front/{pid}/"
            rel_back_dir = f"res://assets/pokemon/battle/animated/gen_{gen}/back/{pid}/"
            rel_icon = f"res://assets/pokemon/icons/{pid}.png"

            manifest[pid] = {
                "icon_path": rel_icon,
                "front_frames_path": rel_front_dir,
                "back_frames_path": rel_back_dir,
                "front_frame_count": front_count,
                "back_frame_count": back_count,
                "has_animation": True,
            }
            species["icon_path"] = rel_icon
            species["sprite_front"] = rel_front_dir + "000.png"
            species["sprite_back"] = rel_back_dir + "000.png"
            species["front_frames_path"] = rel_front_dir
            species["back_frames_path"] = rel_back_dir
            species["has_animation"] = True
            species["front_gif_source"] = front_name
            species["back_gif_source"] = back_name
            done.append(pid)

        manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    all_species = json.loads((ROOT / "data" / "pokemon_species.json").read_text(encoding="utf-8"))
    by_id = {s["id"]: s for s in all_species}
    for species in species_list:
        by_id[species["id"]] = species
    merged = [by_id[s["id"]] for s in all_species]
    (ROOT / "data" / "pokemon_species.json").write_text(
        json.dumps(merged, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )

    print(f"Gen {gen}: extracted {len(done)}/{len(species_list)} species")
    if skipped:
        print(f"Gen {gen}: {len(skipped)} species had no matching sprite in the archive: {skipped}")


if __name__ == "__main__":
    main()

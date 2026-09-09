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

Frame counts in the source GIFs run 20-90+ frames per direction. MAX_FRAMES
is NOT just a quality/size dial - it's capped by a hard technical ceiling in
this environment's Android build pipeline. Godot's non-gradle Android export
mode gives each imported PNG two ZIP entries (a compiled assets/.godot/
imported/*.ctex plus a required assets/*.png.import remap sidecar - see
scripts/tools/build_android_release.sh for why the sidecar can't be
stripped), and the whole APK's ZIP entry count must stay under the classic
65535 cap: past that, Zip64 format kicks in, and every apksigner available
here - and, it turns out, Android's own on-device package parser, which
shares the same Zip64-handling code - fails to read the file at all ("As
the package appears to be invalid" on install, no signing scheme fixes it).
MAX_FRAMES=24 produced ~107k total entries and every install failed; testing
narrowed the safe ceiling to MAX_FRAMES=12 (~55k entries, real margin under
the cap). Raise this only after re-deriving that math for the current asset
count, and rebuild+verify entry count BEFORE handing off an APK.

LOWERING MAX_FRAMES after a higher-count run has already been extracted
leaves orphaned res://....png.import sidecars behind for the now-deleted
higher-numbered frames (save_frames() only clears frames it's about to
rewrite in that same run, and Godot never wrote those .import files itself -
they're the editor's own artifacts from a prior import pass, so it's the
only thing that can prune them). Before re-exporting, delete every
*.import file under assets/ whose corresponding source file no longer
exists, then delete .godot/imported/ and run a headless editor pass
(`godot --headless --editor --quit-after 480`, adjust the timeout for the
asset count) to force a clean reimport - otherwise the orphaned files get
bundled into the APK for nothing, right back over the entry-count cap this
constant exists to stay under.

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
MAX_FRAMES = 12
ICON_SIZE = 96

NAME_RE = re.compile(r"^imgi_(\d+)_(.+)\.(gif|png|jpg|jpeg|svg)$", re.IGNORECASE)


def zip_path_for(gen: int) -> Path:
    return ROOT / f"assets/3D Models_ Generation {gen} Pokémon - Sprite Index - Project Pokemon Forums.zip"


def normalize(slug: str) -> str:
    # Archive names carry stray punctuation from official species names
    # (Mr. Mime -> "mr.mime"/"mr._mime", Mr. Rime -> "mr.-rime", Type: Null ->
    # "typenull") that a species id's own hyphen/underscore convention won't
    # match byte-for-byte - fold every separator to "-" so both sides compare
    # the same way, generically, without a per-species name-fix table.
    slug = slug.lower()
    for ch in (" ", ".", ":", "_"):
        slug = slug.replace(ch, "-")
    while "--" in slug:
        slug = slug.replace("--", "-")
    return slug.strip("-")


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


def _save_optimized(image: Image.Image, out_path: Path) -> None:
    """Pixel art like these sprites almost always uses well under 256
    distinct colors, so an indexed-palette PNG (1 byte/pixel) loses nothing
    visually while running noticeably smaller than RGBA (4 bytes/pixel) -
    that headroom is what lets more frames per species fit under GitHub's
    push-size limit without cutting animation smoothness to compensate.
    Builds the palette directly from the image's own exact colors (not a
    quantizer) so this is lossless whenever the color count allows it;
    only an icon's LANCZOS-resampled edge antialiasing can occasionally
    exceed 256 colors, so this falls back to a (still near-lossless,
    dithered) quantized palette rather than dropping to full RGBA."""
    rgba = image.convert("RGBA")
    colors = rgba.getcolors(maxcolors=100000)
    if colors is not None and len(colors) <= 256:
        color_list = [c[1] for c in colors]
        color_to_index = {c: i for i, c in enumerate(color_list)}
        indexed = Image.new("P", rgba.size)
        flat_palette = []
        alpha_values = []
        for c in color_list:
            flat_palette.extend(c[:3])
            alpha_values.append(c[3])
        flat_palette += [0] * (256 * 3 - len(flat_palette))
        indexed.putpalette(flat_palette)
        indexed.putdata([color_to_index[px] for px in rgba.getdata()])
        indexed.save(out_path, optimize=True, compress_level=9, transparency=bytes(alpha_values))
    else:
        quantized = rgba.quantize(colors=256, method=Image.FASTOCTREE, dither=Image.FLOYDSTEINBERG)
        quantized.save(out_path, optimize=True, compress_level=9)


def save_frames(frames: list[Image.Image], out_dir: Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("*.png"):
        old.unlink()
    for i, frame in enumerate(frames):
        _save_optimized(frame, out_dir / f"{i:03d}.png")
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
    _save_optimized(canvas, out_path)


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
            slug = normalize(pid)
            # A few archive names drop separators entirely (Tapu Bulu ->
            # "tapubulu", Type: Null -> "typenull") - fall back to comparing
            # fully-joined slugs on both sides as a last resort.
            nums = groups.get(slug) or groups.get(slug.replace("-", ""))
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

    # The runtime actually reads from data/pokemon/gen{N}/pokemon.json for any
    # species present there (see PokemonHelpers._loaded_definition_for_id),
    # falling back to pokemon_species.json only when a species is absent from
    # its per-generation file - so the asset fields have to land there too,
    # or extraction has zero in-game effect for a generation that already has
    # its own file (every generation added so far does).
    # Only the asset fields are copied across (not the whole species dict) -
    # the per-generation file is the richer, authoritative record (learnset,
    # evolutions, egg groups, ...) and may have already diverged from
    # pokemon_species.json's copy (e.g. evolution-method adaptations applied
    # directly to it), so a wholesale overwrite would silently lose that.
    ASSET_FIELDS = (
        "icon_path", "sprite_front", "sprite_back", "front_frames_path",
        "back_frames_path", "has_animation", "front_gif_source", "back_gif_source",
    )
    gen_file = ROOT / f"data/pokemon/gen{gen}/pokemon.json"
    if gen_file.exists():
        gen_species = json.loads(gen_file.read_text(encoding="utf-8"))
        by_gen_id = {s["id"]: s for s in gen_species}
        for species in species_list:
            target = by_gen_id.get(species["id"])
            if target is None:
                continue
            for field in ASSET_FIELDS:
                if field in species:
                    target[field] = species[field]
        gen_file.write_text(json.dumps(gen_species, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(f"Gen {gen}: extracted {len(done)}/{len(species_list)} species")
    if skipped:
        print(f"Gen {gen}: {len(skipped)} species had no matching sprite in the archive: {skipped}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Convert only the Gen 1 starter GIFs into PNG frames.

This script intentionally ignores every other Pokemon and generation.
Install Pillow if needed: python3 -m pip install Pillow
"""

from __future__ import annotations

import json
from pathlib import Path
import shutil
from zipfile import ZipFile


CLEANUP_ORIGINALS = False

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_PATH = ROOT / "data" / "pokemon_assets_manifest.json"
CONVERTED_DIR = ROOT / "assets_raw" / "converted_gifs"
GEN1_ZIP = ROOT / "assets" / "3D Models_ Generation 1 Pokémon - Sprite Index - Project Pokemon Forums.zip"

STARTERS = {
    "bulbasaur": {
        "dex_number": 1,
        "name": "Bulbasaur",
        "front_gif": "imgi_4_bulbasaur.gif",
        "back_gif": "imgi_437_bulbasaur.gif",
    },
    "charmander": {
        "dex_number": 4,
        "name": "Charmander",
        "front_gif": "imgi_14_charmander.gif",
        "back_gif": "imgi_447_charmander.gif",
    },
    "squirtle": {
        "dex_number": 7,
        "name": "Squirtle",
        "front_gif": "imgi_24_squirtle.gif",
        "back_gif": "imgi_457_squirtle.gif",
    },
}


def main() -> None:
    manifest = load_manifest()

    for pokemon_id, data in STARTERS.items():
        source_dir = ROOT / "assets_raw" / "gifs" / "gen_1" / pokemon_id
        source_dir.mkdir(parents=True, exist_ok=True)
        converted: dict[str, int] = {}

        for direction in ["front", "back"]:
            gif_path = ensure_source_gif(source_dir, str(data[f"{direction}_gif"]))
            output_dir = frame_output_dir(pokemon_id, direction)
            if gif_path is not None and gif_path.exists():
                converted[direction] = convert_gif(gif_path, output_dir)
                if CLEANUP_ORIGINALS:
                    CONVERTED_DIR.mkdir(parents=True, exist_ok=True)
                    shutil.move(str(gif_path), str(CONVERTED_DIR / gif_path.name))
            elif direction == "back" and frame_output_dir(pokemon_id, "front").exists():
                converted[direction] = copy_front_as_back_fallback(pokemon_id)
            else:
                converted[direction] = write_static_fallback(pokemon_id, direction)

        icon_path = write_icon_from_first_frame(pokemon_id)
        manifest[pokemon_id] = {
            "id": pokemon_id,
            "dex_number": data["dex_number"],
            "name": data["name"],
            "generation": 1,
            "icon_path": res_path(icon_path),
            "front_frames_path": res_path(frame_output_dir(pokemon_id, "front")) + "/",
            "back_frames_path": res_path(frame_output_dir(pokemon_id, "back")) + "/",
            "front_frame_count": converted.get("front", 0),
            "back_frame_count": converted.get("back", 0),
            "has_animation": converted.get("front", 0) > 1 or converted.get("back", 0) > 1,
        }

    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Updated {rel(MANIFEST_PATH)}")


def ensure_source_gif(source_dir: Path, gif_name: str) -> Path | None:
    gif_path = source_dir / gif_name
    if gif_path.exists():
        return gif_path

    if not GEN1_ZIP.exists():
        return None

    with ZipFile(GEN1_ZIP) as archive:
        if gif_name not in archive.namelist():
            return None
        gif_path.write_bytes(archive.read(gif_name))
    print(f"Extracted {gif_name} -> {rel(gif_path)}")
    return gif_path


def convert_gif(gif_path: Path, output_dir: Path) -> int:
    try:
        from PIL import Image, ImageSequence
    except ImportError as exc:
        raise SystemExit("Pillow is required to convert GIFs: python3 -m pip install Pillow") from exc

    output_dir.mkdir(parents=True, exist_ok=True)
    for old_frame in output_dir.glob("*.png"):
        old_frame.unlink()

    with Image.open(gif_path) as image:
        for index, frame in enumerate(ImageSequence.Iterator(image)):
            frame.convert("RGBA").save(output_dir / f"{index:03d}.png")

    frame_count = len(list(output_dir.glob("*.png")))
    print(f"Converted {rel(gif_path)} -> {rel(output_dir)} ({frame_count} frames)")
    return frame_count


def copy_front_as_back_fallback(pokemon_id: str) -> int:
    front_dir = frame_output_dir(pokemon_id, "front")
    back_dir = frame_output_dir(pokemon_id, "back")
    back_dir.mkdir(parents=True, exist_ok=True)
    for old_frame in back_dir.glob("*.png"):
        old_frame.unlink()
    count = 0
    for front_frame in sorted(front_dir.glob("*.png")):
        shutil.copy2(front_frame, back_dir / front_frame.name)
        count += 1
    print(f"Copied front frames as back fallback for {pokemon_id} ({count} frames)")
    return count


def write_static_fallback(pokemon_id: str, direction: str) -> int:
    try:
        from PIL import Image, ImageDraw
    except ImportError as exc:
        raise SystemExit("Pillow is required to write fallback frames: python3 -m pip install Pillow") from exc

    output_dir = frame_output_dir(pokemon_id, direction)
    output_dir.mkdir(parents=True, exist_ok=True)
    for old_frame in output_dir.glob("*.png"):
        old_frame.unlink()

    image = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((6, 6, 58, 58), radius=8, fill=(80, 116, 140, 255))
    draw.text((24, 22), pokemon_id[:1].upper(), fill=(255, 255, 255, 255))
    image.save(output_dir / "000.png")
    print(f"Wrote fallback frame for {pokemon_id} {direction}")
    return 1


def write_icon_from_first_frame(pokemon_id: str) -> Path:
    try:
        from PIL import Image
    except ImportError as exc:
        raise SystemExit("Pillow is required to write starter icons: python3 -m pip install Pillow") from exc

    first_frame = frame_output_dir(pokemon_id, "front") / "000.png"
    icon_path = ROOT / "assets" / "pokemon" / "icons" / f"{pokemon_id}.png"
    icon_path.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(first_frame) as image:
        image.convert("RGBA").save(icon_path)
    print(f"Wrote {rel(icon_path)}")
    return icon_path


def frame_output_dir(pokemon_id: str, direction: str) -> Path:
    return ROOT / "assets" / "pokemon" / "battle" / "animated" / "gen_1" / direction / pokemon_id


def load_manifest() -> dict:
    if not MANIFEST_PATH.exists():
        return {}
    parsed = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    return parsed if isinstance(parsed, dict) else {}


def res_path(path: Path) -> str:
    return "res://" + rel(path)


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT)).replace("\\", "/")


if __name__ == "__main__":
    main()

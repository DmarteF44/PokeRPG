#!/usr/bin/env python3
"""Convert only Charmander Gen 1 GIFs into PNG frames.

This intentionally ignores every other Pokemon and generation.
Install Pillow if needed: python3 -m pip install Pillow
"""

from __future__ import annotations

import json
from pathlib import Path
import shutil


CLEANUP_ORIGINALS = False

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_PATH = ROOT / "data" / "pokemon_assets_manifest.json"
CONVERTED_DIR = ROOT / "assets_raw" / "converted_gifs"
ICON_PATH = ROOT / "assets" / "pokemon" / "icons" / "charmander.png"

GIF_CANDIDATES = {
    "front": [
        ROOT / "assets_raw" / "gifs" / "gen_1" / "charmander" / "imgi_14_charmander.gif",
        ROOT / "assets_raw" / "gifs" / "gen_1" / "charmander" / "charmander_front.gif",
        ROOT / "assets_raw" / "gifs" / "gen_1" / "charmander" / "004_charmander_front.gif",
        ROOT / "assets_raw" / "gifs" / "gen_1" / "charmander" / "004_charmander.gif",
        ROOT / "assets_raw" / "gifs" / "gen_1" / "charmander" / "charmander.gif",
    ],
    "back": [
        ROOT / "assets_raw" / "gifs" / "gen_1" / "charmander" / "imgi_447_charmander.gif",
        ROOT / "assets_raw" / "gifs" / "gen_1" / "charmander" / "charmander_back.gif",
        ROOT / "assets_raw" / "gifs" / "gen_1" / "charmander" / "004_charmander_back.gif",
    ],
}

OUTPUT_DIRS = {
    "front": ROOT / "assets" / "pokemon" / "battle" / "animated" / "gen_1" / "front" / "charmander",
    "back": ROOT / "assets" / "pokemon" / "battle" / "animated" / "gen_1" / "back" / "charmander",
}


def main() -> None:
    manifest = load_manifest()
    converted: dict[str, int] = {}

    for direction, candidates in GIF_CANDIDATES.items():
        gif_path = next((path for path in candidates if path.exists()), None)
        if gif_path is None:
            print(f"No Charmander {direction} GIF found.")
            continue

        frame_count = convert_gif(gif_path, OUTPUT_DIRS[direction])
        converted[direction] = frame_count

        if direction == "front":
            write_icon_from_first_frame(OUTPUT_DIRS[direction] / "000.png")

        if CLEANUP_ORIGINALS:
            CONVERTED_DIR.mkdir(parents=True, exist_ok=True)
            shutil.move(str(gif_path), str(CONVERTED_DIR / gif_path.name))

    if converted:
        manifest["charmander"] = {
            "id": "charmander",
            "dex_number": 4,
            "name": "Charmander",
            "generation": 1,
            "front_frames_path": "res://assets/pokemon/battle/animated/gen_1/front/charmander/",
            "back_frames_path": "res://assets/pokemon/battle/animated/gen_1/back/charmander/",
            "icon_path": "res://assets/pokemon/icons/charmander.png",
            "front_frame_count": converted.get("front", 0),
            "back_frame_count": converted.get("back", 0),
        }
        MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
        MANIFEST_PATH.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(f"Updated {rel(MANIFEST_PATH)}")
    else:
        print("Nothing converted.")


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
            frame_rgba = frame.convert("RGBA")
            frame_rgba.save(output_dir / f"{index:03d}.png")

    frame_count = len(list(output_dir.glob("*.png")))
    print(f"Converted {rel(gif_path)} -> {rel(output_dir)} ({frame_count} frames)")
    return frame_count


def write_icon_from_first_frame(first_frame_path: Path) -> None:
    try:
        from PIL import Image
    except ImportError as exc:
        raise SystemExit("Pillow is required to write Charmander icon: python3 -m pip install Pillow") from exc

    if not first_frame_path.exists():
        return

    ICON_PATH.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(first_frame_path) as image:
        icon = image.convert("RGBA")
        icon.save(ICON_PATH)
    print(f"Wrote {rel(ICON_PATH)}")


def load_manifest() -> dict:
    if not MANIFEST_PATH.exists():
        return {}
    parsed = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    return parsed if isinstance(parsed, dict) else {}


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT)).replace("\\", "/")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Convert only Charmeleon Gen 5 GIFs into PNG frames.

This script intentionally ignores every other Pokemon and generation.
Install Pillow if needed: python3 -m pip install pillow
"""

from __future__ import annotations

import json
from pathlib import Path
import shutil


CLEANUP_ORIGINALS = False

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_PATH = ROOT / "data" / "animated_sprites_manifest.json"
CONVERTED_DIR = ROOT / "assets_raw" / "converted_gifs"

GIF_CANDIDATES = {
    "front": [
        ROOT / "assets_raw" / "gifs" / "gen_5" / "front" / "charmeleon.gif",
        ROOT / "assets_raw" / "gifs" / "gen_5" / "front" / "005_charmeleon.gif",
        ROOT / "assets_raw" / "gifs" / "gen_5" / "front" / "005_charmeleon_front.gif",
    ],
    "back": [
        ROOT / "assets_raw" / "gifs" / "gen_5" / "back" / "charmeleon.gif",
        ROOT / "assets_raw" / "gifs" / "gen_5" / "back" / "005_charmeleon.gif",
        ROOT / "assets_raw" / "gifs" / "gen_5" / "back" / "005_charmeleon_back.gif",
    ],
}

OUTPUT_DIRS = {
    "front": ROOT / "assets" / "pokemon" / "battle" / "animated" / "gen_5" / "front" / "charmeleon",
    "back": ROOT / "assets" / "pokemon" / "battle" / "animated" / "gen_5" / "back" / "charmeleon",
}


def main() -> None:
    manifest = load_manifest()
    converted_any = False

    for direction, candidates in GIF_CANDIDATES.items():
        gif_path = next((path for path in candidates if path.exists()), None)
        if gif_path is None:
            print(f"No Charmeleon {direction} GIF found.")
            continue

        frame_count = convert_gif(gif_path, OUTPUT_DIRS[direction])
        converted_any = True
        manifest[f"gen_5/charmeleon/{direction}"] = {
            "pokemon": "charmeleon",
            "dex_number": 5,
            "generation": 5,
            "direction": direction,
            "source": rel(gif_path),
            "frames_dir": rel(OUTPUT_DIRS[direction]),
            "frame_count": frame_count,
        }

        if CLEANUP_ORIGINALS:
            CONVERTED_DIR.mkdir(parents=True, exist_ok=True)
            shutil.move(str(gif_path), str(CONVERTED_DIR / gif_path.name))

    if converted_any:
        MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
        MANIFEST_PATH.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(f"Updated {rel(MANIFEST_PATH)}")
    else:
        print("Nothing converted.")


def convert_gif(gif_path: Path, output_dir: Path) -> int:
    try:
        from PIL import Image, ImageSequence
    except ImportError as exc:
        raise SystemExit("Pillow is required to convert GIFs: python3 -m pip install pillow") from exc

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


def load_manifest() -> dict:
    if not MANIFEST_PATH.exists():
        return {}
    return json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT)).replace("\\", "/")


if __name__ == "__main__":
    main()

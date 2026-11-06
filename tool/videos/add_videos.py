"""Add filmed exercise clips to the app.

Name each clip after the exercise id and trainer, e.g.
    barbell_bench_press_male.mp4
    barbell_bench_press_female.mov
(ids are listed in docs/exercise-filming-guide.md). Then either:

  Bundle them inside the app (simplest; adds ~0.5-1 MB per clip):
    python3 -I tool/videos/add_videos.py ~/Desktop/clips --bundle

  Or host them for free (keeps the app small) and point the app at them:
    python3 -I tool/videos/add_videos.py ~/Desktop/clips --base-url https://USER.github.io/bmi-videos
  then upload everything in build/exercise_videos/ to that address
  (e.g. a public GitHub repository with GitHub Pages turned on).

Each clip is trimmed to 10 s, silenced, scaled to 720p and compressed with
ffmpeg (free; `brew install ffmpeg`). The catalog's "videos" entries are
updated; the exercise page and Home Challenges player then show the clip
instead of the animation, and fall back to the animation if it can't play.
"""
import argparse
import json
import pathlib
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
CATALOG = ROOT / "assets" / "exercises" / "catalog.json"
BUNDLE_DIR = ROOT / "assets" / "videos"
HOST_DIR = ROOT / "build" / "exercise_videos"
PUBSPEC = ROOT / "pubspec.yaml"
EXTS = {".mp4", ".mov", ".m4v"}


def compress(src: pathlib.Path, dst: pathlib.Path) -> None:
    if shutil.which("ffmpeg") is None:
        print(f"  ! ffmpeg not found, copying {src.name} as-is (install ffmpeg to compress)")
        shutil.copyfile(src, dst)
        return
    subprocess.run(
        [
            "ffmpeg", "-y", "-loglevel", "error", "-i", str(src),
            "-t", "10", "-an",
            "-vf", "scale=-2:720:force_original_aspect_ratio=decrease,fps=30",
            "-c:v", "libx264", "-preset", "slow", "-crf", "28",
            "-pix_fmt", "yuv420p", "-movflags", "+faststart",
            str(dst),
        ],
        check=True,
    )


def ensure_asset_folder() -> None:
    text = PUBSPEC.read_text()
    if "- assets/videos/" in text:
        return
    marker = "    - assets/exercises/"
    if marker not in text:
        sys.exit("Couldn't find the assets list in pubspec.yaml; add '- assets/videos/' by hand.")
    PUBSPEC.write_text(text.replace(marker, marker + "\n    - assets/videos/", 1))
    print("  added assets/videos/ to pubspec.yaml")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src", type=pathlib.Path, help="folder with <id>_male / <id>_female clips")
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--bundle", action="store_true", help="put clips inside the app")
    mode.add_argument("--base-url", help="address where you will upload the clips")
    args = ap.parse_args()

    catalog = json.loads(CATALOG.read_text())
    exercises = {e["id"]: e for e in catalog["exercises"]}
    out_dir = BUNDLE_DIR if args.bundle else HOST_DIR
    out_dir.mkdir(parents=True, exist_ok=True)

    added, skipped = 0, []
    for clip in sorted(args.src.iterdir()):
        if clip.suffix.lower() not in EXTS:
            continue
        stem = clip.stem.lower()
        trainer = next((t for t in ("male", "female") if stem.endswith("_" + t)), None)
        ex_id = stem[: -len(trainer) - 1] if trainer else None
        if trainer is None or ex_id not in exercises:
            skipped.append(clip.name)
            continue
        name = f"{ex_id}_{trainer}.mp4"
        print(f"  {clip.name} -> {name}")
        compress(clip, out_dir / name)
        url = f"asset:assets/videos/{name}" if args.bundle else f"{args.base_url.rstrip('/')}/{name}"
        exercises[ex_id].setdefault("videos", {})[trainer] = url
        added += 1

    if args.bundle and added:
        ensure_asset_folder()
    CATALOG.write_text(json.dumps(catalog, ensure_ascii=False, indent=1))

    have = sum(1 for e in exercises.values() if any((e.get("videos") or {}).values()))
    print(f"\n{added} clip(s) added. {have} of {len(exercises)} exercises now have a video.")
    if skipped:
        print("Skipped (name must be <exercise_id>_male or _female):")
        for s in skipped:
            print("  -", s)
    if not args.bundle and added:
        print(f"\nUpload everything in {out_dir} to {args.base_url}")


if __name__ == "__main__":
    main()

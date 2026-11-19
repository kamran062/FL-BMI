"""Build the app's promo videos from screen recordings and a voice-over.

    python3 -I tool/promo/make_promo.py CLIPS_DIR VO_DIR OUT_DIR

CLIPS_DIR holds emulator recordings (adb screenrecord, 1080x2400) of the
demo build (tool/demo/demo_main.dart): today, bmi, squat, player, logger,
ticks, food. VO_DIR holds l1.wav … l7.wav (one line each, see SCRIPT).
Writes OUT_DIR/promo_landscape.mp4 (1920x1080, Play Store / YouTube) and
OUT_DIR/promo_vertical.mp4 (1080x1920, Reels / Shorts / TikTok).

Needs ffmpeg and Pillow. Fonts: the app's bundled Inter.
"""
from __future__ import annotations

import pathlib
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = pathlib.Path(__file__).resolve().parents[2]
FONTS = ROOT / "assets" / "google_fonts"
ICON = ROOT / "assets" / "icon.png"
APP = "BMI Health"
FPS = 30

BG_TOP = (9, 16, 14)
BG_BOTTOM = (13, 42, 33)
BRAND = (38, 199, 132)
WHITE = (240, 246, 243)
MUTED = (160, 190, 178)

# Voice-over lines (generated with the Mac's "Tara" voice; "B M I" spelled
# so it's read as letters).
SCRIPT = [
    "Meet B M I Health, your all-in-one fitness coach.",
    "Check your B M I, and track your weight, and body measurements.",
    "Train at home or in the gym, with animated guides for over one hundred exercises.",
    "Log every set, and get smart weight suggestions as you get stronger.",
    "Count calories with the food you really eat, like biryani, daal and roti.",
    "Steps, sleep and recovery, all in one place. And your data stays on your phone.",
    "Download B M I Health, free on Google Play.",
]

# Scenes: caption, sub-caption, voice line, clip segments (name, start, end).
# None as segments = the end card.
SCENES = [
    ("Your all-in-one\nfitness coach", "BMI · Workouts · Food · Recovery", 1, [("today", 0.2, 3.0)]),
    ("Know your BMI", "Weight, body fat and measurements", 2, [("bmi", 0.5, 4.4)]),
    ("Train anywhere", "114 exercises with animated guides", 3, [("squat", 3.6, 6.5), ("player", 0.4, 3.0)]),
    ("Get stronger", "Log sets, beat records,\nsmart weight suggestions", 4, [("logger", 1.9, 4.6), ("ticks", 0.6, 2.6)]),
    ("Eat smarter", "Desi food included:\nbiryani, daal, roti", 5, [("food", 0.3, 1.3), ("food", 9.4, 13.3)]),
    ("Your whole day", "Steps, sleep and recovery.\nPrivate on your phone.", 6, [("today", 1.2, 6.9)]),
    (None, None, 7, None),
]

# The vertical cut keeps the strongest scenes.
VERTICAL = [0, 1, 2, 4, 6]


def font(weight: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONTS / f"Inter-{weight}.ttf"), size)


def background(w: int, h: int, glow_at: tuple[int, int] | None) -> Image.Image:
    column = Image.new("RGB", (1, 256))
    for y in range(256):
        t = y / 255
        column.putpixel((0, y), tuple(round(BG_TOP[i] + (BG_BOTTOM[i] - BG_TOP[i]) * t) for i in range(3)))
    img = column.resize((w, h), Image.BILINEAR)
    if glow_at:
        glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        r = int(min(w, h) * 0.42)
        ImageDraw.Draw(glow).ellipse(
            (glow_at[0] - r, glow_at[1] - r, glow_at[0] + r, glow_at[1] + r), fill=BRAND + (70,))
        glow = glow.filter(ImageFilter.GaussianBlur(r // 2))
        img = Image.alpha_composite(img.convert("RGBA"), glow).convert("RGB")
    return img


def phone_frame(screen_w: int, screen_h: int) -> tuple[Image.Image, int]:
    """Transparent PNG of a phone: bezel with a rounded transparent screen."""
    bezel = max(10, screen_w // 34)
    fw, fh = screen_w + 2 * bezel, screen_h + 2 * bezel
    radius = int(screen_w * 0.11)
    frame = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    d = ImageDraw.Draw(frame)
    d.rounded_rectangle((0, 0, fw - 1, fh - 1), radius + bezel, fill=(24, 28, 27, 255),
                        outline=(70, 80, 76, 255), width=3)
    hole = Image.new("L", (fw, fh), 0)
    ImageDraw.Draw(hole).rounded_rectangle((bezel, bezel, bezel + screen_w, bezel + screen_h), radius, fill=255)
    # Clear the screen area so the recording shows through
    frame.putalpha(Image.composite(Image.new("L", (fw, fh), 0), frame.getchannel("A"), hole))
    return frame, bezel


def text_block(d: ImageDraw.ImageDraw, x: int, y: int, title: str, sub: str, size: int,
               align: str = "left", width: int = 0) -> None:
    tf, sf = font("Bold", size), font("Medium", int(size * 0.46))
    anchor = "la" if align == "left" else "ma"
    tx = x if align == "left" else x + width // 2
    d.multiline_text((tx, y), title, font=tf, fill=WHITE, spacing=int(size * 0.12), anchor=anchor,
                     align=align)
    th = d.multiline_textbbox((tx, y), title, font=tf, spacing=int(size * 0.12), anchor=anchor)[3] - y
    d.rounded_rectangle((tx if align == "left" else tx - 40, y + th + int(size * 0.32),
                         (tx if align == "left" else tx - 40) + 80, y + th + int(size * 0.32) + 8), 4, fill=BRAND)
    d.multiline_text((tx, y + th + int(size * 0.62)), sub, font=sf, fill=MUTED,
                     spacing=int(size * 0.14), anchor=anchor, align=align)


def brand_tag(img: Image.Image, x: int, y: int, size: int) -> None:
    icon = Image.open(ICON).convert("RGBA").resize((size, size), Image.LANCZOS)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size - 1, size - 1), size // 4, fill=255)
    img.paste(icon, (x, y), mask)
    ImageDraw.Draw(img).text((x + size + size // 3, y + size // 2), APP, font=font("Bold", int(size * 0.55)),
                             fill=WHITE, anchor="lm")


def end_card(w: int, h: int, out: pathlib.Path) -> None:
    img = background(w, h, (w // 2, h // 2))
    s = int(min(w, h) * 0.24)
    icon = Image.open(ICON).convert("RGBA").resize((s, s), Image.LANCZOS)
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, s - 1, s - 1), s // 4, fill=255)
    cy = int(h * 0.36)
    img.paste(icon, ((w - s) // 2, cy - s // 2), mask)
    d = ImageDraw.Draw(img)
    big = int(min(w, h) * 0.11)
    d.text((w // 2, cy + s // 2 + big), APP, font=font("Bold", big), fill=WHITE, anchor="mm")
    pill_font = font("Bold", int(big * 0.42))
    label = "Free on Google Play"
    tw = d.textlength(label, font=pill_font)
    py = cy + s // 2 + int(big * 2.2)
    pad_x, pad_y = int(big * 0.5), int(big * 0.28)
    d.rounded_rectangle((w // 2 - tw / 2 - pad_x, py - pad_y - big * 0.21, w // 2 + tw / 2 + pad_x, py + pad_y + big * 0.21),
                        int(big * 0.5), fill=BRAND)
    d.text((w // 2, py), label, font=pill_font, fill=(6, 30, 20), anchor="mm")
    d.text((w // 2, py + int(big * 1.3)), "BMI · Workouts · Food · Recovery", font=font("Medium", int(big * 0.34)),
           fill=MUTED, anchor="mm")
    img.save(out)


def run(args: list[str]) -> None:
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", *args], check=True)


def duration(p: pathlib.Path) -> float:
    return float(subprocess.check_output(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(p)]))


def build(kind: str, clips: pathlib.Path, vo: pathlib.Path, out: pathlib.Path, work: pathlib.Path) -> pathlib.Path:
    landscape = kind == "landscape"
    W, H = (1920, 1080) if landscape else (1080, 1920)
    screen_h = 860 if landscape else 1240
    screen_w = round(screen_h * 1080 / 2400 / 2) * 2
    frame, bezel = phone_frame(screen_w, screen_h)
    frame_path = work / f"frame_{kind}.png"
    frame.save(frame_path)
    fx = (W - frame.width - 230) if landscape else (W - frame.width) // 2
    fy = (H - frame.height) // 2 if landscape else H - frame.height - 110

    scenes = [SCENES[i] for i in (range(len(SCENES)) if landscape else VERTICAL)]
    parts = []
    for n, (title, sub, line, segments) in enumerate(scenes):
        voice = vo / f"l{line}.wav"
        dur = round(duration(voice) + (0.9 if segments is None else 0.55), 2)
        part = work / f"{kind}_{n}.mp4"
        if segments is None:
            card = work / f"end_{kind}.png"
            end_card(W, H, card)
            run(["-loop", "1", "-t", str(dur), "-i", str(card), "-i", str(voice),
                 "-filter_complex", f"[0:v]fps={FPS},format=yuv420p,fade=in:st=0:d=0.3[v];"
                 f"[1:a]adelay=250|250,apad,atrim=0:{dur}[a]",
                 "-map", "[v]", "-map", "[a]", "-c:v", "libx264", "-crf", "18", "-c:a", "aac", "-b:a", "192k",
                 "-ar", "48000", str(part)])
            parts.append(part)
            continue

        # Clip segments → one screen video of exactly `dur` seconds
        seg_files = []
        for k, (name, a, b) in enumerate(segments):
            sf = work / f"{kind}_{n}_{k}.mp4"
            run(["-ss", str(a), "-to", str(b), "-i", str(clips / f"{name}.mp4"),
                 "-vf", f"fps={FPS},scale={screen_w}:{screen_h}:flags=lanczos,format=yuv420p",
                 "-an", "-c:v", "libx264", "-crf", "16", str(sf)])
            seg_files.append(sf)
        concat = work / f"{kind}_{n}_list.txt"
        concat.write_text("".join(f"file '{f}'\n" for f in seg_files))
        screen = work / f"{kind}_{n}_screen.mp4"
        run(["-f", "concat", "-safe", "0", "-i", str(concat),
             "-vf", f"tpad=stop_mode=clone:stop_duration={dur},trim=0:{dur},setpts=PTS-STARTPTS",
             "-c:v", "libx264", "-crf", "16", str(screen)])

        bg = background(W, H, (fx + frame.width // 2, fy + frame.height // 2))
        d = ImageDraw.Draw(bg)
        if landscape:
            brand_tag(bg, 150, 120, 64)
            text_block(d, 150, 360, title, sub, 96)
        else:
            brand_tag(bg, 70, 90, 56)
            text_block(d, 0, 230, title, sub, 84, align="center", width=W)
        bg_path = work / f"bg_{kind}_{n}.png"
        bg.save(bg_path)

        run(["-loop", "1", "-t", str(dur), "-i", str(bg_path), "-i", str(screen), "-loop", "1", "-t", str(dur),
             "-i", str(frame_path), "-i", str(voice),
             "-filter_complex",
             f"[0:v][1:v]overlay={fx + bezel}:{fy + bezel}:shortest=1[a];[a][2:v]overlay={fx}:{fy},"
             f"fps={FPS},format=yuv420p,fade=in:st=0:d=0.25,fade=out:st={dur - 0.25}:d=0.25[v];"
             f"[3:a]adelay=200|200,apad,atrim=0:{dur}[aud]",
             "-map", "[v]", "-map", "[aud]", "-t", str(dur), "-c:v", "libx264", "-crf", "18",
             "-c:a", "aac", "-b:a", "192k", "-ar", "48000", str(part)])
        parts.append(part)

    lst = work / f"{kind}_parts.txt"
    lst.write_text("".join(f"file '{p}'\n" for p in parts))
    final = out / f"promo_{kind}.mp4"
    run(["-f", "concat", "-safe", "0", "-i", str(lst), "-c:v", "libx264", "-crf", "18", "-preset", "slow",
         "-pix_fmt", "yuv420p",
         # Loudness for YouTube / social apps (about -14 LUFS)
         "-af", "loudnorm=I=-14:TP=-1.5:LRA=11", "-ar", "48000",
         "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart", str(final)])
    return final


def main() -> None:
    clips, vo, out = (pathlib.Path(a) for a in sys.argv[1:4])
    out.mkdir(parents=True, exist_ok=True)
    work = out / "work"
    work.mkdir(exist_ok=True)
    for kind in ("landscape", "vertical"):
        f = build(kind, clips, vo, out, work)
        print(f"{f}  {duration(f):.1f} s")


if __name__ == "__main__":
    main()

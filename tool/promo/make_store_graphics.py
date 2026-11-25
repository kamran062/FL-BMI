"""Build the Play Store screenshots and feature graphic from raw screenshots.

    python3 tool/promo/make_store_graphics.py SHOTS_DIR OUT_DIR

SHOTS_DIR holds 1080x2400 screenshots of the demo build
(tool/demo/demo_main.dart): 1_today.png … 8_me.png (see SHOTS).
Writes OUT_DIR/screenshot_1.png … screenshot_8.png (1080x1920) and
OUT_DIR/feature_graphic.png (1024x500).

Captions follow docs/store-listing.md: short, no "free", "best", "#1" or
calls to action (Google Play store asset policy).
"""
from __future__ import annotations

import pathlib
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from make_promo import APP, BRAND, ICON, MUTED, WHITE, background, font, phone_frame  # noqa: E402

SHOTS = [
    ("1_today.png", "Your plan for today,\none tap", "Daily goals, streak and quick add"),
    ("2_bmi.png", "BMI & weight\nloss tracker", "Clear advice for your result"),
    ("3_player.png", "Home workouts,\nno equipment", "30-day challenges with voice coach"),
    ("4_exercise.png", "114 exercises\nwith guides", "Animated moves, steps and tips"),
    ("5_logger.png", "Gym log with\nsmart weights", "Sets, rest timer and records"),
    ("6_food.png", "Calorie counter\nwith desi food", "Biryani, daal, roti and more"),
    ("7_recovery.png", "Steps, sleep\n& recovery", "Know when to train hard or rest"),
    ("8_me.png", "Private: your data\nstays on your phone", "No account needed"),
]


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, img.width - 1, img.height - 1), radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def phone(shot: pathlib.Path, screen_h: int, crop_bottom: float = 1.0) -> Image.Image:
    """The screenshot inside a phone frame. crop_bottom < 1 cuts the phone off
    at that fraction of its height (it runs off the image edge)."""
    screen_w = round(screen_h * 1080 / 2400)
    screen = Image.open(shot).convert("RGB").resize((screen_w, screen_h), Image.LANCZOS)
    frame, bezel = phone_frame(screen_w, screen_h)
    out = Image.new("RGBA", frame.size, (0, 0, 0, 0))
    out.paste(rounded(screen, int(screen_w * 0.11)), (bezel, bezel))
    out.alpha_composite(frame)
    if crop_bottom < 1:
        out = out.crop((0, 0, out.width, int(out.height * crop_bottom)))
    return out


def screenshot(shot: pathlib.Path, title: str, sub: str, out: pathlib.Path) -> None:
    W, H = 1080, 1920
    p = phone(shot, 1700, crop_bottom=0.84)
    px, py = (W - p.width) // 2, H - p.height
    img = background(W, H, (W // 2, py + p.height // 2)).convert("RGBA")
    img.alpha_composite(p, (px, py))
    d = ImageDraw.Draw(img)
    size = 84
    d.multiline_text((W // 2, 110), title, font=font("Bold", size), fill=WHITE, anchor="ma", align="center",
                     spacing=10)
    th = d.multiline_textbbox((W // 2, 110), title, font=font("Bold", size), anchor="ma", spacing=10)[3]
    d.rounded_rectangle((W // 2 - 40, th + 26, W // 2 + 40, th + 34), 4, fill=BRAND)
    d.text((W // 2, th + 58), sub, font=font("Medium", 40), fill=MUTED, anchor="ma")
    img.convert("RGB").save(out, optimize=True)


def feature_graphic(shots: pathlib.Path, out: pathlib.Path) -> None:
    W, H = 1024, 500
    img = background(W, H, (760, 250)).convert("RGBA")
    # Three phones on the right, middle one in front
    for name, x, y, h in (("3_player.png", 560, 70, 560), ("6_food.png", 840, 70, 560),
                          ("1_today.png", 690, 40, 640)):
        p = phone(shots / name, h)
        img.alpha_composite(p, (x, y))
    d = ImageDraw.Draw(img)
    s = 104
    icon = rounded(Image.open(ICON).convert("RGB").resize((s, s), Image.LANCZOS), s // 4)
    img.alpha_composite(icon, (64, 72))
    d.text((64, 262), APP, font=font("Bold", 64), fill=WHITE, anchor="ls")
    d.rounded_rectangle((66, 288, 146, 296), 4, fill=BRAND)
    d.multiline_text((64, 318), "BMI · Workouts · Food\nSteps, sleep & recovery", font=font("Medium", 30),
                     fill=MUTED, spacing=10)
    img.convert("RGB").save(out, optimize=True)


def main() -> None:
    shots, out = (pathlib.Path(a) for a in sys.argv[1:3])
    out.mkdir(parents=True, exist_ok=True)
    for i, (name, title, sub) in enumerate(SHOTS, 1):
        screenshot(shots / name, title, sub, out / f"screenshot_{i}.png")
    feature_graphic(shots, out / "feature_graphic.png")
    print(f"wrote {len(SHOTS)} screenshots and the feature graphic to {out}")


if __name__ == "__main__":
    main()

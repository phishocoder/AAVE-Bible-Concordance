from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageColor, ImageDraw, ImageFilter, ImageFont


CANVAS_SIZE = (1242, 2688)
BASE_DIR = Path(__file__).resolve().parent
RAW_DIR = BASE_DIR / "raw"
OUTPUT_DIR = BASE_DIR / "iPhone65"

FONT_BOLD = "/System/Library/Fonts/Supplemental/Avenir Next.ttc"
FONT_BODY = "/System/Library/Fonts/SFNS.ttf"

CREAM = "#F8EFE4"
MUTED = "#CFC4B6"
GOLD = "#D8A85F"
INDIGO = "#7467F0"
DEEP_NAVY = "#050A14"
PHONE_FRAME = "#0D1018"
PHONE_STROKE = "#50453A"

GENERATED_FILENAMES = {
    "01_read-scripture-familiar-voice.png",
    "02_understand-what-youre-reading.png",
    "02_built-for-clarity-culture-faith.png",
    "03_study-save-share.png",
    "04_test-your-bible-knowledge.png",
    "04_daily-scripture-hits-home.png",
    "05_daily-scripture-hits-home.png",
    "06_built-for-clarity-culture-faith.png",
}


@dataclass(frozen=True)
class Slide:
    filename: str
    title: str
    source: str
    accent: str
    zoom: float = 1.0
    anchor_y: float = 0.5
    treatment: str = "default"


SLIDES = [
    Slide(
        filename="01_read-scripture-familiar-voice.png",
        title="Read Scripture in a Familiar Voice",
        source="bible_dark.png",
        accent=GOLD,
        zoom=1.07,
        anchor_y=0.32,
        treatment="reader",
    ),
    Slide(
        filename="02_built-for-clarity-culture-faith.png",
        title="Built for Clarity, Culture, and Faith",
        source="commentary_dark.png",
        accent=INDIGO,
        zoom=1.12,
        anchor_y=0.36,
        treatment="commentary",
    ),
    Slide(
        filename="03_study-save-share.png",
        title="Study, Save, and Share",
        source="home_dark.png",
        accent=GOLD,
        zoom=1.03,
        anchor_y=0.33,
        treatment="engagement",
    ),
    Slide(
        filename="04_daily-scripture-hits-home.png",
        title="Daily Scripture That Hits Home",
        source="home_dark.png",
        accent=INDIGO,
        zoom=1.08,
        anchor_y=0.32,
        treatment="daily",
    ),
]


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    path = FONT_BOLD if bold else FONT_BODY
    return ImageFont.truetype(path, size=size, index=0)


def add_radial_glow(
    base: Image.Image,
    center: tuple[int, int],
    radius: int,
    color: tuple[int, int, int],
    alpha: int,
    blur: int = 58,
) -> None:
    glow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow)
    cx, cy = center
    for r in range(radius, 0, -28):
        a = int(alpha * (r / radius) ** 2)
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=color + (a,))
    base.alpha_composite(glow.filter(ImageFilter.GaussianBlur(blur)))


def build_background(accent: str) -> Image.Image:
    canvas = Image.new("RGBA", CANVAS_SIZE, DEEP_NAVY)
    draw = ImageDraw.Draw(canvas)
    width, height = CANVAS_SIZE

    top = (4, 9, 20)
    mid = (8, 17, 37)
    bottom = (7, 7, 12)
    for y in range(height):
        if y < height * 0.52:
            mix = y / (height * 0.52)
            rgb = tuple(int(top[i] * (1 - mix) + mid[i] * mix) for i in range(3))
        else:
            mix = (y - height * 0.52) / (height * 0.48)
            rgb = tuple(int(mid[i] * (1 - mix) + bottom[i] * mix) for i in range(3))
        draw.line((0, y, width, y), fill=rgb + (255,))

    accent_rgb = ImageColor.getrgb(accent)
    add_radial_glow(canvas, (1000, 300), 520, accent_rgb, 58)
    add_radial_glow(canvas, (230, 2050), 620, (216, 168, 95), 34)
    add_radial_glow(canvas, (620, 1190), 360, (62, 77, 148), 38)

    vignette = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    vignette_draw = ImageDraw.Draw(vignette)
    vignette_draw.rectangle((0, 0, width, 240), fill=(255, 255, 255, 5))
    vignette_draw.rectangle((0, 2260, width, height), fill=(0, 0, 0, 88))
    canvas.alpha_composite(vignette)
    return canvas


def draw_centered_text(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    font: ImageFont.FreeTypeFont,
    fill: str | tuple[int, int, int, int],
) -> None:
    x, y = xy
    box = draw.textbbox((0, 0), text, font=font)
    draw.text((x - (box[2] - box[0]) / 2, y), text, font=font, fill=fill)


def draw_copy(canvas: Image.Image, title: str, accent: str) -> None:
    draw = ImageDraw.Draw(canvas)
    title_font = load_font(94, bold=True)
    title_lines = wrap(title, width=22)

    y = 138
    for line in title_lines:
        draw_centered_text(draw, (621, y), line, title_font, CREAM)
        y += 102

    rule_w = 176
    draw.rounded_rectangle((621 - rule_w // 2, y + 22, 621 + rule_w // 2, y + 34), radius=6, fill=accent)


def fit_source(source: Image.Image, frame_size: tuple[int, int], zoom: float, anchor_y: float) -> Image.Image:
    target_w, target_h = frame_size
    scaled_w = int(target_w * zoom)
    scaled_h = int(scaled_w * source.height / source.width)
    if scaled_h < target_h:
        scaled_h = int(target_h * zoom)
        scaled_w = int(scaled_h * source.width / source.height)

    resized = source.resize((scaled_w, scaled_h), Image.Resampling.LANCZOS)
    max_left = max(scaled_w - target_w, 0)
    max_top = max(scaled_h - target_h, 0)
    left = max_left // 2
    top = max(0, min(int(max_top * anchor_y), max_top))
    return resized.crop((left, top, left + target_w, top + target_h))


def rounded_paste(base: Image.Image, layer: Image.Image, box: tuple[int, int, int, int], radius: int) -> None:
    mask = Image.new("L", base.size, 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(box, radius=radius, fill=255)
    full = Image.new("RGBA", base.size, (0, 0, 0, 0))
    full.paste(layer, (box[0], box[1]))
    base.alpha_composite(Image.composite(full, Image.new("RGBA", base.size, (0, 0, 0, 0)), mask))


def draw_phone(
    canvas: Image.Image,
    source_path: Path,
    outer: tuple[int, int, int, int],
    zoom: float,
    anchor_y: float,
    shadow_alpha: int = 130,
) -> tuple[int, int, int, int]:
    x1, y1, x2, y2 = outer
    bezel = max(16, int((x2 - x1) * 0.026))
    inner = (x1 + bezel, y1 + bezel, x2 - bezel, y2 - bezel)
    outer_radius = int((x2 - x1) * 0.082)
    inner_radius = max(24, outer_radius - 16)

    shadow = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((x1 + 24, y1 + 42, x2 + 24, y2 + 42), radius=outer_radius, fill=(0, 0, 0, shadow_alpha))
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(38)))

    phone = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    phone_draw = ImageDraw.Draw(phone)
    phone_draw.rounded_rectangle(outer, radius=outer_radius, fill=PHONE_FRAME, outline=PHONE_STROKE, width=4)

    source = Image.open(source_path).convert("RGBA")
    frame_w = inner[2] - inner[0]
    frame_h = inner[3] - inner[1]
    cropped = fit_source(source, (frame_w, frame_h), zoom=zoom, anchor_y=anchor_y)
    rounded_paste(phone, cropped, inner, inner_radius)

    island_w = int((x2 - x1) * 0.31)
    island_h = int((y2 - y1) * 0.037)
    island = (
        (x1 + x2 - island_w) // 2,
        y1 + int((y2 - y1) * 0.025),
        (x1 + x2 + island_w) // 2,
        y1 + int((y2 - y1) * 0.025) + island_h,
    )
    phone_draw.rounded_rectangle(island, radius=island_h // 2, fill=(7, 8, 12, 248))

    highlight = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    highlight_draw = ImageDraw.Draw(highlight)
    highlight_draw.rounded_rectangle((x1 + 8, y1 + 8, x2 - 8, y2 - 8), radius=outer_radius - 8, outline=(255, 255, 255, 28), width=2)
    phone.alpha_composite(highlight)
    canvas.alpha_composite(phone)
    return inner


def draw_feature_card(
    canvas: Image.Image,
    box: tuple[int, int, int, int],
    label: str,
    value: str,
    accent: str,
) -> None:
    draw = ImageDraw.Draw(canvas)
    label_font = load_font(28)
    value_font = load_font(40, bold=True)
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=32, fill=(9, 14, 26, 222), outline=(248, 239, 228, 32), width=2)
    draw.rounded_rectangle((x1 + 24, y1 + 24, x1 + 70, y1 + 70), radius=18, fill=ImageColor.getrgb(accent) + (64,))
    draw.text((x1 + 90, y1 + 24), label, font=label_font, fill=(207, 196, 182, 230))
    draw.text((x1 + 90, y1 + 60), value, font=value_font, fill=CREAM)


def draw_commentary_overlay(canvas: Image.Image, accent: str) -> None:
    draw_feature_card(canvas, (92, 2058, 1150, 2194), "Commentary", "Context without confusion", accent)
    draw_feature_card(canvas, (132, 2224, 1110, 2360), "Study Notes", "Meaning, culture, application", GOLD)


def draw_engagement_overlay(canvas: Image.Image, accent: str) -> None:
    draw_feature_card(canvas, (86, 2030, 436, 2172), "Save", "Bookmarks", accent)
    draw_feature_card(canvas, (456, 2030, 806, 2172), "Study", "Quizzes", INDIGO)
    draw_feature_card(canvas, (826, 2030, 1176, 2172), "Return", "Streaks", GOLD)


def draw_daily_overlay(canvas: Image.Image, accent: str) -> None:
    draw = ImageDraw.Draw(canvas)
    box = (92, 2024, 1150, 2234)
    title_font = load_font(40, bold=True)
    body_font = load_font(32)
    time_font = load_font(28)

    draw.rounded_rectangle(box, radius=44, fill=(244, 246, 252, 232), outline=(255, 255, 255, 78), width=2)
    draw.rounded_rectangle((126, 2058, 190, 2122), radius=18, fill=ImageColor.getrgb(accent) + (255,))
    draw.text((218, 2050), "AAVE Bible", font=title_font, fill=(16, 18, 26, 255))
    draw.text((1024, 2058), "now", font=time_font, fill=(82, 86, 98, 255))
    draw.text((218, 2102), "Today’s verse is ready.", font=body_font, fill=(42, 45, 56, 255))
    draw.text((218, 2146), "Open your daily reading.", font=body_font, fill=(42, 45, 56, 210))


def render_slide(slide: Slide) -> None:
    canvas = build_background(slide.accent)
    draw_copy(canvas, slide.title, slide.accent)

    phone_outer = (180, 590, 1062, 2476)
    draw_phone(canvas, RAW_DIR / slide.source, phone_outer, slide.zoom, slide.anchor_y)

    if slide.treatment == "commentary":
        draw_commentary_overlay(canvas, slide.accent)
    elif slide.treatment == "engagement":
        draw_engagement_overlay(canvas, slide.accent)
    elif slide.treatment == "daily":
        draw_daily_overlay(canvas, slide.accent)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(OUTPUT_DIR / slide.filename, format="PNG", optimize=True)


def clear_old_generated_outputs() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    current = {slide.filename for slide in SLIDES}
    for filename in GENERATED_FILENAMES - current:
        path = OUTPUT_DIR / filename
        if path.exists():
            path.unlink()


def main() -> None:
    missing = [slide.source for slide in SLIDES if not (RAW_DIR / slide.source).exists()]
    if missing:
        raise FileNotFoundError(f"Missing source screenshots: {', '.join(sorted(set(missing)))}")

    clear_old_generated_outputs()
    for slide in SLIDES:
        render_slide(slide)


if __name__ == "__main__":
    main()

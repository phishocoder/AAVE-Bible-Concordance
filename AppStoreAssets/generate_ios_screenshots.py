from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFilter, ImageFont


CANVAS_SIZE = (1242, 2688)
BASE_DIR = Path(__file__).resolve().parent
RAW_DIR = BASE_DIR / "raw"
OUTPUT_DIR = BASE_DIR / "iPhone65"

FONT_BOLD = "/System/Library/Fonts/Supplemental/Avenir Next.ttc"
FONT_BODY = "/System/Library/Fonts/SFNS.ttf"

CREAM = "#F7EBDD"
MUTED = "#CDBEAF"
GOLD = "#D2A55B"
DEEP_NAVY = "#081222"
PLUM = "#2A1531"
BROWN = "#2F211C"
PHONE_FRAME = "#171A22"
PHONE_STROKE = "#4A3C31"


@dataclass(frozen=True)
class Slide:
    filename: str
    title: str
    subtitle: str
    source: str
    zoom: float = 1.0
    anchor_y: float = 0.5


SLIDES = [
    Slide(
        filename="01_read-scripture-familiar-voice.png",
        title="Read Scripture in a Familiar Voice",
        subtitle="Bible passages with cultural clarity and everyday language.",
        source="bible_dark.png",
        zoom=1.06,
        anchor_y=0.33,
    ),
    Slide(
        filename="02_understand-what-youre-reading.png",
        title="Understand What You’re Reading",
        subtitle="Commentary that breaks down Scripture with context and real-life application.",
        source="commentary_dark.png",
        zoom=1.1,
        anchor_y=0.38,
    ),
    Slide(
        filename="03_study-save-share.png",
        title="Study, Save, and Share",
        subtitle="Bookmark verses, copy passages, and keep your study flow moving.",
        source="bookmarks_dark.png",
        zoom=1.0,
        anchor_y=0.5,
    ),
    Slide(
        filename="04_test-your-bible-knowledge.png",
        title="Test Your Bible Knowledge",
        subtitle="Quizzes help you learn Scripture without making it feel like homework.",
        source="quiz_dark.png",
        zoom=1.0,
        anchor_y=0.43,
    ),
    Slide(
        filename="05_daily-scripture-hits-home.png",
        title="Daily Scripture That Hits Home",
        subtitle="Stay connected with verses and reflections throughout the week.",
        source="home_dark.png",
        zoom=1.02,
        anchor_y=0.34,
    ),
    Slide(
        filename="06_built-for-clarity-culture-faith.png",
        title="Built for Clarity, Culture, and Faith",
        subtitle="A Bible study experience designed for understanding, not confusion.",
        source="leaderboard_dark.png",
        zoom=1.0,
        anchor_y=0.39,
    ),
]


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    path = FONT_BOLD if bold else FONT_BODY
    index = 0 if not bold else 0
    return ImageFont.truetype(path, size=size, index=index)


def vertical_gradient(size: tuple[int, int], top: str, bottom: str) -> Image.Image:
    image = Image.new("RGBA", size)
    draw = ImageDraw.Draw(image)
    width, height = size
    top_rgb = ImageColor.getrgb(top)
    bottom_rgb = ImageColor.getrgb(bottom)
    for y in range(height):
        mix = y / max(height - 1, 1)
        rgb = tuple(int(top_rgb[i] * (1 - mix) + bottom_rgb[i] * mix) for i in range(3))
        draw.line((0, y, width, y), fill=rgb + (255,))
    return image


def add_radial_glow(base: Image.Image, center: tuple[int, int], radius: int, color: tuple[int, int, int], alpha: int) -> None:
    glow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow)
    cx, cy = center
    for r in range(radius, 0, -24):
        a = int(alpha * (r / radius) ** 2)
        bbox = (cx - r, cy - r, cx + r, cy + r)
        draw.ellipse(bbox, fill=color + (a,))
    glow = glow.filter(ImageFilter.GaussianBlur(42))
    base.alpha_composite(glow)


def build_background() -> Image.Image:
    canvas = Image.new("RGBA", CANVAS_SIZE, DEEP_NAVY)
    grad = Image.new("RGBA", CANVAS_SIZE)
    draw = ImageDraw.Draw(grad)
    width, height = CANVAS_SIZE
    top = (7, 18, 34)
    mid = (22, 27, 57)
    bottom = (42, 26, 42)
    for y in range(height):
        if y < height * 0.58:
            mix = y / (height * 0.58)
            rgb = tuple(int(top[i] * (1 - mix) + mid[i] * mix) for i in range(3))
        else:
            mix = (y - height * 0.58) / (height * 0.42)
            rgb = tuple(int(mid[i] * (1 - mix) + bottom[i] * mix) for i in range(3))
        draw.line((0, y, width, y), fill=rgb + (255,))
    canvas.alpha_composite(grad)
    add_radial_glow(canvas, (980, 240), 420, (130, 91, 220), 72)
    add_radial_glow(canvas, (260, 2080), 520, (197, 140, 59), 42)
    add_radial_glow(canvas, (620, 1160), 320, (89, 120, 255), 46)

    haze = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    haze_draw = ImageDraw.Draw(haze)
    haze_draw.rounded_rectangle((54, 64, 1188, 472), radius=72, fill=(255, 255, 255, 12))
    haze_draw.rounded_rectangle((98, 122, 1144, 428), radius=58, outline=(247, 235, 221, 26), width=2)
    canvas.alpha_composite(haze)
    return canvas


def draw_copy(canvas: Image.Image, title: str, subtitle: str) -> None:
    draw = ImageDraw.Draw(canvas)
    eyebrow_font = load_font(34, bold=False)
    title_font = load_font(90, bold=True)
    body_font = load_font(42, bold=False)

    draw.rounded_rectangle((92, 106, 402, 160), radius=27, fill=(247, 235, 221, 18), outline=(247, 235, 221, 42), width=2)
    draw.text((122, 116), "AAVE Bible Concordance", font=eyebrow_font, fill=(247, 235, 221, 220))

    title_lines = wrap(title, width=24)
    y = 220
    for line in title_lines:
        draw.text((96, y), line, font=title_font, fill=CREAM)
        y += 96

    draw.rounded_rectangle((96, y + 18, 228, y + 30), radius=6, fill=GOLD)
    y += 70
    subtitle_lines = wrap(subtitle, width=38)
    for line in subtitle_lines:
        draw.text((96, y), line, font=body_font, fill=MUTED)
        y += 54


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
    top = int(max_top * anchor_y)
    top = max(0, min(top, max_top))
    return resized.crop((left, top, left + target_w, top + target_h))


def add_phone(canvas: Image.Image, source_path: Path, zoom: float, anchor_y: float) -> None:
    phone_outer = (132, 660, 1110, 2620)
    phone_inner = (154, 682, 1088, 2598)
    outer_radius = 78
    inner_radius = 64

    shadow = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((phone_outer[0] + 18, phone_outer[1] + 32, phone_outer[2] + 18, phone_outer[3] + 32), radius=outer_radius, fill=(0, 0, 0, 112))
    shadow = shadow.filter(ImageFilter.GaussianBlur(30))
    canvas.alpha_composite(shadow)

    phone = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    phone_draw = ImageDraw.Draw(phone)
    phone_draw.rounded_rectangle(phone_outer, radius=outer_radius, fill=PHONE_FRAME, outline=PHONE_STROKE, width=4)

    source = Image.open(source_path).convert("RGBA")
    frame_w = phone_inner[2] - phone_inner[0]
    frame_h = phone_inner[3] - phone_inner[1]
    cropped = fit_source(source, (frame_w, frame_h), zoom=zoom, anchor_y=anchor_y)

    mask = Image.new("L", CANVAS_SIZE, 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(phone_inner, radius=inner_radius, fill=255)

    screen_layer = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    screen_layer.paste(cropped, (phone_inner[0], phone_inner[1]))
    phone = Image.composite(screen_layer, phone, mask)

    island = (469, 710, 773, 782)
    phone_draw = ImageDraw.Draw(phone)
    phone_draw.rounded_rectangle(island, radius=34, fill=(11, 12, 18, 250))

    gold_glow = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(gold_glow)
    glow_draw.ellipse((304, 874, 938, 1508), fill=(210, 165, 91, 18))
    gold_glow = gold_glow.filter(ImageFilter.GaussianBlur(60))
    canvas.alpha_composite(gold_glow)
    canvas.alpha_composite(phone)


def render_slide(slide: Slide) -> None:
    canvas = build_background()
    draw_copy(canvas, slide.title, slide.subtitle)
    add_phone(canvas, RAW_DIR / slide.source, slide.zoom, slide.anchor_y)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(OUTPUT_DIR / slide.filename, format="PNG")


def main() -> None:
    missing = [slide.source for slide in SLIDES if not (RAW_DIR / slide.source).exists()]
    if missing:
        raise FileNotFoundError(f"Missing source screenshots: {', '.join(missing)}")
    for slide in SLIDES:
        render_slide(slide)


if __name__ == "__main__":
    from PIL import ImageColor

    main()

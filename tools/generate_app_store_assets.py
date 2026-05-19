from __future__ import annotations

import json
import math
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "AppStoreAssets" / "Source"
SCREENSHOT_DIR = ROOT / "AppStoreAssets" / "Screenshots"
ICONSET_DIR = ROOT / "ArcanaCodex" / "Assets.xcassets" / "AppIcon.appiconset"

ICON_SOURCE = SOURCE_DIR / "app-icon-source.png"
BACKGROUND_SOURCES = [
    SOURCE_DIR / "screenshot-bg-01.png",
    SOURCE_DIR / "screenshot-bg-02.png",
    SOURCE_DIR / "screenshot-bg-03.png",
]

FONT_REGULAR = Path("C:/Windows/Fonts/NotoSansJP-VF.ttf")
FONT_SERIF = Path("C:/Windows/Fonts/yumin.ttf")
FONT_SERIF_BOLD = Path("C:/Windows/Fonts/yumindb.ttf")

COLORS = {
    "ink": "#070806",
    "card": "#15130D",
    "card2": "#211D14",
    "gold": "#E4C76A",
    "gold2": "#C8A653",
    "muted": "#B8A77A",
    "parchment": "#F4E9C7",
    "green": "#3E8B75",
    "burgundy": "#6E2830",
}


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size=size)


def hex_to_rgba(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    value = value.lstrip("#")
    return (int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16), alpha)


def cover(src: Image.Image, size: tuple[int, int]) -> Image.Image:
    src_ratio = src.width / src.height
    dst_ratio = size[0] / size[1]
    if src_ratio > dst_ratio:
        new_h = size[1]
        new_w = round(new_h * src_ratio)
    else:
        new_w = size[0]
        new_h = round(new_w / src_ratio)
    resized = src.resize((new_w, new_h), Image.Resampling.LANCZOS)
    left = (new_w - size[0]) // 2
    top = (new_h - size[1]) // 2
    return resized.crop((left, top, left + size[0], top + size[1]))


def rounded_rect(draw: ImageDraw.ImageDraw, xy, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def text_wrap(draw: ImageDraw.ImageDraw, text: str, font_obj: ImageFont.FreeTypeFont, width: int) -> list[str]:
    lines: list[str] = []
    for paragraph in text.split("\n"):
        current = ""
        for ch in paragraph:
            candidate = current + ch
            if draw.textbbox((0, 0), candidate, font=font_obj)[2] <= width or not current:
                current = candidate
            else:
                lines.append(current)
                current = ch
        if current:
            lines.append(current)
    return lines


def draw_multiline(draw: ImageDraw.ImageDraw, pos, text, font_obj, fill, width, line_gap=10):
    x, y = pos
    for line in text_wrap(draw, text, font_obj, width):
        draw.text((x, y), line, font=font_obj, fill=fill)
        y += draw.textbbox((0, 0), line, font=font_obj)[3] + line_gap
    return y


def card(draw, xy, radius=18):
    rounded_rect(
        draw,
        xy,
        radius,
        fill=hex_to_rgba(COLORS["card"], 228),
        outline=hex_to_rgba(COLORS["gold2"], 120),
        width=2,
    )


def draw_phone_mockup(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int, variant: int):
    rounded_rect(draw, (x, y, x + w, y + h), 58, hex_to_rgba("#050504", 246), hex_to_rgba(COLORS["gold2"], 160), 3)
    inner = (x + 26, y + 34, x + w - 26, y + h - 34)
    rounded_rect(draw, inner, 42, hex_to_rgba(COLORS["ink"], 255), hex_to_rgba(COLORS["gold2"], 70), 1)
    ix, iy, ir, ib = inner

    title_font = font(FONT_SERIF_BOLD, max(34, w // 13))
    body_font = font(FONT_REGULAR, max(19, w // 25))
    small_font = font(FONT_REGULAR, max(15, w // 32))
    accent = hex_to_rgba(COLORS["gold"], 255)
    primary = hex_to_rgba(COLORS["parchment"], 255)
    muted = hex_to_rgba(COLORS["muted"], 255)

    if variant == 0:
        draw.text((ix + 38, iy + 42), "Arcana Library", font=title_font, fill=primary)
        draw.text((ix + 38, iy + 100), "巨匠の書斎で読む", font=body_font, fill=accent)
        hero_y = iy + 150
        rounded_rect(draw, (ix + 34, hero_y, ir - 34, hero_y + 220), 18, hex_to_rgba(COLORS["card2"], 240), hex_to_rgba(COLORS["gold2"], 120), 2)
        draw.text((ix + 64, hero_y + 48), "Papus / Waite / Ouspensky", font=body_font, fill=accent)
        draw.text((ix + 64, hero_y + 100), "象徴・生命の樹・占星術を\nひとつの体系で学ぶ", font=small_font, fill=muted, spacing=8)
        items = [("0", "愚者", "The Fool"), ("1", "魔術師", "The Magician"), ("2", "女教皇", "The High Priestess")]
        start = hero_y + 270
    elif variant == 1:
        draw.text((ix + 38, iy + 42), "巨匠の解釈", font=title_font, fill=primary)
        draw.text((ix + 38, iy + 100), "同じカードを三つの古典で比較", font=body_font, fill=accent)
        items = [("P", "Papus", "数と象徴の体系"), ("W", "A.E. Waite", "図像と神秘思想"), ("O", "Ouspensky", "意識への鍵")]
        start = iy + 170
    elif variant == 2:
        draw.text((ix + 38, iy + 42), "生命の樹", font=title_font, fill=primary)
        draw.text((ix + 38, iy + 100), "22のパスをカードでたどる", font=body_font, fill=accent)
        cx, cy = ix + w // 2 - 20, iy + 330
        nodes = [(0, -140), (-120, -70), (120, -70), (-120, 60), (120, 60), (0, 140)]
        for a in nodes:
            for b in nodes:
                if nodes.index(a) < nodes.index(b) and abs(nodes.index(a) - nodes.index(b)) <= 2:
                    draw.line((cx + a[0], cy + a[1], cx + b[0], cy + b[1]), fill=hex_to_rgba(COLORS["gold2"], 82), width=2)
        for dx, dy in nodes:
            draw.ellipse((cx + dx - 25, cy + dy - 25, cx + dx + 25, cy + dy + 25), fill=hex_to_rgba(COLORS["card2"], 255), outline=accent, width=2)
        items = [("11", "愚者", "ケテル → コクマー"), ("12", "魔術師", "ケテル → ビナー")]
        start = iy + 540
    elif variant == 3:
        draw.text((ix + 38, iy + 42), "四元素と小アルカナ", font=title_font, fill=primary)
        draw.text((ix + 38, iy + 100), "火・水・風・地から意味を整理", font=body_font, fill=accent)
        items = [("火", "ワンド", "意志・始まり"), ("水", "カップ", "感情・関係"), ("風", "ソード", "知性・選択"), ("地", "ペンタクル", "現実・実務")]
        start = iy + 170
    else:
        draw.text((ix + 38, iy + 42), "天体と占星術", font=title_font, fill=primary)
        draw.text((ix + 38, iy + 100), "星座と惑星の対応を確認", font=body_font, fill=accent)
        items = [("♈", "牡羊座", "皇帝"), ("♉", "牡牛座", "教皇"), ("☉", "太陽", "太陽"), ("☽", "月", "女教皇")]
        start = iy + 170

    row_h = max(86, h // 11)
    for idx, (badge, title, subtitle) in enumerate(items):
        top = start + idx * (row_h + 16)
        if top + row_h > ib - 80:
            break
        rounded_rect(draw, (ix + 34, top, ir - 34, top + row_h), 16, hex_to_rgba(COLORS["card"], 236), hex_to_rgba(COLORS["gold2"], 85), 1)
        draw.ellipse((ix + 58, top + 18, ix + 58 + row_h - 36, top + row_h - 18), fill=hex_to_rgba(COLORS["ink"], 255), outline=accent, width=2)
        draw.text((ix + 82, top + 31), badge, font=small_font, fill=accent, anchor="mm")
        draw.text((ix + 120, top + 18), title, font=body_font, fill=primary)
        draw.text((ix + 120, top + 52), subtitle, font=small_font, fill=muted)

    tab_y = ib - 58
    labels = ["象徴", "生命", "巨匠", "元素", "天体"]
    for i, label in enumerate(labels):
        tx = ix + 54 + i * ((ir - ix - 108) // 4)
        draw.text((tx, tab_y), label, font=small_font, fill=accent if i == variant % 5 else muted, anchor="mm")


def make_screenshot(size: tuple[int, int], name_prefix: str, index: int, title: str, subtitle: str, bg: Image.Image):
    w, h = size
    canvas = cover(bg, size).convert("RGBA")
    overlay = Image.new("RGBA", size, (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.rectangle((0, 0, w, h), fill=(0, 0, 0, 70))
    od.rectangle((0, 0, w, int(h * 0.38)), fill=(0, 0, 0, 120))
    canvas.alpha_composite(overlay)
    draw = ImageDraw.Draw(canvas)

    margin = round(w * 0.075)
    headline_font = font(FONT_SERIF_BOLD, round(w * (0.073 if w < 1600 else 0.056)))
    sub_font = font(FONT_REGULAR, round(w * (0.032 if w < 1600 else 0.024)))
    eyebrow_font = font(FONT_REGULAR, round(w * (0.022 if w < 1600 else 0.018)))

    draw.text((margin, round(h * 0.065)), "ARCANA LIBRARY", font=eyebrow_font, fill=hex_to_rgba(COLORS["gold"], 255))
    end_y = draw_multiline(
        draw,
        (margin, round(h * 0.105)),
        title,
        headline_font,
        hex_to_rgba(COLORS["parchment"], 255),
        w - margin * 2,
        line_gap=round(w * 0.012),
    )
    draw_multiline(
        draw,
        (margin, end_y + round(h * 0.018)),
        subtitle,
        sub_font,
        hex_to_rgba(COLORS["muted"], 255),
        w - margin * 2,
        line_gap=round(w * 0.006),
    )

    if w < 1600:
        phone_w = round(w * 0.64)
        phone_h = round(h * 0.55)
        phone_x = (w - phone_w) // 2
        phone_y = round(h * 0.395)
        draw_phone_mockup(draw, phone_x, phone_y, phone_w, phone_h, index)
    else:
        phone_w = round(w * 0.42)
        phone_h = round(h * 0.68)
        phone_x = round(w * 0.51)
        phone_y = round(h * 0.22)
        draw_phone_mockup(draw, phone_x, phone_y, phone_w, phone_h, index)

    out_dir = SCREENSHOT_DIR / name_prefix
    out_dir.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(out_dir / f"{index + 1:02d}-{slug(title)}.png", quality=95)


def slug(text: str) -> str:
    mapping = {
        "巨匠": "masters",
        "古典": "interpretations",
        "象徴": "symbols",
        "生命": "tree",
        "四元素": "elements",
        "天体": "astrology",
    }
    for key, value in mapping.items():
        if key in text:
            return value
    return "screenshot"


def make_app_icons():
    ICONSET_DIR.mkdir(parents=True, exist_ok=True)
    source = cover(Image.open(ICON_SOURCE).convert("RGBA"), (1024, 1024))
    source.save(ICONSET_DIR / "AppIcon-1024.png")
    (ROOT / "AppStoreAssets" / "AppIcon").mkdir(parents=True, exist_ok=True)
    source.save(ROOT / "AppStoreAssets" / "AppIcon" / "ArcanaCodex-AppIcon-1024.png")

    icons = [
        ("iphone", "20x20", "2x", 40), ("iphone", "20x20", "3x", 60),
        ("iphone", "29x29", "2x", 58), ("iphone", "29x29", "3x", 87),
        ("iphone", "40x40", "2x", 80), ("iphone", "40x40", "3x", 120),
        ("iphone", "60x60", "2x", 120), ("iphone", "60x60", "3x", 180),
        ("ipad", "20x20", "1x", 20), ("ipad", "20x20", "2x", 40),
        ("ipad", "29x29", "1x", 29), ("ipad", "29x29", "2x", 58),
        ("ipad", "40x40", "1x", 40), ("ipad", "40x40", "2x", 80),
        ("ipad", "76x76", "1x", 76), ("ipad", "76x76", "2x", 152),
        ("ipad", "83.5x83.5", "2x", 167),
    ]
    images = []
    for idiom, logical_size, scale, pixels in icons:
        filename = f"AppIcon-{pixels}.png"
        source.resize((pixels, pixels), Image.Resampling.LANCZOS).save(ICONSET_DIR / filename)
        images.append({"idiom": idiom, "size": logical_size, "scale": scale, "filename": filename})

    images.append({"idiom": "ios-marketing", "size": "1024x1024", "scale": "1x", "filename": "AppIcon-1024.png"})
    (ICONSET_DIR / "Contents.json").write_text(
        json.dumps({"images": images, "info": {"author": "xcode", "version": 1}}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    (ICONSET_DIR.parent / "Contents.json").write_text(
        json.dumps({"info": {"author": "xcode", "version": 1}}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def make_screenshots():
    if SCREENSHOT_DIR.exists():
        shutil.rmtree(SCREENSHOT_DIR)

    titles = [
        "巨匠の書斎で\nタロットを読む",
        "古典解釈を\nカードごとに比較",
        "生命の樹と\n象徴をつなげる",
        "四元素から\n小アルカナを整理",
        "天体対応で\n意味を深める",
    ]
    subtitles = [
        "Papus、Waite、Ouspenskyの視点を\nひとつの学習体験に。",
        "同じカードを複数の巨匠から読み\n解釈の差を理解できます。",
        "ヘブライ文字、パス、セフィラを画面の流れで確認。",
        "ワンド、カップ、ソード、ペンタクルを数秘と一緒に学べます。",
        "十二星座と惑星の対応から、大アルカナの背景を読み解きます。",
    ]
    backgrounds = [Image.open(p) for p in BACKGROUND_SOURCES]
    sizes = {
        "iphone-6-9": (1290, 2796),
        "ipad-13": (2048, 2732),
    }
    for name, size in sizes.items():
        for i, title in enumerate(titles):
            make_screenshot(size, name, i, title, subtitles[i], backgrounds[i % len(backgrounds)])


def main():
    make_app_icons()
    make_screenshots()


if __name__ == "__main__":
    main()

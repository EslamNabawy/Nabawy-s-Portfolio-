"""
Tome Thrall pixel-art generator.

Produces:
- 11 full-canvas layer PNGs for the present pose
- 6 pose frame PNGs
- a horizontal spritesheet
- a preview GIF

Palette and character design follow the supplied Tome Thrall reference:
right-facing, gaunt, long-limbed, dark gothic servant figure.
All output uses nearest-neighbor scaling and no anti-aliasing.
"""

from __future__ import annotations

from pathlib import Path
import math
import os

from PIL import Image


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "tome_thrall_outputs_v2"
OUT_DIR.mkdir(parents=True, exist_ok=True)


# ---------------------------------------------------------------------------
# Canvas
# ---------------------------------------------------------------------------

W, H = 128, 160
SCALE = 4


# ---------------------------------------------------------------------------
# Palette
# ---------------------------------------------------------------------------

TRANSPARENT = (0, 0, 0, 0)
OUTLINE = (26, 18, 16, 255)     # #1A1210
SKIN_HI = (200, 192, 176, 255)  # #C8C0B0
SKIN_MID = (168, 152, 136, 255) # #A89888
SKIN_SHADOW = (112, 96, 88, 255)# #706058
SKIN_DEEP = (58, 42, 32, 255)   # #3A2A20
HAIR_DARK = (26, 26, 42, 255)   # #1A1A2A
HAIR_MID = (46, 46, 64, 255)    # #2E2E40
ROBE_HI = (142, 108, 72, 255)   # #8E6C48
ROBE_BASE = (122, 90, 58, 255)  # #7A5A3A
ROBE_SHADOW = (90, 62, 40, 255) # #5A3E28
BELT = (74, 46, 24, 255)        # #4A2E18
BOOK_COVER = (48, 32, 18, 255)
BOOK_PAGE = (210, 198, 168, 255)
BOOK_SPINE = (32, 20, 10, 255)
BOOK_CLASP = (140, 110, 50, 255)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def new_canvas() -> Image.Image:
    return Image.new("RGBA", (W, H), TRANSPARENT)


def px(img: Image.Image, x: int, y: int, colour: tuple[int, int, int, int]) -> None:
    if 0 <= x < W and 0 <= y < H:
        img.putpixel((x, y), colour)


def rect(img: Image.Image, x: int, y: int, w: int, h: int, colour: tuple[int, int, int, int]) -> None:
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            px(img, xx, yy, colour)


def hline(img: Image.Image, x: int, y: int, length: int, colour: tuple[int, int, int, int]) -> None:
    for i in range(length):
        px(img, x + i, y, colour)


def vline(img: Image.Image, x: int, y: int, length: int, colour: tuple[int, int, int, int]) -> None:
    for i in range(length):
        px(img, x, y + i, colour)


def fill_ellipse(
    img: Image.Image,
    cx: int,
    cy: int,
    rx: int,
    ry: int,
    colour: tuple[int, int, int, int],
) -> None:
    if rx <= 0 or ry <= 0:
        px(img, cx, cy, colour)
        return
    rx2 = rx * rx
    ry2 = ry * ry
    for y in range(cy - ry, cy + ry + 1):
        dy2 = (y - cy) * (y - cy)
        for x in range(cx - rx, cx + rx + 1):
            dx2 = (x - cx) * (x - cx)
            if dx2 * ry2 + dy2 * rx2 <= rx2 * ry2:
                px(img, x, y, colour)


def outline_ellipse(
    img: Image.Image,
    cx: int,
    cy: int,
    rx: int,
    ry: int,
    fill_colour: tuple[int, int, int, int],
    outline_colour: tuple[int, int, int, int] = OUTLINE,
) -> None:
    fill_ellipse(img, cx, cy, rx + 1, ry + 1, outline_colour)
    fill_ellipse(img, cx, cy, rx, ry, fill_colour)


def fill_tapered_column(
    img: Image.Image,
    y0: int,
    y1: int,
    c0: int,
    c1: int,
    w0: int,
    w1: int,
    fill_colour: tuple[int, int, int, int],
    outline_colour: tuple[int, int, int, int] = OUTLINE,
) -> None:
    if y1 <= y0:
        return
    span = max(1, y1 - y0)
    # Outline pass.
    for y in range(y0, y1 + 1):
        t = (y - y0) / span
        cx = round(c0 + (c1 - c0) * t)
        half = round((w0 + 1) + ((w1 + 1) - (w0 + 1)) * t)
        hline(img, cx - half, y, half * 2 + 1, outline_colour)
    # Fill pass.
    for y in range(y0, y1 + 1):
        t = (y - y0) / span
        cx = round(c0 + (c1 - c0) * t)
        half = round(w0 + (w1 - w0) * t)
        hline(img, cx - half, y, half * 2 + 1, fill_colour)


def stroke_segment(
    img: Image.Image,
    x0: int,
    y0: int,
    x1: int,
    y1: int,
    width: int,
    fill_colour: tuple[int, int, int, int],
    outline_colour: tuple[int, int, int, int] = OUTLINE,
) -> None:
    steps = max(abs(x1 - x0), abs(y1 - y0), 1)
    inner = max(1, width // 2)
    outer = inner + 1
    for i in range(steps + 1):
        x = round(x0 + (x1 - x0) * i / steps)
        y = round(y0 + (y1 - y0) * i / steps)
        fill_ellipse(img, x, y, outer, outer, outline_colour)
        fill_ellipse(img, x, y, inner, inner, fill_colour)


def stroke_polyline(
    img: Image.Image,
    points: list[tuple[int, int]],
    width: int,
    fill_colour: tuple[int, int, int, int],
    outline_colour: tuple[int, int, int, int] = OUTLINE,
) -> None:
    for a, b in zip(points, points[1:]):
        stroke_segment(img, a[0], a[1], b[0], b[1], width, fill_colour, outline_colour)


def foot(img: Image.Image, x: int, y: int, w: int, h: int, colour: tuple[int, int, int, int]) -> None:
    rect(img, x, y, w, h, colour)
    hline(img, x, y + h - 1, w, OUTLINE)
    for i in range(w):
        if i % 2 == 0:
            px(img, x + i, y - 1, colour)
            px(img, x + i, y + h, OUTLINE)


def hand(img: Image.Image, x: int, y: int, w: int, h: int, colour: tuple[int, int, int, int]) -> None:
    rect(img, x, y, w, h, colour)
    hline(img, x, y, w, OUTLINE)
    hline(img, x, y + h - 1, w, OUTLINE)
    for i in range(0, w, 2):
        px(img, x + i, y - 1, colour)
        px(img, x + i + 1, y - 2, OUTLINE)


def label_font() -> dict[str, list[str]]:
    return {
        "A": ["010", "101", "111", "101", "101"],
        "B": ["110", "101", "110", "101", "110"],
        "C": ["011", "100", "100", "100", "011"],
        "D": ["110", "101", "101", "101", "110"],
        "E": ["111", "100", "110", "100", "111"],
        "F": ["111", "100", "110", "100", "100"],
        "G": ["011", "100", "101", "101", "011"],
        "H": ["101", "101", "111", "101", "101"],
        "I": ["111", "010", "010", "010", "111"],
        "J": ["001", "001", "001", "101", "010"],
        "K": ["101", "101", "110", "101", "101"],
        "L": ["100", "100", "100", "100", "111"],
        "M": ["101", "111", "101", "101", "101"],
        "N": ["101", "111", "111", "101", "101"],
        "O": ["010", "101", "101", "101", "010"],
        "P": ["110", "101", "110", "100", "100"],
        "Q": ["010", "101", "101", "110", "011"],
        "R": ["110", "101", "110", "101", "101"],
        "S": ["011", "100", "010", "001", "110"],
        "T": ["111", "010", "010", "010", "010"],
        "U": ["101", "101", "101", "101", "010"],
        "V": ["101", "101", "101", "010", "010"],
        "W": ["101", "101", "101", "111", "101"],
        "X": ["101", "101", "010", "101", "101"],
        "Y": ["101", "010", "010", "010", "010"],
        "Z": ["111", "001", "010", "100", "111"],
        " ": ["000", "000", "000", "000", "000"],
    }


def draw_pixel_label(img: Image.Image, text: str, cx: int, y: int, scale: int) -> None:
    font = label_font()
    char_w = 4
    total_w = len(text) * char_w * scale
    sx = cx - total_w // 2
    for ci, ch in enumerate(text.upper()):
        glyph = font.get(ch, font[" "])
        bx = sx + ci * char_w * scale
        for row, bits in enumerate(glyph):
            for col, bit in enumerate(bits):
                if bit != "1":
                    continue
                for dy in range(scale):
                    for dx in range(scale):
                        px(img, bx + col * scale + dx, y + row * scale + dy, SKIN_HI)


def upscale(img: Image.Image) -> Image.Image:
    return img.resize((W * SCALE, H * SCALE), Image.NEAREST)


def save(img: Image.Image, name: str) -> Path:
    path = OUT_DIR / name
    upscale(img).save(path)
    return path


def pose_is_standing(pose: str) -> bool:
    return pose in {"present", "reach", "tug"}


# ---------------------------------------------------------------------------
# Pose-specific layer makers
# ---------------------------------------------------------------------------

def make_torso(pose: str = "present") -> Image.Image:
    img = new_canvas()
    if pose == "collapsed":
        fill_tapered_column(img, 90, 123, 62, 64, 8, 6, SKIN_MID)
        fill_ellipse(img, 60, 104, 12, 10, SKIN_SHADOW)
        fill_ellipse(img, 64, 102, 13, 11, OUTLINE)
        rect(img, 54, 108, 16, 8, SKIN_MID)
        px(img, 57, 107, SKIN_HI)
        px(img, 68, 107, SKIN_HI)
    elif pose == "crawl":
        fill_tapered_column(img, 78, 96, 62, 66, 16, 14, SKIN_MID)
        fill_tapered_column(img, 80, 98, 62, 66, 17, 15, OUTLINE)
        rect(img, 45, 82, 14, 8, SKIN_SHADOW)
        rect(img, 70, 82, 14, 8, SKIN_SHADOW)
        for y in range(82, 96, 3):
            px(img, 48, y, SKIN_SHADOW)
            px(img, 76, y, SKIN_SHADOW)
    elif pose == "climb":
        fill_tapered_column(img, 56, 104, 62, 64, 9, 8, SKIN_MID)
        fill_tapered_column(img, 58, 106, 62, 64, 10, 9, OUTLINE)
        px(img, 57, 64, SKIN_HI)
        px(img, 67, 82, SKIN_SHADOW)
        for y in range(62, 98, 6):
            px(img, 55, y, SKIN_SHADOW)
            px(img, 69, y, SKIN_SHADOW)
    else:
        top_y = 74 if pose == "present" else 73
        bottom_y = 104 if pose == "present" else (103 if pose == "reach" else 102)
        top_cx = 61 if pose == "present" else (63 if pose == "reach" else 60)
        bottom_cx = 62 if pose == "present" else (66 if pose == "reach" else 58)
        fill_tapered_column(img, top_y, bottom_y, top_cx, bottom_cx, 10, 7, SKIN_MID)
        fill_tapered_column(img, top_y + 1, bottom_y - 1, top_cx, bottom_cx, 9, 6, OUTLINE)
        # Collarbone, ribs, and shoulder blades.
        px(img, top_cx - 6, top_y + 6, SKIN_SHADOW)
        px(img, top_cx + 6, top_y + 6, SKIN_SHADOW)
        vline(img, top_cx - 5, top_y + 4, 14, SKIN_HI)
        px(img, top_cx + 4, top_y + 12, SKIN_SHADOW)
        px(img, top_cx + 5, top_y + 13, SKIN_SHADOW)
        hline(img, top_cx - 2, top_y + 1, 5, SKIN_HI)
        # Neck socket.
        px(img, top_cx, top_y, SKIN_HI)
        px(img, top_cx + 1, top_y, OUTLINE)
    return img


def make_robe_body(pose: str = "present") -> Image.Image:
    img = new_canvas()
    if pose == "collapsed":
        fill_tapered_column(img, 100, 120, 62, 64, 15, 13, ROBE_BASE)
        fill_tapered_column(img, 102, 121, 62, 64, 16, 14, OUTLINE)
        hline(img, 53, 110, 20, BELT)
        for x in range(54, 74, 3):
            px(img, x, 119, ROBE_SHADOW)
    elif pose == "crawl":
        fill_tapered_column(img, 84, 104, 61, 66, 18, 16, ROBE_BASE)
        fill_tapered_column(img, 86, 105, 61, 66, 19, 17, OUTLINE)
        rect(img, 47, 92, 18, 5, ROBE_SHADOW)
        rect(img, 70, 92, 14, 5, ROBE_SHADOW)
        hline(img, 50, 95, 28, BELT)
        vline(img, 53, 88, 12, ROBE_HI)
    elif pose == "climb":
        fill_tapered_column(img, 70, 112, 62, 65, 10, 8, ROBE_BASE)
        fill_tapered_column(img, 72, 113, 62, 65, 11, 9, OUTLINE)
        hline(img, 56, 86, 17, BELT)
        vline(img, 58, 72, 20, ROBE_HI)
        rect(img, 53, 100, 23, 9, ROBE_SHADOW)
    else:
        if pose == "present":
            fill_tapered_column(img, 98, 121, 62, 63, 11, 10, ROBE_BASE)
            fill_tapered_column(img, 100, 122, 62, 63, 12, 11, OUTLINE)
            rect(img, 53, 104, 20, 8, ROBE_SHADOW)
            hline(img, 54, 98, 17, BELT)
            vline(img, 56, 100, 15, ROBE_HI)
            for x in range(53, 73, 2):
                px(img, x, 119, ROBE_SHADOW)
                if x % 4 == 0:
                    px(img, x, 120, ROBE_BASE)
        elif pose == "reach":
            fill_tapered_column(img, 96, 120, 64, 68, 11, 9, ROBE_BASE)
            fill_tapered_column(img, 98, 121, 64, 68, 12, 10, OUTLINE)
            rect(img, 55, 101, 22, 10, ROBE_SHADOW)
            hline(img, 56, 97, 18, BELT)
            vline(img, 58, 99, 14, ROBE_HI)
            for x in range(55, 75, 2):
                px(img, x, 120, ROBE_SHADOW)
        else:  # tug
            fill_tapered_column(img, 97, 121, 60, 60, 11, 10, ROBE_BASE)
            fill_tapered_column(img, 99, 122, 60, 60, 12, 11, OUTLINE)
            rect(img, 53, 101, 18, 11, ROBE_SHADOW)
            hline(img, 54, 98, 16, BELT)
            vline(img, 56, 99, 13, ROBE_HI)
            for x in range(54, 72, 2):
                px(img, x, 119, ROBE_SHADOW)
    return img


def make_neck(pose: str = "present") -> Image.Image:
    img = new_canvas()
    if pose == "collapsed":
        rect(img, 60, 94, 6, 8, SKIN_MID)
        px(img, 60, 94, OUTLINE)
        px(img, 65, 94, OUTLINE)
        px(img, 60, 101, OUTLINE)
        px(img, 65, 101, OUTLINE)
    elif pose == "crawl":
        stroke_segment(img, 65, 80, 61, 88, 4, SKIN_MID)
    elif pose == "climb":
        stroke_segment(img, 63, 58, 63, 68, 4, SKIN_MID)
    else:
        if pose == "present":
            rect(img, 60, 66, 6, 10, SKIN_MID)
            px(img, 61, 67, SKIN_HI)
            px(img, 60, 66, OUTLINE)
            px(img, 65, 66, OUTLINE)
            px(img, 60, 75, OUTLINE)
            px(img, 65, 75, OUTLINE)
        elif pose == "reach":
            rect(img, 61, 66, 6, 9, SKIN_MID)
            px(img, 62, 67, SKIN_HI)
            px(img, 61, 66, OUTLINE)
            px(img, 66, 66, OUTLINE)
            px(img, 61, 74, OUTLINE)
            px(img, 66, 74, OUTLINE)
        else:  # tug
            rect(img, 59, 67, 6, 9, SKIN_MID)
            px(img, 60, 68, SKIN_HI)
            px(img, 59, 67, OUTLINE)
            px(img, 64, 67, OUTLINE)
            px(img, 59, 75, OUTLINE)
            px(img, 64, 75, OUTLINE)
    return img


def make_head(pose: str = "present") -> Image.Image:
    img = new_canvas()
    if pose == "collapsed":
        outline_ellipse(img, 63, 88, 11, 10, SKIN_MID)
        rect(img, 54, 88, 18, 10, SKIN_SHADOW)
        px(img, 59, 86, SKIN_HI)
        px(img, 67, 86, SKIN_HI)
    elif pose == "crawl":
        outline_ellipse(img, 64, 85, 10, 12, SKIN_MID)
        rect(img, 56, 89, 18, 10, SKIN_SHADOW)
        hline(img, 58, 84, 9, SKIN_HI)
        px(img, 66, 91, SKIN_DEEP)
        px(img, 69, 92, SKIN_DEEP)
        px(img, 70, 90, SKIN_SHADOW)
    elif pose == "climb":
        outline_ellipse(img, 64, 45, 10, 12, SKIN_MID)
        rect(img, 56, 49, 18, 8, SKIN_SHADOW)
        hline(img, 58, 40, 9, SKIN_HI)
        px(img, 66, 49, SKIN_DEEP)
        px(img, 69, 48, SKIN_DEEP)
        px(img, 70, 49, SKIN_SHADOW)
        hline(img, 67, 56, 5, SKIN_DEEP)
    else:
        if pose == "present":
            outline_ellipse(img, 64, 46, 10, 13, SKIN_MID)
            rect(img, 56, 50, 17, 10, SKIN_SHADOW)
            hline(img, 58, 38, 8, SKIN_HI)
            # Right-facing profile. One hollow eye socket, thin nose, slack mouth.
            rect(img, 66, 44, 2, 3, SKIN_DEEP)
            px(img, 67, 45, OUTLINE)
            px(img, 69, 47, SKIN_SHADOW)
            px(img, 70, 48, OUTLINE)
            px(img, 68, 52, SKIN_DEEP)
            hline(img, 66, 54, 4, SKIN_DEEP)
        elif pose == "reach":
            outline_ellipse(img, 64, 48, 10, 13, SKIN_MID)
            rect(img, 56, 52, 17, 10, SKIN_SHADOW)
            hline(img, 59, 40, 8, SKIN_HI)
            rect(img, 66, 45, 2, 3, SKIN_DEEP)
            px(img, 67, 46, OUTLINE)
            px(img, 69, 48, SKIN_SHADOW)
            px(img, 70, 49, OUTLINE)
            px(img, 68, 53, SKIN_SHADOW)
            hline(img, 66, 55, 4, SKIN_DEEP)
        else:  # tug
            outline_ellipse(img, 64, 47, 10, 13, SKIN_MID)
            rect(img, 56, 51, 17, 10, SKIN_SHADOW)
            hline(img, 58, 39, 8, SKIN_HI)
            rect(img, 66, 44, 2, 3, SKIN_DEEP)
            px(img, 67, 45, OUTLINE)
            px(img, 69, 47, SKIN_SHADOW)
            px(img, 70, 48, OUTLINE)
            px(img, 68, 52, SKIN_SHADOW)
            hline(img, 66, 55, 4, SKIN_DEEP)
    return img


def make_hair_back(pose: str = "present") -> Image.Image:
    img = new_canvas()
    if pose == "collapsed":
        for x in range(51, 75, 2):
            stroke_segment(img, x, 84, x - 2, 122, 3, HAIR_DARK)
        for x in range(54, 72, 3):
            stroke_segment(img, x, 86, x, 112, 2, HAIR_MID)
        for x in range(46, 81, 1):
            px(img, x, 91 + abs(x - 63) // 3, HAIR_DARK)
    elif pose == "crawl":
        for x in range(54, 73, 2):
            stroke_segment(img, x, 82, x, 110, 3, HAIR_DARK)
        for x in range(55, 71, 3):
            stroke_segment(img, x, 84, x, 102, 2, HAIR_MID)
    elif pose == "climb":
        for x in range(52, 69, 2):
            stroke_segment(img, x, 40, x, 96, 3, HAIR_DARK)
        for x in range(55, 67, 3):
            stroke_segment(img, x, 42, x, 82, 2, HAIR_MID)
    else:
        if pose == "present":
            # Hair pulled back. Keep face readable; hair sits behind shoulders.
            for x in range(49, 56, 2):
                stroke_segment(img, x, 38, x - 2, 108, 3, HAIR_DARK)
            for x in range(69, 75, 2):
                stroke_segment(img, x, 38, x, 106, 3, HAIR_DARK)
            for x in range(52, 58, 2):
                stroke_segment(img, x, 40, x - 1, 78, 2, HAIR_MID)
            for x in range(67, 72, 2):
                stroke_segment(img, x, 40, x + 1, 84, 2, HAIR_MID)
        elif pose == "reach":
            for x in range(49, 56, 2):
                stroke_segment(img, x, 40, x - 1, 104, 3, HAIR_DARK)
            for x in range(68, 74, 2):
                stroke_segment(img, x, 38, x, 100, 3, HAIR_DARK)
            for x in range(54, 58, 2):
                stroke_segment(img, x, 42, x - 1, 76, 2, HAIR_MID)
            for x in range(66, 71, 2):
                stroke_segment(img, x, 42, x + 1, 80, 2, HAIR_MID)
        else:  # tug
            for x in range(49, 56, 2):
                stroke_segment(img, x, 42, x - 2, 100, 3, HAIR_DARK)
            for x in range(68, 74, 2):
                stroke_segment(img, x, 40, x, 102, 3, HAIR_DARK)
            for x in range(54, 58, 2):
                stroke_segment(img, x, 44, x - 1, 76, 2, HAIR_MID)
            for x in range(66, 71, 2):
                stroke_segment(img, x, 44, x + 1, 82, 2, HAIR_MID)
    return img


def make_hair_front(pose: str = "present") -> Image.Image:
    img = new_canvas()
    if pose == "collapsed":
        for x in range(56, 74, 2):
            stroke_segment(img, x, 86, x + 1, 124, 3, HAIR_DARK)
        for x in range(58, 70, 3):
            px(img, x, 90, HAIR_MID)
            px(img, x + 1, 95, HAIR_MID)
    elif pose == "crawl":
        for x in range(55, 72, 2):
            stroke_segment(img, x, 84, x + 1, 112, 3, HAIR_DARK)
        for x in range(57, 69, 4):
            px(img, x, 90, HAIR_MID)
    elif pose == "climb":
        # Hair mostly pushed back on the raised-arm side.
        for x in range(60, 67, 2):
            stroke_segment(img, x, 42, x + 3, 66, 2, HAIR_DARK)
        for x in range(58, 64, 3):
            px(img, x, 47, HAIR_MID)
    else:
        if pose == "present":
            # Hair pulled back behind shoulders. Keep profile readable.
            stroke_segment(img, 49, 38, 52, 108, 3, HAIR_DARK)
            stroke_segment(img, 52, 40, 55, 102, 2, HAIR_MID)
            stroke_segment(img, 69, 38, 72, 84, 2, HAIR_DARK)
            px(img, 54, 42, HAIR_MID)
            px(img, 69, 44, HAIR_MID)
        elif pose == "reach":
            stroke_segment(img, 49, 40, 53, 106, 3, HAIR_DARK)
            stroke_segment(img, 52, 42, 55, 98, 2, HAIR_MID)
            stroke_segment(img, 70, 40, 72, 82, 2, HAIR_DARK)
            for x in range(55, 62, 3):
                px(img, x, 46, HAIR_MID)
                px(img, x, 51, HAIR_MID)
        else:  # tug
            stroke_segment(img, 49, 41, 53, 104, 3, HAIR_DARK)
            stroke_segment(img, 52, 43, 55, 96, 2, HAIR_MID)
            stroke_segment(img, 70, 40, 72, 84, 2, HAIR_DARK)
            for x in range(55, 62, 3):
                px(img, x, 47, HAIR_MID)
                px(img, x, 53, HAIR_MID)
    return img


def make_back_arm(pose: str = "present") -> Image.Image:
    img = new_canvas()
    skin = SKIN_MID
    if pose == "collapsed":
        stroke_polyline(img, [(53, 109), (47, 124), (53, 133)], 4, skin)
        hand(img, 49, 130, 8, 5, skin)
        for i in range(5):
            px(img, 47 + i * 2, 129 + i // 2, skin)
    elif pose == "crawl":
        stroke_polyline(img, [(56, 86), (39, 100), (24, 108)], 4, skin)
        hand(img, 16, 106, 10, 6, skin)
        for i in range(5):
            px(img, 16 + i * 2, 105, skin)
    elif pose == "climb":
        stroke_polyline(img, [(58, 72), (68, 52), (76, 28)], 4, skin)
        hand(img, 72, 20, 8, 7, skin)
        for i in range(4):
            px(img, 74 + i, 19, skin)
    elif pose == "reach":
        stroke_polyline(img, [(56, 79), (42, 86), (26, 92)], 4, skin)
        hand(img, 18, 90, 9, 6, skin)
        for i in range(5):
            px(img, 18 + i * 2, 89 + (i % 2), skin)
    elif pose == "tug":
        stroke_polyline(img, [(56, 80), (46, 93), (36, 100)], 4, skin)
        hand(img, 30, 98, 9, 6, skin)
        for i in range(5):
            px(img, 31 + i * 2, 97 + (i % 2), skin)
    else:  # present
        stroke_polyline(img, [(56, 80), (43, 90), (30, 96)], 4, skin)
        hand(img, 24, 94, 10, 6, skin)
        for i in range(5):
            px(img, 24 + i * 2, 93 + (i % 2), skin)
    return img


def make_front_arm(pose: str = "present") -> Image.Image:
    img = new_canvas()
    skin = SKIN_HI
    if pose == "collapsed":
        stroke_polyline(img, [(67, 110), (74, 120), (71, 132)], 4, skin)
        hand(img, 69, 130, 9, 5, skin)
        for i in range(5):
            px(img, 70 + i * 2, 129 + i // 2, skin)
    elif pose == "crawl":
        stroke_polyline(img, [(66, 86), (84, 100), (98, 108)], 4, skin)
        hand(img, 100, 106, 10, 6, skin)
        for i in range(5):
            px(img, 100 + i * 2, 105, skin)
    elif pose == "climb":
        stroke_polyline(img, [(66, 76), (74, 95), (80, 108)], 4, skin)
        hand(img, 76, 106, 9, 6, skin)
        for i in range(4):
            px(img, 77 + i * 2, 105, skin)
    elif pose == "reach":
        stroke_polyline(img, [(67, 78), (88, 86), (104, 90)], 4, skin)
        hand(img, 104, 88, 10, 6, skin)
        for i in range(5):
            px(img, 104 + i, 87 + (i % 2), skin)
    elif pose == "tug":
        stroke_polyline(img, [(67, 80), (84, 88), (98, 90)], 4, skin)
        hand(img, 97, 88, 10, 6, skin)
        for i in range(5):
            px(img, 97 + i, 87 + (i % 2), skin)
    else:  # present
        stroke_polyline(img, [(67, 78), (83, 88), (100, 92)], 4, skin)
        hand(img, 99, 90, 10, 6, skin)
        for i in range(5):
            px(img, 99 + i, 89 + (i % 2), skin)
    return img


def make_back_leg(pose: str = "present") -> Image.Image:
    img = new_canvas()
    skin = SKIN_SHADOW
    if pose == "collapsed":
        stroke_polyline(img, [(58, 112), (49, 126), (54, 145)], 4, skin)
        foot(img, 52, 146, 12, 5, skin)
    elif pose == "crawl":
        stroke_polyline(img, [(59, 95), (54, 114), (57, 132)], 4, skin)
        foot(img, 54, 132, 12, 5, skin)
        rect(img, 52, 112, 5, 4, SKIN_MID)
    elif pose == "climb":
        stroke_polyline(img, [(60, 96), (63, 122), (63, 148)], 4, skin)
        foot(img, 61, 148, 9, 5, skin)
        rect(img, 59, 121, 5, 4, SKIN_MID)
    elif pose == "reach":
        stroke_polyline(img, [(59, 111), (56, 132), (58, 151)], 4, skin)
        foot(img, 54, 150, 12, 5, skin)
        rect(img, 55, 133, 5, 4, SKIN_MID)
    elif pose == "tug":
        stroke_polyline(img, [(58, 110), (55, 134), (56, 152)], 4, skin)
        foot(img, 52, 150, 12, 5, skin)
        rect(img, 54, 134, 5, 4, SKIN_MID)
    else:
        stroke_polyline(img, [(58, 110), (55, 134), (57, 152)], 4, skin)
        foot(img, 53, 150, 12, 5, skin)
        rect(img, 54, 134, 5, 4, SKIN_MID)
    return img


def make_front_leg(pose: str = "present") -> Image.Image:
    img = new_canvas()
    skin = SKIN_MID
    if pose == "collapsed":
        stroke_polyline(img, [(66, 113), (74, 126), (70, 146)], 4, skin)
        foot(img, 67, 146, 12, 5, skin)
    elif pose == "crawl":
        stroke_polyline(img, [(67, 95), (75, 116), (71, 135)], 4, skin)
        foot(img, 65, 134, 12, 5, skin)
        rect(img, 69, 113, 5, 4, SKIN_HI)
    elif pose == "climb":
        stroke_polyline(img, [(66, 98), (73, 76), (78, 94)], 5, skin)
        foot(img, 72, 94, 12, 5, skin)
        rect(img, 70, 74, 5, 4, SKIN_HI)
    elif pose == "reach":
        stroke_polyline(img, [(68, 112), (73, 136), (73, 153)], 4, skin)
        foot(img, 68, 151, 13, 5, skin)
        rect(img, 70, 134, 5, 4, SKIN_HI)
    elif pose == "tug":
        stroke_polyline(img, [(68, 112), (74, 136), (76, 152)], 4, skin)
        foot(img, 70, 150, 13, 5, skin)
        rect(img, 70, 134, 5, 4, SKIN_HI)
    else:
        stroke_polyline(img, [(68, 112), (71, 136), (71, 153)], 4, skin)
        foot(img, 65, 150, 13, 5, skin)
        rect(img, 68, 134, 5, 4, SKIN_HI)
    return img


def make_held_object(pose: str = "present") -> Image.Image:
    img = new_canvas()
    if pose != "present":
        return img
    rect(img, 92, 88, 26, 18, BOOK_COVER)
    rect(img, 114, 90, 6, 14, BOOK_PAGE)
    for y in range(91, 103, 2):
        px(img, 114, y, BOOK_SPINE)
    vline(img, 94, 90, 14, (72, 50, 28, 255))
    px(img, 92, 88, BOOK_CLASP)
    px(img, 117, 88, BOOK_CLASP)
    px(img, 92, 105, BOOK_CLASP)
    px(img, 117, 105, BOOK_CLASP)
    hline(img, 92, 88, 26, OUTLINE)
    hline(img, 92, 105, 26, OUTLINE)
    vline(img, 92, 89, 16, OUTLINE)
    vline(img, 117, 89, 16, OUTLINE)
    return img


# ---------------------------------------------------------------------------
# Composition
# ---------------------------------------------------------------------------

LAYER_ORDER = [
    "hair_back",
    "back_arm",
    "back_leg",
    "robe_body",
    "torso",
    "front_leg",
    "front_arm",
    "neck",
    "head",
    "hair_front",
    "held_object",
]

LAYER_MAKERS = {
    "torso": make_torso,
    "robe_body": make_robe_body,
    "neck": make_neck,
    "head": make_head,
    "hair_back": make_hair_back,
    "hair_front": make_hair_front,
    "back_arm": make_back_arm,
    "front_arm": make_front_arm,
    "back_leg": make_back_leg,
    "front_leg": make_front_leg,
    "held_object": make_held_object,
}

POSES = ["collapsed", "crawl", "climb", "reach", "tug", "present"]
POSE_LABELS = {
    "collapsed": "COLLAPSED",
    "crawl": "CRAWLING",
    "climb": "CLIMBING",
    "reach": "REACHING",
    "tug": "TUGGING",
    "present": "PRESENTING",
}


def compose_pose(pose: str) -> Image.Image:
    base = new_canvas()
    for layer_name in LAYER_ORDER:
        base = Image.alpha_composite(base, LAYER_MAKERS[layer_name](pose))
    return base


# ---------------------------------------------------------------------------
# Exporters
# ---------------------------------------------------------------------------

def generate_layers(pose: str = "present") -> None:
    pose_dir = OUT_DIR / f"layers_{pose}"
    pose_dir.mkdir(parents=True, exist_ok=True)
    for layer_name, maker in LAYER_MAKERS.items():
        img = maker(pose)
        upscale(img).save(pose_dir / f"{layer_name}.png")
    print(f"  Layers saved -> {pose_dir}")


def generate_pose_frames() -> list[Path]:
    paths: list[Path] = []
    for pose in POSES:
        char = compose_pose(pose)
        path = OUT_DIR / f"pose_{pose}.png"
        upscale(char).save(path)
        paths.append(path)
        print(f"  Pose frame saved -> {path.name}")
    return paths


def generate_spritesheet() -> Path:
    label_h = 12
    sheet_w = W * len(POSES)
    sheet_h = H + label_h
    sheet = Image.new("RGBA", (sheet_w * SCALE, sheet_h * SCALE), (58, 48, 40, 255))
    for i, pose in enumerate(POSES):
        char = upscale(compose_pose(pose))
        x_off = i * W * SCALE
        sheet.paste(char, (x_off, 0), char)
        draw_pixel_label(sheet, POSE_LABELS[pose], x_off + (W * SCALE // 2), H * SCALE + 4, SCALE)
    path = OUT_DIR / "tome_thrall_spritesheet.png"
    sheet.save(path)
    return path


def generate_animated_gif() -> Path:
    frames: list[Image.Image] = []
    for pose in POSES:
        char = compose_pose(pose)
        bg = Image.new("RGBA", (W, H), (58, 48, 40, 255))
        bg = Image.alpha_composite(bg, char)
        frames.append(bg.resize((W * SCALE, H * SCALE), Image.NEAREST).convert("RGB"))
    path = OUT_DIR / "tome_thrall_preview.gif"
    frames[0].save(
        path,
        save_all=True,
        append_images=frames[1:],
        duration=600,
        loop=0,
        optimize=False,
    )
    return path


def main() -> None:
    print("Tome Thrall Generator v2 - starting...")
    print(f"Output directory: {OUT_DIR}\n")

    print("[1/4] Generating individual layer PNGs (present pose)...")
    generate_layers("present")

    print("[2/4] Generating pose frame PNGs...")
    generate_pose_frames()

    print("[3/4] Generating spritesheet...")
    sheet_path = generate_spritesheet()
    print(f"  Spritesheet saved -> {sheet_path}")

    print("[4/4] Generating preview GIF...")
    gif_path = generate_animated_gif()
    print(f"  Preview GIF saved -> {gif_path}")

    print("\nDone. Files in:", OUT_DIR)


if __name__ == "__main__":
    main()

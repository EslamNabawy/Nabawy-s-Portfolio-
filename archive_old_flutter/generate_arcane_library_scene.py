"""
Arcane Library scene generator.

Creates a low-res pixel-art background for the homepage hero based on the
environment description:
- 384x216 base resolution
- nearest-neighbor upscale
- central bookshelf wall
- left stained-glass window and desk
- right torch wall and reading stand
- center rug, chest, and floor clock

The goal is a readable, atmospheric main screen rather than fine illustration.
"""

from __future__ import annotations

from pathlib import Path
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "portfolio_site" / "public" / "scene-assets"
OUT_DIR.mkdir(parents=True, exist_ok=True)

W, H = 384, 216
SCALE = 4

PAL = {
    "ink": (8, 8, 10, 255),
    "ceiling": (38, 24, 10, 255),
    "beam": (58, 40, 16, 255),
    "wall": (62, 68, 86, 255),
    "wall_shadow": (42, 46, 58, 255),
    "wall_hi": (86, 92, 114, 255),
    "book_dark": (58, 36, 16, 255),
    "book_base": (90, 58, 30, 255),
    "book_hi": (126, 84, 50, 255),
    "book_rust": (114, 50, 38, 255),
    "book_green": (48, 84, 54, 255),
    "book_cream": (188, 172, 132, 255),
    "wood_dark": (36, 22, 12, 255),
    "wood_base": (74, 46, 24, 255),
    "wood_hi": (106, 70, 38, 255),
    "floor": (58, 52, 48, 255),
    "floor_2": (42, 36, 32, 255),
    "rug_dark": (10, 18, 40, 255),
    "rug_blue": (28, 44, 76, 255),
    "rug_gold": (174, 134, 44, 255),
    "rug_cream": (214, 204, 168, 255),
    "window_navy": (12, 24, 58, 255),
    "window_glow": (196, 220, 255, 255),
    "window_line": (40, 76, 148, 255),
    "torch_flame": (252, 180, 54, 255),
    "torch_core": (255, 238, 194, 255),
    "torch_glow": (182, 102, 36, 255),
    "stone": (74, 82, 96, 255),
    "stone_dark": (46, 52, 64, 255),
    "stone_hi": (96, 106, 122, 255),
    "skin": (168, 152, 136, 255),
    "skin_hi": (200, 192, 176, 255),
    "shadow_skin": (112, 96, 88, 255),
    "parchment": (210, 196, 168, 255),
    "blue_glow": (96, 180, 220, 255),
    "purple": (110, 90, 152, 255),
    "red": (150, 72, 56, 255),
    "green": (88, 120, 78, 255),
    "amber": (174, 120, 50, 255),
}


def new_canvas() -> Image.Image:
    return Image.new("RGBA", (W, H), PAL["ink"])


def px(img: Image.Image, x: int, y: int, color: tuple[int, int, int, int]) -> None:
    if 0 <= x < W and 0 <= y < H:
        img.putpixel((x, y), color)


def rect(img: Image.Image, x: int, y: int, w: int, h: int, color) -> None:
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            px(img, xx, yy, color)


def hline(img: Image.Image, x: int, y: int, w: int, color) -> None:
    for i in range(w):
        px(img, x + i, y, color)


def vline(img: Image.Image, x: int, y: int, h: int, color) -> None:
    for i in range(h):
        px(img, x, y + i, color)


def fill_ellipse(img: Image.Image, cx: int, cy: int, rx: int, ry: int, color) -> None:
    rx2 = rx * rx
    ry2 = ry * ry
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            dx2 = (x - cx) * (x - cx)
            dy2 = (y - cy) * (y - cy)
            if dx2 * ry2 + dy2 * rx2 <= rx2 * ry2:
                px(img, x, y, color)


def outline_ellipse(img: Image.Image, cx: int, cy: int, rx: int, ry: int, fill, outline=PAL["wood_dark"]) -> None:
    fill_ellipse(img, cx, cy, rx + 1, ry + 1, outline)
    fill_ellipse(img, cx, cy, rx, ry, fill)


def draw_shelf_band(img: Image.Image, x: int, y: int, w: int, h: int) -> None:
    rect(img, x, y, w, h, PAL["wood_base"])
    hline(img, x, y, w, PAL["wood_hi"])
    hline(img, x, y + h - 1, w, PAL["wood_dark"])
    for yy in range(y + 4, y + h - 1, 3):
        hline(img, x + 1, yy, w - 2, PAL["wood_dark"])


def draw_book_spine(img: Image.Image, x: int, y: int, w: int, h: int, color, edge=None):
    edge = edge or PAL["wood_dark"]
    rect(img, x, y, w, h, color)
    vline(img, x, y, h, edge)
    vline(img, x + w - 1, y, h, edge)
    hline(img, x, y, w, edge)
    hline(img, x, y + h - 1, w, edge)
    if w >= 4:
        px(img, x + 1, y + 1, PAL["book_hi"])


def draw_window(img: Image.Image) -> None:
    # Stone wall panel.
    rect(img, 8, 28, 68, 130, PAL["wall_shadow"])
    rect(img, 10, 30, 64, 126, PAL["wall"])
    for y in range(34, 146, 16):
        hline(img, 12, y, 60, PAL["wall_hi"])
    # Gothic arch.
    fill_ellipse(img, 42, 70, 22, 34, PAL["window_navy"])
    rect(img, 20, 70, 44, 58, PAL["window_navy"])
    fill_ellipse(img, 30, 72, 8, 26, PAL["window_navy"])
    fill_ellipse(img, 54, 72, 8, 26, PAL["window_navy"])
    # Tracery.
    vline(img, 42, 42, 82, PAL["window_line"])
    hline(img, 24, 64, 36, PAL["window_line"])
    hline(img, 20, 52, 44, PAL["window_line"])
    for dx in (-12, 12):
        for i in range(12):
            px(img, 42 + dx // 2 + i // 2, 46 + i, PAL["window_line"])
    # Constellation lines / stars.
    stars = [(30, 60), (36, 54), (46, 62), (55, 49), (58, 70), (28, 82), (47, 86)]
    for sx, sy in stars:
        px(img, sx, sy, PAL["window_glow"])
        px(img, sx + 1, sy, PAL["window_glow"])
    for a, b in zip(stars, stars[1:]):
        x0, y0 = a
        x1, y1 = b
        steps = max(abs(x1 - x0), abs(y1 - y0), 1)
        for i in range(steps + 1):
            x = round(x0 + (x1 - x0) * i / steps)
            y = round(y0 + (y1 - y0) * i / steps)
            px(img, x, y, PAL["window_line"])


def draw_desk(img: Image.Image) -> None:
    # Desk under window.
    rect(img, 18, 124, 58, 18, PAL["wood_base"])
    rect(img, 22, 138, 50, 8, PAL["wood_dark"])
    vline(img, 24, 140, 24, PAL["wood_base"])
    vline(img, 66, 140, 24, PAL["wood_base"])
    hline(img, 18, 124, 58, PAL["wood_hi"])
    # Quill, crystal, scrolls.
    vline(img, 28, 104, 22, PAL["rug_cream"])
    px(img, 28, 103, PAL["rug_cream"])
    px(img, 29, 103, PAL["rug_cream"])
    fill_ellipse(img, 40, 118, 6, 8, PAL["blue_glow"])
    fill_ellipse(img, 40, 118, 4, 6, PAL["window_glow"])
    rect(img, 48, 118, 8, 4, PAL["parchment"])
    rect(img, 58, 120, 9, 3, PAL["parchment"])
    rect(img, 70, 122, 4, 2, PAL["red"])


def draw_bookshelf(img: Image.Image) -> None:
    x0, y0 = 108, 26
    w, h = 180, 150
    # Main frame.
    rect(img, x0, y0, w, h, PAL["wood_dark"])
    rect(img, x0 + 4, y0 + 4, w - 8, h - 8, PAL["wood_base"])
    # Vertical dividers.
    rect(img, x0 + 58, y0 + 4, 8, h - 8, PAL["wood_dark"])
    rect(img, x0 + 116, y0 + 4, 8, h - 8, PAL["wood_dark"])
    # Shelf rows.
    shelf_ys = [44, 72, 100, 128, 156]
    for sy in shelf_ys:
        draw_shelf_band(img, x0 + 4, sy, w - 8, 4)

    # Left column books and crystal.
    left_x = x0 + 10
    for i, bx in enumerate(range(left_x, left_x + 46, 7)):
        draw_book_spine(img, bx, 30, 5, 14 + (i % 3) * 2, [PAL["book_rust"], PAL["book_green"], PAL["book_base"], PAL["book_cream"]][i % 4])
    for i, bx in enumerate(range(left_x + 2, left_x + 44, 8)):
        draw_book_spine(img, bx, 58, 5, 12 + (i % 2) * 3, [PAL["book_green"], PAL["book_rust"], PAL["book_base"]][i % 3])
    fill_ellipse(img, x0 + 38, 80, 12, 10, PAL["purple"])
    fill_ellipse(img, x0 + 40, 78, 10, 8, PAL["window_glow"])
    for dx, dy in [(-8, 0), (-4, -3), (2, -2), (8, 1), (0, 4)]:
        px(img, x0 + 40 + dx, 80 + dy, PAL["window_glow"])
    for y in [108, 112, 116, 120, 124, 128]:
        draw_book_spine(img, x0 + 10 + (y % 4) * 4, y, 5, 12, PAL["book_rust" if y % 2 else "book_green"])

    # Center column detailed clutter.
    for i, bx in enumerate(range(x0 + 70, x0 + 110, 7)):
        draw_book_spine(img, bx, 32, 5, 16 + (i % 2) * 2, [PAL["book_base"], PAL["book_rust"], PAL["book_green"]][i % 3])
    # Parchment map.
    rect(img, x0 + 84, 34, 26, 10, PAL["parchment"])
    hline(img, x0 + 84, 34, 26, PAL["wood_dark"])
    # Hourglass.
    rect(img, x0 + 86, 58, 14, 18, PAL["wood_dark"])
    rect(img, x0 + 88, 60, 10, 14, PAL["parchment"])
    for yy in range(62, 72):
        px(img, x0 + 93, yy, PAL["rug_gold"])
    # Potion bottles.
    rect(img, x0 + 104, 58, 6, 12, PAL["blue_glow"])
    rect(img, x0 + 111, 56, 5, 14, PAL["green"])
    rect(img, x0 + 118, 59, 5, 11, PAL["purple"])
    rect(img, x0 + 105, 86, 5, 12, PAL["green"])
    rect(img, x0 + 112, 84, 5, 14, PAL["purple"])
    rect(img, x0 + 119, 86, 5, 12, PAL["amber"])
    # Open grimoire and gears.
    rect(img, x0 + 74, 113, 22, 8, PAL["parchment"])
    hline(img, x0 + 74, 113, 22, PAL["wood_dark"])
    hline(img, x0 + 74, 120, 22, PAL["wood_dark"])
    for cx, cy, r in [(x0 + 108, 118, 5), (x0 + 117, 114, 4), (x0 + 123, 121, 4)]:
        fill_ellipse(img, cx, cy, r, r, PAL["rug_gold"])
        fill_ellipse(img, cx, cy, r - 2, r - 2, PAL["wood_base"])

    # Right column books and decor.
    for i, bx in enumerate(range(x0 + 126, x0 + 168, 7)):
        draw_book_spine(img, bx, 32, 5, 12 + (i % 3) * 3, [PAL["book_rust"], PAL["book_base"], PAL["book_green"], PAL["book_cream"]][i % 4])
    rect(img, x0 + 144, 54, 14, 6, PAL["book_rust"])
    fill_ellipse(img, x0 + 154, 78, 8, 8, PAL["wood_base"])
    fill_ellipse(img, x0 + 154, 78, 6, 6, PAL["blue_glow"])
    for y in range(104, 132, 7):
        draw_book_spine(img, x0 + 128 + ((y // 7) % 3) * 5, y, 5, 10, PAL["book_base"])
    for i in range(4):
        px(img, x0 + 158 + i, 116 + i, PAL["rug_cream"])
    # Skull on far right.
    outline_ellipse(img, x0 + 164, 126, 8, 8, PAL["book_cream"])
    px(img, x0 + 161, 125, PAL["wood_dark"])
    px(img, x0 + 167, 125, PAL["wood_dark"])

    # Top crest.
    rect(img, x0 + 62, 8, 56, 12, PAL["wood_base"])
    fill_ellipse(img, x0 + 70, 12, 10, 8, PAL["red"])
    fill_ellipse(img, x0 + 107, 12, 10, 8, PAL["book_cream"])
    fill_ellipse(img, x0 + 89, 12, 9, 7, PAL["rug_gold"])
    px(img, x0 + 89, 12, PAL["wood_dark"])


def draw_right_side(img: Image.Image) -> None:
    # Wall and torches.
    rect(img, 294, 26, 82, 130, PAL["wall_shadow"])
    rect(img, 298, 30, 76, 126, PAL["wall"])
    for y in range(34, 148, 18):
        hline(img, 300, y, 72, PAL["wall_hi"])
    # Torches.
    for tx, ty in [(334, 54), (354, 74)]:
        rect(img, tx - 1, ty, 2, 20, PAL["wood_dark"])
        fill_ellipse(img, tx, ty - 3, 6, 10, PAL["torch_glow"])
        fill_ellipse(img, tx, ty - 7, 4, 8, PAL["torch_flame"])
        px(img, tx, ty - 10, PAL["torch_core"])

    # Reading stand.
    rect(img, 326, 126, 42, 6, PAL["wood_base"])
    rect(img, 340, 94, 16, 36, PAL["wood_dark"])
    rect(img, 316, 88, 44, 18, PAL["wood_base"])
    hline(img, 316, 88, 44, PAL["wood_hi"])
    rect(img, 322, 92, 32, 10, PAL["parchment"])
    # Glasses / vials.
    fill_ellipse(img, 352, 120, 5, 3, PAL["blue_glow"])
    rect(img, 364, 118, 3, 7, PAL["purple"])


def draw_floor_and_rug(img: Image.Image) -> None:
    rect(img, 0, 156, W, 60, PAL["floor"])
    for y in range(156, 216, 12):
        hline(img, 0, y, W, PAL["floor_2"])
    for x in range(0, W, 24):
        vline(img, x, 156, 60, PAL["floor_2"])

    # Rug.
    rect(img, 92, 144, 200, 50, PAL["rug_dark"])
    rect(img, 96, 148, 192, 42, PAL["rug_blue"])
    for i in range(0, 192, 12):
        hline(img, 100 + i, 150 + (i % 24) // 12, 6, PAL["rug_gold"])
        hline(img, 100 + i, 186 - (i % 24) // 12, 6, PAL["rug_gold"])
    fill_ellipse(img, 190, 171, 24, 14, PAL["rug_dark"])
    fill_ellipse(img, 190, 171, 18, 10, PAL["rug_blue"])
    fill_ellipse(img, 190, 171, 7, 7, PAL["rug_gold"])
    hline(img, 160, 171, 60, PAL["rug_cream"])
    vline(img, 190, 156, 30, PAL["rug_cream"])

    # Chest and clock.
    rect(img, 166, 150, 34, 20, PAL["wood_base"])
    rect(img, 168, 146, 30, 8, PAL["wood_dark"])
    hline(img, 166, 150, 34, PAL["wood_hi"])
    rect(img, 204, 154, 10, 14, PAL["wood_dark"])
    fill_ellipse(img, 220, 160, 7, 7, PAL["wood_base"])
    fill_ellipse(img, 220, 160, 5, 5, PAL["rug_cream"])
    px(img, 220, 160, PAL["wood_dark"])


def draw_character(img: Image.Image) -> None:
    # Tome Thrall in presenting stance on the rug, right-facing.
    # Hair behind shoulders.
    rect(img, 140, 74, 10, 24, PAL["wood_dark"])
    rect(img, 150, 78, 8, 18, PAL["wood_base"])
    rect(img, 153, 80, 3, 8, PAL["parchment"])
    # Neck and head.
    rect(img, 163, 73, 6, 9, PAL["skin"])
    outline_ellipse(img, 170, 60, 10, 12, PAL["skin"])
    rect(img, 160, 64, 16, 12, PAL["shadow_skin"])
    px(img, 174, 58, PAL["wood_dark"])
    px(img, 175, 59, PAL["wood_dark"])
    px(img, 172, 62, PAL["shadow_skin"])
    hline(img, 166, 51, 8, PAL["skin_hi"])
    # Hair masses.
    for x in range(156, 168, 2):
        vline(img, x, 52, 82 - (x - 156) * 2, PAL["ink"])
    for x in range(176, 186, 2):
        vline(img, x, 52, 78 - (x - 176) * 2, PAL["ink"])
    for x in range(158, 166, 3):
        px(img, x, 64, PAL["window_line"])
    # Torso robe.
    rect(img, 162, 88, 18, 48, PAL["book_dark"])
    rect(img, 164, 90, 14, 42, PAL["wood_base"])
    rect(img, 166, 92, 10, 10, PAL["wood_hi"])
    rect(img, 166, 100, 10, 18, PAL["wood_dark"])
    hline(img, 164, 110, 14, PAL["wood_dark"])
    hline(img, 162, 126, 18, PAL["wood_dark"])
    # Arms.
    for pts, color in [
        ([(164, 98), (146, 108), (128, 112)], PAL["skin_hi"]),
        ([(178, 100), (196, 104), (214, 110)], PAL["skin_hi"]),
    ]:
        for a, b in zip(pts, pts[1:]):
            x0, y0 = a
            x1, y1 = b
            steps = max(abs(x1 - x0), abs(y1 - y0), 1)
            for i in range(steps + 1):
                x = round(x0 + (x1 - x0) * i / steps)
                y = round(y0 + (y1 - y0) * i / steps)
                fill_ellipse(img, x, y, 2, 2, color)
                fill_ellipse(img, x, y, 1, 1, PAL["wood_dark"])
        hand_x, hand_y = pts[-1]
        rect(img, hand_x - 4, hand_y - 2, 8, 5, color)
    # Legs.
    rect(img, 166, 132, 8, 24, PAL["shadow_skin"])
    rect(img, 176, 132, 8, 24, PAL["book_base"])
    rect(img, 164, 152, 12, 6, PAL["wood_dark"])
    rect(img, 174, 152, 12, 6, PAL["rug_cream"])
    # Held book.
    rect(img, 216, 102, 28, 20, PAL["wood_base"])
    rect(img, 240, 104, 6, 16, PAL["parchment"])
    hline(img, 216, 102, 28, PAL["wood_dark"])
    hline(img, 216, 121, 28, PAL["wood_dark"])
    vline(img, 216, 103, 18, PAL["wood_dark"])
    vline(img, 243, 103, 18, PAL["wood_dark"])


def draw_ceiling(img: Image.Image) -> None:
    rect(img, 0, 0, W, 28, PAL["ceiling"])
    for x in range(0, W, 48):
        rect(img, x, 0, 4, 28, PAL["beam"])
    for y in range(0, 28, 14):
        hline(img, 0, y, W, PAL["beam"])
    # Subtle carved symbols.
    for x in [24, 72, 120, 168, 216, 264, 312, 360]:
        px(img, x, 8, PAL["wood_hi"])
        px(img, x + 2, 12, PAL["wood_hi"])
        px(img, x - 2, 16, PAL["wood_hi"])


def draw_ambient_lights(img: Image.Image) -> None:
    # Soft light bloom around the two major light sources and the center shelf glow.
    for cx, cy, color, r in [
        (42, 74, PAL["window_line"], 18),
        (42, 110, PAL["blue_glow"], 12),
        (334, 64, PAL["torch_glow"], 14),
        (356, 84, PAL["torch_glow"], 13),
        (220, 88, PAL["rug_gold"], 10),
    ]:
        fill_ellipse(img, cx, cy, r, r + 4, color)
    for x, y in [(152, 78), (184, 64), (236, 86), (268, 120), (110, 124), (312, 118)]:
        px(img, x, y, PAL["wood_hi"])
        px(img, x + 1, y, PAL["wood_hi"])
        px(img, x, y + 1, PAL["wood_hi"])


def upscale(img: Image.Image) -> Image.Image:
    return img.resize((W * SCALE, H * SCALE), Image.NEAREST)


def main() -> None:
    img = new_canvas()
    draw_ceiling(img)
    draw_window(img)
    draw_desk(img)
    draw_bookshelf(img)
    draw_right_side(img)
    draw_floor_and_rug(img)
    draw_character(img)
    draw_ambient_lights(img)

    out = OUT_DIR / "arcane_library_scene.png"
    upscale(img).save(out)
    print(out)


if __name__ == "__main__":
    main()

"""Draws a top-down diagram of the repaired ship from the layout in shared.lua.

Usage: python3 dev/draw_layout.py OUTPUT.png     (needs `pip install lupa pillow`)
"""
import os, sys
import lupa
from PIL import Image, ImageDraw, ImageFont

mod = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
L = lupa.LuaRuntime(unpack_returned_tuples=True)
L.execute('package.path = "%s/?.lua;" .. package.path' % mod)
shared = L.eval('(require("shared"))')
layout, built = shared.layout, shared.build_layout()
W, H = int(layout.width), int(layout.length)
T, PAD = 44, 60                                   # pixels per tile, margin
img = Image.new("RGB", (W * T + PAD * 2 + 250, H * T + PAD * 2), (36, 36, 36))
d = ImageDraw.Draw(img)
font, small = ImageFont.load_default(size=15), ImageFont.load_default(size=12)

def tile(x, y, colour):
    d.rectangle([PAD + x * T, PAD + y * T, PAD + (x + 1) * T - 1, PAD + (y + 1) * T - 1], fill=colour, outline=(28, 28, 28))

def block(cx, cy, w, h, colour, label):
    x0, y0 = PAD + (cx - w / 2) * T, PAD + (cy - h / 2) * T
    d.rectangle([x0 + 3, y0 + 3, x0 + w * T - 4, y0 + h * T - 4], fill=colour, outline=(240, 240, 240), width=2)
    d.multiline_text((x0 + w * T / 2, y0 + h * T / 2), label, font=font, fill=(255, 255, 255), anchor="mm", align="center")

FLOOR, WALL, GATE = (74, 78, 92), (150, 156, 172), (222, 170, 60)
for y in range(H):
    for x in range(W):
        tile(x, y, FLOOR)
for wall in built.walls.values():
    tile(int(wall.x), int(wall.y), WALL)
for gate in layout.gates.values():
    tile(int(gate.x), int(gate.y), GATE)
block(layout.console.x, layout.console.y, 4, 4, (60, 120, 190), "Console\n4 x 4")
block(layout.tank.x, layout.tank.y, 3, 3, (170, 90, 60), "Booster\ntank\n3 x 3")
block(layout.engine.x, layout.engine.y, 3, 4, (190, 60, 60), "Rocket\nengine\n3 x 4")
d.text((PAD + W * T / 2, PAD - 28), "NORTH (front of ship)", font=font, fill=(220, 220, 220), anchor="mm")
d.text((PAD + W * T / 2, PAD + H * T + 26), "engine exhaust", font=small, fill=(170, 170, 170), anchor="mm")

lx, ly = PAD + W * T + 36, PAD + 6
counts = built.counts
legend = [(FLOOR, "Floor", counts.floor), (WALL, "Wall", counts.wall), (GATE, "Gate", counts.gate),
          ((60, 120, 190), "Console", counts.console), ((170, 90, 60), "Booster tank", counts.tank), ((190, 60, 60), "Rocket engine", counts.engine)]
d.text((lx, ly), "%d x %d tiles" % (W, H), font=font, fill=(235, 235, 235)); ly += 34
for colour, name, count in legend:
    d.rectangle([lx, ly, lx + 20, ly + 20], fill=colour, outline=(28, 28, 28))
    d.text((lx + 30, ly + 10), "%s  x %d" % (name, int(count)), font=font, fill=(220, 220, 220), anchor="lm"); ly += 30
free = (W - 2) * (H - 2) - 16 - 9 - 9
ly += 14
d.multiline_text((lx, ly), "Free interior floor:\n%d tiles" % free, font=small, fill=(170, 170, 170))
img.save(sys.argv[1])

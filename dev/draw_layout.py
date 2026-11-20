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
WRECK = (15.6, 7.8)                               # the wreck's outline in tiles (its collision box)
img = Image.new("RGB", (W * T + PAD * 2 + 250 + int(WRECK[0] * T) + 40, max(H * T, 420) + PAD * 2), (36, 36, 36))
d = ImageDraw.Draw(img)
font, small = ImageFont.load_default(size=15), ImageFont.load_default(size=12)

def tile(x, y, colour):
    d.rectangle([PAD + x * T, PAD + y * T, PAD + (x + 1) * T - 1, PAD + (y + 1) * T - 1], fill=colour, outline=(28, 28, 28))

def block(cx, cy, w, h, colour, label):
    x0, y0 = PAD + (cx - w / 2) * T, PAD + (cy - h / 2) * T
    d.rectangle([x0 + 3, y0 + 3, x0 + w * T - 4, y0 + h * T - 4], fill=colour, outline=(240, 240, 240), width=2)
    d.multiline_text((x0 + w * T / 2, y0 + h * T / 2), label, font=font, fill=(255, 255, 255), anchor="mm", align="center")

FLOOR, WALL, GATE = (74, 78, 92), (150, 156, 172), (222, 170, 60)
for t in built.tiles.values():
    tile(int(t.x), int(t.y), FLOOR)
for wall in built.walls.values():
    tile(int(wall.x), int(wall.y), WALL)
for gate in layout.gates.values():
    tile(int(gate.x), int(gate.y), GATE)
for console in layout.consoles.values():
    block(console.x, console.y, 4, 4, (60, 120, 190), "Console\n4 x 4")
for tank in layout.tanks.values():
    block(tank.x, tank.y, 3, 3, (170, 90, 60), "Booster\ntank")
for engine in layout.engines.values():
    block(engine.x, engine.y, 3, 4, (190, 60, 60), "Rocket\nengine")
d.text((PAD + W * T / 2, PAD - 28), "NORTH (front of ship)", font=font, fill=(220, 220, 220), anchor="mm")
d.text((PAD + W * T / 2, PAD + H * T + 26), "engine exhaust", font=small, fill=(170, 170, 170), anchor="mm")

lx, ly = PAD + W * T + 36, PAD + 6
counts = built.counts
legend = [(FLOOR, "Floor", counts.floor), (WALL, "Wall", counts.wall), (GATE, "Gate", counts.gate),
          ((60, 120, 190), "Console", counts.console), ((170, 90, 60), "Booster tank", counts.tank), ((190, 60, 60), "Rocket engine", counts.engine)]
d.text((lx, ly), "%d x %d tiles overall" % (W, H), font=font, fill=(235, 235, 235)); ly += 34
for colour, name, count in legend:
    d.rectangle([lx, ly, lx + 20, ly + 20], fill=colour, outline=(28, 28, 28))
    d.text((lx + 30, ly + 10), "%s  x %d" % (name, int(count)), font=font, fill=(220, 220, 220), anchor="lm"); ly += 30
free = int(counts.floor) - int(counts.wall) - int(counts.gate) - 16 * int(counts.console) - 9 * int(counts.tank) - 12 * int(counts.engine)
ly += 14
d.multiline_text((lx, ly), "Free interior floor:\n%d tiles" % free, font=small, fill=(170, 170, 170))
wx, wy = lx + 230, PAD + 60
d.text((wx, PAD + 6), "The wreck, same scale", font=font, fill=(235, 235, 235))
d.rectangle([wx, wy, wx + WRECK[0] * T, wy + WRECK[1] * T], fill=(70, 62, 52), outline=(200, 170, 120), width=2)
d.multiline_text((wx + WRECK[0] * T / 2, wy + WRECK[1] * T / 2), "Crashed spaceship\n%.1f x %.1f tiles\n(lies east-west)" % WRECK, font=font, fill=(235, 225, 205), anchor="mm", align="center")
d.multiline_text((wx, wy + WRECK[1] * T + 14), "Wreck outline: %d tiles of ground\nRepaired ship: %d tiles" % (round(WRECK[0] * WRECK[1]), int(counts.floor)), font=small, fill=(170, 170, 170))
img.save(sys.argv[1])

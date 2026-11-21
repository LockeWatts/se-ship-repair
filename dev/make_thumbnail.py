"""Builds thumbnail.png (144 x 144, shown in Factorio's mod list): the repaired ship
seen from above, drawn from the layout in shared.lua.

Usage: python3 dev/make_thumbnail.py OUTPUT.png     (needs `pip install lupa pillow`)
"""
import os, sys
import lupa
from PIL import Image, ImageDraw, ImageFilter

mod = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
L = lupa.LuaRuntime(unpack_returned_tuples=True)
L.execute('package.path = "%s/?.lua;" .. package.path' % mod)
shared = L.eval('(require("shared"))')
layout, built = shared.layout, shared.build_layout()
W, H = int(layout.width), int(layout.length)

SIZE, S = 144, 4                      # final size, supersampling
T = 5.6 * S                           # pixels per tile at the supersampled size
ox = (SIZE * S - W * T) / 2
oy = (SIZE * S - H * T) / 2 - 5 * S   # a little high, leaving room for the exhaust

img = Image.new("RGBA", (SIZE * S, SIZE * S), (18, 20, 28, 255))
# a few stars
import random
random.seed(4)
d = ImageDraw.Draw(img)
for _ in range(70):
    x, y, b = random.random() * SIZE * S, random.random() * SIZE * S, random.randint(70, 190)
    r = random.choice([1, 1, 1, 2]) * S / 3
    d.ellipse([x - r, y - r, x + r, y + r], fill=(b, b, min(255, b + 30), 255))

def rect(x, y, w, h, colour, inset=0):
    d.rectangle([ox + x * T + inset, oy + y * T + inset, ox + (x + w) * T - inset - 1, oy + (y + h) * T - inset - 1], fill=colour)

# engine exhaust, drawn first so the hull sits on top of it
glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
gd = ImageDraw.Draw(glow)
for engine in layout.engines.values():
    cx, top = ox + engine.x * T, oy + (engine.y + 2) * T
    gd.polygon([(cx - 1.3 * T, top), (cx + 1.3 * T, top), (cx, top + 5.2 * T)], fill=(255, 150, 40, 255))
    gd.polygon([(cx - 0.7 * T, top), (cx + 0.7 * T, top), (cx, top + 3.2 * T)], fill=(255, 240, 200, 255))
img.alpha_composite(glow.filter(ImageFilter.GaussianBlur(2.2 * S)))
d = ImageDraw.Draw(img)

for t in built.tiles.values():
    rect(int(t.x), int(t.y), 1, 1, (62, 68, 84, 255))
for t in built.walls.values():
    rect(int(t.x), int(t.y), 1, 1, (168, 176, 194, 255))
for g in layout.gates.values():
    rect(int(g.x), int(g.y), 1, 1, (226, 172, 60, 255))
for c in layout.consoles.values():
    rect(c.x - 2, c.y - 2, 4, 4, (70, 140, 215, 255), inset=S)
for t in layout.tanks.values():
    rect(t.x - 1.5, t.y - 1.5, 3, 3, (176, 96, 64, 255), inset=S)
for e in layout.engines.values():
    rect(e.x - 1.5, e.y - 2, 3, 4, (200, 66, 66, 255), inset=S)

img.resize((SIZE, SIZE), Image.LANCZOS).convert("RGB").save(sys.argv[1])

"""Checks the repaired ship's layout against Space Exploration's own hull rules.

Re-implements, for our layout only, the two tests in SE's spaceship-integrity.lua that
the shape has to pass: containment (no floor may touch the outside, diagonals included)
and the streamlining score. Also checks that no part overlaps a wall or another part,
that booster tanks line up with engine fuel inlets, and estimates structural integrity.

Usage: python3 dev/check_hull.py      (needs `pip install lupa`)
"""
import os, sys, math
import lupa

mod = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
L = lupa.LuaRuntime(unpack_returned_tuples=True)
L.execute('package.path = "%s/?.lua;" .. package.path' % mod)
shared = L.eval('(require("shared"))')
layout, built = shared.layout, shared.build_layout()
ok = True
def check(condition, text):
    global ok
    print(("  ok    " if condition else "  FAIL  ") + text)
    ok = ok and condition

hull = {(int(t.x), int(t.y)) for t in built.tiles.values()}
walls = {(int(t.x), int(t.y)) for t in built.walls.values()}
gates = {(int(g.x), int(g.y)) for g in layout.gates.values()}
part_tiles = {}
for part, key in (("console", "consoles"), ("tank", "tanks"), ("engine", "engines")):
    for i, centre in enumerate(layout[key].values()):
        part_tiles[(part, i)] = {(int(t.x), int(t.y)) for t in shared.part_tiles(part, centre).values()}
engine_tiles = set().union(*[v for k, v in part_tiles.items() if k[0] == "engine"])
bulkheads = walls | gates | engine_tiles

print("Parts")
seen = {}
for key, tiles in part_tiles.items():
    check(tiles <= hull, "%s %d sits entirely on the hull" % key)
    check(not (tiles & (walls | gates)), "%s %d does not overlap a wall or gate" % key)
    for t in tiles:
        check(t not in seen, "%s %d does not overlap %s" % (key + (seen.get(t),))) if t in seen else None
        seen[t] = key
check(gates <= hull and all(any((x + dx, y) not in hull for dx in (-1, 1)) for x, y in gates), "each gate is in a side wall")

print("Fuel lines")
for i, engine in enumerate(layout.engines.values()):
    inlets = {(math.floor(engine.x - 1), math.floor(engine.y - 1.5) - 1), (math.floor(engine.x + 1), math.floor(engine.y - 1.5) - 1)}
    outlets = set()
    for tank in layout.tanks.values():
        outlets.add((math.floor(tank.x), math.floor(tank.y + 1)))       # the tank's south-facing connection tile
    check(bool(inlets & outlets), "engine %d has a booster tank outlet directly above one of its inlets" % i)

print("Containment (SE: floor touching the outside in any of 8 directions is a leak)")
floor = hull - bulkheads
leaks = [t for t in floor if any((t[0] + dx, t[1] + dy) not in hull for dx in (-1, 0, 1) for dy in (-1, 0, 1))]
check(not leaks, "no interior floor touches the outside (%d leaks)" % len(leaks))

print("Streamlining (SE formula)")
min_x, max_x = min(x for x, _ in hull), max(x for x, _ in hull) + 1
front = {}
for x, y in hull:
    front[x] = min(front.get(x, y), y)
average_x = (min_x + max_x) // 2
by_y, left, right = {}, set(), set()
for x, y in front.items():
    by_y[y] = by_y.get(y, 0) + 1
    (left if x < average_x else right).add(y)
width, max_flat = max_x - min_x, max(by_y.values())
flatness = min(1, (1 - (max_flat - 2) / (width - 2)) * 1.5)
s_left = min(1, 2 * (len(left) - 1) / max(0.5, (width - 1) / 2.5))
s_right = min(1, 2 * (len(right) - 1) / max(0.5, (width - 1) / 2.5))
streamline = (flatness + s_left + s_right + 3 * min(flatness, s_left, s_right)) / 6
print("  widest flat front: %d of %d columns; flatness %.2f, left %.2f, right %.2f" % (max_flat, width, flatness, s_left, s_right))
check(abs(streamline - 1) < 1e-9, "streamline score is %.0f%%" % (streamline * 100))

print("Integrity (structure only, before the 10% empty-floor credit)")
length = max(y for _, y in hull) + 1 - min(y for _, y in hull)
widths = {}
for x, y in hull:
    widths[y] = widths.get(y, 0) + 1
stress = len(hull) - 0.75 * len(walls)
ratio = length / (sum(widths.values()) / len(widths))
if 1 + 0.05 * (ratio - 4) > 1: stress *= 1 + 0.05 * (ratio - 4)
print("  %d hull tiles, %d walls, length-to-width %.2f: stress about %.0f of the 300 allowed without research" % (len(hull), len(walls), ratio, stress))
check(stress < 300, "structural stress is under the base limit")
print("  free interior floor: %d tiles" % (len(floor) - sum(len(v) for k, v in part_tiles.items() if k[0] != "engine") - len(engine_tiles - bulkheads)))
sys.exit(0 if ok else 1)

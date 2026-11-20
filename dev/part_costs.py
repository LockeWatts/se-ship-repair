"""Works out what Space Exploration's own spaceship part recipes cost in raw materials.

The recipes below were read from three places and are per ONE unit of the product:
  base   Factorio 2.1.25 (wube/factorio-data, base/prototypes/recipe.lua)
  aai    AAI Industry 0.7.5, which replaces several base recipes
  se     Space Exploration 0.7.65
Conventions: no productivity or modules; sand made by hand or assembler (2 per stone,
the pulveriser gives 3); the vulcanite (pyroflux) smelting routes; chance-based steps
taken at their average.

Usage: python3 dev/part_costs.py
"""
from collections import defaultdict

R = {
    # --- base
    "iron-plate": {"iron-ore": 1}, "copper-plate": {"copper-ore": 1},
    "steel-plate": {"iron-plate": 5}, "stone-brick": {"stone": 2},
    "copper-cable": {"copper-plate": 0.5}, "iron-gear-wheel": {"iron-plate": 2},
    "iron-stick": {"iron-plate": 0.5}, "pipe": {"iron-plate": 1},
    "advanced-circuit": {"electronic-circuit": 2, "plastic-bar": 2, "copper-cable": 4},
    "processing-unit": {"electronic-circuit": 20, "advanced-circuit": 2, "sulfuric-acid": 5},
    "plastic-bar": {"coal": 0.5, "petroleum-gas": 10},
    "sulfur": {"petroleum-gas": 15, "water": 15},
    "sulfuric-acid": {"sulfur": 0.1, "iron-plate": 0.02, "water": 2},
    "battery": {"sulfuric-acid": 20, "iron-plate": 1, "copper-plate": 1},
    "storage-tank": {"iron-plate": 20, "steel-plate": 5},
    "lubricant": {"heavy-oil": 1},
    # --- aai
    "stone-tablet": {"stone-brick": 0.25},
    "sand": {"stone": 0.5}, "glass": {"sand": 4},
    "electronic-circuit": {"stone-tablet": 1, "copper-cable": 3},
    "electric-motor": {"iron-plate": 1, "iron-gear-wheel": 1, "copper-cable": 6},
    "electric-engine-unit": {"lubricant": 40, "steel-plate": 2, "electronic-circuit": 4, "electric-motor": 2},
    "pump": {"electric-motor": 2, "pipe": 2, "steel-plate": 1},
    # --- se
    "low-density-structure": {"steel-plate": 5, "copper-plate": 10, "glass": 10, "plastic-bar": 10},
    "se-heat-shielding": {"stone-tablet": 20, "sulfur": 8, "steel-plate": 2},
    "se-space-pipe": {"copper-cable": 2, "steel-plate": 1, "plastic-bar": 1, "glass": 1},
    "se-aeroframe-pole": {"iron-stick": 1, "se-beryllium-plate": 2},
    "se-aeroframe-scaffold": {"se-aeroframe-pole": 4, "se-cryonite-rod": 1},
    "se-aeroframe-bulkhead": {"low-density-structure": 2, "se-aeroframe-scaffold": 2, "se-beryllium-plate": 8},
    "se-cryonite-rod": {"cryonite": 10, "heavy-oil": 1},
    "se-pyroflux": {"vulcanite": 1, "sand": 0.1},
    "se-vulcanite-block": {"vulcanite": 10, "sulfur": 0.67},
    # 1 plate = 5 hydroxide = 2.5 sulfate (4 ore + 1 acid each) + 0.1 cryonite rod + 1 pyroflux
    "se-beryllium-plate": {"beryllium-ore": 10, "sulfuric-acid": 2.5, "se-cryonite-rod": 0.1, "se-pyroflux": 1, "sand": 0.2},
    # 1 plate = 2.5 chloride (4 ore + 2 ion-exchange beads each) + 0.5 cable + 1 pyroflux
    "se-cryonite-ion-exchange-beads": {"se-cryonite-rod": 0.1, "plastic-bar": 0.1, "sulfuric-acid": 0.5},
    "se-holmium-plate": {"holmium-ore": 10, "se-cryonite-ion-exchange-beads": 5, "copper-cable": 0.5, "se-pyroflux": 1, "sand": 0.2},
    "se-holmium-cable": {"se-holmium-plate": 1, "plastic-bar": 0.5},
    "se-holmium-solenoid": {"iron-stick": 1, "se-holmium-cable": 8, "se-holmium-plate": 8},
    "se-heavy-girder": {"se-vulcanite-block": 1, "se-iridium-plate": 4},
    # 1 plate = 1 blastcake = 5 powder = 10 ore + 3.4 ion-exchange beads + 0.25 enriched vulcanite + 0.5 pyroflux
    "se-vulcanite-ion-exchange-beads": {"se-vulcanite-block": 0.1, "plastic-bar": 0.1, "sulfuric-acid": 0.5},
    "se-iridium-plate": {"iridium-ore": 10, "se-vulcanite-ion-exchange-beads": 3.4, "vulcanite": 1, "se-pyroflux": 0.5},
    # Space Exploration's rocket control unit (not used by its ship parts, but by the crude console)
    "rocket-control-unit": {"iron-plate": 5, "glass": 5, "battery": 5, "advanced-circuit": 5},
}
# Left as it is: the astronomic catalogue is a long chain of chance-based data cards.
PARTS = {
    "Console": {"se-aeroframe-pole": 20, "glass": 20, "low-density-structure": 20, "processing-unit": 200, "se-astronomic-catalogue-3": 1},
    "Floor": {"se-aeroframe-bulkhead": 4, "se-heat-shielding": 4},
    "Wall": {"se-aeroframe-bulkhead": 2, "glass": 8, "low-density-structure": 4, "se-heat-shielding": 4},
    "Gate": {"Wall": 1, "electric-engine-unit": 6, "se-aeroframe-bulkhead": 1, "se-heat-shielding": 1},
    "Rocket engine": {"se-aeroframe-scaffold": 4, "steel-plate": 20, "se-heat-shielding": 20, "se-space-pipe": 20, "electric-engine-unit": 10},
    "Booster tank": {"se-aeroframe-scaffold": 4, "steel-plate": 10, "storage-tank": 10, "se-heat-shielding": 10, "se-space-pipe": 4, "electric-engine-unit": 4},
    "Clamp": {"se-aeroframe-scaffold": 10, "se-heavy-girder": 6, "electric-engine-unit": 10, "processing-unit": 10},
    "Ion engine": {"Rocket engine": 1, "low-density-structure": 40, "se-holmium-cable": 40, "se-holmium-solenoid": 8},
    "Ion booster tank": {"storage-tank": 1, "electric-engine-unit": 4, "se-holmium-solenoid": 8, "se-beryllium-plate": 10, "se-holmium-cable": 40},
}
ROWS = ["iron-ore", "copper-ore", "stone", "coal", "petroleum-gas", "heavy-oil", "water",
        "beryllium-ore", "cryonite", "vulcanite", "holmium-ore", "iridium-ore", "se-astronomic-catalogue-3"]

# One number for comparing recipes: every solid raw material counts 1 each, whatever it
# is, so beryllium ore is valued like copper ore and iridium ore like iron ore. Oil
# products count a tenth each and water nothing.
WEIGHT = {"petroleum-gas": 0.1, "heavy-oil": 0.1, "water": 0, "se-astronomic-catalogue-3": 0}

def ore_equivalents(raw):
    return sum(WEIGHT.get(name, 1) * amount for name, amount in raw.items())

def crude_recipes():
    """The crude recipes from crude-recipes.lua, as {part: {ingredient: amount}}."""
    import os, lupa
    mod = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    lua = lupa.LuaRuntime(unpack_returned_tuples=True)
    lua.execute('package.path = "%s/?.lua;" .. package.path' % mod)
    table = lua.eval('(require("crude-recipes"))')
    part_of = {"se-spaceship-console": "Console", "se-spaceship-floor": "Floor", "se-spaceship-wall": "Wall", "se-spaceship-gate": "Gate",
               "se-spaceship-rocket-engine": "Rocket engine", "se-spaceship-rocket-booster-tank": "Booster tank",
               "se-spaceship-clamp": "Clamp", "se-spaceship-ion-engine": "Ion engine", "se-spaceship-ion-booster-tank": "Ion booster tank"}
    out = {}
    for name, entry in table.items():
        out[part_of[name]] = {("glass" if i.name == "@glass" else part_of.get(i.name, i.name)): i.amount for i in entry.ingredients.values()}
    return out

def expand(name, amount, out, parts=None):
    recipe = (parts or PARTS).get(name) or R.get(name)
    if recipe is None:
        out[name] += amount
    else:
        for ingredient, count in recipe.items():
            expand(ingredient, count * amount, out, parts)

def cost(part, amount=1, parts=None):
    out = defaultdict(float)
    expand(part, amount, out, parts)
    return out

def show(title, columns):
    print("\n" + title)
    print("%-28s" % "" + "".join("%13s" % name[:12] for name in columns))
    for row in ROWS:
        if any(columns[c].get(row, 0) > 0 for c in columns):
            print("%-28s" % row + "".join("%13s" % ("{:,.0f}".format(columns[c][row]) if columns[c].get(row, 0) >= 0.5 else ("<1" if columns[c].get(row, 0) > 0 else "")) for c in columns))
    unknown = sorted({k for c in columns.values() for k in c} - set(ROWS))
    if unknown: print("not broken down:", unknown)

if __name__ == "__main__":
    basic = ["Console", "Floor", "Wall", "Gate", "Rocket engine", "Booster tank"]
    show("Space Exploration's recipes, raw materials per part", {p: cost(p) for p in basic})
    show("The later parts", {p: cost(p) for p in ["Clamp", "Ion engine", "Ion booster tank"]})
    ship = {"Floor": 232, "Wall": 54, "Gate": 2, "Console": 1, "Rocket engine": 2, "Booster tank": 2}
    total = defaultdict(float)
    for part, count in ship.items():
        for k, v in cost(part, count).items(): total[k] += v
    show("The whole repaired ship at these prices (%s)" % ", ".join("%d %s" % (n, p.lower()) for p, n in ship.items()), {"Ship": total})
    show("A few intermediates, for reference", {p: cost(p) for p in ["low-density-structure", "se-heat-shielding", "processing-unit", "electric-engine-unit", "se-aeroframe-bulkhead", "se-beryllium-plate"]})

    crude = crude_recipes()
    print("\nCrude recipes against Space Exploration's, in ore-equivalents (see WEIGHT)")
    print("%-18s %12s %12s %7s   crude ingredients" % ("", "SE", "crude", "ratio"))
    for part in list(PARTS):
        se, cr = ore_equivalents(cost(part)), ore_equivalents(cost(part, 1, crude))
        print("%-18s %12s %12s %6.2fx   %s" % (part, "{:,.0f}".format(se), "{:,.0f}".format(cr), cr / se,
              ", ".join("%g %s" % (v, k) for k, v in crude[part].items())))
    se_ship, crude_ship = defaultdict(float), defaultdict(float)
    for part, count in ship.items():
        for k, v in cost(part, count).items(): se_ship[k] += v
        for k, v in cost(part, count, crude).items(): crude_ship[k] += v
    print("%-18s %12s %12s %6.2fx" % ("Repaired ship", "{:,.0f}".format(ore_equivalents(se_ship)), "{:,.0f}".format(ore_equivalents(crude_ship)), ore_equivalents(crude_ship) / ore_equivalents(se_ship)))
    show("The whole repaired ship built from crude recipes", {"Ship": crude_ship})

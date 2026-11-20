from collections import defaultdict
SUB = {  # recipes defined or altered by Space Exploration (0.7.65), per 1 item
 "low-density-structure": {"steel-plate":5,"copper-plate":10,"glass":10,"plastic-bar":10},
 "glass": {"stone":2},
 "se-heat-shielding": {"stone-tablet":20,"sulfur":8,"steel-plate":2},
 "rocket-control-unit": {"iron-plate":5,"glass":5,"battery":5,"advanced-circuit":5},
 "se-aeroframe-pole": {"iron-stick":1,"se-beryllium-plate":2},
 "se-aeroframe-scaffold": {"se-aeroframe-pole":4,"se-cryonite-rod":1},
 "se-aeroframe-bulkhead": {"low-density-structure":2,"se-aeroframe-scaffold":2,"se-beryllium-plate":8},
}
EARLY = {
 "console": {"glass":20,"low-density-structure":20,"processing-unit":200,"rocket-control-unit":20},
 "floor": {"low-density-structure":5,"se-heat-shielding":4},
 "wall": {"steel-plate":10,"glass":8,"low-density-structure":4,"se-heat-shielding":4},
 "gate": {"WALL":1,"electric-engine-unit":6,"low-density-structure":1,"se-heat-shielding":1},
 "rocket engine": {"pump":4,"steel-plate":20,"se-heat-shielding":20,"pipe":20,"electric-engine-unit":10,"lubricant":25},
 "booster tank": {"pump":4,"steel-plate":10,"storage-tank":10,"se-heat-shielding":10,"electric-engine-unit":4,"lubricant":25},
}
REFINED = {
 "console": {"se-aeroframe-pole":20,"glass":20,"low-density-structure":20,"processing-unit":200,"se-astronomic-catalogue-3":1},
 "floor": {"se-aeroframe-bulkhead":4,"se-heat-shielding":4},
 "wall": {"se-aeroframe-bulkhead":2,"glass":8,"low-density-structure":4,"se-heat-shielding":4},
 "gate": {"WALL":1,"electric-engine-unit":6,"se-aeroframe-bulkhead":1,"se-heat-shielding":1},
 "rocket engine": {"se-aeroframe-scaffold":4,"steel-plate":20,"se-heat-shielding":20,"se-space-pipe":20,"electric-engine-unit":10},
 "booster tank": {"se-aeroframe-scaffold":4,"steel-plate":10,"storage-tank":10,"se-heat-shielding":10,"se-space-pipe":4,"electric-engine-unit":4},
}
def expand(name, amount, tier, out):
    if name == "WALL":
        for k, v in tier["wall"].items(): expand(k, v * amount, tier, out)
    elif name in SUB:
        for k, v in SUB[name].items(): expand(k, v * amount, tier, out)
    else: out[name] += amount
def table(tier, label):
    cols = defaultdict(dict)
    for part, ing in tier.items():
        out = defaultdict(float)
        for k, v in ing.items(): expand(k, v, tier, out)
        for k, v in out.items(): cols[k][part] = v
    order = sorted(cols, key=lambda k: -sum(cols[k].values()))
    print("\n" + label)
    print("%-26s" % "" + "".join("%14s" % p for p in tier))
    for k in order:
        print("%-26s" % k + "".join("%14s" % (("%g" % cols[k][p]) if p in cols[k] else "") for p in tier))
table(EARLY, "EARLY TIER (Early Spaceships' values)")
table(REFINED, "REFINED TIER (Space Exploration's originals)")

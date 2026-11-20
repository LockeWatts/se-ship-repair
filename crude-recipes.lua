-- Crude recipes for spaceship parts: a second, early-game way to make each part,
-- alongside Space Exploration's own recipe, which is left untouched.
--
-- Each entry is keyed by the Space Exploration recipe it is the crude version of.
-- "@glass" stands for whichever glass item Space Exploration is using.
-- A part may set `categories` to say where it is crafted; parts with a fluid
-- ingredient need a category that accepts fluids.
--
-- The amounts are set so that each part costs about twice as much in raw materials
-- as Space Exploration's own recipe for it. The ingredients are the materials rockets
-- are built from: low density structure standing in for the beryllium aeroframe, and
-- steel for iridium girders. `python3 dev/part_costs.py` prints the comparison.
return {
  ["se-spaceship-console"] = {
    ingredients = {
      { type = "item", name = "@glass", amount = 40 },
      { type = "item", name = "low-density-structure", amount = 40 },
      { type = "item", name = "processing-unit", amount = 350 },
      { type = "item", name = "rocket-control-unit", amount = 40 },
    },
  },
  ["se-spaceship-floor"] = {
    ingredients = {
      { type = "item", name = "low-density-structure", amount = 40 },
      { type = "item", name = "se-heat-shielding", amount = 35 },
    },
  },
  ["se-spaceship-wall"] = {
    ingredients = {
      { type = "item", name = "steel-plate", amount = 60 },
      { type = "item", name = "@glass", amount = 50 },
      { type = "item", name = "low-density-structure", amount = 25 },
      { type = "item", name = "se-heat-shielding", amount = 20 },
    },
  },
  ["se-spaceship-gate"] = {
    ingredients = {
      { type = "item", name = "se-spaceship-wall", amount = 1 },
      { type = "item", name = "electric-engine-unit", amount = 25 },
      { type = "item", name = "low-density-structure", amount = 5 },
      { type = "item", name = "se-heat-shielding", amount = 5 },
    },
  },
  ["se-spaceship-rocket-engine"] = {
    categories = { "crafting-with-fluid" },
    ingredients = {
      { type = "item", name = "pump", amount = 12 },
      { type = "item", name = "steel-plate", amount = 60 },
      { type = "item", name = "se-heat-shielding", amount = 60 },
      { type = "item", name = "pipe", amount = 60 },
      { type = "item", name = "electric-engine-unit", amount = 30 },
      { type = "fluid", name = "lubricant", amount = 75 },
    },
  },
  ["se-spaceship-rocket-booster-tank"] = {
    categories = { "crafting-with-fluid" },
    ingredients = {
      { type = "item", name = "pump", amount = 10 },
      { type = "item", name = "steel-plate", amount = 30 },
      { type = "item", name = "storage-tank", amount = 30 },
      { type = "item", name = "se-heat-shielding", amount = 25 },
      { type = "item", name = "electric-engine-unit", amount = 10 },
      { type = "fluid", name = "lubricant", amount = 75 },
    },
  },
  ["se-spaceship-ion-engine"] = {
    ingredients = {
      { type = "item", name = "se-spaceship-rocket-engine", amount = 1 },
      { type = "item", name = "low-density-structure", amount = 120 },
      { type = "item", name = "se-cryonite-rod", amount = 120 },
      { type = "item", name = "se-holmium-plate", amount = 120 },
    },
  },
  ["se-spaceship-ion-booster-tank"] = {
    ingredients = {
      { type = "item", name = "storage-tank", amount = 2 },
      { type = "item", name = "electric-engine-unit", amount = 6 },
      { type = "item", name = "low-density-structure", amount = 65 },
      { type = "item", name = "se-cryonite-rod", amount = 65 },
      { type = "item", name = "se-holmium-plate", amount = 65 },
    },
  },
  ["se-spaceship-clamp"] = {
    categories = { "advanced-crafting" },
    ingredients = {
      { type = "item", name = "steel-plate", amount = 50 },
      { type = "item", name = "se-heat-shielding", amount = 20 },
      { type = "item", name = "low-density-structure", amount = 32 },
      { type = "item", name = "copper-cable", amount = 80 },
      { type = "item", name = "electric-engine-unit", amount = 20 },
      { type = "item", name = "processing-unit", amount = 20 },
    },
  },
}

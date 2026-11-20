-- The early tier of spaceship part recipes: what each part costs before the refined
-- recipes are unlocked. These are meant to be inefficient.
--
-- "@glass" stands for whichever glass item Space Exploration is using.
-- A part may set `categories` to say where it is crafted; parts with a fluid
-- ingredient need a category that accepts fluids.
--
-- The values below are the ones Early Spaceships 1.4.0 uses, as a starting point.
return {
  ["se-spaceship-console"] = {
    ingredients = {
      { type = "item", name = "@glass", amount = 20 },
      { type = "item", name = "low-density-structure", amount = 20 },
      { type = "item", name = "processing-unit", amount = 200 },
      { type = "item", name = "rocket-control-unit", amount = 20 },
    },
  },
  ["se-spaceship-floor"] = {
    ingredients = {
      { type = "item", name = "low-density-structure", amount = 5 },
      { type = "item", name = "se-heat-shielding", amount = 4 },
    },
  },
  ["se-spaceship-wall"] = {
    ingredients = {
      { type = "item", name = "steel-plate", amount = 10 },
      { type = "item", name = "@glass", amount = 8 },
      { type = "item", name = "low-density-structure", amount = 4 },
      { type = "item", name = "se-heat-shielding", amount = 4 },
    },
  },
  ["se-spaceship-gate"] = {
    ingredients = {
      { type = "item", name = "se-spaceship-wall", amount = 1 },
      { type = "item", name = "electric-engine-unit", amount = 6 },
      { type = "item", name = "low-density-structure", amount = 1 },
      { type = "item", name = "se-heat-shielding", amount = 1 },
    },
  },
  ["se-spaceship-rocket-engine"] = {
    categories = { "crafting-with-fluid" },
    ingredients = {
      { type = "item", name = "pump", amount = 4 },
      { type = "item", name = "steel-plate", amount = 20 },
      { type = "item", name = "se-heat-shielding", amount = 20 },
      { type = "item", name = "pipe", amount = 20 },
      { type = "item", name = "electric-engine-unit", amount = 10 },
      { type = "fluid", name = "lubricant", amount = 25 },
    },
  },
  ["se-spaceship-rocket-booster-tank"] = {
    categories = { "crafting-with-fluid" },
    ingredients = {
      { type = "item", name = "pump", amount = 4 },
      { type = "item", name = "steel-plate", amount = 10 },
      { type = "item", name = "storage-tank", amount = 10 },
      { type = "item", name = "se-heat-shielding", amount = 10 },
      { type = "item", name = "electric-engine-unit", amount = 4 },
      { type = "fluid", name = "lubricant", amount = 25 },
    },
  },
  ["se-spaceship-ion-engine"] = {
    ingredients = {
      { type = "item", name = "se-spaceship-rocket-engine", amount = 1 },
      { type = "item", name = "low-density-structure", amount = 40 },
      { type = "item", name = "se-cryonite-rod", amount = 40 },
      { type = "item", name = "se-holmium-plate", amount = 40 },
    },
  },
  ["se-spaceship-ion-booster-tank"] = {
    ingredients = {
      { type = "item", name = "storage-tank", amount = 1 },
      { type = "item", name = "electric-engine-unit", amount = 4 },
      { type = "item", name = "low-density-structure", amount = 40 },
      { type = "item", name = "se-cryonite-rod", amount = 40 },
      { type = "item", name = "se-holmium-plate", amount = 40 },
    },
  },
  ["se-spaceship-clamp"] = {
    categories = { "advanced-crafting" },
    ingredients = {
      { type = "item", name = "se-heat-shielding", amount = 10 },
      { type = "item", name = "low-density-structure", amount = 20 },
      { type = "item", name = "copper-cable", amount = 40 },
      { type = "item", name = "electric-engine-unit", amount = 10 },
      { type = "item", name = "processing-unit", amount = 10 },
    },
  },
}

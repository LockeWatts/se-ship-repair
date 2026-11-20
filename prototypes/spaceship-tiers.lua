-- Makes spaceships available at rocket science, and gives every spaceship part two recipes.
--
--   Early    the part's normal recipe, changed to early-game ingredients (early-recipes.lua)
--            and unlocked by the Spaceship technology, which moves to the cargo rocket's
--            place in the tree.
--   Refined  Space Exploration's own recipe for the part, kept as a separate recipe and
--            unlocked where Space Exploration originally unlocked it.
--
-- The technology moves follow the design of "Space Exploration: Early Spaceships" by
-- stringweasel (MIT licence, see NOTICE.md), which this replaces.
local shared = require("shared")
local early_recipes = require("early-recipes")

local glass = (SEItemNames and SEItemNames.get_glass_name and SEItemNames.get_glass_name()) or "glass"

local function strip_se(name)
  return (string.gsub(name, "^se%-", ""))
end

local function contains(list, value)
  for _, entry in pairs(list or {}) do
    if entry == value then return true end
  end
  return false
end

--------------------------------------------------------------------------------
-- Refined tier: copies of Space Exploration's originals, taken before anything changes
--------------------------------------------------------------------------------
local refined_recipe = {} -- original recipe name -> refined recipe name
for name in pairs(early_recipes) do
  local original = data.raw.recipe[name]
  if original then
    local refined = table.deepcopy(original)
    refined.name = shared.prefix .. "refined-" .. strip_se(name)
    refined.enabled = false
    refined.localised_name = { "recipe-name.sesr-refined", { "?", { "entity-name." .. name }, { "item-name." .. name } } }
    data:extend({ refined })
    refined_recipe[name] = refined.name
  end
end

for _, tech_name in ipairs({ "se-spaceship", "se-spaceship-clamps", "se-ion-engine" }) do
  local original = data.raw.technology[tech_name]
  if original then
    local effects = {}
    for _, effect in pairs(original.effects or {}) do
      if effect.type == "unlock-recipe" and refined_recipe[effect.recipe] then
        table.insert(effects, { type = "unlock-recipe", recipe = refined_recipe[effect.recipe] })
      end
    end
    if #effects > 0 then
      local refined = table.deepcopy(original)
      refined.name = shared.prefix .. "refined-" .. strip_se(tech_name)
      refined.effects = effects
      refined.prerequisites = table.deepcopy(original.prerequisites or {})
      if not contains(refined.prerequisites, tech_name) then table.insert(refined.prerequisites, tech_name) end
      refined.localised_name = { "technology-name.sesr-refined", { "technology-name." .. tech_name } }
      refined.localised_description = { "technology-description.sesr-refined" }
      data:extend({ refined })
    end
  end
end

--------------------------------------------------------------------------------
-- Early tier: the normal recipes, on early-game ingredients
--------------------------------------------------------------------------------
for name, early in pairs(early_recipes) do
  local recipe = data.raw.recipe[name]
  if recipe then
    local ingredients = table.deepcopy(early.ingredients)
    for _, ingredient in ipairs(ingredients) do
      if ingredient.name == "@glass" then ingredient.name = glass end
    end
    recipe.ingredients = ingredients
    if early.categories then
      recipe.categories = table.deepcopy(early.categories)
      recipe.category = nil
    end
  end
end

-- Space pipes are needed to plumb a ship, so they are craftable on the ground too.
-- The long variants stay space-only.
for _, name in ipairs({ "se-space-pipe", "se-space-pipe-to-ground" }) do
  local recipe = data.raw.recipe[name]
  if recipe then recipe.categories = { "crafting" } recipe.category = nil end
end
for name in pairs(data.raw["storage-tank"] or {}) do
  if string.find(name, "se%-space%-pipe%-long%-") then
    local recipe = data.raw.recipe[name]
    if recipe then recipe.categories = { "space-crafting" } recipe.category = nil end
  end
end

--------------------------------------------------------------------------------
-- Technologies: spaceships move to rocket science, the rest follow
--------------------------------------------------------------------------------
local function ingredient_name(ingredient) return ingredient.name or ingredient[1] end

-- Removes the space-era science packs, keeping the rocket science pack.
local function remove_space_packs(tech)
  local kept = {}
  for _, ingredient in ipairs(tech.unit.ingredients) do
    local name = ingredient_name(ingredient)
    local space_pack = string.sub(name, 1, 3) == "se-" and name ~= "se-rocket-science-pack"
    if not (space_pack or name == "utility-science-pack" or name == "production-science-pack") then
      table.insert(kept, ingredient)
    end
  end
  tech.unit.ingredients = kept
end

local function add_packs(tech, packs)
  for _, pack in ipairs(packs) do
    local present = false
    for _, ingredient in ipairs(tech.unit.ingredients) do
      present = present or ingredient_name(ingredient) == pack
    end
    if not present then table.insert(tech.unit.ingredients, { pack, 1 }) end
  end
end

-- prerequisites: a new list, or nil to leave them alone. packs: science packs to use
-- in place of the space-era ones.
local function move_tech(name, prerequisites, packs)
  local tech = data.raw.technology[name]
  if not (tech and tech.unit and tech.unit.ingredients) then return end
  if prerequisites then tech.prerequisites = prerequisites end
  remove_space_packs(tech)
  add_packs(tech, packs)
end

local launch_pad = data.raw.technology["se-rocket-launch-pad"]
local spaceship = data.raw.technology["se-spaceship"]
if launch_pad and spaceship then
  spaceship.prerequisites = table.deepcopy(launch_pad.prerequisites)
  spaceship.unit.ingredients = table.deepcopy(launch_pad.unit.ingredients)
end

local space, production, utility = "space-science-pack", "production-science-pack", "utility-science-pack"
move_tech("se-spaceship-clamps", { "se-spaceship" }, { space })
move_tech("se-ion-engine", { "se-spaceship", production, utility, "se-processing-holmium" }, { space, production, utility })
move_tech("se-spaceship-integrity-1", { "se-spaceship", space }, { space })
move_tech("se-spaceship-integrity-2", { "se-spaceship-integrity-1" }, { space, production })
move_tech("se-spaceship-integrity-3", nil, { space, production, "se-astronomic-science-pack-1" })
move_tech("se-spaceship-integrity-4", nil, { space, production, "se-astronomic-science-pack-2" })
move_tech("se-spaceship-integrity-5", nil, { space, production, "se-astronomic-science-pack-3", "se-material-science-pack-1" })
move_tech("se-spaceship-integrity-6", nil, { space, production, "se-astronomic-science-pack-3", "se-material-science-pack-2" })
move_tech("se-spaceship-integrity-7", nil, { space, production, "se-astronomic-science-pack-3", "se-material-science-pack-3" })

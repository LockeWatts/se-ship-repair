-- Makes spaceships buildable at rocket science by adding a crude recipe for every
-- spaceship part, unlocked by crude versions of the spaceship technologies.
-- Space Exploration's own part recipes and the technologies that unlock them are left
-- exactly as they are.
--
-- Where the crude technologies sit, and the two earlier integrity levels, follow the
-- design of "Space Exploration: Early Spaceships" by stringweasel (MIT licence, see
-- NOTICE.md), which this replaces.
local shared = require("shared")
local crude_recipes = require("crude-recipes")

local glass = (SEItemNames and SEItemNames.get_glass_name and SEItemNames.get_glass_name()) or "glass"

local function ingredient_name(ingredient) return ingredient.name or ingredient[1] end

--------------------------------------------------------------------------------
-- Crude recipes
--------------------------------------------------------------------------------
for name, crude in pairs(crude_recipes) do
  local original = data.raw.recipe[name]
  if original then
    -- Copied from the original so the product, icon and craft time stay the same.
    local recipe = table.deepcopy(original)
    recipe.name = shared.crude_name(name)
    recipe.enabled = false
    -- Named in the locale file ("Crude spaceship floor"). It makes the ordinary part:
    -- Space Exploration recognises ship parts by name, so there is no separate crude part.
    recipe.localised_name = { "recipe-name." .. recipe.name }
    recipe.ingredients = table.deepcopy(crude.ingredients)
    for _, ingredient in ipairs(recipe.ingredients) do
      if ingredient.name == "@glass" then ingredient.name = glass end
    end
    if crude.categories then
      recipe.categories = table.deepcopy(crude.categories)
      recipe.category = nil
    end
    data:extend({ recipe })
  end
end

--------------------------------------------------------------------------------
-- Crude technologies
--------------------------------------------------------------------------------
-- Swaps a technology's space-era science packs for the given ones, keeping the
-- rocket science pack.
local function set_packs(tech, packs)
  local kept = {}
  for _, ingredient in ipairs(tech.unit.ingredients) do
    local name = ingredient_name(ingredient)
    local space_pack = string.sub(name, 1, 3) == "se-" and name ~= "se-rocket-science-pack"
    if not (space_pack or name == "utility-science-pack" or name == "production-science-pack") then
      table.insert(kept, ingredient)
    end
  end
  for _, pack in ipairs(packs) do
    local present = false
    for _, ingredient in ipairs(kept) do present = present or ingredient_name(ingredient) == pack end
    if not present then table.insert(kept, { pack, 1 }) end
  end
  tech.unit.ingredients = kept
end

-- A crude copy of one of Space Exploration's spaceship technologies, unlocking the
-- crude versions of the same recipes. Returns nil if there is nothing for it to unlock.
local function crude_tech(original_name)
  local original = data.raw.technology[original_name]
  if not original then return nil end
  local effects = {}
  for _, effect in pairs(original.effects or {}) do
    if effect.type == "unlock-recipe" and crude_recipes[effect.recipe] and data.raw.recipe[shared.crude_name(effect.recipe)] then
      table.insert(effects, { type = "unlock-recipe", recipe = shared.crude_name(effect.recipe) })
    end
  end
  if #effects == 0 then return nil end
  local tech = table.deepcopy(original)
  tech.name = shared.crude_name(original_name)
  tech.effects = effects
  tech.localised_name = { "technology-name." .. tech.name }
  tech.localised_description = { "technology-description." .. tech.name }
  return tech
end

local launch_pad = data.raw.technology["se-rocket-launch-pad"]
local space, production, utility = "space-science-pack", "production-science-pack", "utility-science-pack"
local crude_spaceship_name = shared.crude_name("se-spaceship")

local crude_spaceship = crude_tech("se-spaceship")
if crude_spaceship and launch_pad then
  -- Sits where the cargo rocket launch pad does.
  crude_spaceship.prerequisites = table.deepcopy(launch_pad.prerequisites)
  crude_spaceship.unit.ingredients = table.deepcopy(launch_pad.unit.ingredients)
  data:extend({ crude_spaceship })
end

local crude_clamps = crude_tech("se-spaceship-clamps")
if crude_clamps and crude_spaceship then
  crude_clamps.prerequisites = { crude_spaceship_name }
  set_packs(crude_clamps, { space })
  data:extend({ crude_clamps })
end

local crude_ion = crude_tech("se-ion-engine")
if crude_ion and crude_spaceship then
  crude_ion.prerequisites = { crude_spaceship_name, production, utility, "se-processing-holmium" }
  set_packs(crude_ion, { space, production, utility })
  data:extend({ crude_ion })
end

--------------------------------------------------------------------------------
-- Changes to Space Exploration's own prototypes
--------------------------------------------------------------------------------
-- The first two levels of integrity research move earlier and follow the crude
-- Spaceship technology, so an early ship can grow a little (from 300 to 500). The
-- higher levels stay where Space Exploration puts them.
local function move_integrity(level, prerequisites, packs)
  local tech = data.raw.technology["se-spaceship-integrity-" .. level]
  if not (tech and tech.unit and tech.unit.ingredients and crude_spaceship) then return end
  tech.prerequisites = prerequisites
  set_packs(tech, packs)
end
move_integrity(1, { crude_spaceship_name, space }, { space })
move_integrity(2, { "se-spaceship-integrity-1" }, { space, production })

-- Space pipes are needed to plumb a ship, so they can be crafted on the ground too.
-- Their ingredients are unchanged, and the long variants stay space-only.
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

local config = require("config")
local shared = require("shared")

local wreck = data.raw.container[shared.wreck_name]
if not wreck then
  error("se-ship-repair: the base game's '" .. shared.wreck_name .. "' entity was not found.")
end

-- The wreck is the objective, so it can no longer be mined away.
wreck.minable = nil

data:extend({ { type = "recipe-category", name = shared.category } })

-- The wreck's picture, reused for the repair site. Sprite dicing is a container-only
-- option, so it is dropped when the layers become a machine animation.
local function wreck_animation()
  local layers = {}
  for _, layer in ipairs((wreck.picture and wreck.picture.layers) or { wreck.picture }) do
    local copy = table.deepcopy(layer)
    copy.dice, copy.dice_x, copy.dice_y = nil, nil, nil
    table.insert(layers, copy)
  end
  return { layers = layers }
end

for stage, key in ipairs(shared.stage_keys) do
  -- A repair site: a machine that looks like the wreck and can only run its stage's recipe.
  local site = table.deepcopy(wreck)
  site.type = "assembling-machine"
  site.name = shared.site_names[stage]
  site.hidden = nil
  site.minable = nil
  site.picture = nil
  site.inventory_size = nil
  site.inventory_type = nil
  site.default_status = nil
  site.flags = {
    "placeable-neutral", "placeable-player", "player-creation", "placeable-off-grid",
    "not-rotatable", "not-deconstructable", "not-blueprintable",
  }
  site.crafting_categories = { shared.category }
  site.fixed_recipe = shared.recipe_names[stage]
  site.crafting_speed = 1
  site.energy_usage = "1kW"
  site.energy_source = { type = "void" }
  site.module_slots = 0
  site.allowed_effects = {}
  site.graphics_set = { animation = wreck_animation() }

  local token = {
    type = "item",
    name = shared.token_names[stage],
    icon = wreck.icon,
    icon_size = wreck.icon_size,
    stack_size = 1,
    hidden = true,
  }

  local recipe = {
    type = "recipe",
    name = shared.recipe_names[stage],
    categories = { shared.category },
    icon = wreck.icon,
    icon_size = wreck.icon_size,
    -- The last stage waits for the Spaceship repair technology.
    enabled = stage < shared.final_stage,
    energy_required = config.stage_time,
    -- Real costs are worked out in data-final-fixes, once every mod has set its part recipes.
    ingredients = { { type = "item", name = "iron-plate", amount = 1 } },
    results = { { type = "item", name = shared.token_names[stage], amount = 1 } },
    hide_from_player_crafting = true,
    allow_productivity = false,
    allow_as_intermediate = false,
    allow_decomposition = false,
    auto_recycle = false,
  }

  data:extend({ site, token, recipe })
end

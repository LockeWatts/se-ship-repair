local config = require("config")
local shared = require("shared")

-- Each stage costs a share of what its parts would cost to craft with the crude
-- recipes, as those stand after every other mod has adjusted them. The crude recipes
-- are used because the repair has to be possible before space-era materials exist.
-- That cost is split into equal steps, and the stage's recipe is one step.
local counts = shared.build_layout().counts

local part_of_item = {}
for part, item in pairs(shared.parts) do part_of_item[item] = part end

-- Adds the item ingredients needed for `amount` of a part to `totals`. Parts made
-- from other parts (a gate contains a wall) are broken down further. Fluids are left
-- out: the repair site takes items only.
local function add_cost(item_name, amount, totals, depth)
  local recipe = data.raw.recipe[shared.crude_name(item_name)] or data.raw.recipe[item_name]
  if not recipe then return end
  local yield = 1
  for _, result in pairs(recipe.results or {}) do
    if (result.name or result[1]) == item_name then yield = result.amount or result[2] or 1 end
  end
  for _, ingredient in pairs(recipe.ingredients or {}) do
    local name = ingredient.name or ingredient[1]
    local count = (ingredient.amount or ingredient[2] or 1) * amount / yield
    if (ingredient.type or "item") == "item" then
      if part_of_item[name] and depth < 4 then
        add_cost(name, count, totals, depth + 1)
      else
        totals[name] = (totals[name] or 0) + count
      end
    end
  end
end

-- Rounds a per-step amount to a tidy number: down to a multiple of 5 from 10 upward,
-- to the nearest whole number below that, and nothing at all under a half.
local function tidy(amount)
  if amount >= 10 then return math.floor(amount / 5) * 5 end
  if amount >= 0.5 then return math.floor(amount + 0.5) end
  return 0
end

for stage, parts in ipairs(shared.stage_parts) do
  local totals = {}
  for _, part in ipairs(parts) do
    add_cost(shared.parts[part], counts[part], totals, 0)
  end

  local names = {}
  for name in pairs(totals) do table.insert(names, name) end
  table.sort(names)

  local steps = config.stage_steps[stage]
  local ingredients = {}
  for _, name in ipairs(names) do
    local amount = math.min(65535, tidy(totals[name] * config.salvage_factor / steps))
    if amount > 0 then table.insert(ingredients, { type = "item", name = name, amount = amount }) end
  end

  local recipe = data.raw.recipe[shared.recipe_names[stage]]
  if recipe and #ingredients > 0 then recipe.ingredients = ingredients end
end

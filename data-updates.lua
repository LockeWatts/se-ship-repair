local shared = require("shared")

-- Spaceship tiers first: this moves the Spaceship technology to the cargo rocket's
-- place and splits the part recipes into early and refined.
require("prototypes.spaceship-tiers")

-- Spaceship repair goes in that same place, and building new ships follows from
-- repairing the first one.
local launch_pad = data.raw.technology["se-rocket-launch-pad"]
local spaceship = data.raw.technology["se-spaceship"]
if not (launch_pad and spaceship) then
  error("se-ship-repair: Space Exploration's 'se-rocket-launch-pad' or 'se-spaceship' technology was not found.")
end

data:extend({
  {
    type = "technology",
    name = shared.tech_name,
    icon = spaceship.icon,
    icon_size = spaceship.icon_size,
    icons = table.deepcopy(spaceship.icons),
    order = spaceship.order,
    effects = { { type = "unlock-recipe", recipe = shared.recipe_names[shared.final_stage] } },
    prerequisites = table.deepcopy(launch_pad.prerequisites),
    unit = table.deepcopy(launch_pad.unit),
  },
})

spaceship.prerequisites = spaceship.prerequisites or {}
local already = false
for _, name in pairs(spaceship.prerequisites) do already = already or name == shared.tech_name end
if not already then table.insert(spaceship.prerequisites, shared.tech_name) end

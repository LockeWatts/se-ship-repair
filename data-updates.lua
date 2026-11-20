local shared = require("shared")

-- Crude spaceship recipes and technologies first: this puts a crude Spaceship
-- technology in the cargo rocket launch pad's place.
require("prototypes.crude-spaceships")

-- Spaceship repair goes in that same place, and building new ships, crudely at
-- first, follows from repairing the one you crashed in.
local launch_pad = data.raw.technology["se-rocket-launch-pad"]
local spaceship = data.raw.technology["se-spaceship"]
local crude_spaceship = data.raw.technology[shared.crude_name("se-spaceship")]
if not (launch_pad and spaceship and crude_spaceship) then
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

table.insert(crude_spaceship.prerequisites, shared.tech_name)

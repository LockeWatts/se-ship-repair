-- Names and the repaired ship's layout, used by both the data stage and the runtime script.
local shared = {}

shared.prefix = "sesr-"
shared.wreck_name = "crash-site-spaceship"
shared.category = shared.prefix .. "ship-repair"
shared.tech_name = shared.prefix .. "spaceship-repair"

shared.stage_keys = { "hull", "systems", "propulsion" }
shared.site_names, shared.recipe_names, shared.token_names = {}, {}, {}
for index, key in ipairs(shared.stage_keys) do
  shared.site_names[index] = shared.prefix .. "repair-site-" .. key
  shared.recipe_names[index] = shared.prefix .. "repair-" .. key
  shared.token_names[index] = shared.prefix .. "repaired-" .. key
end
shared.final_stage = #shared.stage_keys

-- Space Exploration prototypes the repaired ship is made of.
shared.floor_tile = "se-spaceship-floor"
shared.parts = {
  floor = "se-spaceship-floor",
  wall = "se-spaceship-wall",
  gate = "se-spaceship-gate",
  console = "se-spaceship-console",
  engine = "se-spaceship-rocket-engine",
  tank = "se-spaceship-rocket-booster-tank",
}
-- Which parts each repair stage pays for.
shared.stage_parts = {
  { "floor", "wall", "gate" },
  { "console" },
  { "engine", "tank" },
}

-- The repaired ship: a 9 x 14 hull with its nose to the north, as SE requires.
-- Tile coordinates count from the hull's top-left tile, (0, 0).
--   rows 1-4   console (4 x 4)
--   row 6      a gate in each side wall
--   rows 7-9   booster tank (3 x 3), feeding straight into the engine below it
--   rows 10-13 rocket engine (3 x 4), its tail forming part of the rear hull
shared.layout = {
  width = 9,
  length = 14,
  -- Entity centres, measured from the top-left corner of the hull.
  console = { x = 4, y = 3 },
  tank = { x = 3.5, y = 8.5 },
  engine = { x = 4.5, y = 12 },
  gates = { { x = 0, y = 6 }, { x = 8, y = 6 } },
  engine_columns = { first = 3, last = 5 },
}

-- Returns the wall tile coordinates and how many of each part the ship contains.
function shared.build_layout()
  local l = shared.layout
  local gate_at = {}
  for _, gate in ipairs(l.gates) do gate_at[gate.x .. "," .. gate.y] = true end
  local walls = {}
  for y = 0, l.length - 1 do
    for x = 0, l.width - 1 do
      local on_edge = x == 0 or y == 0 or x == l.width - 1 or y == l.length - 1
      local engine_tail = y == l.length - 1 and x >= l.engine_columns.first and x <= l.engine_columns.last
      if on_edge and not engine_tail and not gate_at[x .. "," .. y] then
        table.insert(walls, { x = x, y = y })
      end
    end
  end
  return {
    walls = walls,
    counts = { floor = l.width * l.length, wall = #walls, gate = #l.gates, console = 1, engine = 1, tank = 1 },
  }
end

return shared

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

-- The repaired ship: a 12 x 19 hull with its nose to the north, as SE requires.
-- That is about the size of the wreck as it is drawn, turned to stand north-south.
-- Tile coordinates count from the hull's top-left tile, (0, 0).
--   rows 2-5    console (4 x 4)
--   row 8       a gate in each side wall
--   rows 12-14  two booster tanks (3 x 3), each feeding straight into the engine below it
--   rows 15-18  two rocket engines (3 x 4), their tails forming part of the rear hull
-- An engine takes fuel through the top of its outer columns, and a tank gives it out
-- through the middle of each side, so each tank sits one column outboard of its engine.
shared.layout = {
  width = 12,
  length = 19,
  -- Entity centres, measured from the top-left corner of the hull.
  consoles = { { x = 6, y = 4 } },
  tanks = { { x = 2.5, y = 13.5 }, { x = 9.5, y = 13.5 } },
  engines = { { x = 3.5, y = 17 }, { x = 8.5, y = 17 } },
  -- Tile coordinates of the gates.
  gates = { { x = 0, y = 8 }, { x = 11, y = 8 } },
}

-- Sizes of the parts in tiles, for working out which hull tiles they replace and
-- for drawing the layout.
shared.part_size = {
  console = { w = 4, h = 4 },
  tank = { w = 3, h = 3 },
  engine = { w = 3, h = 4 },
}

-- Returns the wall tile coordinates and how many of each part the ship contains.
function shared.build_layout()
  local l = shared.layout
  -- Hull tiles that hold something other than a wall: gates and engine tails.
  local taken = {}
  for _, gate in ipairs(l.gates) do taken[gate.x .. "," .. gate.y] = true end
  for _, engine in ipairs(l.engines) do
    local size = shared.part_size.engine
    for x = math.floor(engine.x - size.w / 2), math.floor(engine.x - size.w / 2) + size.w - 1 do
      for y = math.floor(engine.y - size.h / 2), math.floor(engine.y - size.h / 2) + size.h - 1 do
        taken[x .. "," .. y] = true
      end
    end
  end
  local walls = {}
  for y = 0, l.length - 1 do
    for x = 0, l.width - 1 do
      local on_edge = x == 0 or y == 0 or x == l.width - 1 or y == l.length - 1
      if on_edge and not taken[x .. "," .. y] then table.insert(walls, { x = x, y = y }) end
    end
  end
  return {
    walls = walls,
    counts = {
      floor = l.width * l.length, wall = #walls, gate = #l.gates,
      console = #l.consoles, engine = #l.engines, tank = #l.tanks,
    },
  }
end

return shared

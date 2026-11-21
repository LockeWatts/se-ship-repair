-- Names and the repaired ship's layout, used by both the data stage and the runtime script.
local shared = {}

shared.prefix = "sesr-"
shared.wreck_name = "crash-site-spaceship"
shared.category = shared.prefix .. "ship-repair"
shared.tech_name = shared.prefix .. "spaceship-repair"

shared.stage_keys = { "hull", "systems", "propulsion" }
shared.site_names, shared.recipe_names = {}, {}
for index, key in ipairs(shared.stage_keys) do
  shared.site_names[index] = shared.prefix .. "repair-site-" .. key
  shared.recipe_names[index] = shared.prefix .. "repair-" .. key
end
shared.final_stage = #shared.stage_keys

-- The crude counterpart of one of Space Exploration's recipes or technologies:
-- "se-spaceship-floor" -> "sesr-crude-spaceship-floor".
function shared.crude_name(name)
  return shared.prefix .. "crude-" .. (string.gsub(name, "^se%-", ""))
end

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

-- The repaired ship: a hull 12 tiles wide and 21 long with a tapered nose, flying
-- nose-north as SE requires. Tile coordinates count from the top-left corner of the
-- hull's bounding box, (0, 0).
--
-- `front` gives, for each column from left to right, the row where the hull begins.
-- The 45-degree taper down to a 4-tile tip scores 100% on SE's streamlining formula
-- (spaceship-integrity.lua): no more than a third of the width may be flat, and each
-- side must step back over several rows.
--
--   rows 6-9    console (4 x 4)
--   row 11      a gate in each side wall
--   rows 14-16  two booster tanks (3 x 3), each feeding straight into the engine below it
--   rows 17-20  two rocket engines (3 x 4), their tails forming part of the rear hull
-- An engine takes fuel through the top of its outer columns, and a tank gives it out
-- through the middle of each side, so each tank sits one column outboard of its engine.
shared.layout = {
  length = 21,
  front = { 4, 3, 2, 1, 0, 0, 0, 0, 1, 2, 3, 4 },
  -- Entity centres, measured from the top-left corner of the bounding box.
  consoles = { { x = 6, y = 8 } },
  tanks = { { x = 2.5, y = 15.5 }, { x = 9.5, y = 15.5 } },
  engines = { { x = 3.5, y = 19 }, { x = 8.5, y = 19 } },
  -- Tile coordinates of the gates.
  gates = { { x = 0, y = 11 }, { x = 11, y = 11 } },
}
shared.layout.width = #shared.layout.front

-- Sizes of the parts in tiles, for working out which tiles they cover.
shared.part_size = {
  console = { w = 4, h = 4 },
  tank = { w = 3, h = 3 },
  engine = { w = 3, h = 4 },
}

function shared.in_hull(x, y)
  local l = shared.layout
  return x >= 0 and x < l.width and y < l.length and y >= l.front[x + 1]
end

-- The tiles a part covers, given its centre.
function shared.part_tiles(part, centre)
  local size, tiles = shared.part_size[part], {}
  local left, top = math.floor(centre.x - size.w / 2), math.floor(centre.y - size.h / 2)
  for y = top, top + size.h - 1 do
    for x = left, left + size.w - 1 do
      table.insert(tiles, { x = x, y = y })
    end
  end
  return tiles
end

-- Works out the hull: its floor tiles, where the walls go, and how many of each part
-- the ship contains. A hull tile needs a wall if any of the eight tiles around it is
-- outside the hull, because SE counts a diagonal gap as a leak.
function shared.build_layout()
  local l = shared.layout
  -- Hull-edge tiles that hold something other than a wall: gates and engine tails.
  local taken = {}
  for _, gate in ipairs(l.gates) do taken[gate.x .. "," .. gate.y] = true end
  for _, engine in ipairs(l.engines) do
    for _, tile in ipairs(shared.part_tiles("engine", engine)) do taken[tile.x .. "," .. tile.y] = true end
  end

  local tiles, walls = {}, {}
  for y = 0, l.length - 1 do
    for x = 0, l.width - 1 do
      if shared.in_hull(x, y) then
        table.insert(tiles, { x = x, y = y })
        local on_edge = false
        for dy = -1, 1 do
          for dx = -1, 1 do
            if not shared.in_hull(x + dx, y + dy) then on_edge = true end
          end
        end
        if on_edge and not taken[x .. "," .. y] then table.insert(walls, { x = x, y = y }) end
      end
    end
  end
  return {
    tiles = tiles,
    walls = walls,
    counts = {
      floor = #tiles, wall = #walls, gate = #l.gates,
      console = #l.consoles, engine = #l.engines, tank = #l.tanks,
    },
  }
end

return shared

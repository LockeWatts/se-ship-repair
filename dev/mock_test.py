"""Runs the mod's data-stage and runtime scripts against a small stand-in for Factorio.

This catches Lua errors and logic mistakes, not mistakes about what the real game accepts.
Usage: python3 dev/mock_test.py [mod directory]     (needs `pip install lupa`)
"""
import os, sys
import lupa

MOD = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), ".."))

COMMON = r'''
function table.deepcopy(o) if type(o) ~= "table" then return o end local c = {} for k, v in pairs(o) do c[k] = table.deepcopy(v) end return c end
function ser(v) if type(v) ~= "table" then return tostring(v) end local keys = {} for k in pairs(v) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b) return tostring(a) < tostring(b) end) local parts = {}
  for _, k in ipairs(keys) do parts[#parts + 1] = (type(k) == "number" and "" or (k .. "=")) .. ser(v[k]) end return "{" .. table.concat(parts, ", ") .. "}" end
'''

def runtime(path):
    L = lupa.LuaRuntime(unpack_returned_tuples=True)
    L.execute('package.path = "%s/?.lua;" .. package.path' % path)
    L.execute(COMMON)
    return L

# ------------------------------------------------------------------ data stage
def data_stage():
    L = runtime(MOD)
    L.execute(r'''
data = { raw = { container = {}, technology = {}, recipe = {}, item = {}, ["recipe-category"] = {}, ["assembling-machine"] = {} } }
function data:extend(list) for _, p in ipairs(list) do assert(p.type and p.name) data.raw[p.type] = data.raw[p.type] or {} assert(not data.raw[p.type][p.name], "duplicate " .. p.name) data.raw[p.type][p.name] = p end end
data.raw.container["crash-site-spaceship"] = { type = "container", name = "crash-site-spaceship", icon = "__base__/graphics/icons/crash-site-spaceship.png",
  flags = {"placeable-player"}, hidden = true, max_health = 600, inventory_size = 5, minable = { mining_time = 2.3 },
  collision_box = {{-8.7, -3.3}, {6.9, 4.5}}, selection_box = {{-8.7, -3.3}, {6.9, 4.5}},
  picture = { layers = { { filename = "spaceship.png", width = 1228, height = 790, scale = 0.5, dice_x = 4, dice_y = 3 },
                         { filename = "spaceship-shadow.png", width = 1340, height = 842, scale = 0.5, dice_x = 5, dice_y = 4, draw_as_shadow = true } } } }
local packs = { {"automation-science-pack", 1}, {"se-rocket-science-pack", 1} }
data.raw.technology["se-rocket-launch-pad"] = { type = "technology", name = "se-rocket-launch-pad", prerequisites = {"se-thruster-suit"}, unit = { count = 300, time = 60, ingredients = packs } }
data.raw.technology["se-spaceship"] = { type = "technology", name = "se-spaceship", icon = "spaceship.png", icon_size = 128, order = "e-g", prerequisites = {"se-thruster-suit"}, unit = { count = 200, time = 60, ingredients = packs } }
local function recipe(name, ingredients, category) data.raw.recipe[name] = { type = "recipe", name = name, categories = category and { category } or nil, ingredients = ingredients, results = { { type = "item", name = name, amount = 1 } } } end
local function I(name, amount) return { type = "item", name = name, amount = amount } end
-- Space Exploration's own part recipes (0.7.65), which become the refined tier.
recipe("se-spaceship-console", { I("se-aeroframe-pole", 20), I("glass", 20), I("low-density-structure", 20), I("processing-unit", 200), I("se-astronomic-catalogue-3", 1) })
recipe("se-spaceship-floor", { I("se-aeroframe-bulkhead", 4), I("se-heat-shielding", 4) })
recipe("se-spaceship-wall", { I("se-aeroframe-bulkhead", 2), I("glass", 8), I("low-density-structure", 4), I("se-heat-shielding", 4) })
recipe("se-spaceship-gate", { I("se-spaceship-wall", 1), I("electric-engine-unit", 6), I("se-aeroframe-bulkhead", 1), I("se-heat-shielding", 1) })
recipe("se-spaceship-rocket-engine", { I("se-aeroframe-scaffold", 4), I("steel-plate", 20), I("se-heat-shielding", 20), I("se-space-pipe", 20), I("electric-engine-unit", 10) })
recipe("se-spaceship-rocket-booster-tank", { I("se-aeroframe-scaffold", 4), I("steel-plate", 10), I("storage-tank", 10), I("se-heat-shielding", 10), I("se-space-pipe", 4), I("electric-engine-unit", 4) })
recipe("se-spaceship-ion-engine", { I("se-spaceship-rocket-engine", 1), I("low-density-structure", 40), I("se-holmium-cable", 40), I("se-holmium-solenoid", 8) })
recipe("se-spaceship-ion-booster-tank", { I("storage-tank", 1), I("electric-engine-unit", 4), I("se-holmium-solenoid", 8), I("se-beryllium-plate", 10), I("se-holmium-cable", 40) })
recipe("se-spaceship-clamp", { I("se-aeroframe-scaffold", 10), I("se-heavy-girder", 6), I("electric-engine-unit", 10), I("processing-unit", 10) })
recipe("se-space-pipe", { I("steel-plate", 1) }, "space-crafting")
SEItemNames = { get_glass_name = function() return "glass" end }
local function unlocks(...) local e = {} for _, r in ipairs({...}) do e[#e + 1] = { type = "unlock-recipe", recipe = r } end return e end
local space_packs = { {"automation-science-pack", 1}, {"se-rocket-science-pack", 1}, {"se-astronomic-science-pack-3", 1}, {"utility-science-pack", 1} }
local st = data.raw.technology["se-spaceship"]
st.prerequisites = { "se-astronomic-science-pack-3", "se-aeroframe-bulkhead" } st.unit.ingredients = table.deepcopy(space_packs)
st.effects = unlocks("se-spaceship-console", "se-spaceship-floor", "se-spaceship-wall", "se-spaceship-gate", "se-spaceship-rocket-engine", "se-spaceship-rocket-booster-tank")
data.raw.technology["se-spaceship-clamps"] = { type = "technology", name = "se-spaceship-clamps", prerequisites = { "se-spaceship", "se-heavy-girder" }, effects = unlocks("se-spaceship-clamp"), unit = { count = 500, time = 60, ingredients = table.deepcopy(space_packs) } }
data.raw.technology["se-ion-engine"] = { type = "technology", name = "se-ion-engine", prerequisites = { "se-spaceship", "se-holmium-solenoid" }, effects = unlocks("se-spaceship-ion-engine", "se-spaceship-ion-booster-tank"), unit = { count = 1600, time = 60, ingredients = table.deepcopy(space_packs) } }
data.raw.technology["se-spaceship-integrity-1"] = { type = "technology", name = "se-spaceship-integrity-1", prerequisites = { "se-spaceship", "se-material-science-pack-1" }, unit = { count_formula = "2^L*50", time = 60, ingredients = { {"automation-science-pack", 1}, {"se-astronomic-science-pack-3", 1}, {"se-material-science-pack-1", 1} } } }
''')
    for stage in ("data", "data-updates", "data-final-fixes"):
        L.execute('dofile("%s/%s.lua")' % (MOD, stage))
    print(L.eval(r'''(function()
  local shared = require("shared") local out = {}
  local built = shared.build_layout()
  out[#out + 1] = "PART COUNTS " .. ser(built.counts)
  for i, name in ipairs(shared.recipe_names) do local r = data.raw.recipe[name]
    out[#out + 1] = "RECIPE " .. name .. " enabled=" .. tostring(r.enabled) .. " time=" .. r.energy_required
    for _, ing in ipairs(r.ingredients) do out[#out + 1] = string.format("    %-24s %5d", ing.name, ing.amount) end
    local site = data.raw["assembling-machine"][shared.site_names[i]]
    out[#out + 1] = "  SITE " .. site.name .. " fixed_recipe=" .. site.fixed_recipe .. " minable=" .. tostring(site.minable) .. " layers=" .. #site.graphics_set.animation.layers .. " dice_x=" .. tostring(site.graphics_set.animation.layers[1].dice_x)
  end
  out[#out + 1] = "WRECK minable=" .. tostring(data.raw.container["crash-site-spaceship"].minable) .. " picture layer dice_x=" .. tostring(data.raw.container["crash-site-spaceship"].picture.layers[1].dice_x)
  out[#out + 1] = "TECH " .. ser(data.raw.technology["sesr-spaceship-repair"])
  out[#out + 1] = "se-spaceship prerequisites " .. ser(data.raw.technology["se-spaceship"].prerequisites) .. " packs " .. ser(data.raw.technology["se-spaceship"].unit.ingredients)
  for _, t in ipairs({ "sesr-refined-spaceship", "sesr-refined-spaceship-clamps", "sesr-refined-ion-engine", "se-spaceship-clamps", "se-ion-engine", "se-spaceship-integrity-1" }) do local tech = data.raw.technology[t]
    out[#out + 1] = "TECH " .. t .. " prerequisites " .. ser(tech.prerequisites) .. " packs " .. ser(tech.unit.ingredients) .. (tech.effects and (" unlocks " .. ser(tech.effects)) or "") end
  for _, r in ipairs({ "se-spaceship-floor", "sesr-refined-spaceship-floor", "se-spaceship-rocket-engine", "sesr-refined-spaceship-rocket-engine", "se-space-pipe" }) do local recipe = data.raw.recipe[r]
    out[#out + 1] = "RECIPE " .. r .. " enabled=" .. tostring(recipe.enabled) .. " categories=" .. ser(recipe.categories) .. " " .. ser(recipe.ingredients) end
  return table.concat(out, "\n") end)()'''))

# ---------------------------------------------------------------- runtime stage
def control_stage(with_wreck):
    L = runtime(MOD)
    L.execute(r'''
defines = { direction = { north = 0, east = 4, south = 8, west = 12 } }
log_lines = {}
local function say(prefix) return function(msg) log_lines[#log_lines + 1] = prefix .. ser(msg) end end
world = { entities = {}, tiles = {}, rectangles = 0, spilled = {} }
local next_unit = 1
local function inventory(owner) local inv = { items = {} }
  setmetatable(inv, { __len = function() return 4 end, __index = function(t, k) if type(k) == "number" then local it = rawget(t, "items")[k]
      if it then return { valid_for_read = true, name = it.name, count = it.count } end return { valid_for_read = false } end end })
  function inv.get_item_count(name) local n = 0 for _, it in pairs(inv.items) do if it.name == name then n = n + it.count end end return n end
  function inv.insert(stack) inv.items[#inv.items + 1] = { name = stack.name, count = stack.count } return stack.count end
  return inv end
local boxes = { ["sesr-repair-site-hull"] = true, ["sesr-repair-site-systems"] = true, ["sesr-repair-site-propulsion"] = true }
local function make_entity(surface, spec, kind)
  local e = { name = spec.name, type = kind or "assembling-machine", position = { x = spec.position.x or spec.position[1], y = spec.position.y or spec.position[2] },
    force = spec.force, surface = surface, valid = true, unit_number = next_unit, direction = spec.direction, raised = spec.raise_built,
    localised_name = { "entity-name." .. spec.name }, destructible = true, inv = nil }
  next_unit = next_unit + 1
  if type(e.force) == "string" then e.force = game.forces[e.force] end
  e.inv = inventory(e)
  e.prototype = { collision_box = { left_top = { x = -8.7, y = -3.3 }, right_bottom = { x = 6.9, y = 4.5 } } }
  function e.get_max_inventory_index() return 1 end
  function e.get_inventory(i) return e.inv end
  function e.get_output_inventory() return e.inv end
  function e.destroy() e.valid = false for i, other in ipairs(world.entities) do if other == e then table.remove(world.entities, i) break end end return true end
  function e.teleport(pos) e.position = pos e.teleported = true return true end
  world.entities[#world.entities + 1] = e
  return e end
local surface = { name = "nauvis" }
function surface.create_entity(spec) return make_entity(surface, spec, spec.name:find("wall") and "wall" or nil) end
function surface.find_entities_filtered(filter) local found = {}
  for _, e in ipairs(world.entities) do local ok = true
    if filter.name and e.name ~= filter.name then ok = false end
    if filter.area and ok then local a = filter.area ok = e.position.x >= a.left_top.x and e.position.x <= a.right_bottom.x and e.position.y >= a.left_top.y and e.position.y <= a.right_bottom.y end
    if ok then found[#found + 1] = e end end
  return found end
function surface.spill_item_stack(spec) world.spilled[#world.spilled + 1] = spec.stack.name end
function surface.set_tiles(tiles) for _, t in ipairs(tiles) do world.tiles[#world.tiles + 1] = t end end
function surface.find_non_colliding_position(name, centre) if world.no_room then return nil end return { x = centre.x + 1, y = centre.y + 1 } end
local player_force = { name = "player", valid = true, print = say("FORCE: ") }
function player_force.get_spawn_position() return { x = 0, y = 0 } end
local neutral = { name = "neutral", valid = true, print = say("NEUTRAL: ") }
game = { tick = 0, surfaces = { nauvis = surface }, forces = { player = player_force, neutral = neutral }, print = say("GAME: ") }
function game.get_player() return { admin = true, print = say("PLAYER: ") } end
rendering = { draw_rectangle = function() world.rectangles = world.rectangles + 1 end }
storage = {}
handlers = {}
script = { on_init = function(f) handlers.init = f end, on_configuration_changed = function(f) handlers.config = f end, on_nth_tick = function(n, f) handlers.tick = f handlers.interval = n end }
commands = { add_command = function(name, help, f) handlers.command = f end }
function advance(seconds) for _ = 1, seconds do game.tick = game.tick + 60 handlers.tick({ tick = game.tick }) end end
function add(name, x, y, kind, force) return make_entity(surface, { name = name, position = { x = x, y = y }, force = force or "player" }, kind) end
function count(name) local n = 0 for _, e in ipairs(world.entities) do if e.name == name then n = n + 1 end end return n end
''')
    L.execute('dofile("%s/control.lua")' % MOD)
    L.execute('WITH_WRECK = %s' % ("true" if with_wreck else "false"))
    print(L.eval(r'''(function()
  local out = {}
  local function note(s) out[#out + 1] = s end
  if WITH_WRECK then local w = add("crash-site-spaceship", -5, -6, "container") w.inv.insert({ name = "firearm-magazine", count = 8 }) end
  handlers.init()
  advance(5)  note("after 5 s: state=" .. storage.state .. " (still waiting)")
  advance(6)  note("after 11 s: state=" .. storage.state .. " stage=" .. tostring(storage.stage) .. " site=" .. tostring(storage.site and storage.site.name) .. " at " .. ser(storage.site and storage.site.position)
    .. " wrecks left=" .. count("crash-site-spaceship") .. " spilled=" .. ser(world.spilled) .. " destructible=" .. tostring(storage.site and storage.site.destructible))
  handlers.command({ player_index = 1 }) advance(1)
  note("stage 1 done: stage=" .. storage.stage .. " site=" .. storage.site.name)
  handlers.command({ player_index = 1 }) advance(1)
  note("stage 2 done: stage=" .. storage.stage .. " site=" .. storage.site.name .. " outline drawn=" .. world.rectangles)
  -- Put a player's chest, a tree, a wreck fragment and a character inside the footprint.
  local sx, sy = storage.site.position.x - 0.9, storage.site.position.y + 0.6
  local chest = add("iron-chest", sx + 1, sy + 1, "container") add("tree-01", sx - 2, sy + 2, "tree", "neutral")
  add("crash-site-spaceship-wreck-small-1", sx + 2, sy - 3, "simple-entity-with-owner", "neutral") local me = add("character", sx, sy - 5.5, "character")
  handlers.command({ player_index = 1 }) advance(2)
  note("stage 3 done, blocked: state=" .. storage.state .. " origin=" .. ser(storage.origin) .. " outlines=" .. world.rectangles)
  chest.destroy() advance(1)
  note("cleared: state=" .. storage.state .. " tiles=" .. #world.tiles .. " walls=" .. count("se-spaceship-wall") .. " gates=" .. count("se-spaceship-gate")
    .. " consoles=" .. count("se-spaceship-console") .. " engines=" .. count("se-spaceship-rocket-engine") .. " tanks=" .. count("se-spaceship-rocket-booster-tank")
    .. " trees=" .. count("tree-01") .. " fragments=" .. count("crash-site-spaceship-wreck-small-1") .. " sites=" .. count("sesr-repair-site-propulsion") .. " character moved=" .. tostring(me.teleported))
  for _, e in ipairs(world.entities) do if e.name == "se-spaceship-console" or e.name == "se-spaceship-rocket-engine" or e.name == "se-spaceship-rocket-booster-tank" or e.name == "se-spaceship-gate" then
    note("   " .. e.name .. " at " .. ser(e.position) .. " raised=" .. tostring(e.raised) .. " dir=" .. tostring(e.direction)) end end
  advance(3) note("later: state=" .. storage.state)
  for _, line in ipairs(log_lines) do note("   " .. line:sub(1, 150)) end
  return table.concat(out, "\n") end)()'''))

if __name__ == "__main__":
    print("=== data stage"); data_stage()
    print("\n=== runtime, new game with a wreck"); control_stage(True)
    print("\n=== runtime, existing save with no wreck"); control_stage(False)

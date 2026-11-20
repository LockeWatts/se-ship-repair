local config = require("config")
local shared = require("shared")

local CHECK_INTERVAL = 60

-- storage.state is one of:
--   "searching"  looking for the wreck, or for somewhere to put a repair site
--   "repairing"  a repair site exists and is on stage storage.stage
--   "clearing"   the last stage is finished and the ship is waiting for a clear footprint
--   "done"       the ship has been built

local function setup_storage()
  if not storage.state then
    storage.state = "searching"
    storage.search_from = game.tick + config.search_delay
  end
end

local function home_surface()
  return game.surfaces["nauvis"] or game.surfaces[1]
end

local function gps(position, surface)
  return "[gps=" .. math.floor(position.x) .. "," .. math.floor(position.y) .. "," .. surface.name .. "]"
end

local function tell(force, message)
  if force and force.valid then force.print(message) else game.print(message) end
end

-- At most one chat warning per interval, so a standing problem does not flood the chat.
local function warn(force, message)
  if storage.last_warning and game.tick < storage.last_warning + config.warning_interval then return end
  storage.last_warning = game.tick
  tell(force, message)
end

-- Drops everything an entity holds onto the ground, except repair progress tokens.
local function spill_contents(entity)
  local is_token = {}
  for _, name in pairs(shared.token_names) do is_token[name] = true end
  for index = 1, entity.get_max_inventory_index() do
    local inventory = entity.get_inventory(index)
    if inventory then
      for slot = 1, #inventory do
        local stack = inventory[slot]
        if stack.valid_for_read and not is_token[stack.name] then
          entity.surface.spill_item_stack{
            position = entity.position,
            stack = stack,
            enable_looted = true,
            force = entity.force,
            allow_belts = false,
          }
        end
      end
    end
  end
end

local function create_site(surface, position, force, stage)
  local site = surface.create_entity{
    name = shared.site_names[stage],
    position = position,
    force = force,
    create_build_effect_smoke = false,
  }
  if not site then return nil end
  site.destructible = false
  storage.site = site
  storage.stage = stage
  storage.state = "repairing"
  return site
end

-- The ship's footprint, centred on the middle of the wreck's own outline.
local function ship_origin(site)
  local box = site.prototype.collision_box
  local centre_x = site.position.x + (box.left_top.x + box.right_bottom.x) / 2
  local centre_y = site.position.y + (box.left_top.y + box.right_bottom.y) / 2
  return {
    x = math.floor(centre_x - shared.layout.width / 2 + 0.5),
    y = math.floor(centre_y - shared.layout.length / 2 + 0.5),
  }
end

local function footprint_area(origin)
  return {
    left_top = { x = origin.x, y = origin.y },
    right_bottom = { x = origin.x + shared.layout.width, y = origin.y + shared.layout.length },
  }
end

local function draw_footprint(surface, origin, force, ticks)
  local area = footprint_area(origin)
  rendering.draw_rectangle{
    color = { 1, 0.6, 0.1 },
    width = 4,
    filled = false,
    left_top = area.left_top,
    right_bottom = area.right_bottom,
    surface = surface,
    forces = { force },
    time_to_live = ticks,
  }
end

--------------------------------------------------------------------------------
-- Searching: turn the wreck into a repair site, or place one if the wreck is gone
--------------------------------------------------------------------------------
local function search()
  if game.tick < (storage.search_from or 0) then return end
  local surface = home_surface()
  if not surface then return end

  local wreck = surface.find_entities_filtered{ name = shared.wreck_name, limit = 1 }[1]
  if wreck then
    local position, force = wreck.position, wreck.force
    spill_contents(wreck)
    wreck.destroy()
    if create_site(surface, position, force, 1) then
      tell(force, { "sesr.repair-started", gps(position, surface) })
      return
    end
  end

  -- No wreck (an older save, or it was removed): put a repair site near spawn.
  local force = game.forces["player"]
  local spawn = force.get_spawn_position(surface)
  local position = surface.find_non_colliding_position(shared.site_names[1], spawn, config.fallback_radius, 1)
  if position and create_site(surface, position, force, 1) then
    tell(force, { "sesr.repair-site-placed", gps(position, surface) })
  else
    warn(force, { "sesr.no-room-for-site", gps(spawn, surface), config.fallback_radius })
  end
end

--------------------------------------------------------------------------------
-- Repairing: move to the next stage when the current one finishes
--------------------------------------------------------------------------------
local function stage_finished(site, stage)
  local output = site.get_output_inventory()
  return output ~= nil and output.get_item_count(shared.token_names[stage]) > 0
end

local function repair()
  local site, stage = storage.site, storage.stage
  if not (site and site.valid) then
    -- The site has vanished (removed in the editor, for instance). Start again.
    storage.state = "searching"
    storage.search_from = game.tick
    return
  end
  if not stage_finished(site, stage) then return end

  local surface, position, force = site.surface, site.position, site.force
  if stage < shared.final_stage then
    spill_contents(site)
    site.destroy()
    local next_site = create_site(surface, position, force, stage + 1)
    if not next_site then
      storage.state = "searching"
      storage.search_from = game.tick
      return
    end
    tell(force, { "sesr.stage-complete-" .. shared.stage_keys[stage], gps(position, surface) })
    if stage + 1 == shared.final_stage then
      -- Show where the finished ship will stand, so the area can be kept clear.
      draw_footprint(surface, ship_origin(next_site), force, 60 * 20)
      tell(force, { "sesr.footprint-notice", shared.layout.width, shared.layout.length })
    end
  else
    storage.state = "clearing"
    storage.origin = ship_origin(site)
    storage.last_warning = nil
  end
end

--------------------------------------------------------------------------------
-- Clearing and building: replace the repair site with a working spaceship
--------------------------------------------------------------------------------
local removable_types = { tree = true, fish = true, cliff = true }

-- Sorts everything inside the footprint into things that are cleared away
-- automatically and things the player has to move.
local function survey(surface, origin, site)
  local area = footprint_area(origin)
  -- Shrunk slightly so entities that merely touch the outline are not counted.
  local inner = {
    left_top = { x = area.left_top.x + 0.05, y = area.left_top.y + 0.05 },
    right_bottom = { x = area.right_bottom.x - 0.05, y = area.right_bottom.y - 0.05 },
  }
  local removable, blockers, characters = {}, {}, {}
  for _, entity in pairs(surface.find_entities_filtered{ area = inner }) do
    local kind = entity.type
    if entity == site or kind == "resource" or kind == "corpse" or kind == "character-corpse"
      or kind == "item-entity" or kind == "entity-ghost" or kind == "tile-ghost" then
      -- Not in the way.
    elseif kind == "character" then
      table.insert(characters, entity)
    elseif removable_types[kind] or string.sub(entity.name, 1, 11) == "crash-site-"
      or (kind == "simple-entity" and entity.force.name == "neutral") then
      table.insert(removable, entity)
    else
      table.insert(blockers, entity)
    end
  end
  return removable, blockers, characters
end

local function place(surface, force, name, origin, offset, direction)
  local entity = surface.create_entity{
    name = name,
    position = { x = origin.x + offset.x, y = origin.y + offset.y },
    direction = direction,
    force = force,
    raise_built = true,
    create_build_effect_smoke = false,
  }
  return entity ~= nil
end

local function build_ship(surface, origin, force, site, removable, characters)
  local layout = shared.layout
  local position = site.position

  for _, entity in pairs(removable) do
    if entity.valid then
      if entity.type == "cliff" then
        entity.destroy({ do_cliff_correction = true })
      else
        if entity.type == "container" then spill_contents(entity) end
        entity.destroy()
      end
    end
  end
  spill_contents(site)
  site.destroy()
  storage.site = nil

  local tiles = {}
  for y = 0, layout.length - 1 do
    for x = 0, layout.width - 1 do
      table.insert(tiles, { name = shared.floor_tile, position = { x = origin.x + x, y = origin.y + y } })
    end
  end
  surface.set_tiles(tiles, true, false, true, true)

  local complete = true
  for _, wall in ipairs(shared.build_layout().walls) do
    complete = place(surface, force, shared.parts.wall, origin, { x = wall.x + 0.5, y = wall.y + 0.5 }) and complete
  end
  for _, gate in ipairs(layout.gates) do
    -- Gates sit in the side walls, so they run north to south.
    complete = place(surface, force, shared.parts.gate, origin, { x = gate.x + 0.5, y = gate.y + 0.5 }, defines.direction.north) and complete
  end
  complete = place(surface, force, shared.parts.tank, origin, layout.tank) and complete
  complete = place(surface, force, shared.parts.engine, origin, layout.engine) and complete
  -- The console goes in last: building it is what makes Space Exploration register
  -- the ship and check its hull, so everything else should already be there.
  complete = place(surface, force, shared.parts.console, origin, layout.console) and complete

  -- Anyone standing where a part now is gets moved to the nearest free spot.
  for _, character in pairs(characters) do
    if character.valid then
      local free = surface.find_non_colliding_position(character.name, character.position, 8, 0.25)
      if free then character.teleport(free) end
    end
  end

  storage.state = "done"
  storage.origin = nil
  tell(force, { complete and "sesr.ship-repaired" or "sesr.ship-repaired-incomplete", gps(position, surface) })
end

local function clear_and_build()
  local site, origin = storage.site, storage.origin
  if not (site and site.valid and origin) then
    storage.state = "searching"
    storage.search_from = game.tick
    return
  end
  local surface, force = site.surface, site.force
  local removable, blockers, characters = survey(surface, origin, site)
  if #blockers > 0 then
    draw_footprint(surface, origin, force, CHECK_INTERVAL + 5)
    local example = blockers[1]
    warn(force, { "sesr.footprint-blocked", #blockers, example.localised_name, gps(example.position, surface) })
    return
  end
  build_ship(surface, origin, force, site, removable, characters)
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------
script.on_init(setup_storage)
script.on_configuration_changed(setup_storage)

script.on_nth_tick(CHECK_INTERVAL, function()
  if not storage.state then return end
  if storage.state == "searching" then
    search()
  elseif storage.state == "repairing" then
    repair()
  elseif storage.state == "clearing" then
    clear_and_build()
  end
end)

-- Testing aid for admins: finishes the current repair stage at once.
commands.add_command("ship-repair-advance", { "sesr.command-advance-help" }, function(command)
  local player = command.player_index and game.get_player(command.player_index)
  if player and not player.admin then
    player.print({ "sesr.command-admin-only" })
    return
  end
  local reply = player and player.print or game.print
  local site = storage.site
  if storage.state ~= "repairing" or not (site and site.valid) then
    reply({ "sesr.command-nothing-to-advance", storage.state or "none" })
    return
  end
  -- The technology gate is skipped too, so the last stage can be tested directly.
  local output = site.get_output_inventory()
  if output then output.insert({ name = shared.token_names[storage.stage], count = 1 }) end
  reply({ "sesr.command-advanced", shared.stage_keys[storage.stage] })
end)

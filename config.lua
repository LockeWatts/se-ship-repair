-- All tunable numbers live here.
local config = {}

-- Share of the normal build cost that the repair needs (0.5 = half price, as salvage).
-- The normal cost is whatever the spaceship part recipes cost when the game loads,
-- multiplied by the number of each part in the repaired ship.
config.salvage_factor = 0.5

-- Each repair stage is done in equal steps, like a rocket silo building rocket parts:
-- the wreck's recipe is one step, and the stage is finished after this many of them.
-- The hull goes in 1% steps. The other two stages cost far less, so they use fewer,
-- larger steps to keep every amount a whole number.
config.stage_steps = { 100, 20, 20 }

-- Per-step amounts set by hand, by stage number, where the calculated one is awkward.
config.step_overrides = {
  [2] = { ["processing-unit"] = 10 },
}

-- Seconds one step takes once its materials are in.
config.step_time = 1

-- Ticks to wait after the mod starts before looking for the wreck, so the freeplay
-- scenario has created the crash site and its intro is under way (60 ticks = 1 second).
config.search_delay = 600

-- If the wreck no longer exists, a repair site is placed within this many tiles of spawn.
config.fallback_radius = 48

-- Ticks between repeated chat warnings while something is in the way.
config.warning_interval = 60 * 30

return config

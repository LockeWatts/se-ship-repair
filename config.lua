-- All tunable numbers live here.
local config = {}

-- Share of the normal build cost that the repair needs (0.5 = half price, as salvage).
-- The normal cost is whatever the spaceship part recipes cost when the game loads,
-- multiplied by the number of each part in the repaired ship.
config.salvage_factor = 0.5

-- Seconds each repair stage takes once its materials are in.
config.stage_time = 60

-- Ticks to wait after the mod starts before looking for the wreck, so the freeplay
-- scenario has created the crash site and its intro is under way (60 ticks = 1 second).
config.search_delay = 600

-- If the wreck no longer exists, a repair site is placed within this many tiles of spawn.
config.fallback_radius = 48

-- Ticks between repeated chat warnings while something is in the way.
config.warning_interval = 60 * 30

return config

# Space Exploration: Ship Repair

Your first spaceship is the one you crashed in.

In [Space Exploration](https://mods.factorio.com/mod/space-exploration), this mod turns the wreck at the crash site into a repair project. Finish it and the wreck is rebuilt, where it lies, as a working spaceship. It also adds crude recipes that make spaceships buildable from rocket science.

## How it works

The crashed ship becomes a repair site. Open it to see what the current stage needs, put the materials in, and wait for it to finish.

1. **Hull**: the floor, walls and gates.
2. **Systems**: the spaceship console.
3. **Propulsion**: the rocket engine and booster tank. This stage needs the new Spaceship repair technology.

When the last stage finishes, the wreck is replaced by a complete spaceship about its own size. It is an ordinary Space Exploration ship from then on: give it power and rocket fuel and it can launch.

Each stage costs a share (half, by default) of what the same parts cost to craft.

## Spaceships at rocket science

Space Exploration's own spaceship recipes, and the technologies that unlock them, are left as they are. Alongside them this mod adds a crude way to build:

- **Crude recipes** for every spaceship part, made from early-game materials and deliberately costly.
- **Crude technologies** that unlock them: a crude Spaceship technology in the cargo rocket launch pad's place, and crude clamp and ion engine technologies after it.

Spaceship repair sits beside the launch pad at rocket science, and the crude Spaceship technology follows it. You repair your first ship, learn to build crude ones, and reach Space Exploration's proper recipes when you get to them.

Two of Space Exploration's own prototypes do change. The spaceship integrity technologies move earlier, so an early ship can grow, and space pipes can be crafted on the ground.

## Good to know

- The wreck can no longer be mined or destroyed.
- The finished ship needs a 12 x 21 tile area centred on the wreck. It is outlined when the last stage begins. Trees, rocks and loose wreckage are cleared automatically; anything you built there has to be moved first, and the mod tells you what is in the way.
- Added to an existing save where the wreck is gone, the mod places a repair site near spawn.
- Repair costs and timings are set in `config.lua`, the ship's layout in `shared.lua`, and the crude part recipes in `crude-recipes.lua`.
- The ship has a tapered nose and scores 100% on Space Exploration's streamlining.

## Requirements

- Factorio 2.1
- Space Exploration 0.7.64 or later

It replaces Space Exploration: Early Spaceships and cannot be used alongside it.

## Credits

Space Exploration is by Earendel. Where the crude technologies sit follows the design of Early Spaceships by stringweasel; see `NOTICE.md`. This mod contains none of Space Exploration's code or artwork.

# Space Exploration: Ship Repair

Your first spaceship is the one you crashed in.

In [Space Exploration](https://mods.factorio.com/mod/space-exploration), this mod turns the wreck at the crash site into a repair project. Finish it and the wreck is rebuilt, where it lies, as a working spaceship. It also adds crude recipes that make spaceships buildable from rocket science.

## How it works

The crashed ship becomes a repair site, and each stage is done a little at a time, the way a rocket silo builds a rocket. Open the wreck to see what one step needs and, in the panel beside it, how far the stage has come. Keep it supplied and it keeps going.

1. **Hull** (100 steps): the floor, walls and doors.
2. **Systems** (20 steps): the spaceship console.
3. **Propulsion** (20 steps): the rocket engines and booster tanks. This stage needs the new Spaceship repair technology.

When the last stage finishes, the wreck is replaced by a complete spaceship about its own size. It is an ordinary Space Exploration ship from then on: give it power and rocket fuel and it can launch.

In total each stage costs about half of what the same parts cost to craft with the crude recipes, which is close to what Space Exploration's own recipes would charge.

## Spaceships at rocket science

Space Exploration's own spaceship recipes, and the technologies that unlock them, are left as they are. Alongside them this mod adds a crude way to build:

- **Crude recipes** for every spaceship part ("Crude spaceship floor" and so on). They make the same parts from the materials rockets are built of, at about twice the raw material cost of the proper recipes.
- **Crude technologies** that unlock them: a crude Spaceship technology in the cargo rocket launch pad's place, and crude clamp and ion engine technologies after it.

Spaceship repair sits beside the launch pad at rocket science, and the crude Spaceship technology follows it. You repair your first ship, learn to build crude ones, and reach Space Exploration's proper recipes when you get to them.

Two of Space Exploration's own prototypes do change. The first two spaceship integrity levels move earlier, so an early ship can grow a little, and space pipes can be crafted on the ground.

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

Released under the MIT licence; see `LICENSE`.

# Space Exploration: Ship Repair

Your first spaceship is the one you crashed in.

In [Space Exploration](https://mods.factorio.com/mod/space-exploration), this mod turns the wreck at the crash site into a repair project. Finish it and the wreck is rebuilt, where it lies, as a working spaceship. It also brings spaceships forward to rocket science, so you never need a cargo rocket.

## How it works

The crashed ship becomes a repair site. Open it to see what the current stage needs, put the materials in, and wait for it to finish.

1. **Hull**: the floor, walls and gates.
2. **Systems**: the spaceship console.
3. **Propulsion**: the rocket engine and booster tank. This stage needs the new Spaceship repair technology.

When the last stage finishes, the wreck is replaced by a complete spaceship about its own size. It is an ordinary Space Exploration ship from then on: give it power and rocket fuel and it can launch.

Each stage costs a share (half, by default) of what the same parts cost to craft.

## Spaceships at rocket science

The Spaceship technology moves to the cargo rocket's place in the tree, and the clamp, integrity and ion engine technologies move earlier to match.

Every spaceship part has two recipes:

- **Early**: made from early-game materials, and deliberately costly. Unlocked with the part's technology.
- **Refined**: Space Exploration's original recipe, unlocked by a "Refined" technology where Space Exploration originally unlocked the part.

Spaceship repair sits beside the launch pad at rocket science, and Spaceship follows it. You repair your first ship, then learn to build new ones.

## Good to know

- The wreck can no longer be mined or destroyed.
- The finished ship needs a 12 x 21 tile area centred on the wreck. It is outlined when the last stage begins. Trees, rocks and loose wreckage are cleared automatically; anything you built there has to be moved first, and the mod tells you what is in the way.
- Added to an existing save where the wreck is gone, the mod places a repair site near spawn.
- Repair costs and timings are set in `config.lua`, the ship's layout in `shared.lua`, and the early part recipes in `early-recipes.lua`.
- The ship has a tapered nose and scores 100% on Space Exploration's streamlining.

## Requirements

- Factorio 2.1
- Space Exploration 0.7.64 or later

It replaces Space Exploration: Early Spaceships and cannot be used alongside it.

## Credits

Space Exploration is by Earendel. The move of spaceships to rocket science follows the design of Early Spaceships by stringweasel; see `NOTICE.md`. This mod contains none of Space Exploration's code or artwork.

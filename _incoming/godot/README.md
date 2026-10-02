# LTTP Roguelike — Godot 4 scaffold

A minimal-but-real vertical slice for a top-down **A-Link-to-the-Past-style roguelike**.
It exists so Kiro's `tasks.md` has a target to build against — movement, generation and the
combat "feel" systems are already wired; art, enemies, items and real room generation are not.

> ⚠️ **Unvalidated.** This scaffold was authored *without* Godot installed on the machine that
> wrote it. The scripts are written to Godot 4.x conventions and reviewed by eye, but the project
> has not been opened/imported, so treat first-run errors as expected and fix-on-open.

## Run it

1. Godot **4.3+** → *Import* → select `godot/project.godot` → *Import & Edit*.
2. Press **F5**. You get a generated dungeon: a green player, brown walls, orange door markers.
3. Walk into a wall edge with a door to move between rooms. Press **I** to print run state
   (seed / depth / hearts / room) to the console.

## Controls (keyboard ↔ SNES)

| Keyboard | SNES | Action |
|---|---|---|
| WASD / Arrows | D-Pad | Move (8-directional) |
| **J** or **Z** | B | Sword — tap to swing, **hold ~2 s then release = Spin Attack** |
| **K** or **X** | A | Interact (context: lift/throw/pull/talk/chest/swim/dash) — **stub** |
| **L** or **C** | Y | Use equipped item — **stub** |
| **M** or Tab | X | Map — **stub** |
| **I** or Enter | Start | Inventory / pause — prints run state |

Input actions are created at runtime in `scripts/Game.gd` (`_setup_input_map`) so the project has no
fragile `InputMap` section in `project.godot`. Move them to Project Settings → Input Map whenever.

## What already works

- **Seeded run** (`Game.gd` autoload): one `RandomNumberGenerator`, seed printed and shareable.
- **Dungeon generation** (`DungeonGenerator.gd`): N rooms scattered on a cell grid, orthogonally
  connected, start + far exit tagged, and a **hard reachability assertion** before play.
- **Room model** (`Room.gd`): 16×14 tile grid = 256×224 px, door cells, world↔tile helpers.
- **Player state machine** (`Player.gd`): `IDLE / WALK / CHARGE / ATTACK / SPIN / HURT`, 8-direction
  movement, wall sliding, the ~2 s charge → spin, and the damage feel: **knockback + i-frames +
  passive facing-based shield**.
- **Feel tunables** (`Feel.gd`): every number in one place, with the reference's confidence flags.
- Rendering: `Main.gd` draws the current room and moves the player between rooms.
- **Enemies + bestiary** (`Bestiary.gd`, `Enemy.gd`, `Spawner.gd`, `Projectile.gd`): 7 biomes, ~40
  enemies across 9 AI archetypes, spawns from the run seed, per-biome floor/wall colours, a boss in
  the exit room, and a depth≥5 "corrupted elite" leak of techno enemies into any biome.
- **Items & Attunement** (`Items.gd`, `Inventory.gd`, `Meta.gd`, `Pickup.gd`): attacks are locked
  behind items — you start with only a swing, and the **Spin Attack is gated behind the Knights'
  Crest**. Clear the dungeon carrying an ATTACK/UTILITY item and it is **Attuned** (saved to
  `user://meta.json`, permanent, granted from the start of every future run). Die and the run's finds
  are lost. Pedestals drop unowned items; the boss always drops one.
- **The boss ladder** (`BossRoster.gd`, `Boss.gd`): **one boss per dungeon**. Dungeon #1 is the
tutorial **dragon**; each *cleared* dungeon (`Meta.clears()`) advances the ladder one rung through
**100 escalating bosses**. `Boss.gd` runs a phase machine over 7 telegraphed patterns (breath,
volley, stomp, ring, charge, laser, summon) with a post-breath **weak window**. A boss HP bar draws
top-centre. Press **F1** to unlock every item for the current run (sandbox — never persists).

## What is stubbed / next (feed these to Kiro's tasks)

1. **Real room generation** — the tile grids are empty sockets; add layout generators + tile sets.
2. **Enemies** — none yet. They should call `player.take_damage(hp, from_pos)` and respect contact
   damage + knockback + i-frames. Test `player.attack_box()` against them for sword hits.
3. **Interaction verbs** — `Player._interact()` is a stub; resolve by the tile/entity in front of
   `facing` (lift / throw / pull / push / open / talk / swim).
4. **Dash (Pegasus Boots)** — `Game.has_pegasus_boots` exists; wire a dash state (hold interact)
   that cannot turn, damages on contact, and smashes pots/cracks.
5. **Items + gated placement** — an item pool shuffled so runs stay completable; extend
   `Reachability` with item-gate logic.
6. **Depth scaling, permadeath, meta-progression** — see `00-LTTP-controls-and-feel.md` §7.
7. **HUD** — hearts, equipped item, seed, depth. Currently only console prints.
8. **Art/audio** — all original placeholders; no Nintendo assets.

## Files

```
godot/
  project.godot          # Godot 4 project (256x224 viewport, Game autoload)
  icon.svg
  scenes/
    Main.tscn            # root Node2D -> Main.gd
    Player.tscn          # CharacterBody2D -> Player.gd (+ placeholder Polygon2D)
  scripts/
    Feel.gd              # tunables (feel numbers, with confidence flags)
    Game.gd              # autoload: seed, RNG, run state, runtime input map
    Room.gd              # 16x14 tile grid + doors + biome
    Reachability.gd      # BFS over the room graph (the generation gate)
    DungeonGenerator.gd  # minimal procedural dungeon (assigns biome by depth)
    Player.gd            # state machine + movement + damage feel
    Bestiary.gd          # biome + enemy tables (data-driven)
    Enemy.gd             # base enemy: archetype AI + contact damage + knockback + i-frames
    Projectile.gd        # straight / lob / laser / spread shots (player + enemy)
    Spawner.gd           # seeds a room's enemies from the biome + depth
    Items.gd             # item + power-up catalogue (attack/utility/passive/consumable)
    Inventory.gd         # this run's items + the permanent Attuned set
    Meta.gd              # persistence: user://meta.json (Attunement + clears)
    Pickup.gd            # pedestal item you walk into
    BossRoster.gd        # the 100-boss ladder (rank 1 = dragon), scaled by clears
    Boss.gd              # boss phase machine + the 7 attack patterns
    Main.gd              # bootstrap + room rendering + enemy/item drops + clear/attune loop
```

## Design reference

`../00-LTTP-controls-and-feel.md` — how the original LTTP controls and feels (sourced), plus the
roguelike deltas and a ready-to-paste Kiro prompt (`../kiro-prompt.md`).

`../01-bestiary.md` — the full enemy roster: archetypes, 7 biomes, bosses, spawn rules.

`../02-items-and-powerups.md` — items, power-ups, attack unlocks, and the Attunement loop.

`../03-bosses.md` — boss framework, the dragon (boss #1), biome bosses, loot.

`../04-boss-roster-100.md` — all 100 bosses, escalating, sad fantasy + techno.

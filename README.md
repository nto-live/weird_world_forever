# Weird World Forever

A top-down, *A Link to the Past*-style action-adventure **roguelike** built in **Godot 4 (GDScript)**.

Every run begins and ends in **Vigil**, the last warm town. From there you descend into a single
seeded, procedurally generated dungeon of screen-sized rooms, fight through seven biomes to one of a
100-boss ladder, and recover a mysterious artifact. Attack and utility items you carry through a
**clear** become permanent (**Attunement**); death costs you the run but not your permanent progress.
The mood is sad fantasy fused with techno-future: cold neon against warm decay.

> Status: **spec + scaffold**. This repo currently holds the design documentation and an early,
> unvalidated Godot 4 scaffold. Full implementation follows the task plan.

## Repository layout

```
.kiro/specs/procedural-zelda-game/   The spec (source of truth)
  requirements.md                    50 EARS requirements across Systems A-T
  design.md                          Godot 4 architecture, generation pipeline, properties
_incoming/                           Reference docs + the Godot 4 scaffold
  00-LTTP-controls-and-feel.md       LTTP control/feel reference
  01-bestiary.md                     Enemies, archetypes, biomes
  02-items-and-powerups.md           Items + the Attunement loop
  03-bosses.md                       Boss framework + the dragon
  04-boss-roster-100.md              The 100-boss ladder
  05-town-bar-restaurant.md          Vigil: hub, bar, restaurant, NPCs
  06-graphics.md                     Art direction + pipeline
  godot/                             Godot 4 project scaffold (GDScript)
```

## Getting started

Requires **Godot 4.3+** (GL Compatibility renderer).

1. Open Godot 4, choose *Import*, and select `_incoming/godot/project.godot`.
2. Press **F5** to run the current scaffold.

> Note: the scaffold was authored without Godot installed, so treat first-run import errors as
> expected and fix-on-open. See `_incoming/godot/README.md` for what already works vs. what is stubbed.

### Controls (scaffold)

| Keyboard | SNES | Action |
|---|---|---|
| WASD / Arrows | D-Pad | Move (8-directional) |
| J / Z | B | Sword (tap = swing, hold ~2s = spin) |
| K / X | A | Context action (lift/throw/talk/dash) |
| L / C | Y | Use equipped item |
| M / Tab | X | Map |
| I / Enter | Start | Inventory / pause |

## Working with the spec

The `.kiro/specs/procedural-zelda-game/` documents are the source of truth. Requirements use EARS;
the design maps every requirement onto the Godot scaffold with a Keep/Extend/Replace plan, correctness
properties (determinism + reachability are the headliners), and a graphics system (640x448 HD pixel
art, free-scroll camera). Update the spec before changing behavior.

## Development conventions

- **GDScript** uses tabs for indentation (see `.editorconfig`).
- Line endings are normalized to LF via `.gitattributes`.
- All feel numbers live as configurable tunables (`Feel.gd`), never scattered constants.
- Generation draws from a single seeded RNG; never use global `randi()` / `randf()`.

## Assets & licensing

All art and audio are original placeholders. **No Nintendo assets** are used or distributed. See
`LICENSE` for terms.

## Changelog
- **2026-10-03** — Graphical direction moved to a **32px grid** (tiles 32×32, player 32×48, view 640×448, ×3 = 1920×1344); biome worlds are large **maze-like** regions ≈ **128×112 tiles** (8×8 LTTP screens), rooms up to 80×56 tiles; health pip is an **emerald leaf**. Design docs only — no code.

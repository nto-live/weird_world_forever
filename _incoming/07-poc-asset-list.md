# POC Asset List — Grasslands + One Short Dungeon

**Scope:** the first-iteration tutorial / proof-of-concept vertical slice (Requirement 56.7-56.11):
Vigil -> Grasslands (Route_Length 1) -> short dungeon (~5-8 rooms) -> Gloamwing tutorial boss ->
amulet -> return to Vigil. This is the complete graphical asset set needed to make that loop playable.

All sizes follow `06-graphics.md` (LOCKED): 16x16 tiles, 320x224 canvas, modern HD pixel art,
nearest-neighbour, integer scaling. Everything is referenced as data (via `AssetResolver`) so final
art swaps in for procedural placeholders without code changes.

## Conventions
- **Pixel canvas:** 320x224 (20x14 tiles). **Tile:** 16x16.
- **Player:** 16x24. **Enemies:** 16/24/32/48 by class. **Boss:** 64/96/128+. **UI:** 8/16. **Font:** 8x8 or 16x16.
- **Mood:** sad fantasy + techno-future; grasslands skews warm/organic for the gentle tutorial.
- Emissive pixels (fireflies, magic, lantern) feed selective bloom.

## 1. Player (16x24, 4-directional) - one sheet
Clips: idle, walk, attack, charge, spin, hurt, dash, lift-carry, death. (swim / push-pull optional
for the POC if the tutorial has no water or push-blocks.)
Starter look: white shirt, brown shorts, barefoot ("sad-but-trying"). Sword/mail/shield tiers can be
palette/overlay swaps later.

## 2. Grasslands tileset (16x16)
- Floor: 3-5 grass variants (plain, tufted, flowered, worn/path).
- Wall: 2-3 variants + a top face (for the 3/4 overhead look).
- Autotile corners/edges (Godot TileSet terrain set) for grass<->wall transitions.
- Path / dirt tiles; door / threshold tiles.
- Decorations: 4-8 (bush, rock, flower cluster, tree, sign, fence).
- Lights: 1-2 emissive tiles (lantern / torch).
- One signature prop (a lone standing stone or small shrine).
- Overlay: drifting FIREFLIES particle art (the grassland/woods ambient overlay).

## 3. Dungeon tileset (16x16) - the short first dungeon
- Floor: 2-3 variants; Wall: 2-3 + top face; autotile edges.
- Door tiles: open + LOCKED variant; key pickup sprite.
- Cracked-wall tile (bomb-openable gate).
- Chest + pedestal sprites.
- Optional single hazard tile if the tutorial uses one.

## 4. Enemies - Grasslands tutorial roster (3 sheets)
Each sheet: idle, walk, attack, hurt, death. Teaches telegraph -> dodge -> punish.
| Enemy | Archetype | Size | Notes |
|---|---|---|---|
| Field Critter (hopping rodent/beetle) | PATROL | 16px | fodder; walks a fixed path |
| Meadow Hound (wild dog) | CHASE | 24px | pursues within aggro range |
| Thistle Boar (horned charger) | CHARGER | 24px | **requires a distinct telegraph/wind-up frame** (gameplay-critical), then dash |

(Names/stats are data-driven per Req 19; roster composition patrol+chase+charger is fixed for the POC per Req 56.11.)

## 5. Boss - Gloamwing, the tutorial dragon (64-128px)
Clips: idle, telegraph, 1-3 attacks, hurt, phase-transition, death. Optional name-card portrait.
Gentle/slow/honest tutorial boss (Req 51.8); patterns from breath/stomp/volley/charge.
Guaranteed loot drop: bombs + fire rod (per the boss framework).

## 6. VFX
Sword arc, spin ring, hit spark, grassland ichor (sap), projectile trail (ranged enemies / boss),
bomb burst, dust, and the PICKUP VFX: purple-sparkle cloud + green leaves (shown on spawn and
collect, Req 52.6).

## 7. Items / pickups (8/16px icons)
Starter sword, boss-reward item(s) (bombs, fire rod), bomb ammo, arrow ammo, key, health pickup,
chevron token(s), spark, and the amulet (the run artifact).

## 8. UI (8/16px + one pixel font)
- Hearts using the EVOLVING health-container icon - leaf form for early game (Req 41).
- Equipped-item box; boss HP bar.
- Inventory-screen frame: worn-gear slots (helmet / body-clothes / shoes) + Armor_Type (Tactical/Armor),
  consumables/potions panel (with modifier+heal values), ammo panel (arrows/bombs/bullets).
- Title-screen title/logo (Start New Run / Continue Saved Run / Exit).
- One pixel font (8x8 or 16x16).

## 9. Folder targets (res://art/, per 06-graphics.md)
```
res://art/
  characters/            # player (16x24), human NPCs
  enemies/grasslands/    # field_critter, meadow_hound, thistle_boar
  bosses/                # gloamwing (+ optional name-card portrait)
  tilesets/grasslands/   # floor/wall/door/deco/light/transition/signature-prop
  tilesets/dungeon/      # floor/wall/door(+locked)/cracked-wall/chest/pedestal/key
  overlays/grasslands/   # fireflies
  vfx/                   # sword arc, spin ring, spark, ichor, bomb burst, dust, pickup_cloud, pickup_leaves
  ui/                    # health icon (leaf), item box, boss bar, inventory frame, title, font
```

## Notes
- Grasslands is authored as a NEW data-driven base Biome (Req 56.10); it is plain (no Biome_Variant) in the POC.
- Until final art lands, the upgraded procedural placeholder generator (3-tone ramps + outline +
  dither + a signature prop) stands in, so the slice is playable with placeholders first.
- This list is the first-iteration graphical scope only; later biomes/variants/content are authored incrementally.
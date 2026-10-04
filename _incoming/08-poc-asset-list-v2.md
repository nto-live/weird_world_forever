# POC Asset Build List v2 — Dark Room + Grasslands + One Short Dungeon

**Supersedes** `07-poc-asset-list.md` for the current slice. This is the complete art set needed to
build and play the first-iteration tutorial / proof-of-concept vertical slice.

**Slice loop:** Dark_Room (start hub) → pick loadout + level → Grasslands → short dungeon
(~5–8 rooms, incl. one Choice_Room) → Gloamwing boss → amulet → return to Dark_Room →
Post_Run_Choice on a successful Clear.

**Spec basis:** Requirements 56.7–56.11 (POC scope + Grasslands roster), 73 (Dark Room start hub),
74 (Choice Rooms), and System Z (64–72) for all locked sizes. Everything is referenced as data via
`AssetResolver` so final art swaps in over procedural placeholders with no code change.

## Loadout decision (current)

The first slice ships **Sword / Nothing** only. The **Pistol and all other firearms (Req 75) and the
Knight/Cyberpunk armor sets (Req 76) are deferred** — they remain in the full-game spec but are NOT
required to finish the POC. All gun art (gun poses, muzzle flash, bullet, bullet ammo icon/panel) is
out of this list.

## Conventions (LOCKED, per `06-graphics.md` / System Z)

- **Canvas:** 320×224 (20×14 tiles). **Tile:** 16×16. **Player:** 16×24.
- **Enemies:** 16 / 24 px (this roster). **Boss:** 64–128 px. **UI icons:** 8 / 16. **Font:** 8×8.
- Modern HD pixel art, nearest-neighbour, integer scaling, no runtime rotation/scale.
- Emissive pixels (TV glow, lanterns, fireflies, bomb burst) feed the lighting / selective-bloom pass.
- **Author the 12-piece autotile terrain set per tileset FIRST** (4 outer corners, 4 edges, 4 inner
  corners) — rooms will not assemble cleanly without it. Cosmetic variants come after.

---

## A. Main Character — one sheet, 16×24, 4-directional

Author each clip in all 4 directions (up / down / left / right). Starter look: white shirt, brown
shorts, barefoot (""sad-but-trying""). Sword/mail/shield tiers are palette/overlay swaps later.

**Required clips (POC):**
- idle (2), walk (6), attack — sword swing (3), charge (2), spin (4), hurt (1), dash (4),
  lift-carry (2 + 2), death (4).

**Deferred (only if the dungeon later gets water or push-blocks):** swim (4), push-pull (2). The POC
dungeon has neither, so skip for now.

---

## B. Dark Room (start hub) tileset + props — 16×16

The first screen the player sees: a small, dim interior.

**Floor / walls**
- Dark floor — base + 1–2 subtle variants.
- Dark wall body + wall top face.
- Autotile terrain set (floor↔wall): 12 pieces.

**Signature props (interactable)**
- TV_Screen — frame / cabinet tile(s).
- TV_Screen — emissive ""on"" screen, 1–2 glow states (this is the Level_Select display; feeds bloom).
- Loadout stand / rack — base.
- Loadout rack — **sword** displayed.
- Loadout rack — **""nothing"" / empty** marker.
- Exit door / portal threshold into the chosen level (closed + open).

**Ambience**
- 1 emissive accent (dim wall light or the TV's floor-glow spill).

---

## C. Grasslands tileset + props — 16×16

**Floor**
- Grass — 3–5 variants (plain, tufted, flowered, worn/path).

**Walls (3/4 overhead)**
- Grass wall body — 2–3 variants + wall top face.

**Autotile terrain set (grass↔wall):** 12 pieces.

**Paths & thresholds**
- Dirt / path — 2–3 tiles.
- Dungeon-entrance threshold tile (field → dungeon transition).

**Decorations (placed objects) — pick 4–8**
- bush, rock, flower cluster, tree, sign, fence.

**Lights (emissive)**
- lantern / torch — 1–2.

**Signature prop (Req 56)**
- lone standing stone OR small shrine.

**Ambient overlay (particle art, not a tile)**
- drifting fireflies.

---

## D. Short Dungeon tileset + props — 16×16

Starts at the dark entry room; ~5–8 rooms including one Choice_Room and the boss antechamber.

**Floor / walls**
- Dungeon floor — base + 2 alt variants (cracks / stain).
- Dungeon wall body — base + 1–2 variants + wall top face.
- Autotile terrain set (floor↔wall): 12 pieces.

**Doors & progression**
- Door — open.
- Door — LOCKED variant.
- Door frame / threshold trim (N/S + E/W if they differ by axis).
- Entry / stair-down tile (start cell).
- Cracked wall — bomb-openable + broken-open state.

**Room contents**
- Chest — closed + open.
- Pedestal — item pedestal.

**Choice_Room (Req 74)** — reuses dungeon tiles plus:
- Choice plinth / stand — the ""item on offer"" stand (place N of them; N is a Tunable).
- Plinth — ""taken / empty"" state after the pick.

**Boss antechamber (prefab chunk — hand-authored pattern, not autotiled)**
- Boss door — closed + open.
- Boss arena floor accent — 1–2 tiles so the arena reads distinct.

**Optional (only if the tutorial uses one hazard)**
- single hazard tile (spikes or pit) + safe/off state.

---

## E. Enemies — Grasslands tutorial roster (3 sheets)

Each sheet: idle, walk, attack, hurt, death. Teaches telegraph → dodge → punish.

| Enemy | Archetype | Size | Must-have |
|---|---|---|---|
| Field Critter (hopping rodent/beetle) | PATROL | 16px | fodder; fixed path |
| Meadow Hound (wild dog) | CHASE | 24px | pursue pose |
| Thistle Boar (horned charger) | CHARGER | 24px | **distinct telegraph / wind-up frame** (gameplay-critical) + dash pose |

Names/stats are data-driven (Req 19); roster composition patrol + chase + charger is fixed (Req 56.11).

---

## F. Boss — Gloamwing, the tutorial dragon (64–128px, one sheet)

Clips: idle, telegraph, 1–3 attacks, hurt, phase-transition, death. Optional name-card portrait.
Gentle / slow / honest tutorial boss (Req 51.8); patterns from breath / stomp / volley / charge.
Guaranteed loot drop on defeat (the amulet + boss-reward tool(s)).

---

## G. VFX (small sheets / particle art)

- sword arc, spin ring, hit spark.
- grassland ichor / sap (enemy hit).
- projectile trail (ranged enemy / boss breath).
- bomb burst, dust.
- **PICKUP VFX (Req 52.6):** purple-sparkle cloud + green leaves (on spawn and on collect).

*(Gun muzzle flash / bullet VFX deferred with the pistol.)*

---

## H. Items / Pickups (8 / 16px icons)

- starter **sword** icon.
- bomb icon + bomb-ammo.
- arrow-ammo icon (if arrows appear in the slice).
- key.
- health pickup.
- chevron token(s).
- spark (currency).
- **amulet** (the run artifact / Gloamwing reward).
- boss-reward item icon(s) per the boss framework.

*(Pistol icon + bullet-ammo icon deferred.)*

---

## I. UI (8 / 16px + one pixel font)

- Hearts — **evolving health-container icon, leaf form** for early game (Req 41).
- Equipped-item box.
- Boss HP bar.
- Ammo panel (bombs / arrows). *(bullets deferred with the pistol.)*
- Inventory-screen frame: worn-gear slots (helmet / body / shoes) + Armor_Type (Tactical / Armor),
  consumables / potions panel, ammo panel.
- **Dark_Room Level_Select UI** (TV content: unlocked-level list; POC shows GRASSLANDS only).
- **Dark_Room loadout prompt UI** — **Sword / Nothing**.
- **Post_Run_Choice UI** (one of: new weapon / level unlock / perk).
- **Choice_Room offer UI** (N items, pick one).
- Title-screen title / logo (Start New Run / Continue Saved Run / Exit).
- one pixel font (8×8).

---

## Folder targets (`res://art/`)

```
res://art/
  characters/            # player (16x24)
  rooms/darkroom/        # dark floor/wall + TV screen, loadout rack, exit door
  tilesets/grasslands/   # floor/wall/door/deco/light/transition/signature-prop
  tilesets/dungeon/      # floor/wall/door(+locked)/cracked-wall/chest/pedestal/key/choice-plinth/boss-antechamber
  enemies/grasslands/    # field_critter, meadow_hound, thistle_boar
  bosses/                # gloamwing (+ optional name-card portrait)
  overlays/grasslands/   # fireflies
  vfx/                   # sword arc, spin ring, spark, ichor, bomb burst, dust, pickup_cloud, pickup_leaves
  ui/                    # health icon (leaf), item box, boss bar, inventory frame,
                         #   darkroom level-select, loadout prompt, post-run choice, choice-room offer, title, font
```

---

## Build order (fastest path to a playable slice)

1. **MC base sheet** (A) — nothing moves without it.
2. **Dark Room** (B) — first screen; gets you to Level_Select.
3. **Grasslands** (C) + fireflies.
4. **Dungeon** (D) incl. Choice_Room + boss antechamber.
5. **3 enemies** (E), then **Gloamwing** (F).
6. **VFX** (G) + **item icons** (H) + **UI** (I) last, as polish over placeholders.

**Within each tileset, author the 12-piece autotile terrain set first.** Everything resolves through
`AssetResolver`, so drop assets in one at a time and each replaces its procedural placeholder.

## Notes

- Loadout for this slice is **Sword / Nothing**; Pistol / firearms (Req 75) and Knight/Cyber armor
  (Req 76) are deferred — in the spec, out of the POC build.
- Grasslands is a NEW data-driven base Biome (Req 56.10), plain / no Biome_Variant in the POC (Req 58.10).
- Until final art lands, the upgraded procedural placeholder generator (3-tone ramp + outline + dither
  + signature prop) stands in, so the slice is playable with placeholders first.
- This is first-iteration graphical scope only; later biomes / variants / firearms / armor are authored
  incrementally.
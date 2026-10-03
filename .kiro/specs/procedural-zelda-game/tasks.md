# Implementation Plan: Procedural Zelda Game — Graphics / Presentation Layer (System Z)

## Overview

This plan implements **System Z — Graphics & Presentation Layer only** (Requirements 64–72:
`REQ-GFX-` / `REQ-RES-` / `REQ-CAM-` / `REQ-ROOM-` / `REQ-SPR-` / `REQ-TILE-` / `REQ-ART-REF-` /
`REQ-ART-PIPE-` / `REQ-UI-`), plus the **System Z Config Constants (LOCKED)** subsection and
Requirement 48 criteria 4–5 (every presentation-layer size/scale factor is a named config constant,
never a bare literal). This is the **presentation layer the user asked to spec — it is NOT the full
game task plan.** Gameplay systems (combat, generation beyond room sizing, economy, bosses, etc.)
are out of scope here except where a presentation task must wire into them.

The work extends the Godot 4 (GDScript) scaffold under `_incoming/godot/` and follows the design's
**System S — Graphics & Art Direction** section: the 320×224 pixel canvas, integer scaling, the
`Camera2D` free-scroll rig, the `AssetResolver` data-driven swap-in, and the Keep/Extend/Replace
table. The design uses GDScript throughout (not pseudocode), so all tasks are written for **GDScript
/ Godot 4**.

### Config-constant discipline (Req 48.4 / 48.5, System Z constants)

Every size or scale factor below MUST come from a named config constant. **No task may hardcode any
of these as a bare literal.** The LOCKED constants are:

`TILE_PX` (16), `PLAYER_W` (16), `PLAYER_H` (24), `VIEW_W` (320), `VIEW_H` (224),
`VIEW_TILES_W` (20), `VIEW_TILES_H` (14), `ROOM_MAX_TILES_W` (40), `ROOM_MAX_TILES_H` (28),
`ROOM_MAX_W` (640), `ROOM_MAX_H` (448), `SCALE_PRIMARY` (6), `SCALE_FALLBACK` (5), `DISPLAY_W` (1920),
`DISPLAY_H` (1344), `FALLBACK_DISPLAY_W` (1600), `FALLBACK_DISPLAY_H` (1120), `PLAYER_RENDER_W` (96),
`PLAYER_RENDER_H` (144), `SHEET_MAX_PX` (2048), `UI_SMALL` (8), `UI_LARGE` (16), `FONT_CELL` (8).
Enemy/boss sprite tiers are also named constants: `ENEMY_TIERS` (16, 24, 32, 48) and
`BOSS_TIERS` (64, 96, 128).

## Scaffold alignment: extend vs. replace vs. new (presentation layer)

This mapping aligns the task list with the actual scaffold at `_incoming/godot/scripts/`. **Nothing
in this presentation layer is a wholesale REPLACE** — existing feel/room/entity scripts are extended,
not rewritten.

**EXTEND (scripts that already exist in the scaffold):**
- `Feel.gd` — holds the LOCKED System Z config constants. **Discrepancy note:** `Feel.gd` currently
  carries the pre-System-Z room model (`TILE = 16`, `ROOM_W = 16`, `ROOM_H = 14` → 256×224, the
  room-equals-view assumption of Requirement 27). System Z supersedes this: the VIEW is
  `VIEW_TILES_W × VIEW_TILES_H` (20 × 14 = 320 × 224) and a ROOM may be larger (up to 40 × 28). The
  config task reconciles `Feel.gd` to the System Z constants.
- `Room.gd` + `DungeonGenerator.gd` — big rooms on the grid (20×14 up to 40×28), density-by-area.
- `Player.gd` / `Enemy.gd` / `Boss.gd` — wire sprite clips to the existing state machines.
- The `Camera2D` rig from the design (already specified as a Player-child free-scroll rig) — extend
  it with dead-zone follow + pixel-snap + room-bounds clamp.
- `Main.gd` — render/scene wiring (viewport, stitched bounds, HUD/Overlay layers, camera limits).
- `Reachability.gd` — re-verify reachability still holds for big rooms (no code change expected; a
  verification hook).

**NEW (scripts/resources/tooling that do not exist in the scaffold):**
- `GfxConfig.gd` — OPTIONAL dedicated config autoload for presentation constants if not folded into
  `Feel.gd`. (This plan folds the System Z constants into `Feel.gd` per the design, and treats
  `GfxConfig.gd` as the alternative home.)
- `Lighting.gd` — **does NOT exist in the scaffold**; create it (`CanvasModulate` + `PointLight2D`).
- `Ambience.gd` — **does NOT exist in the scaffold**; create it (ambient atmosphere driver).
- `Vfx.gd` — **does NOT exist in the scaffold**; create it (`CPUParticles2D` particle effects).
  > The user's request mentioned `Lighting.gd` / `Ambience.gd` / `Vfx.gd` as if present. They are
  > not in the scaffold, so they are created new here (not extended).
- HUD / UI `CanvasLayer` (`HUD.gd` + scene) — screen-space pixel-grid UI (per the design's NEW HUD).
- `SpriteFrames` resources (player + enemy/boss clip sets) and per-biome `TileSet` resources.
- `AssetResolver.gd` — data-driven art swap-in (NEW per the design).
- Art-pipeline tooling + an originality/non-shipping guard (slice → resample → hand-edit → scrub).

## Tasks

- [ ] 1. Define System Z config constants (central, named, LOCKED)
  - Extend `Feel.gd` (scaffold) with all System Z LOCKED constants as named, `exact`-flagged config
    values: `TILE_PX`, `PLAYER_W`, `PLAYER_H`, `VIEW_W`, `VIEW_H`, `VIEW_TILES_W`, `VIEW_TILES_H`,
    `ROOM_MAX_TILES_W`, `ROOM_MAX_TILES_H`, `ROOM_MAX_W`, `ROOM_MAX_H`, `SCALE_PRIMARY`,
    `SCALE_FALLBACK`, `DISPLAY_W`, `DISPLAY_H`, `FALLBACK_DISPLAY_W`, `FALLBACK_DISPLAY_H`,
    `PLAYER_RENDER_W`, `PLAYER_RENDER_H`, `SHEET_MAX_PX`, `UI_SMALL`, `UI_LARGE`, `FONT_CELL`, plus
    `ENEMY_TIERS` and `BOSS_TIERS` arrays.
  - Derive dependent constants from their bases where the spec states a relation (e.g.
    `VIEW_TILES_W = VIEW_W / TILE_PX`, `PLAYER_RENDER_W = PLAYER_W * SCALE_PRIMARY`,
    `ROOM_MAX_W = ROOM_MAX_TILES_W * TILE_PX`) so values stay internally consistent.
  - Reconcile the scaffold's legacy `ROOM_W = 16` / `ROOM_H = 14` (256×224 room-equals-view model)
    to the System Z VIEW/ROOM model; keep a short comment that System Z supersedes Requirement 27.
  - (If a dedicated `GfxConfig.gd` autoload is preferred over `Feel.gd`, place the constants there and
    reference them identically — but only one home.)
  - Touches: `_incoming/godot/scripts/Feel.gd` (or NEW `GfxConfig.gd`).
  - _Requirements: Req 48.4, Req 48.5; System Z Config Constants (LOCKED); REQ-GFX-001, REQ-RES-001,
    REQ-CAM-001, REQ-ROOM-001, REQ-SPR-001, REQ-TILE-001, REQ-ART-PIPE-001, REQ-UI-001_

  - [ ]* 1.1 Write a config-literal guard test (no bare literals)
    - Assert every presentation-layer size/scale value in System Z scripts is read from the named
      config constant, not embedded as a bare numeric literal.
    - _Requirements: Req 48.5, REQ-RES-001-1_

- [ ] 2. Configure project resolution and integer scaling
  - [ ] 2.1 Set Godot project display settings from config constants
    - In `project.godot`: base viewport = `VIEW_W × VIEW_H` (320×224); `stretch/mode = canvas_items`;
      `stretch/aspect = keep`; `stretch/scale_mode = integer`; `rendering/.../default_texture_filter`
      = Nearest (0).
    - Present letterbox/pillarbox bars only as needed; never stretch the view to remove bars.
    - Touches: `_incoming/godot/project.godot`.
    - _Requirements: REQ-RES-001-1, REQ-RES-001-2, REQ-RES-001-7_

  - [ ] 2.2 Implement integer scale selection with ×6 primary / ×5 fallback
    - Target `SCALE_PRIMARY` (×6) → `DISPLAY_W × DISPLAY_H` (1920×1344); if hardware cannot sustain
      ×6, fall back to `SCALE_FALLBACK` (×5) → `FALLBACK_DISPLAY_W × FALLBACK_DISPLAY_H` (1600×1120).
    - Never drop below integer scaling under any resolution condition.
    - Compute all window/scale sizes from config constants (no literals).
    - Touches: `_incoming/godot/scripts/Main.gd` (window/scale setup), `Feel.gd`/`GfxConfig.gd`.
    - _Requirements: REQ-RES-001-3, REQ-RES-001-4, REQ-RES-001-5, REQ-RES-001-6_

  - [ ]* 2.3 Write resolution/scaling acceptance test
    - Assert the view is exactly `VIEW_W × VIEW_H` (320×224 = 20×14 tiles) and that at ×6 the player
      renders at `PLAYER_RENDER_W × PLAYER_RENDER_H` (96×144) and the view fills `DISPLAY_W × DISPLAY_H`
      (1920×1344) with no fractional blur.
    - _Requirements: REQ-RES-001-8, REQ-RES-001-6_

- [ ] 3. Extend the Camera2D free-scroll rig into a pixel-snapped, dead-zone, room-clamped camera
  - Extend the design's existing Player-child `Camera2D` rig: add dead-zone follow (small moves
    inside the dead-zone do not scroll), clamp camera limits to the active room bounds, and enable
    pixel snapping so scroll never lands on a half-pixel.
  - Do not apply camera smoothing that breaks the pixel grid; hold the camera static when a room
    equals the view (`VIEW_TILES_W × VIEW_TILES_H`), scroll when a room is larger than the view.
  - Read room bounds / stitched bounds from `Main.gd`; dead-zone and limits sized from config
    constants (`VIEW_W`/`VIEW_H`/`TILE_PX`), not literals.
  - Touches: Camera2D rig script (design's NEW rig, child of Player), `_incoming/godot/scripts/Main.gd`.
  - _Requirements: REQ-CAM-001-1, REQ-CAM-001-2, REQ-CAM-001-3, REQ-CAM-001-4, REQ-CAM-001-5,
    REQ-CAM-001-6_

  - [ ]* 3.1 Write pixel-snapped scrolling acceptance test
    - **Property: a room larger than the view scrolls smoothly and never renders a half-pixel.**
    - Assert camera position is always integer-aligned to the pixel grid across traversal of a room
      bigger than the view, and that camera stays clamped within room bounds.
    - **Validates: REQ-CAM-001-7, REQ-CAM-001-3, REQ-CAM-001-2**

- [ ] 4. Extend Room / DungeonGenerator for big rooms on the grid
  - [ ] 4.1 Size rooms within the System Z range
    - Extend `Room.gd` and `DungeonGenerator.gd` so each room is grid-aligned to `TILE_PX` and sized
      within the range from the view (`VIEW_TILES_W × VIEW_TILES_H` = 20×14) up to
      `ROOM_MAX_TILES_W × ROOM_MAX_TILES_H` (40×28), equal in pixels to 320×224 up to 640×448.
    - A baseline room equals the view (no scroll); big rooms scroll (consistent with the camera rig,
      task 3). Explicitly supersede Requirement 27's room-equals-view assumption in `Room.gd`.
    - All ranges from config constants (no literals).
    - Touches: `_incoming/godot/scripts/Room.gd`, `_incoming/godot/scripts/DungeonGenerator.gd`.
    - _Requirements: REQ-ROOM-001-1, REQ-ROOM-001-2, REQ-ROOM-001-5, REQ-ROOM-001-6_

  - [ ] 4.2 Scale enemy and decor density with room area
    - WHERE a room is larger than the view, scale enemy/decor counts with room area so bigger rooms
      are proportionally fuller and never feel empty. Area computed from room tile dims × `TILE_PX`.
    - Touches: `_incoming/godot/scripts/DungeonGenerator.gd` (and `Room.gd` interior placement).
    - _Requirements: REQ-ROOM-001-4_

  - [ ] 4.3 Keep the door graph + reachability valid for big rooms
    - Ensure rooms are connected with a Door_Graph and the run stays completable; wire generation to
      the `Reachability` pre-play gate so the check (Req 30) passes before play on big rooms too.
    - Touches: `_incoming/godot/scripts/DungeonGenerator.gd`, `_incoming/godot/scripts/Reachability.gd`.
    - _Requirements: REQ-ROOM-001-3_

  - [ ]* 4.4 Write big-room generation + reachability test
    - **Property: generated room dimensions always fall in [VIEW_TILES_W × VIEW_TILES_H,
      ROOM_MAX_TILES_W × ROOM_MAX_TILES_H] on the TILE_PX grid, and Reachability still passes.**
    - Assert a baseline room equals the view and big rooms scroll; re-verify reachability holds.
    - **Validates: REQ-ROOM-001-6, REQ-ROOM-001-2, REQ-ROOM-001-3**

- [ ] 5. Enforce pixel-grid honesty across rendering
  - Ensure nearest-neighbour sampling everywhere (`default_texture_filter` = Nearest / 0), integer
    scaling only, no runtime rotation and no runtime scaling of sprites (apparent rotation/scaling is
    authored into frames), and pixel snapping on moving renderers.
  - Apply the honesty rules to the player, enemies, bosses, tilemaps, VFX, overlays, and UI layers.
  - Touches: `_incoming/godot/project.godot`, `Main.gd`, sprite setup in `Player.gd`/`Enemy.gd`/`Boss.gd`.
  - _Requirements: REQ-GFX-001-1, REQ-GFX-001-2, REQ-GFX-001-3, REQ-GFX-001-4, REQ-GFX-001-5_

  - [ ]* 5.1 Write pixel-grid honesty verification test
    - **Property: the pixel grid stays honest at all times — nearest filtering, integer scale, and
      no node applies runtime rotation or non-integer scale to a sprite.**
    - Scan the scene/render config and assert no sprite node carries a nonzero `rotation` or a
      fractional `scale`, and that the texture filter resolves to Nearest.
    - **Validates: REQ-GFX-001-5, REQ-GFX-001-1, REQ-GFX-001-2, REQ-GFX-001-3**

- [ ] 6. Checkpoint — canvas, scaling, camera, and rooms
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 7. Author sprite sizes and the player clip set, wired to state machines
  - [ ] 7.1 Build the player `SpriteFrames` at the LOCKED cell size and clip set
    - Create an `AnimatedSprite2D` + `SpriteFrames` for the player at exactly `PLAYER_W × PLAYER_H`
      (16×24) with the LOCKED clips and frame counts, authored in 4 directions each: idle (2),
      walk (6), attack (3), charge (2), spin (4), hurt (1), dash (4), lift/carry (2 + 2), swim (4),
      death (4), push/pull (2). Outfit: white shirt, brown shorts, bare feet.
    - Cell size read from `PLAYER_W`/`PLAYER_H` (no literals).
    - Touches: NEW player `SpriteFrames` resource, `_incoming/godot/scripts/Player.gd`.
    - _Requirements: REQ-SPR-001-1, REQ-SPR-001-6, REQ-SPR-001-7_

  - [ ] 7.2 Wire player clips to the existing Player state machine
    - Bind clips one-to-one to the scaffold `Player.gd` states (idle/walk/attack/charge/spin/hurt and
      the dash sub-states → `dash`, context verbs → lift-carry/swim/push-pull), selecting by current
      state + 4-way facing; `death` plays on the final hurt.
    - Touches: `_incoming/godot/scripts/Player.gd`.
    - _Requirements: REQ-SPR-001-6_

  - [ ] 7.3 Author enemy/boss sprite tiers and wire their clips
    - Author enemy sprites at an `ENEMY_TIERS` size (16, 24, 32, or 48) and boss sprites at a
      `BOSS_TIERS` size (64, 96, 128+); wire clips to the `Enemy.gd` / `Boss.gd` state machines
      (idle/walk/attack/hurt/death, charger telegraph frame, boss telegraph/phase-transition).
    - Tier sizes read from `ENEMY_TIERS`/`BOSS_TIERS` (no literals).
    - Touches: NEW enemy/boss `SpriteFrames` resources, `_incoming/godot/scripts/Enemy.gd`,
      `_incoming/godot/scripts/Boss.gd`.
    - _Requirements: REQ-SPR-001-2, REQ-SPR-001-3_

  - [ ] 7.4 Define UI icon + font cell sizes for sprite authoring
    - Set UI icon sizes to `UI_SMALL × UI_SMALL` (8×8) or `UI_LARGE × UI_LARGE` (16×16) and the pixel
      font to a `FONT_CELL × FONT_CELL` (8×8) grid (consumed by the HUD in task 11).
    - Touches: NEW UI icon/font resources, `Feel.gd`/`GfxConfig.gd` references.
    - _Requirements: REQ-SPR-001-4, REQ-SPR-001-5_

  - [ ]* 7.5 Write sprite-size acceptance test
    - **Property: the player cell is exactly PLAYER_W × PLAYER_H (16×24), and every staged asset's
      dimensions equal its declared tier (ENEMY_TIERS / BOSS_TIERS / UI size).**
    - Assert each clip has its LOCKED frame count in all 4 directions.
    - **Validates: REQ-SPR-001-8, REQ-SPR-001-1, REQ-SPR-001-6**

- [ ] 8. Build per-biome tilesets (data-driven, via AssetResolver)
  - [ ] 8.1 Create the AssetResolver tileset swap-in
    - Implement `AssetResolver.gd` to resolve a biome id to a real `res://art/...` `TileSet` if
      present, else a procedural placeholder set — graceful fallback on missing art.
    - Touches: NEW `AssetResolver.gd`.
    - _Requirements: REQ-TILE-001-4_

  - [ ] 8.2 Author one 16×16 TileSet per biome with terrains and pieces
    - Build a `TILE_PX × TILE_PX` (16×16) Godot `TileSet` per biome (the seven core biomes of
      Req 21) with terrains configured for autotiling, plus doors, animated hazards, decorations,
      and lights; define each tileset as data (Req 19 / Req 56 data-driven approach). Provide a
      tileset for any catalogued biome beyond the core seven as it is authored.
    - Tile size read from `TILE_PX` (no literals).
    - Touches: NEW per-biome `TileSet` resources, `AssetResolver.gd`, `Room.gd` tile rendering.
    - _Requirements: REQ-TILE-001-1, REQ-TILE-001-2, REQ-TILE-001-3, REQ-TILE-001-5_

  - [ ]* 8.3 Write tileset structure test
    - Assert each biome tileset is 16×16, has autotile terrains, and includes door/hazard/decoration/
      light pieces; assert data-driven resolution falls back to a placeholder on missing art.
    - _Requirements: REQ-TILE-001-1, REQ-TILE-001-2, REQ-TILE-001-3_

- [ ] 9. Implement v1 effects (lighting, ambience, particles)
  - [ ] 9.1 Create Lighting.gd (dynamic 2D lighting)
    - NEW `Lighting.gd`: global `CanvasModulate` + `PointLight2D` lights, tinted per biome palette;
      resolve light art via `AssetResolver` with placeholder fallback.
    - Touches: NEW `_incoming/godot/scripts/Lighting.gd`.
    - _Requirements: REQ-GFX-001-6_

  - [ ] 9.2 Create Vfx.gd (particles)
    - NEW `Vfx.gd`: `CPUParticles2D`-based effects (hits, pickups, hazards), authored first-party and
      resolved via `AssetResolver`.
    - Touches: NEW `_incoming/godot/scripts/Vfx.gd`.
    - _Requirements: REQ-GFX-001-6_

  - [ ] 9.3 Create Ambience.gd (ambient atmosphere) and defer out-of-scope effects
    - NEW `Ambience.gd`: per-biome ambient atmosphere layer driving particles/scrolling tint,
      rendered above tilemap/VFX and below the UI `CanvasLayer`. Explicitly DO NOT build normal maps,
      HD-2D, or 3D planes in v1.
    - Touches: NEW `_incoming/godot/scripts/Ambience.gd`.
    - _Requirements: REQ-GFX-001-6, REQ-GFX-001-7_

  - [ ]* 9.4 Write v1 effects scope test
    - Assert lighting uses `CanvasModulate`/`PointLight2D`, particles use `CPUParticles2D`, and no
      deferred effect (normal maps / HD-2D / 3D plane) is present in v1.
    - _Requirements: REQ-GFX-001-6, REQ-GFX-001-7_

- [ ] 10. Checkpoint — sprites, tilesets, and effects
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 11. Implement UI/HUD presentation on the pixel grid
  - Build a screen-space `CanvasLayer` HUD drawn over the `VIEW_W × VIEW_H` (320×224) view at integer
    scale, unaffected by camera scroll; render icons at `UI_SMALL`/`UI_LARGE` and text on the
    `FONT_CELL × FONT_CELL` (8×8) pixel-font grid.
  - Specify only how UI renders on the pixel grid (keep HUD/inventory content consistent with
    Req 46/47/63); draw UI art via `AssetResolver` with placeholder fallback.
  - All sizes from config constants (`VIEW_W`/`VIEW_H`/`UI_SMALL`/`UI_LARGE`/`FONT_CELL`), no literals.
  - Touches: NEW `HUD.gd` + scene (`CanvasLayer`), `_incoming/godot/scripts/Main.gd` (layer wiring),
    `AssetResolver.gd`.
  - _Requirements: REQ-UI-001-1, REQ-UI-001-2, REQ-UI-001-3_

  - [ ]* 11.1 Write UI pixel-grid test
    - **Property: HUD/menus render in screen space at integer scale and do not move with camera
      scroll.**
    - Assert icons are 8×8 or 16×16 and text uses the 8×8 font grid.
    - **Validates: REQ-UI-001-2, REQ-UI-001-1**

- [ ] 12. Build the art pipeline and reference-asset governance
  - [ ] 12.1 Implement the asset-prep pipeline
    - Build pipeline tooling (under `work/`, outside `res://`): accept native sizes (character cells
      32×32, tile atlases 40×40), then slice → integer-resample to the game grid (characters to
      `PLAYER_W × PLAYER_H` = 16×24, tiles to `TILE_PX × TILE_PX` = 16×16) → hand-edit for
      originality → scrub metadata. Export PNG sheets (optional JSON), importing characters as
      `AnimatedSprite2D` + `SpriteFrames` and tiles as `TileSet` terrains; keep each sheet's max
      dimension ≤ `SHEET_MAX_PX` (2048).
    - Reference material (71 LTTP movement PNGs, `size_ref.png`, `lttp_link_ref_x6.png`) is STUDY-ONLY
      under `work/asset-packs/reference/lttp/movement/`: nearest-neighbour integer DOWNSAMPLE from the
      24×32 reference grid to `PLAYER_W × PLAYER_H` (16×24) + hand-clean; used for motion/proportion/
      frame-count study only; never resold, never used to train AI.
    - Touches: NEW art-pipeline tooling under `work/`.
    - _Requirements: REQ-ART-PIPE-001-1, REQ-ART-PIPE-001-2, REQ-ART-PIPE-001-5, REQ-ART-PIPE-001-6,
      REQ-ART-PIPE-001-7, REQ-ART-PIPE-001-8, REQ-ART-PIPE-001-9, REQ-ART-REF-001-1, REQ-ART-REF-001-2,
      REQ-ART-REF-001-3, REQ-ART-REF-001-6_

  - [ ] 12.2 Implement the originality / non-shipping guard
    - NEW build/CI guard that verifies: `res://` and the export contain ZERO reference files; every
      prepared/staged asset has zero brand strings in its filename AND zero brand strings in its PNG
      metadata; and each staged asset's dimensions exactly equal its declared tier (player cell
      `PLAYER_W × PLAYER_H`, `ENEMY_TIERS`/`BOSS_TIERS`, or UI size). Reference files live only under
      `work/`.
    - Touches: NEW guard script/tool.
    - _Requirements: REQ-ART-REF-001-4, REQ-ART-REF-001-5, REQ-ART-PIPE-001-3, REQ-ART-PIPE-001-4,
      REQ-ART-PIPE-001-10_

  - [ ]* 12.3 Write pipeline/governance verification test
    - **Property: no reference file exists inside res:// or the export; every staged asset has zero
      brand strings in filename and metadata and dimensions exactly equal to its tier.**
    - **Validates: REQ-ART-REF-001-7, REQ-ART-PIPE-001-10, REQ-ART-PIPE-001-3**

- [ ] 13. Final acceptance verification
  - [ ]* 13.1 Pixel-grid honesty holds
    - Nearest filtering, integer scaling, no runtime rotation/scaling anywhere.
    - **Validates: REQ-GFX-001-5**
  - [ ]* 13.2 Player cell and view sizes exact
    - Player cell exactly `PLAYER_W × PLAYER_H` (16×24); view exactly `VIEW_W × VIEW_H` (320×224 =
      20×14 tiles).
    - **Validates: REQ-SPR-001-8, REQ-RES-001-1**
  - [ ]* 13.3 Big-room scroll is pixel-snapped
    - A room larger than the view scrolls smoothly with a pixel-snapped camera and never shows a
      half-pixel.
    - **Validates: REQ-CAM-001-7, REQ-ROOM-001-6**
  - [ ]* 13.4 ×6 lands clean
    - At `SCALE_PRIMARY` (×6): player renders at `PLAYER_RENDER_W × PLAYER_RENDER_H` (96×144), view
      fills `DISPLAY_W × DISPLAY_H` (1920×1344), no fractional blur.
    - **Validates: REQ-RES-001-8, REQ-RES-001-6**
  - [ ]* 13.5 Asset governance holds
    - Every staged asset has zero brand strings in name/metadata and dimensions equal to its tier; no
      reference file inside `res://` or the export.
    - **Validates: REQ-ART-PIPE-001-10, REQ-ART-REF-001-7**

- [ ] 14. Final checkpoint — ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- This plan is scoped to **System Z — the presentation layer only** (Requirements 64–72 + the LOCKED
  config constants). It is **not** the full-game task plan.
- Tasks marked with `*` are optional (tests/verification) and can be skipped for a faster first pass.
- Every size/scale factor is a named config constant per Req 48.4/48.5 — no task hardcodes these
  values as literals.
- `Lighting.gd`, `Ambience.gd`, and `Vfx.gd` are **new** files (not present in the scaffold), despite
  being referenced as if they existed in the original request.
- Nothing in this presentation layer is a wholesale REPLACE; existing scaffold scripts are extended.
- Each task references its System Z `REQ-` acceptance-criteria IDs for traceability.

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1", "8.1", "12.1"] },
    { "id": 1, "tasks": ["1.1", "2.1", "4.1", "7.1", "8.2", "9.1", "9.2", "9.3", "12.2"] },
    { "id": 2, "tasks": ["2.2", "4.2", "7.2", "7.3", "7.4", "8.3", "9.4", "12.3"] },
    { "id": 3, "tasks": ["5", "2.3", "4.3", "7.5"] },
    { "id": 4, "tasks": ["3", "4.4", "5.1"] },
    { "id": 5, "tasks": ["11", "3.1"] },
    { "id": 6, "tasks": ["11.1"] },
    { "id": 7, "tasks": ["13.1", "13.2", "13.3", "13.4", "13.5"] }
  ]
}
```

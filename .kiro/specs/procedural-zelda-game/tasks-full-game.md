# Implementation Plan: Procedural Zelda Game — Full Game (Gameplay Systems A—Y)

## Overview

This plan implements the **full gameplay layer** of *Weird World Forever* — Requirements 1—63 across
**Systems A—Y** — in Godot 4 (GDScript), extending the scaffold under `_incoming/godot/`. It is the
companion to the presentation-layer plan in **`tasks.md` (System Z, Requirements 64—72)**.

**Scope boundary with `tasks.md`:** The **graphics / presentation layer (System Z, Reqs 64—72)** —
pixel-grid honesty, resolution/integer scaling, the camera rig, room *sizing*, sprite/tileset
authoring, v1 effects, UI *rendering*, and the art pipeline/governance — is specified and tasked in
**`tasks.md`** and is NOT re-tasked here. This plan owns gameplay *behavior and content*; where a
gameplay task needs to draw something, it consumes the System Z presentation layer rather than
re-specifying it (e.g. HUD *content* is here under System P; HUD *pixel-grid rendering* is in
`tasks.md`). Room *sizing/scroll* lives in `tasks.md` (REQ-ROOM / REQ-CAM); room *generation logic,
door graph, reachability* live here (System H/I).

The design is authoritative: see `design.md` → **Components and Interfaces** (per-system sections
A—Y), **Correctness Properties** (48 properties), **Data Models** (item schema, save schema,
Tunables table), **Error Handling**, and **Testing Strategy** (pure-logic layer vs. integration).

### Build order rationale (from the design's testing strategy)

The game splits into a **pure logic layer** (seeding, generation, reachability, item/attunement
rules, tier scaling, economy math, unlock rules) and an **integration layer** (movement, combat,
enemies/bosses, town, save, UI). This plan front-loads the pure logic layer (property-testable
without the engine running) and layers interactive systems on top, matching `design.md` → Testing
Strategy.

### Config-constant discipline (Req 48)

Every feel number is a named `Tunable` in `Feel.gd` with a confidence flag (`exact` / `[approx]` /
`[verify]`), per Req 48 and the Tunables table in `design.md` → Data Models. **No task may hardcode
a feel number as a bare literal** — speeds, durations, radii, multipliers, costs, densities, and
thresholds all come from named Tunables. Tune-first values are flagged.

## Scaffold alignment: extend vs. replace vs. new (gameplay)

Grounded in `design.md` → **Keep / Extend / Replace** and the scaffold scripts under
`_incoming/godot/scripts/`.

**EXTEND (exist in scaffold):**
- `Feel.gd` — the Tunables home (all feel numbers + confidence flags).
- `Game.gd` / `Main.gd` — top-level state machine and scene wiring (town<->run lifecycle, pause).
- `Player.gd` — movement, combat, context action, dash, equipped item.
- `Enemy.gd` / `Bestiary.gd` — archetypes, telegraphs, spawn behavior.
- `Boss.gd` / `BossRoster.gd` — phased boss framework, the ladder.
- `DungeonGenerator.gd` / `Room.gd` — rooms, door graph, biome/depth, tile-based assembly.
- `Reachability.gd` — gated generation / completability.
- `Items.gd` / `Inventory.gd` / `Pickup.gd` — item catalogue, held items, drops.
- `Projectile.gd` — beams, bombs, ranged attacks.
- `Spawner.gd` — seeded enemy placement.
- `Meta.gd` — persistent unlocks, max-health, attunement, save/resume.

**NEW (do not exist in scaffold):**
- `Rng.gd` — single seeded RNG service threaded through all generation (System J).
- `Attunement.gd` — keep-on-clear classification + application (System E, Req 18).
- `TierScale.gd` — level-anchored tier window `[Base−5, Base+5]` (System X, Req 61).
- `Curse.gd` — cursed-item negative-tier handling (System X, Req 62).
- `Economy.gd` — Sparks + Chevrons dual economy (System U, Reqs 52—54).
- `Town.gd` + building controllers (Bar, Restaurant, Board, Chapel) (System K).
- `Npc.gd` — simulacra + recruited humans (System L).
- `Route.gd` — route-length progression + per-biome content (System V).
- `UnlockRules.gd` — procedurally generated unlock conditions (System W, Req 60).
- `Variant.gd` — biome-variant selection (System V, Req 58).
- `Health.gd` — containers + evolving icon state (System M).
- `TitleScreen.gd` + scene — launch experience (System T, Req 50).
- `SaveStore.gd` — single resumable-run serialization (System O).

> Several of these may already be partially stubbed inside the EXTEND scripts; create a NEW file only
> where the design calls out a distinct authority. Confirm against the scaffold before splitting.

## Tasks

- [ ] 1. Seeded RNG foundation (System J)
  - Create NEW `Rng.gd`: a single seeded RNG service that threads one seed through route, layout,
    loot, and enemy placement so a seed reproduces the whole run; expose named draw points so draws
    are stable and order-independent across subsystems.
  - Keep strict determinism (same seed + same unlocked-variant set → identical run). No wall-clock or
    unseeded randomness in any generation path.
  - Touches: NEW `_incoming/godot/scripts/Rng.gd`; wiring hooks in `DungeonGenerator.gd`,
    `Spawner.gd`.
  - _Requirements: 31.1, 31.3, 22.5, 58 (seeded variant selection)_

  - [ ]* 1.1 Property: seed determinism
    - **Property: identical seed + identical unlocked-variant set always produces an identical run
      (route, layout, loot, enemy placement).**
    - **Validates: Req 31, Property (seeding) in design.md**

- [ ] 2. Dungeon generation core — rooms, door graph, biome/depth (System H)
  - [ ] 2.1 Build rooms on a door graph with start + far exit
    - Extend `DungeonGenerator.gd` / `Room.gd`: rooms as door-graph nodes, doors as edges, a tagged
      start room and far exit/boss room; locked doors with matching keys as graph elements. (Room
      *sizing/scroll* is owned by `tasks.md` REQ-ROOM/REQ-CAM — consume it, do not re-task.)
    - Touches: `DungeonGenerator.gd`, `Room.gd`.
    - _Requirements: 27.2, 27.4, 27.5_

  - [ ] 2.2 Tile-based "decide-then-assemble" generation
    - Implement the two-stage generator: (a) decide route/room/graph structure from the seed, then
      (b) assemble each room from large tile libraries + seeded assembly rules + pre-authored prefab
      chunks stamped onto the grid, per Req 59.
    - Touches: `DungeonGenerator.gd`, `Room.gd`.
    - _Requirements: 59.1, 59.2, 59.3, 59 (prefab chunks)_

  - [ ] 2.3 Depth-based difficulty scaling
    - Scale enemy density and encounter composition by room Depth (new archetype combinations at
      greater depth, not just higher HP); set pedestal loot quality to a positive baseline scaling up
      with depth and biome rarity. Depth 0 is a valid, scaled room.
    - Touches: `DungeonGenerator.gd`.
    - _Requirements: 28.1, 28.2_

  - [ ] 2.4 Seven biomes and the depth route
    - Data-drive the seven core biomes (Req 21) with per-biome hazards applied within their rooms;
      Grasslands authored as the first-iteration tutorial POC biome (Req 56.10).
    - Touches: `Bestiary.gd` (BIOMES), `DungeonGenerator.gd`, `Room.gd`.
    - _Requirements: 21.1, 21.2, 56.10_

  - [ ]* 2.5 Property: generated structure is well-formed
    - **Property: every generated dungeon has exactly one start and one far-exit/boss room, all rooms
      are reachable from start via the door graph, and biome/depth tags are consistent.**
    - **Validates: Reqs 27, 28, 59**

- [ ] 3. Reachability & gated generation (System I)
  - Extend `Reachability.gd`: enforce the Logic Rule so every run is completable and no seed dead-ends
    — place each gate's opener (key or gate-key item) in a room reachable *before* the gate it opens;
    never place a key behind the door it unlocks. Run the pre-play reachability gate before play
    begins; on failure, re-generate (never ship an uncompletable seed).
  - Treat gate-key items (Req 15) and bombs-as-gate-key (Req 16) as reachability openers.
  - Touches: `Reachability.gd`, `DungeonGenerator.gd`.
  - _Requirements: 30.1, 30.2, 30.3, 30.4, 30.5, 27.4, 15.*, 16.*_

  - [ ]* 3.1 Property: completability holds for all seeds
    - **Property: for any seed, the pre-play reachability gate passes — every gate's opener is
      reachable before the gate, and the far exit/boss room is reachable from start.**
    - **Validates: Req 30, Property (reachability) in design.md**

- [ ] 4. Checkpoint — pure generation layer
  - Ensure seeding, generation, and reachability tests pass; ask the user if questions arise.

- [ ] 5. Items, taxonomy & attunement (System E)
  - [ ] 5.1 Item taxonomy and the data-driven catalogue
    - Extend `Items.gd`: classify every item ATTACK / UTILITY / PASSIVE / CONSUMABLE per the item
      catalogue schema (`design.md` → Data Models); the basic sword swing is an innate action, every
      other attack/utility is an unlocked Item.
    - Touches: `Items.gd`.
    - _Requirements: 13.1, 13.2, 13.3, 14.1_

  - [ ] 5.2 Pedestals and boss loot as item sources
    - Pedestals and boss drops add items to the current run; a boss's guaranteed tool must be claimed
      to count a clear (ties to System G).
    - Touches: `Items.gd`, `Pickup.gd`, `DungeonGenerator.gd`.
    - _Requirements: 17.1, 17.2, 25.*_

  - [ ] 5.3 Attunement on clear (keep-on-clear)
    - Create NEW `Attunement.gd`: on a counted clear, attune (permanently keep) the attack and utility
      items carried through; town buffs are never attuned (Req 35.2). Persist via `Meta.gd`.
    - Touches: NEW `Attunement.gd`, `Meta.gd`, `Inventory.gd`.
    - _Requirements: 18.1, 18.2, 35.2_

  - [ ]* 5.4 Property: attunement keeps the right items
    - **Property: after a counted clear, exactly the carried ATTACK/UTILITY items persist; CONSUMABLE
      run-scoped state and town buffs do not.**
    - **Validates: Req 18, Property (attunement) in design.md**

- [ ] 6. Items as gate keys (System E)
  - Extend `Items.gd` / reachability wiring so certain items double as world gate-keys for
    Reachability purposes (Req 15); bombs act as both weapon and gate-key with knockback, cracking
    open marked walls, with blast radius and knockback as Tunables (Req 16).
  - Touches: `Items.gd`, `Projectile.gd` (bomb), `Reachability.gd`.
  - _Requirements: 15.1, 15.2, 15 (reachability tie), 16.1, 16.2, 16.3, 16.4_

- [ ] 7. Input & control + single equipped item (System A)
  - Extend `Player.gd` / `Game.gd`: the fixed six-input map resolving attack / context / item / map /
    pause; exactly one item equipped at a time. Pause/menu actions set `get_tree().paused` on the
    relevant `CanvasLayer` (ties to System P pausing).
  - Touches: `Player.gd`, `Game.gd`, `project.godot` (input map).
  - _Requirements: 1.1, 1.*, 2.1, 2.*_

- [ ] 8. Movement + authentic diagonal quirk (System B)
  - [ ] 8.1 Eight-directional movement with per-axis wall slide
    - Extend `Player.gd`: continuous 8-dir movement on tile collision, per-axis wall slide, 4-cardinal
      facing; walk/dash speeds from `Feel.WALK_SPEED` / `Feel.DASH_SPEED` (Req 3.5), no hardcoded
      constants.
    - Touches: `Player.gd`, `Feel.gd`.
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [ ] 8.2 Authentic faster-diagonal movement
    - Reproduce LTTP's diagonal-is-faster quirk deliberately (per-axis speed summed, not normalized),
      as an authored feel, driven by Tunables.
    - Touches: `Player.gd`, `Feel.gd`.
    - _Requirements: 4.1, 4.*_

- [ ] 9. Interaction + dash (System D)
  - [ ] 9.1 Context action verbs
    - Extend `Player.gd`: the single Context_Action (A) resolves exactly one verb from the faced
      target (lift/carry, push/pull, talk, read, swim-enter, open, etc.) per Req 11; swim enters the
      swim state over water.
    - Touches: `Player.gd`.
    - _Requirements: 11.1, 11.*, 12.7_

  - [ ] 9.2 Dash with Pegasus Boots (tap-dodge / hold-run)
    - The action button serves as a quick directional dodge-dash (tap → i-frames) and sustained run
      (hold), gated behind the Pegasus Boots unlock; dash speed, i-frame window, and dash distance as
      Tunables (i-frames `[approx]`, tune-first).
    - Touches: `Player.gd`, `Feel.gd`.
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6_

- [ ] 10. Combat — melee, spin, beams, damage model (System C)
  - [ ] 10.1 Melee sword with reach + tier multipliers
    - Extend `Player.gd` / combat: short-reach readable swing; reach, swing-active duration, and
      sword-tier multipliers as Tunables.
    - Touches: `Player.gd`, `Feel.gd`.
    - _Requirements: 5.1, 5.2, 5.3_

  - [ ] 10.2 Charged spin attack
    - Charge-and-release spin answering circling enemies; spin-charge duration and spin damage
      multiplier as Tunables.
    - Touches: `Player.gd`, `Feel.gd`.
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [ ] 10.3 Sword beams at full health
    - Fire a Sword_Beam on swing WHEN at full health with a strong-enough sword; never fire below full
      health. Beams via `Projectile.gd`.
    - Touches: `Player.gd`, `Projectile.gd`.
    - _Requirements: 7.1, 7.2, 7.3_

  - [ ] 10.4 Contact damage, knockback, i-frames
    - Contact damage with knockback and invincibility frames; magnitudes/durations as Tunables with
      the i-frame duration `[approx]` and tune-first.
    - Touches: `Player.gd`, `Enemy.gd`, `Feel.gd`.
    - _Requirements: 8.1, 8.2, 8.3_

  - [ ] 10.5 Passive facing shield + damage-taken reduction
    - Passive facing shield that blocks what the player faces (no block input); tunic/mail reduces
      damage taken. System C is the single damage-reduction authority (combines shield + armor
      factors), per the design's System C delta.
    - Touches: `Player.gd`, `Items.gd` (armor), `Feel.gd`.
    - _Requirements: 9.1, 9.2, 9.3, 10.1, 10.*_

  - [ ]* 10.6 Property: damage reduction is single-authority and bounded
    - **Property: all damage-taken reduction resolves through System C's combined factor; the result
      is bounded and shield/armor never double-apply.**
    - **Validates: Reqs 9, 10, Property (damage) in design.md**

- [ ] 11. Checkpoint — player feel (movement, interaction, combat)
  - Ensure movement/interaction/combat tests pass; ask the user if questions arise.

- [ ] 12. Enemies — bestiary, archetypes, fairness, spawning (System F)
  - [ ] 12.1 Data-driven bestiary and nine archetypes
    - Extend `Enemy.gd` / `Bestiary.gd`: nine archetypes with distinct readable behaviors and
      element/reaction rules (fire splits a Lava Slime, ice shatters an Obsidian Golem, bombs crack a
      Warden shield). Grasslands 3-enemy tutorial roster: PATROL field critter, CHASE hound, CHARGER
      boar with telegraph (Req 56.11).
    - Touches: `Enemy.gd`, `Bestiary.gd`.
    - _Requirements: 19.1, 19.2, 56.11_

  - [ ] 12.2 Telegraph-first fairness, no off-screen ambush
    - Every attack telegraphed; no enemy initiates an attack from off-screen. Charger has a visible
      telegraph frame before its charge.
    - Touches: `Enemy.gd`.
    - _Requirements: 20.1, 20.2_

  - [ ] 12.3 Seeded spawn rules
    - Extend `Spawner.gd`: placement fits each room and never feels unfair; same seed → same
      placement (consume `Rng.gd`).
    - Touches: `Spawner.gd`, `Rng.gd`.
    - _Requirements: 22.1, 22.2, 22.3, 22.4, 22.5_

  - [ ] 12.4 Corrupted elite leak
    - Rare high-tech corrupted elites leak into any biome at depth per Req 23.
    - Touches: `Spawner.gd`, `Bestiary.gd`.
    - _Requirements: 23.1, 23.*_

  - [ ]* 12.5 Property: fairness + seeded placement
    - **Property: no enemy attack originates off-screen; identical seed reproduces identical enemy
      placement.**
    - **Validates: Reqs 20, 22**

- [ ] 13. Bosses — framework, ladder, Souls-style difficulty (System G)
  - [ ] 13.1 Boss framework (telegraphed, phased, weak window)
    - Extend `Boss.gd`: learnable telegraphed phased cycle over the 7 patterns, with a Weak_Window
      after a big attack and a double-damage multiplier (both Tunables).
    - Touches: `Boss.gd`, `Feel.gd`.
    - _Requirements: 24.1, 24.2, 24.3, 24.4, 24.5_

  - [ ] 13.2 Guaranteed loot required to count a clear
    - Boss always drops a real tool that must be claimed for the clear to count (and for attunement /
      banking). Ties to System E (5.2) and System N clear logic.
    - Touches: `Boss.gd`, `Items.gd`, `Attunement.gd`.
    - _Requirements: 25.1, 25.2_

  - [ ] 13.3 The 100-boss ladder + negative-rank special bosses
    - Extend `BossRoster.gd`: one escalating boss per dungeon, dragon always first; the world starts
      at Rank 0; negative Rank = special out-of-ladder bosses (Req 26 amendment).
    - Touches: `BossRoster.gd`.
    - _Requirements: 26.1, 26.2, 26 (negative-rank amendment)_

  - [ ] 13.4 Souls-style difficulty + anti-panic-roll
    - Souls-level difficulty: death ends the run; bosses demand mastery and are learned through death;
      include delayed/feinted attacks that punish panic-rolling (Req 51).
    - Touches: `Boss.gd`, `Feel.gd`.
    - _Requirements: 51.1, 51.*_

  - [ ]* 13.5 Property: boss clear is gated on claimed loot
    - **Property: a boss clear counts only after its guaranteed tool is claimed; the weak window and
      double-damage apply only during the telegraphed window.**
    - **Validates: Reqs 24, 25, 51**

- [ ] 14. Tier scaling & cursed items (System X)
  - [ ] 14.1 Level-anchored tier scaling
    - Create NEW `TierScale.gd`: roll item/enemy tiers within the window `[Base_Level − TIER_WINDOW,
      Base_Level + TIER_WINDOW]` (TIER_WINDOW = 5), deterministic at each draw point; defensively
      clamp any out-of-window result back into the window (per `design.md` → Error Handling).
    - Touches: NEW `TierScale.gd`, `Feel.gd`, `Items.gd`, `Spawner.gd`.
    - _Requirements: 61.1, 61.2_

  - [ ] 14.2 Cursed items (negative tier)
    - Create NEW `Curse.gd`: cursed items modeled as negative tier — powerful or strange with a
      drawback; uncurse mechanism left TBD and flagged as an open design question.
    - Touches: NEW `Curse.gd`, `Items.gd`.
    - _Requirements: 62.1, 62.* (uncurse TBD)_

  - [ ]* 14.3 Property: tier window invariant
    - **Property: every rolled tier lies within `[Base_Level − 5, Base_Level + 5]` (clamp guarantees
      it), and the roll is deterministic for a given seed/draw point.**
    - **Validates: Req 61, Property 46 in design.md**

- [ ] 15. Checkpoint — enemies, bosses, tiers
  - Ensure enemy/boss/tier tests pass; ask the user if questions arise.

- [ ] 16. Drops, chevrons & dual economy (System U)
  - [ ] 16.1 Enemy death drops
    - Create/extend drop logic (`Pickup.gd` + NEW `Economy.gd`): enemies drop bombs / arrows /
      bullets / keys / notes / weapons / health / exp with the cloud + leaf pickup VFX (VFX visuals
      owned by System Z `tasks.md`). Run-scoped unless a drop type is explicitly Persistent_State.
    - Touches: `Pickup.gd`, NEW `Economy.gd`, `Enemy.gd`.
    - _Requirements: 52.1, 52.2, 52.6_

  - [ ] 16.2 Chevron tokens (8 colors, 3 persistent)
    - Chevrons in 8 colors used to trade and open things; three persist across runs (shiny light
      purple, rainbow, black); each presents its color-balanced pickup VFX (Req 52.6).
    - Touches: NEW `Economy.gd`, `Pickup.gd`.
    - _Requirements: 53.1, 53.2, 53.*_

  - [ ] 16.3 Dual economy — Sparks vs. Chevrons
    - Sparks (money) and Chevrons (tokens) are two separate systems with separate totals and separate
      spend/loss paths; spending or losing one never touches the other.
    - Touches: NEW `Economy.gd`, `Meta.gd` (persistent chevrons).
    - _Requirements: 36.1, 36.*, 54.1, 54.*_

  - [ ]* 16.4 Property: economies never cross-contaminate
    - **Property: a Sparks spend/loss leaves Chevron totals unchanged and vice-versa; persistent
      chevrons survive death, run-scoped drops do not.**
    - **Validates: Reqs 36, 52, 53, 54**

- [ ] 17. Town / Vigil & buildings (System K)
  - [ ] 17.1 Vigil as run boundary + lifecycle entry
    - Create NEW `Town.gd`: every run begins and ends in Vigil; choosing a dungeon at The_Board and
      entering begins a new run.
    - Touches: NEW `Town.gd`, `Game.gd`.
    - _Requirements: 32.1, 32.2, 32.3_

  - [ ] 17.2 The Bar — one drink per visit
    - One drink per visit → short buff and sometimes a truthful-but-partial rumor (e.g. a boss tell).
    - Touches: `Town.gd`.
    - _Requirements: 33.1, 33.2, 33.3_

  - [ ] 17.3 The Restaurant — one meal per visit
    - One meal per visit → full heal + a whole-run buff; drink/meal buffs are independent (one per
      visit each; no stacking violation).
    - Touches: `Town.gd`.
    - _Requirements: 34.1, 34.2, 34.3_

  - [ ] 17.4 Town buffs are run-scoped
    - Drink/meal buffs last only for the run they were bought for and are never attuned.
    - Touches: `Town.gd`, `Attunement.gd`.
    - _Requirements: 35.1, 35.2_

  - [ ] 17.5 The Board and the Chapel
    - The_Board: choose next dungeon / route. The Chapel: review permanent unlocks.
    - Touches: `Town.gd`, `Meta.gd`, `Route.gd`.
    - _Requirements: 37.1, 37.2_

- [ ] 18. NPCs & Ruined Vigil (System L)
  - [ ] 18.1 Simulacra populate the town
    - Create NEW `Npc.gd`: warm, uncanny simulacra (a mechanical "glitch" tell, never confirmed real),
      concentrated in Vigil and thinning smoothly with distance into the wild/dungeons (Req 38
      density gradient).
    - Touches: NEW `Npc.gd`, `Town.gd`.
    - _Requirements: 38.1, 38.2, 38.*_

  - [ ] 18.2 Rare human NPCs recruited from dungeons
    - Rare real humans found in dungeons can be brought home; the "glitch" tell is present
      mechanically as a tell that is never proof.
    - Touches: `Npc.gd`, `DungeonGenerator.gd`.
    - _Requirements: 39.1, 39.2, 39.*_

  - [ ] 18.3 The Ruined Vigil mirror dungeon
    - A mirror of the town gone to rot that never resolves its nature; reuses crypts undead reskinned
      (ties to biome-variant corruption, Req 58).
    - Touches: `Npc.gd`, `DungeonGenerator.gd`, `Variant.gd`.
    - _Requirements: 40.1, 40.*_

- [ ] 19. Health & persistence (System M)
  - [ ] 19.1 Health containers with evolving icon
    - Create NEW `Health.gd`: containers of 8 Damage_Units each; the icon evolves leaf → yellow star
      → rainbow star with progression; at 0 current health, leave max unchanged (no refill/adjust).
    - Touches: NEW `Health.gd`, `Player.gd`.
    - _Requirements: 41.1, 41.2, 41.*_

  - [ ] 19.2 Persistent maximum health
    - Max-health upgrades persist across runs like abilities (via `Meta.gd`).
    - Touches: `Health.gd`, `Meta.gd`.
    - _Requirements: 42.1, 42.*_

- [ ] 20. Run lifecycle, death, save/resume (Systems N & O)
  - [ ] 20.1 Run lifecycle (town → dungeon → town)
    - Extend `Game.gd`: the town/dungeon/town arc without restarting the game; run-scoped state is
      distinct from persistent state.
    - Touches: `Game.gd`, `Town.gd`.
    - _Requirements: 43.1, 43.2, 43.*_

  - [ ] 20.2 Death is final for the run
    - Death ends the run and discards run-scoped state (unbanked Sparks, run-only drops) but preserves
      permanent progress (attunement, max-health, persistent chevrons, unlocks).
    - Touches: `Game.gd`, `Economy.gd`, `Meta.gd`.
    - _Requirements: 44.1, 44.2, 44.*_

  - [ ] 20.3 Resumable in-progress run
    - Create NEW `SaveStore.gd`: a single resumable in-progress run serialized to the save schema
      (`design.md` → Data Models); restore exactly; discard on new game or on run end.
    - On resume failure: surface an error and auto-start a new run (never dead-end), per the Req 50.5
      reconciliation.
    - Touches: NEW `SaveStore.gd`, `Meta.gd`, `Game.gd`.
    - _Requirements: 45.1, 45.2, 45.*, 50.5_

  - [ ]* 20.4 Property: persistence survives death, run-state does not
    - **Property: after death, permanent progress is intact and run-scoped state is gone; a saved run
      restores identically, and a corrupt/failed resume recovers into a fresh run.**
    - **Validates: Reqs 44, 45, 50.5**

- [ ] 21. Checkpoint — economy, town, meta/save
  - Ensure economy/town/health/save tests pass; ask the user if questions arise.

- [ ] 22. Route progression, biome content & variants (Systems V & W)
  - [ ] 22.1 Route-length progression
    - Create NEW `Route.gd`: unlock progressively longer biome routes (length 1→7) by clearing them;
      N biomes per route feeding into 1 dungeon; chosen Route_Length drives biome count and run length
      (reconciled with Req 29).
    - Touches: NEW `Route.gd`, `Meta.gd`, `DungeonGenerator.gd`.
    - _Requirements: 55.1, 55.2, 55.*, 29.2_

  - [ ] 22.2 Per-biome required content
    - Each biome carries its own NPCs, secrets, exclusive items, and puzzle; first version is the
      1-biome / 1-short-dungeon tutorial POC (Req 56.7/56.8) with Grasslands authored (Req 56.10).
    - Touches: `Route.gd`, `Bestiary.gd`, `Items.gd`, `DungeonGenerator.gd`.
    - _Requirements: 56.1, 56.7, 56.8, 56.10, 56.11_

  - [ ] 22.3 Biome puzzle placement and solvability
    - Each biome's puzzle sits within that biome and is always solvable; integrate with Reachability
      (Req 30) so a biome puzzle never soft-locks a route.
    - Touches: `Route.gd`, `Reachability.gd`, `DungeonGenerator.gd`.
    - _Requirements: 57.1, 57.2, 57.*_

  - [ ] 22.4 Biome variants
    - Create NEW `Variant.gd`: discovered variant forms (corrupted / negative / rainbow; open set),
      one active at a time, seeded, unlocked over time; variant selection consumes `Rng.gd`.
    - Touches: NEW `Variant.gd`, `Route.gd`, `Rng.gd`.
    - _Requirements: 58.1, 58.2, 58.3, 58.4, 58.5_

  - [ ] 22.5 Procedurally generated unlock rules
    - Create NEW `UnlockRules.gd`: procedurally generate the conditions for unlocking new biomes,
      puzzles, NPCs, and variants (Req 60), persisted via `Meta.gd`.
    - Touches: NEW `UnlockRules.gd`, `Meta.gd`, `Route.gd`.
    - _Requirements: 60.1, 60.*_

  - [ ]* 22.6 Property: route + variant generation is sound and deterministic
    - **Property: chosen Route_Length always yields that many biomes feeding one dungeon; exactly one
      variant is active; same seed + unlocked set reproduces the route; biome puzzles never soft-lock.**
    - **Validates: Reqs 55, 56, 57, 58, 60**

- [ ] 23. Inventory screen & worn-gear equipment (System Y)
  - Extend `Inventory.gd`: inventory screen showing worn gear slots (Helmet / Body / Shoes),
    consumables, and items, with an Armor_Type distinction (Tactical / Armor) per Req 63. Inventory
    *content/logic* here; inventory *pixel-grid rendering* is in `tasks.md` (System Z UI).
  - Touches: `Inventory.gd`, `Items.gd`.
  - _Requirements: 63.1, 63.2, 63.3, 63.4, 63.14, 63.15, 63.*_

- [ ] 24. Run HUD content + pausing menus (System P)
  - [ ] 24.1 Run HUD content
    - Feed the HUD (hearts with evolving icon, equipped item, seed, depth, boss HP bar while a boss is
      active) with gameplay state. HUD *rendering on the pixel grid* is owned by `tasks.md` (System Z
      REQ-UI); this task supplies the data/content.
    - Touches: `Game.gd`, `Health.gd`, `Boss.gd`, HUD content binding.
    - _Requirements: 46.1, 46.2, 46.3_

  - [ ] 24.2 Pausing menus
    - Menus pause the world like LTTP (no real-time while open) via `get_tree().paused` on the menu
      `CanvasLayer`.
    - Touches: `Game.gd`, inventory/map/pause menus.
    - _Requirements: 47.1, 47.*_

- [ ] 25. Title / Start screen (System T)
  - Create NEW `TitleScreen.gd` + scene: present a Title Screen at application start with New Game /
    Continue (Continue resumes the saved run via `SaveStore.gd`; New Game discards it).
  - Touches: NEW `TitleScreen.gd` + scene, `Game.gd`, `SaveStore.gd`.
  - _Requirements: 50.1, 50.2, 50.3, 50.4, 50.5_

- [ ] 26. Tunables as configurable data (System Q)
  - Ensure every feel number used by Systems A—Y is a named `Tunable` in `Feel.gd` with a confidence
    flag (`exact` / `[approx]` / `[verify]`), matching the Tunables table in `design.md` → Data
    Models; tune-first values flagged (Req 48.2).
  - Touches: `Feel.gd`.
  - _Requirements: 48.1, 48.2, 48.3_

  - [ ]* 26.1 Property: no bare feel-number literals
    - **Property: every speed/duration/radius/multiplier/cost/density/threshold in Systems A—Y scripts
      is read from a named Tunable, never embedded as a bare literal.**
    - **Validates: Req 48**

- [ ] 27. Out-of-scope guard (System R)
  - Add a lightweight scope check / documentation guard asserting the explicit exclusions (Req 49): no
    fixed LTTP overworld/story/item-gate progression, no Nintendo assets (original placeholders only),
    and the other stated non-goals remain absent.
  - Touches: NEW scope-guard note/test; `design.md` → System R.
  - _Requirements: 49.1, 49.*_

- [ ] 28. Final acceptance verification (gameplay)
  - [ ]* 28.1 Seed reproduces a whole run
    - **Validates: Req 31**
  - [ ]* 28.2 Every seed is completable (reachability gate passes)
    - **Validates: Req 30**
  - [ ]* 28.3 Attunement keeps the right items; death discards run-scoped state only
    - **Validates: Reqs 18, 44**
  - [ ]* 28.4 Tier rolls stay within the level-anchored window
    - **Validates: Req 61**
  - [ ]* 28.5 Sparks and Chevrons never cross-contaminate; persistent chevrons survive death
    - **Validates: Reqs 36, 53, 54**
  - [ ]* 28.6 Bosses are telegraphed/phased and a clear requires claimed loot
    - **Validates: Reqs 24, 25, 51**
  - [ ]* 28.7 Saved run restores identically; failed resume recovers into a fresh run
    - **Validates: Reqs 45, 50.5**

- [ ] 29. Final checkpoint — full gameplay layer
  - Ensure all gameplay tests pass; confirm presentation (System Z, `tasks.md`) integrates cleanly;
    ask the user if questions arise.

## Notes

- This plan covers **gameplay Systems A—Y (Requirements 1—63)**. The **graphics/presentation layer
  (System Z, Reqs 64—72)** is specified and tasked in **`tasks.md`** and is intentionally not
  re-tasked here; gameplay tasks consume it.
- Tasks marked with `*` are optional (tests/verification/properties) and can be skipped for a faster
  first pass, mapping to the 48 correctness properties in `design.md`.
- Every feel number is a named `Tunable` per Req 48 — no task hardcodes feel numbers as literals.
- Determinism is strict: identical seed + unlocked-variant set → identical run (Req 31).
- Each task cites its requirement IDs for traceability back to `requirements.md` and the matching
  `design.md` system section.

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1"] },
    { "id": 1, "tasks": ["2.1", "2.2", "2.3", "2.4", "5.1"] },
    { "id": 2, "tasks": ["2.5", "3", "5.2", "5.3"] },
    { "id": 3, "tasks": ["3.1", "4", "5.4", "6", "7"] },
    { "id": 4, "tasks": ["8.1", "8.2", "9.1", "9.2", "10.1", "10.2", "10.3", "10.4", "10.5"] },
    { "id": 5, "tasks": ["10.6", "11", "14.1", "14.2"] },
    { "id": 6, "tasks": ["12.1", "12.2", "12.3", "12.4", "13.1", "13.2", "13.3", "13.4", "14.3"] },
    { "id": 7, "tasks": ["12.5", "13.5", "15", "16.1", "16.2", "16.3", "19.1", "19.2"] },
    { "id": 8, "tasks": ["16.4", "17.1", "17.2", "17.3", "17.4", "17.5", "18.1", "18.2", "18.3"] },
    { "id": 9, "tasks": ["20.1", "20.2", "20.3"] },
    { "id": 10, "tasks": ["20.4", "21", "22.1", "22.2", "22.3", "22.4", "22.5"] },
    { "id": 11, "tasks": ["22.6", "23", "24.1", "24.2", "25", "26"] },
    { "id": 12, "tasks": ["26.1", "27"] },
    { "id": 13, "tasks": ["28.1", "28.2", "28.3", "28.4", "28.5", "28.6", "28.7"] },
    { "id": 14, "tasks": ["29"] }
  ]
}
```
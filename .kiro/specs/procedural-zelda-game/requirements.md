# Requirements Document

## Introduction

This document defines the requirements for a top-down, *A Link to the Past*-style action-adventure
**roguelike** built in **Godot 4 (GDScript)**. The requirements describe behavior and are
engine-agnostic, but acknowledge Godot 4 / GDScript as the implementation platform.

The game is framed around two places. The first is **Vigil**, the last warm town — a melancholy
hub of half-dead neon and androids remembering things that may never have happened. The second is a
**Dungeon**: a single seeded, procedurally generated descent of connected rooms explored as one
continuous, free-scrolling space that the player
chooses from the Board in Vigil. A **Run** begins in Vigil and ends in Vigil, whether the player
clears the dungeon or dies in it. Between runs the player spends **Sparks**, drinks at the bar for
rumors and short buffs, eats at the restaurant for a full heal and run-long buffs, picks the next
dungeon at the Board, and locks in unlocks at the Chapel.

The game keeps LTTP's control feel exactly: a six-input scheme, 8-directional movement, a melee
sword with a charged spin attack and sword beams, a single overloaded context-action button, a
single equipped item, and menus that pause the world. Combat is built from four systems acting
together — short sword reach, contact ("bump") damage, knockback, and invincibility frames — plus a
passive facing-based shield. Every feel number from the reference is expressed as a configurable
**Tunable**, carrying the reference's `[approx]` / `[verify]` confidence flags, rather than a
hardcoded constant.

Progression is **Attunement**. The player starts each run with only the abilities they have already
earned and begins deliberately poor. ATTACK and UTILITY items found in a dungeon work for that run;
carry them to a clear (reach the end alive, defeat the boss, claim the loot) and they become
permanent, granted at the start of every future run. Death loses that run's finds. Deviating from
the source material, **maximum-health (life) upgrades also persist on a clear**, like abilities do;
they do not reset per run. The health meter uses a Zelda-style container system with an evolving
icon that changes with progression — a leaf early, a yellow star mid-game, a rainbow star at the
end.

Each dungeon fights exactly one boss. The ladder is literal: the Nth cleared dungeon fights boss
N+1, the very first clear is always the tutorial dragon Gloamwing, and the ladder climbs through 100
escalating bosses with monotonic scaling. Enemies are a data-driven bestiary of nine AI archetypes
across seven biomes, each biome asking a different question, all obeying telegraph-first fairness.
The generator guarantees completability: it places each gate's required item (or key) before the
gate and reachable without it, then runs a reachability check before play and re-rolls on failure,
so there are no impossible seeds.

The world's tone is sad fantasy fused with techno-future, carried through the mystery of Vigil's
simulacra — broken representations of people the game never confirms are real or not — the rare real
humans found in dungeons, and the Ruined Vigil, a mirror dungeon of the same town gone to rot.

This specification captures behavioral requirements organized into clearly separated systems so each
can be designed and implemented independently. It is a documentation pass only; no implementation is
included.

## Glossary

### Core structure

- **Game**: The complete software application, including all subsystems described below.
- **Player**: The human operating the Game through input devices.
- **Player_Character**: The avatar the Player controls, in Vigil or within a Dungeon.
- **Vigil**: The persistent town hub where every Run begins and ends. Also "the town."
- **Dungeon**: One seeded, procedurally generated descent of Rooms that constitutes a single Run's
  playable challenge.
- **Run**: A single playthrough, beginning when the Player enters the chosen Dungeon from Vigil and
  ending when the Player returns to Vigil, whether by clearing the Dungeon or by Player_Character
  defeat.
- **Route**: The ordered sequence of Biomes a single Run traverses in sequence before its one end
  Dungeon. A Route leads to exactly one end Dungeon containing exactly one Boss (see Boss_Ladder,
  Requirement 26); a Route is not one Dungeon per Biome. (See Requirement 55.)
- **Route_Length**: The number of Biomes in a Route. Route_Lengths are unlocked progressively
  (1 unlocks 2, 2 unlocks 3, and so on) up to a configurable maximum (first-iteration value 7, with
  the system architected to support higher values up to every Biome in the Biome_Library). The
  highest unlocked Route_Length is Persistent_State. (See Requirement 55.)
- **First_Iteration**: The tutorial / proof-of-concept build: a single authored Biome plus one short
  first Dungeon played as a Route_Length of 1, forming a complete playable vertical slice of the core
  loop (Vigil → one-Biome Route → short Dungeon → Gloamwing → Clear → return to Vigil), with the rest
  of the Biome_Library present as defined structure to be authored later. (See Requirement 56.7–56.8
  and Requirement 55.3.)
- **Clear**: A Run outcome in which the Player_Character reaches the Dungeon's exit alive, defeats
  the Boss, and claims its guaranteed loot. A Clear triggers Attunement, banks Sparks, and advances
  the Boss_Ladder.
- **Run-Scoped_State**: State belonging only to the current Run and discarded when the Run ends,
  including found ATTACK/UTILITY items not yet Attuned, PASSIVE items, CONSUMABLE items, keys, town
  Buffs, unbanked Sparks, and the five run-scoped Chevron colors (gold, silver, blue, brown, pink).
- **Persistent_State**: State retained across Runs and surviving defeat (meta-progression): the
  Attuned set, persistent maximum-health upgrades, banked Sparks, the Boss_Ladder position (Clears
  count), recruited human NPC roles, the three ultra-rare persistent Chevron colors (shiny light
  purple, rainbow, black), the highest unlocked Route_Length (see Route_Length and
  Requirement 55), and the set of unlocked Biome_Variants (see Biome_Variant and Requirement 58).

### Control and feel

- **Input_Scheme**: The fixed six-input control mapping (movement plus B, A, Y, X, Start).
- **Context_Action**: The single overloaded "A"-button behavior that resolves by context
  (lift, throw, pull, push, talk, read, open chest, swim, dash).
- **Equipped_Item**: The single item currently bound to the item button (Y).
- **Spin_Attack**: The charged 360° sword attack performed by holding the attack button and
  releasing, doing double a normal swing.
- **Sword_Beam**: A projectile fired by a sword swing when the Player_Character is at full health
  and holds the Master Sword or better.
- **Facing_Shield**: The passive shield that blocks projectiles arriving from the Player_Character's
  current facing direction, with no block input.
- **I_Frames**: A brief window of invulnerability following a damaging hit; applied per damage type,
  since some sources ignore it.
- **Knockback**: The brief displacement and control loss applied when the Player_Character or an
  Enemy is struck.
- **Tunable**: A named, configurable value (not a hardcoded constant) controlling feel. Each Tunable
  may carry a confidence flag of `exact`, `[approx]`, or `[verify]`.

### Items and progression

- **Item**: A collectible object granting a verb, resource, or stat to the Player_Character.
- **ATTACK_Item**: An item granting a new way to deal damage (for example Bow, Bombs, Hookshot, Fire
  Rod). Persists on a Clear via Attunement.
- **UTILITY_Item**: An item granting a new way to move or open the world (for example Pegasus Boots,
  Flippers, Glove, Cape). Persists on a Clear via Attunement.
- **PASSIVE_Item**: A run-scoped stat upgrade (for example Sword tier, Shield, Mail, Magic upgrade).
  Does not Attune. (Note: maximum-health upgrades are an explicit exception and persist — see
  Health_Container and Persistent_State.)
- **CONSUMABLE_Item**: A run-scoped spendable (for example potions, fairies, arrows, bomb ammo, and
  bullets — bullets being a distinct ammo type alongside arrows and bombs). Does not Attune.
- **Attunement**: The meta-progression rule by which ATTACK/UTILITY items carried to a Clear become
  permanent and are granted at the start of future Runs.
- **Attuned_Item**: An ATTACK or UTILITY item that has been Attuned and is part of Persistent_State.
- **Attuned_Set**: The collection of all Attuned_Items.
- **Pedestal**: The primary in-Dungeon item source; a Room feature that may hold one unattuned item,
  weighted by biome and depth.
- **Inventory**: The subsystem holding the current Run's items plus a reference to the Attuned_Set.
- **Base_Level**: The integer level anchoring a generated area's (level, Dungeon region, or Biome
  instance) expected Tier. The Base_Level is the center of the Tier window from which seeded random
  content for that area is rolled (see Tier, Requirement 61).
- **Tier**: A level-anchored power/rarity rank for generated content. A Tier is rolled relative to
  the area's Base_Level within the window [Base_Level − 5, Base_Level + 5] — up to 5 above and up to
  5 below the Base_Level — with tiers nearer the Base_Level common and tiers farther from the
  Base_Level increasingly rare, following a data-driven ladder/rarity curve. The same Seed reproduces
  the same Tier rolls (see Requirement 61 and Requirement 31). A resulting absolute Tier below 0 is
  negative and marks a Cursed_Item (see Cursed_Item and Requirement 62). Tier is distinct from Rank,
  which positions a Boss on the Boss_Ladder (see Rank).
- **Cursed_Item**: An Item whose resulting absolute Tier is negative (below 0), regardless of the
  area's Base_Level. A Cursed_Item is rare and special, consistent with the rarity-by-distance curve
  of Requirement 61 and the "negative is special" treatment of Rank in Requirement 26. A Cursed_Item
  imposes a negative effect on the Player_Character while held or equipped (the specific penalty is
  data-driven per item), and CAN be uncursed/cleansed at a great tradeoff to the Player_Character
  whose exact cost and location are a deferred decision (TBD / `[verify]`) (see Requirement 62).
- **Inventory_Screen**: The paused inventory sub-screen opened via the Inventory/Pause input
  (Requirement 1 and Requirement 2) and pausing the world like other menus (Requirement 47). The
  Inventory_Screen displays the Worn_Gear equip slots and current Armor_Type (each with its Item,
  Tier, and modifiers), CONSUMABLE_Items and potions with their modifier and/or healing values, AMMO
  counts for arrows, bombs, and bullets, and the current active Equipped_Item (the Y-button item).
  The Inventory_Screen is a presentation of the Inventory subsystem, distinct from the Inventory
  itself (see Requirement 63).
- **Worn_Gear**: The Player_Character's worn equipment — the three Gear_Slots (Helmet, Body/Clothes,
  Shoes) plus the chosen Armor_Type (Tactical or Armor) — each slot holding at most one gear Item and
  providing defense (damage reduction) and/or stat modifiers to the Player_Character while equipped.
  Worn_Gear is SEPARATE from the single active Equipped_Item bound to the Item (Y) button
  (Requirement 2); equipping Worn_Gear does not change the Equipped_Item. A Worn_Gear piece carries a
  Tier (Requirement 61) that scales its modifiers and CAN be a Cursed_Item at a negative Tier
  (Requirement 62). Worn_Gear is PASSIVE_Item-like and Run-Scoped_State: it does not Attune and is
  lost on death, consistent with the item taxonomy of Requirement 13 (this does not change the
  maximum-health persistence exception of Requirement 42) (see Requirement 63).
- **Armor_Type**: The Player's chosen body/defense style, exactly one of Tactical or Armor. Tactical
  leans toward mobility/utility modifiers; Armor leans toward defense (damage reduction). The two
  styles trade off differently, with their specific modifier/defense emphases held as data-driven
  Tunables and per-item data (see Requirement 48 and Requirement 63).
- **Gear_Slot**: One of the three Worn_Gear equip slots — Helmet, Body/Clothes, and Shoes/Footwear —
  each holding at most one gear Item of the matching slot type (see Requirement 63).

### Enemies and bosses

- **Enemy**: A hostile, computer-controlled entity that can damage the Player_Character.
- **Archetype**: One of nine AI behaviors — PATROL, CHASE, CHARGER, TURRET, LOBBER, JUMPER, SWARM,
  PHASE, SUMMONER.
- **Bestiary**: The data-driven catalogue of Enemy definitions, biome rosters, and boss data.
- **Biome**: A themed region vocabulary (Hollow Crypts, Silkfall Warrens, Thornwild, Emberdeep,
  Glacier Barrow, Sunken Ruins, The Arcanum), each with its own enemies, hazards, and boss, and each
  asking a different question. These seven (Crypts … Arcanum) are the scaffold's core route data; the
  Biome_Library ALSO includes the catalogued base Biomes Grasslands, Graveyard, Noir City (a 16-bit
  noir city with a distinct noir palette and art treatment), and Temple. Of these, Grasslands is the
  Biome authored and used for the first iteration / tutorial proof-of-concept — the single plain,
  Route_Length-of-1 Biome leading to the short first Dungeon and the tutorial Boss Gloamwing (see
  Requirement 56.10 and Requirement 56.7). The ruined/corrupted forms of Graveyard, Noir City, and
  Temple are produced via Biome_Variant (see Requirement 58) rather than as separate Biomes. These
  catalogued additional base Biomes are catalogued structure; apart from Grasslands as the authored
  first-iteration Biome, they are not part of the fixed first-iteration Route (see Requirement 56.9
  and Requirement 56.10).
- **Biome_Library**: The full retained set of all potential Biomes kept in the project. The
  Biome_Library is retained in full even when only a subset of its Biomes has been authored with
  complete Biome_Content; Biomes gain their content incrementally as development scales. The
  Biome_Library grows with catalogued base Biomes beyond the scaffold's core seven — Grasslands,
  Graveyard, Noir City, and Temple — each added as a data-driven entry. Grasslands is the authored
  first-iteration / tutorial proof-of-concept Biome (see Requirement 56.10 and Requirement 56.7),
  while Graveyard, Noir City, and Temple are catalogued as defined structure to be authored later
  (see Requirement 56).
- **Biome_Content**: The required per-Biome content a Biome definition carries, authored as
  data-driven structure: multiple NPCs, multiple secrets, one or more biome-only Items (Items, keys,
  or power-ups obtainable only within that Biome), and at least one Biome_Puzzle (see
  Requirement 56).
- **Biome_Puzzle**: A puzzle associated with a Biome and placed within that Biome's region of a
  Route. A Biome_Puzzle SHALL be solvable using only an ability or item obtainable before it within
  the same Run, so it never soft-locks a Route (see Requirement 57).
- **Biome_Variant**: A data-driven modifier layered on top of a base Biome — for example
  Corrupted/Infected, Negative, or Rainbow, among an open set that grows as data without changing
  the central generation algorithm — that reshapes that Biome instance's difficulty, possible
  pickups (Death_Drops, Items, and biome-only Items), Biome_Puzzle, NPCs, and story/flavor while the
  underlying Biome identity and place remain. A Biome instance is either plain (no variant) or
  carries exactly one Biome_Variant; variants do not stack. The Generator chooses a Biome instance's
  variant (or plain) deterministically from the Seed, rarity-weighted per variant, drawing only from
  the unlocked set. The set of unlocked Biome_Variants is Persistent_State, discovered over time and
  persisting across Runs. The ruined/corrupted forms of catalogued base Biomes — for example Ruined
  Graveyard, Corrupted Noir City, and Ruined Temple — are examples of a ruined/corrupted
  Biome_Variant applied to a base Biome, not separate Biome_Library entries (see Requirement 56.9
  and Requirement 58).
- **Telegraph**: A readable wind-up (flash, recoil, glow, crouch) preceding any harmful Enemy or
  Boss action.
- **Corrupted_Elite**: A rare Techno-Priest or Laser Warthog that leaks into any biome at Depth ≥ 5.
- **Boss**: A distinguished Enemy in a Dungeon's exit Room, with HP phases, a Weak_Window, and
  guaranteed loot.
- **Weak_Window**: A brief post-big-attack state (~1.5 s) during which the Boss takes double damage.
- **Boss_Ladder**: The ordered list of 100 bosses at Ranks 1–100; the Nth cleared Dungeon fights
  boss N+1 for a Clears count N ≥ 0.
- **Rank**: A Boss's position on the Boss_Ladder. Standard Ranks run 1–100 and drive HP/speed/phase
  scaling and prices; a Clears count N ≥ 0 maps to Rank N+1, so normal play starts at Clears count 0
  (Rank 1, Gloamwing) and never goes negative. Negative Rank/Clears values are reserved for special,
  scripted cases and denote special, out-of-ladder Bosses that are not part of the 1–100 ladder and
  are not bound by the standard scaling formulas; normal progression never produces a negative value
  (see Requirement 26).
- **Gloamwing**: The tutorial dragon; always the first Boss the Player ever fights.

### Dungeon, generation, seeding

- **Room**: The unit of generation and collision within a Dungeon: a 20 × 14-tile grid (640 × 448 px)
  with door cells, connected to adjacent Rooms by a door graph and stitched with neighbors into one
  continuously scrolled space rather than a locked screen.
- **Door_Graph**: The logical graph of a Dungeon (Rooms = nodes, doors = edges), including locked
  doors, keys, boss room, and exit.
- **Depth**: A Room's distance along the Dungeon's biome route, driving difficulty and loot quality.
- **Gate**: A traversal obstacle requiring a specific item or key to pass — a locked door (key), a
  cracked wall (bombs), deep water (Flippers), a gap (Hookshot), webs (Fire Rod), or frozen water
  (Ice Rod).
- **Reachability**: The property, and the check enforcing it, that a Dungeon is completable from
  start to exit using only the keys/items reachable before each Gate.
- **Seed**: The value deterministically controlling Generator output; visible and shareable.
- **Generator**: The subsystem that produces a Dungeon (Rooms, Door_Graph, enemies, loot) from a
  Seed.
- **Semantic_Object**: A thing the Generator decides to build at a location — for example a house, a
  bridge, a shrine, a river, a landmark, or a settlement — assembled from its Tile_Library and/or
  Prefab_Chunks. The Generator works in two levels: it first decides which Semantic_Object it wants
  at a location, then assembles that object from the curated, data-driven pieces scoped to that
  object type. New Semantic_Object types are added as data without changing the central generation
  algorithm (see Requirement 59).
- **Tile_Library**: The data-driven set of premade tiles/pieces scoped (tagged) to a single
  Semantic_Object type — for example a "house" Tile_Library carrying wall, roof, door, and window
  pieces. Each object part/slot has many interchangeable tile options, so variation scales with
  Tile_Library size. New tiles and object types are added as data/assets without changing the
  central generation algorithm (see Requirement 59).
- **Prefab_Chunk**: A pre-authored multi-tile piece (for example a whole house or a bridge segment)
  that the Generator places and stitches to its neighbors, used for complex Semantic_Objects
  alongside per-slot tile assembly in a hybrid approach (see Requirement 59).
- **Assembly_Rule**: A seeded rule that varies a Semantic_Object's structure — its size, shape, and
  layout — when assembling it from the object's Tile_Library, drawing from the single seeded RNG so
  the same Seed reproduces the same assembled object (see Requirement 59 and Requirement 31).
- **Unlock_Rule**: A procedurally generated condition, deterministic from the Seed, that unlocks a
  Biome, a Biome_Puzzle, a Human_NPC, or an Enemy. An Unlock_Rule is composed from an open,
  data-driven set of condition types (for example defeat a specific Boss, solve a specific
  Biome_Puzzle, find a specific Item in a specific Biome, collect N Chevrons or N Sparks, clear a
  Route of a given Route_Length, discover a specific secret, or recruit a specific Human_NPC). The
  Generator validates each Unlock_Rule for satisfiability and acyclicity so it cannot soft-lock or
  form a circular dependency, and the unlocked result becomes Persistent_State once the condition is
  met (see Requirement 60).

### Town, economy, people

- **Sparks**: The currency, written "⚡," dropped by Enemies and Bosses; banked on a Clear, lost on
  death if unbanked. Sparks are the Game's money — the primary spendable resource at Vigil's shops
  (Forge, Apothecary, The_Last_Call, The_Warm_Machine, Pawnbroker) — and are a system distinct from
  Chevrons, which are tradeable tokens rather than shop money (see Chevron and Requirement 54).
- **Death_Drop**: An Item or token spawned at an Enemy's position when that Enemy is defeated, drawn
  from a rarity-weighted drop table and collected on overlap by the Player_Character (see
  Requirement 52).
- **Note**: A collectible, lore-flavoured, tradeable Death_Drop item; a drop type distinct from ammo,
  keys, weapons, health, and EXP (see Requirement 52).
- **EXP**: An experience pickup used by an experience/leveling system. EXP is conditional: it applies
  only WHERE the Game includes an EXP/leveling system. No EXP/leveling system is otherwise specified
  in this document; such a system would require its own requirement (see Requirement 52).
- **Chevron**: An upward-pointing, chevron-shaped collectible token that drops from defeated Enemies
  (rarity-scaled) and sometimes from the environment. Chevrons form a token economy that is separate
  from Sparks money; they are spent to trade with vendors/NPCs, to open certain doors, and to alter
  the environment (see Requirement 53). There are eight Chevron colors: gold, silver, black, blue,
  rainbow, brown, pink, and the ever-rare shiny light purple (seven standard colors plus one
  ultra-rare special). Of the eight, exactly three are ultra-rare and persist between Runs as
  Persistent_State — shiny light purple, rainbow, and black — while the other five — gold, silver,
  blue, brown, and pink — are Run-Scoped_State and are lost on death or Run end.
- **Shiny_Light_Purple_Chevron**: The rarest, special eighth Chevron color; ultra-rare and persistent
  across Runs (Persistent_State).
- **Buff**: A timed or run-scoped effect bought in town; never Attuned.
- **Rumor**: A truthful-but-partial hint about the next Dungeon drawn from its real generation.
- **The_Last_Call**: The bar, run by the barkeep Marrow; sells one drink per visit (short Buff plus
  often a Rumor).
- **The_Warm_Machine**: The restaurant, run by the cook Ash; sells one meal per visit (full heal
  plus a run-long Buff).
- **The_Board**: The town building where the Player chooses the next Dungeon and sees its Rank and
  one hint.
- **The_Chapel**: The Chapel of Small Mercies, the Attunement shrine; displays the Attuned_Set.
- **Simulacrum**: A broken computer representation of a person populating most of Vigil; glitches
  mechanically; never confirmed real or not.
- **Human_NPC**: A rare real surviving person found in a Dungeon; glitches emotionally; can be led
  back to Vigil to take a persistent town role.
- **Ruined_Vigil**: A Dungeon variant mirroring Vigil street-for-street with zombified versions of
  the same NPCs, reusing the Crypts undead roster reskinned.

### Health and persistence

- **Health_Container**: The unit of maximum health, displayed with an evolving icon (leaf → yellow
  star → rainbow star) that changes with progression; maximum-health upgrades persist on a Clear.
- **Damage_Unit**: The internal damage measure; 8 units = 1 full Health_Container.
- **Resumable_Save**: A single saved in-progress Run allowing the Player to stop and continue the
  same Dungeon/Run later; discarded when a new game is started; not a death-recovery mechanism.

## Requirements

---

## System A — Input & Control

### Requirement 1: Six-Input Control Scheme

**User Story:** As a player, I want LTTP's tight six-button scheme, so that control feels like
*A Link to the Past* and the input map stays small.

#### Acceptance Criteria

1. THE Input_Scheme SHALL map exactly six inputs: 8-directional movement, Attack (B), Context_Action
   (A), Item (Y), Map (X), and Inventory/Pause (Start).
2. THE Input_Scheme SHALL accept 8-directional movement from D-pad, WASD, and arrow keys mapped to
   the same movement actions.
3. WHEN the Player taps the Attack input, THE Game SHALL perform a sword swing in the
   Player_Character's facing direction.
4. WHEN the Player holds the Attack input for the configured spin-charge duration and then releases,
   THE Game SHALL perform a Spin_Attack, provided the Spin_Attack is unlocked.
5. WHEN the Player presses the Context_Action input, THE Game SHALL resolve a single context verb
   from the tile or entity the Player_Character faces, selected from lift, throw, pull, push, talk,
   read, open chest, swim, and dash.
6. WHEN the Player presses the Item input, THE Game SHALL activate the Equipped_Item's verb.
7. WHEN the Player presses the Map input, THE Game SHALL open the Dungeon map view.
8. WHEN the Player presses the Inventory/Pause input, THE Game SHALL open the inventory sub-screen
   and pause the world per Requirement 47.
9. THE Input_Scheme SHALL NOT define any player-facing combat or interaction input beyond the six
   inputs named in criterion 1.

### Requirement 2: Single Equipped Item

**User Story:** As a player, I want only one item equipped at a time, so that loadout choices carry
the tension LTTP's single-item economy creates.

#### Acceptance Criteria

1. THE Inventory SHALL allow exactly one Equipped_Item bound to the Item input at a time.
2. WHEN the Player selects a different item as the Equipped_Item in the paused inventory sub-screen,
   THE Inventory SHALL replace the previously Equipped_Item binding with the newly selected item.
3. WHEN the Player presses the Item input WHILE no item is equipped, THE Game SHALL take no item
   action.

---

## System B — Movement

### Requirement 3: Eight-Directional Movement

**User Story:** As a player, I want free 8-directional movement on a tile-collision world, so that
traversal feels like LTTP rather than grid-stepping.

#### Acceptance Criteria

1. THE Game SHALL move the Player_Character continuously in pixels in any of 8 directions, not
   snapped to a tile grid while walking.
2. THE Game SHALL resolve Player_Character collision against a 32 × 32 px tile grid using a
   collision bounds smaller than the Player_Character's sprite so corners can be slipped past.
3. WHEN the Player_Character pushes against a wall adjacent to a one-tile doorway, THE Game SHALL
   actively slide and nudge the Player_Character toward and into alignment with the one-tile doorway
   opening so the doorway can be entered cleanly, as an active assist rather than only passing the
   Player_Character through when the raw movement vector already aligns with the opening (edge
   alignment).
4. THE Game SHALL set the Player_Character's facing to one of 4 cardinal directions determined by
   the last-pressed movement axis, even while moving diagonally, and SHALL direct sword attacks along
   that facing.
5. THE Game SHALL drive walk and dash speeds from Tunables (see Requirement 48) rather than
   hardcoded constants.

### Requirement 4: Authentic Fast Diagonal Movement

**User Story:** As a player, I want LTTP's authentic diagonal-is-faster quirk, so that traversal
feels like the original and speed-tech is preserved.

#### Acceptance Criteria

1. WHILE moving diagonally AND the authentic-diagonal Tunable is set to its default (authentic-fast),
   THE Game SHALL advance each movement axis at the full walk speed, so diagonal movement covers
   approximately 1.41× the ground per frame of cardinal movement.
2. THE Game SHALL expose the authentic-diagonal behavior as a configurable Tunable toggle whose
   default value is authentic-fast.
3. WHILE the authentic-diagonal Tunable is set to normalized, THE Game SHALL scale diagonal movement
   so its magnitude equals cardinal walk speed.

---

## System C — Combat

### Requirement 5: Melee Sword and Reach

**User Story:** As a player, I want a short-reach sword with a readable swing, so that jousting in
and out of range is the core melee rhythm.

#### Acceptance Criteria

1. WHEN the Player taps the Attack input, THE Game SHALL produce a melee hitbox in front of the
   Player_Character reaching approximately one tile beyond the Player_Character's body for the
   configured swing-active duration.
2. WHEN the sword hitbox overlaps an Enemy during its active frames, THE Game SHALL apply sword
   damage scaled by the current sword tier (×1 / ×2 / ×3 / ×4) and apply Knockback to that Enemy.
3. THE Game SHALL define sword reach, swing-active duration, and sword-tier multipliers as Tunables.

### Requirement 6: Spin Attack

**User Story:** As a player, I want a charged spin attack, so that I can answer enemies that circle
or bounce away.

#### Acceptance Criteria

1. WHILE the Player holds the Attack input AND the Spin_Attack is unlocked, THE Game SHALL charge the
   Spin_Attack over the configured spin-charge duration while still permitting walking.
2. WHEN the Player releases the Attack input after the spin-charge duration is met, THE Game SHALL
   perform a 360° attack hitting the surrounding tiles for approximately double a normal swing's
   damage and SHALL lock the Player_Character's facing for the duration of the spin; IF the Player
   releases the Attack input before the spin-charge duration is met, THEN THE Game SHALL perform a
   normal, uncharged sword swing rather than cancelling the attack with no damage.
3. IF the Spin_Attack is not unlocked WHEN the Player holds and releases the Attack input, THEN THE
   Game SHALL perform a normal swing on tap and SHALL NOT perform a Spin_Attack.
4. THE Game SHALL define the spin-charge duration and spin damage multiplier as Tunables.

### Requirement 7: Sword Beams at Full Health

**User Story:** As a player, I want sword beams at full health with a strong enough sword, so that
staying topped up is rewarded.

#### Acceptance Criteria

1. WHEN the Player swings the sword WHILE the Player_Character is at full health AND holds the Master
   Sword or a higher tier, THE Game SHALL always fire a Sword_Beam projectile along the facing
   direction dealing normal sword damage, with no additional prerequisite such as a cooldown or
   target-availability condition suppressing the Sword_Beam.
2. IF the Player_Character is below full health OR does not hold the Master Sword or higher WHEN
   swinging, THEN THE Game SHALL NOT fire a Sword_Beam.

### Requirement 8: Contact Damage, Knockback, and I-Frames

**User Story:** As a player, I want contact damage with knockback and invincibility frames, so that
combat has the exact LTTP bump-and-recover feel.

#### Acceptance Criteria

1. WHEN an Enemy's body overlaps the Player_Character's hurtbox AND the Player_Character is not in
   I_Frames, THE Game SHALL apply that Enemy's bump damage to the Player_Character.
2. WHEN the Player_Character takes a damaging hit, THE Game SHALL apply Knockback and a brief
   hit-stun that removes Player control for the configured hit-stun duration.
3. WHEN the Player_Character takes a damaging hit, THE Game SHALL grant I_Frames for the configured
   i-frame duration, during which further hits from i-frame-respecting sources pass through without
   dealing damage.
4. WHERE a damage source is defined to ignore I_Frames, WHEN that source overlaps the
   Player_Character during I_Frames, THE Game SHALL apply that source's damage.
5. THE Game SHALL define the i-frame duration, hit-stun duration, and knockback magnitude as
   Tunables, with the i-frame duration flagged `[approx]` and marked tune-first.

### Requirement 9: Passive Facing Shield

**User Story:** As a player, I want a passive shield that blocks what I face, so that positioning is
my defense without a block button.

#### Acceptance Criteria

1. WHEN a blockable projectile reaches the Player_Character from within the arc of the
   Player_Character's current facing direction, THE Game SHALL block that projectile and apply no
   damage.
2. WHERE the equipped shield tier is defined to block beams or lasers, WHEN such a beam reaches the
   Player_Character from the faced direction, THE Game SHALL block it.
3. THE Game SHALL perform shield blocking passively, with no dedicated block input.

### Requirement 10: Damage Taken Reduction (Tunic/Mail)

**User Story:** As a player, I want armor that reduces damage, so that mail upgrades matter within a
run.

#### Acceptance Criteria

1. WHEN the Player_Character takes damage, THE Game SHALL reduce the Damage_Unit amount by the
   equipped mail tier's reduction factor (0% / 50% / 75%).
2. THE Game SHALL measure damage in Damage_Units where 8 Damage_Units equal one Health_Container, and
   SHALL define mail reduction factors as Tunables.

---

## System D — Interaction

### Requirement 11: Context Action Verbs

**User Story:** As a player, I want one button that does the right thing based on what I face, so
that the world stays interactive with a tiny input map.

#### Acceptance Criteria

1. WHEN the Player presses the Context_Action input, THE Game SHALL select exactly one verb based on
   the tile or entity in the Player_Character's facing direction and the Player_Character's current
   capabilities.
2. WHEN the faced entity is an NPC or a readable object, THE Game SHALL talk or read, locking
   Player_Character movement for the duration of the resulting text.
3. WHEN the faced object is a liftable object AND the Player_Character meets the lift requirement for
   that object, THE Game SHALL lift it; WHILE carrying a lifted object, WHEN the Player presses the
   Context_Action input, THE Game SHALL throw it as a projectile that damages Enemies and breaks on
   impact.
4. WHEN the faced object is a chest, THE Game SHALL open it and suspend play for the item-get
   sequence.
5. WHEN the faced object is a pullable or pushable block, THE Game SHALL pull it (when the Player
   presses away while adjacent) or push it one tile per push (when the Player walks into it).
6. WHEN the faced tile is deep water AND the Player_Character holds the Flippers, THE Game SHALL
   enter the swim state.

### Requirement 12: Dash with Pegasus Boots

**User Story:** As a player, I want the action button to serve both as a quick directional dodge-dash
and a sustained run once I have the Pegasus Boots, so that I can dodge attacks with a tap and cover
ground with a hold while keeping the six-input scheme intact.

#### Acceptance Criteria

1. WHILE the Player_Character holds the Pegasus Boots, WHEN the Player taps the Context_Action input
   and releases it before the configured hold-threshold duration, THE Game SHALL perform a
   directional dodge-dash: a short, fast burst in the current movement direction, or in the facing
   direction when the Player_Character is stationary, over the configured dodge-dash distance and
   duration.
2. WHEN the Player_Character performs a dodge-dash, THE Game SHALL grant I_Frames for the configured
   dodge i-frame duration, during which further hits from i-frame-respecting sources pass through
   without dealing damage, consistent with the I_Frames model in Requirement 8.
3. WHILE the Player_Character holds the Pegasus Boots AND the Player holds the Context_Action input
   past the configured hold-threshold duration, THE Game SHALL run the Player_Character (sustained
   dash) in the facing direction at the configured dash/run speed.
4. WHILE running, THE Game SHALL NOT allow the Player_Character to turn, and WHEN the Player presses
   a different movement direction, THE Game SHALL end the run.
5. WHILE dodge-dashing or running, WHEN the Player_Character contacts an Enemy, THE Game SHALL apply
   damage and Knockback to that Enemy as an offensive dash-attack rather than only halting the dash;
   AND WHILE dodge-dashing or running, WHEN the Player_Character contacts a pot, a breakable block, or
   a cracked wall, THE Game SHALL break that object.
6. THE Game SHALL distinguish a tap from a hold using the configured hold-threshold duration Tunable:
   a Context_Action release before the hold-threshold duration is a dodge-dash, and a Context_Action
   hold past the hold-threshold duration begins the run.
7. IF the Player_Character does not hold the Pegasus Boots, THEN THE Game SHALL perform neither the
   dodge-dash nor the run, while the Context_Action input continues to resolve its other context
   verbs per Requirement 11; the dodge-dash and run are the Context_Action behavior only when the
   Player_Character holds the Pegasus Boots and no other context verb applies.

---

## System E — Items & Attunement

### Requirement 13: Item Taxonomy

**User Story:** As a player, I want items grouped into clear kinds, so that I understand what will
persist and what resets.

#### Acceptance Criteria

1. THE Inventory SHALL classify every Item as exactly one of ATTACK_Item, UTILITY_Item,
   PASSIVE_Item, or CONSUMABLE_Item.
2. THE Game SHALL read item definitions from a data-driven catalogue keyed by item id, each carrying
   at least name, kind, verb, magic cost, gate, biome, tier, attune flag, and description.
3. THE Game SHALL start a brand-new Player_Character with the bare sword swing as the single starting
   cataloged Item in the Inventory — an Item instance in the data-driven catalogue of criterion 2
   rather than an innate non-Item action — and with no other attack or utility verb unlocked.

### Requirement 14: Attack and Utility Unlocks

**User Story:** As a player, I want every attack beyond the basic swing to be an unlock I find, so
that power is progression.

#### Acceptance Criteria

1. WHEN the Player_Character acquires an ATTACK_Item or UTILITY_Item within a Run, THE Game SHALL
   enable that item's verb for the remainder of the Run.
2. THE Game SHALL gate the Spin_Attack behind acquiring the Knights' Crest, the Sword_Beam behind the
   Master Sword, and each item verb behind acquiring its item.
3. WHEN the Player presses the Item input WHILE an item with a magic or ammo cost is equipped AND the
   Player_Character has insufficient magic or ammo, THE Game SHALL NOT activate the verb and SHALL
   leave the resource unchanged.

### Requirement 15: Items as Gate Keys

**User Story:** As a player, I want certain items to double as keys to the world, so that finding a
tool opens new paths.

#### Acceptance Criteria

1. WHEN the Player_Character uses Bombs adjacent to a cracked wall, THE Game SHALL open that cracked
   wall into a passage.
2. WHEN the Player_Character uses the Fire Rod on web tiles, THE Game SHALL clear those web tiles;
   WHEN the Player_Character uses the Ice Rod on deep-water tiles, THE Game SHALL freeze those tiles
   into crossable surface; WHEN the Player_Character uses the Hookshot across a gap toward a valid
   anchor, THE Game SHALL pull the Player_Character across the gap.
3. WHILE the Player_Character holds the Flippers, THE Game SHALL allow crossing deep-water tiles that
   otherwise act as a wall.
4. THE Game SHALL treat each gate-opening item use as satisfying the corresponding Gate for
   Reachability purposes (see Requirement 30).

### Requirement 16: Bombs as Weapon and Gate Key with Knockback

**User Story:** As a player, I want bombs that blow things back and crack open walls, so that bombs
are both a weapon and a key.

#### Acceptance Criteria

1. WHEN a bomb detonates, THE Game SHALL apply blast damage to Enemies within the blast radius and
   apply Knockback to those Enemies.
2. WHEN a bomb detonates WHILE the Player_Character is within the blast radius, THE Game SHALL apply
   both blast damage and Knockback to the Player_Character.
3. WHEN a bomb detonates adjacent to a cracked dungeon wall, THE Game SHALL open that cracked wall
   (cracked-wall Gate).
4. THE Game SHALL define bomb blast radius and bomb knockback magnitude as Tunables.

### Requirement 17: Pedestals and Boss Loot as Item Sources

**User Story:** As a player, I want to find items on pedestals and from bosses, so that each dungeon
can grow my toolkit.

#### Acceptance Criteria

1. THE Generator SHALL NOT place a Pedestal item in the start Room, and SHALL give each non-start
   Room a chance to hold exactly one Pedestal item, weighted by the Room's biome and Depth, such that
   deeper and rarer biomes draw from a better pool, so that the per-Room Pedestal chance applies only
   to non-start Rooms and the start Room never holds a Pedestal item.
2. THE Generator SHALL place on Pedestals only items not already in the Attuned_Set.
3. WHEN the Player_Character defeats the Dungeon's Boss, THE Game SHALL drop one to two guaranteed
   ATTACK/UTILITY items the Player_Character does not already own, never duplicating an Attuned_Item.
4. WHEN the Player_Character's bounds overlap a Pedestal item or a dropped item, THE Inventory SHALL
   add it to the current Run's items.

### Requirement 18: Attunement on Clear

**User Story:** As a player, I want to keep the attack and utility items I carried through a cleared
dungeon, so that each clear permanently widens my toolkit.

#### Acceptance Criteria

1. WHEN a Run ends in a Clear, THE Game SHALL Attune every ATTACK_Item and UTILITY_Item the
   Player_Character was carrying, adding each to the Attuned_Set as Persistent_State.
2. WHEN a Run ends in a Clear, THE Game SHALL NOT Attune PASSIVE_Items or CONSUMABLE_Items.
3. WHEN a new Run begins, THE Game SHALL grant the Player_Character every Attuned_Item from the start
   and SHALL remove Attuned_Items from the Pedestal and Boss-loot pools for that Run.
4. WHEN a Run ends in Player_Character defeat, THE Game SHALL discard that Run's found ATTACK/UTILITY
   items and SHALL NOT Attune them, while leaving the previously Attuned_Set intact.

---

## System F — Enemies

### Requirement 19: Data-Driven Bestiary and Archetypes

**User Story:** As a player, I want enemies with distinct, readable behaviors, so that each fight
poses a clear question.

#### Acceptance Criteria

1. THE Game SHALL read all Enemy definitions from the data-driven Bestiary and SHALL NOT depend on a
   hardcoded enumeration of enemies in the spawning algorithm.
2. THE Game SHALL implement the nine Archetypes PATROL, CHASE, CHARGER, TURRET, LOBBER, JUMPER,
   SWARM, PHASE, and SUMMONER, each with its defined behavior.
3. THE Game SHALL define each Enemy with at least archetype, HP (measured in base sword hits), damage
   (in Damage_Units), speed (in px/s), an optional ranged block, aggro radius, tags, and an
   elite-at-depth value.
4. THE Game SHALL resolve Enemy weaknesses from tags rather than hardcoded identities (for example
   fire splits a Lava Slime, ice shatters an Obsidian Golem, bombs crack a Warden shield).

### Requirement 20: Telegraph-First Fairness

**User Story:** As a player, I want every attack telegraphed and no off-screen ambush, so that
procedural rooms stay fair.

#### Acceptance Criteria

1. WHEN an Enemy begins a harmful action, THE Game SHALL play a readable Telegraph (flash, recoil,
   wind-up, or crouch) before the action deals damage.
2. THE Game SHALL NOT allow an Enemy to deal first-contact damage to the Player_Character from
   off-screen.

### Requirement 21: Seven Biomes and the Depth Route

**User Story:** As a player, I want the dungeon to move through themed biomes, so that the run has a
route with escalating variety.

#### Acceptance Criteria

1. THE Generator SHALL assign each Room a Biome from the depth route in the order Hollow Crypts →
   Silkfall Warrens → Thornwild → Emberdeep → Glacier Barrow → Sunken Ruins → The Arcanum, so a Run
   follows a route rather than a shuffle.
2. THE Game SHALL populate each Biome's Rooms from that Biome's defined enemy roster, hazards, and
   boss.
3. WHERE a Biome defines environmental hazards (web tiles, lava tiles, ice tiles, deep water), THE
   Game SHALL apply those hazards' defined effects within that Biome's Rooms.

### Requirement 22: Spawn Rules

**User Story:** As a player, I want enemy placement that fits each room and never feels unfair, so
that encounters read well in generated layouts.

#### Acceptance Criteria

1. WHEN populating a Room, THE Spawner SHALL draw 0–N Enemies weighted by archetype, biasing
   SWARM/CHASE toward wide rooms, TURRET/LOBBER toward rooms with cover, and CHARGER toward
   corridors.
2. THE Spawner SHALL place at most one SUMMONER per Room.
3. THE Spawner SHALL NOT place any SUMMONER in the first Room of a Run.
4. THE Spawner SHALL place the Boss, with its fixed escort, only in the Dungeon's exit Room, and
   SHALL NOT place the Boss or its escort in any Room that is not the Dungeon's exit Room, so that
   placing the Boss or its escort outside the exit Room is a hard violation.
5. WHEN the same Seed is used, THE Spawner SHALL produce the same enemy placement.

### Requirement 23: Corrupted Elite Leak

**User Story:** As a player, I want rare high-tech elites to leak into any biome at depth, so that
the techno threat feels like it is spreading.

#### Acceptance Criteria

1. WHERE a Room's Depth is 5 or greater, THE Spawner SHALL have a defined rare chance to place a
   Corrupted_Elite (a Techno-Priest or Laser Warthog) in that Room regardless of its Biome.
2. WHILE a Room's Depth is less than 5, THE Spawner SHALL NOT place a Corrupted_Elite.

---

## System G — Bosses

### Requirement 24: Boss Framework

**User Story:** As a player, I want bosses that are learnable, telegraphed, and phased, so that
mastering a fight is a skill, not luck.

#### Acceptance Criteria

1. WHEN a Boss begins any action, THE Game SHALL play a readable Telegraph before the action deals
   damage.
2. THE Game SHALL run each Boss as a repeating cycle of named patterns drawn from the implemented set
   {breath, volley, stomp, ring, charge, laser, summon}.
3. WHEN a Boss's HP crosses a defined phase threshold, THE Game SHALL swap the Boss's pattern set and
   apply its defined phase speed change.
4. WHEN a Boss completes a defined big attack, THE Game SHALL enter a Weak_Window of approximately
   1.5 s during which the Boss takes double damage.
5. THE Game SHALL define Weak_Window duration and the double-damage multiplier as Tunables.

### Requirement 25: Guaranteed Loot Required to Count a Clear

**User Story:** As a player, I want the boss to always drop a real tool I must claim, so that the
clear and its attunement are earned.

#### Acceptance Criteria

1. WHEN a Boss is defeated, THE Game SHALL drop one to two guaranteed ATTACK/UTILITY items in the
   arena, none duplicating an Attuned_Item.
2. THE Game SHALL count a Dungeon as solved only when the Boss is defeated AND its guaranteed loot
   has been claimed by the Player_Character.
3. WHEN the Dungeon is counted solved, THE Game SHALL treat the Run as a Clear for Attunement and
   banking purposes.

### Requirement 26: The 100-Boss Ladder

**User Story:** As a player, I want one escalating boss per dungeon with the dragon always first, so
that progress through the ladder is literal and legible.

#### Acceptance Criteria

1. THE Generator SHALL place exactly one Boss in each Dungeon.
2. WHEN the Player_Character's recorded Clears count is 0, THE Game SHALL make the Dungeon's Boss
   Gloamwing the tutorial dragon.
3. WHEN the Player_Character has recorded N Clears where N is greater than or equal to 0, THE Game
   SHALL select the Boss at Rank N+1 on the Boss_Ladder for the next Dungeon.
4. THE Boss_Ladder SHALL define 100 Bosses in a fixed escalating order at Ranks 1 through 100.
5. THE Game SHALL compute each standard Boss_Ladder Boss (Rank 1 through 100) HP as 12 + Rank × 2 and
   base speed as 48 + Rank × 0.8 px/s, and SHALL increase the Boss's phase count at Ranks 20, 60, and
   85, using these formulas as Tunables.
6. THE Game SHALL render every standard Boss_Ladder Boss's HP, speed, and phase scaling (Rank 1
   through 100) as monotonically non-decreasing with Rank.
7. WHILE play follows normal progression, THE Game SHALL start the Clears count at 0 and SHALL
   increment the Clears count only on a Clear, so that normal progression keeps the Clears count
   greater than or equal to 0 and the normal Rank greater than or equal to 1 (Clears count 0 maps to
   Rank 1, Gloamwing).
8. WHERE a special or scripted case sets a negative Clears count or negative Rank value, THE Game
   SHALL select a special, out-of-ladder Boss defined for that negative value rather than a standard
   Boss_Ladder Boss at Rank 1 through 100.
9. THE Game SHALL reserve negative Clears count and negative Rank values for special or scripted
   cases only, and normal progression SHALL NOT produce a negative Clears count or negative Rank
   value.
10. WHERE a Boss is a special, out-of-ladder Boss selected for a negative Rank value, THE Game SHALL
    define that Boss's HP, speed, and phase behavior separately from the standard Boss_Ladder
    formulas, so the Rank 1 through 100 scaling formulas and the monotonic-with-Rank rule in criteria
    5 and 6 apply only to standard Boss_Ladder Ranks 1 through 100 and do not bind special
    out-of-ladder Bosses.

---

## System H — Dungeon Generation

### Requirement 27: Rooms on a Door Graph with Free-Scrolling Camera

**User Story:** As a player, I want a dungeon built from connected rooms that I explore as one
continuous, free-scrolling space, so that each run is a distinct, coherent descent without hard
screen-to-screen snaps.

> **Room model (reconciled with System Z):** A Room is NOT fixed to the view. The VIEW is
> VIEW_TILES_W × VIEW_TILES_H (20 × 14 / 640 × 448 px); a ROOM ranges from the view size up to
> ROOM_MAX_TILES_W × ROOM_MAX_TILES_H (80 × 56 / 2560 × 1792 px) and the camera scrolls within larger
> Rooms. Requirements 66 and 67 (System Z) are authoritative for Room sizing and camera scroll; this
> requirement is now consistent with that model (room ≠ view).

#### Acceptance Criteria

1. THE Generator SHALL build each Room on the TILE_PX grid at a size in the range VIEW_TILES_W × VIEW_TILES_H (20 × 14, 640 × 448 px) up to ROOM_MAX_TILES_W × ROOM_MAX_TILES_H (80 × 56, 2560 × 1792 px) with defined door cells, where a Room MAY be larger than the view (room ≠ view): a baseline Room equals the view and does not scroll, while a larger Room scrolls within its bounds (see Requirement 66 and Requirement 67 of System Z, which are authoritative for Room sizing).
2. THE Generator SHALL connect Rooms into a Door_Graph where Rooms are nodes and doors are edges,
   tagging a start Room and a far exit Room.
3. WHILE the Player_Character moves through the Dungeon, THE Game SHALL follow the Player_Character
   with a continuously scrolling camera across contiguous Rooms as one stitched space, performing no
   hard room-to-room screen snap, AND SHALL clamp the camera to the bounds of the active stitched
   generated region so the camera never shows outside the generated space.
4. THE Generator SHALL place locked doors with matching keys and the boss/exit room as part of the
   Door_Graph, and SHALL guarantee that every locked door's matching key is reachable before that
   locked door — never placing a key behind the locked door it unlocks or in an area unreachable
   without that door — so that key-before-lock reachability holds for every locked door, consistent
   with the Reachability rule of Requirement 30.
5. THE Generator SHALL treat each Room as the unit of generation, collision, and Reachability even
   though Rooms are not individually screen-locked and MAY be larger than the view.

### Requirement 28: Depth-Based Difficulty Scaling

**User Story:** As a player, I want deeper rooms to get harder through new combinations, so that
descent feels like escalation rather than only bigger numbers.

#### Acceptance Criteria

1. WHERE a Room's Depth is 0 or greater, THE Generator SHALL scale enemy density and encounter
   composition by Room Depth, adding new archetype combinations at greater Depth rather than only
   increasing HP, so that Depth-based scaling applies from Depth 0 upward (the Depth 0 entry Room is a
   valid, scaled Room).
2. THE Generator SHALL set Pedestal loot quality to a positive baseline and SHALL scale that quality
   only upward with Room Depth and biome rarity, so that Pedestal loot quality is positive even at
   Depth 0 and zero biome rarity and increases from the baseline as Depth and biome rarity increase.

### Requirement 29: Run Length Scaling with Biome Count

**User Story:** As a player, I want the first world to take 15–25 minutes and runs to grow as more
biomes unlock, so that session length scales with content.

> **Cross-reference (Route_Length):** The explicit Route_Length the Player chooses at The_Board (see
> Requirement 55) is the concrete driver of how many Biomes a Run traverses, and therefore of Run
> length. The looser "scales with the number of available Biomes" wording in this requirement is
> clarified by, and reconciled with, that model: the chosen Route_Length determines the Biome count
> for the Run, the shortest unlocked routes target the 15–25 minute first-world duration below, and
> longer routes take proportionally longer. This note ties the two requirements together without
> changing the behavior of either.

#### Acceptance Criteria

1. THE Generator SHALL size the first available world so a representative Clear targets a
   15–25 minute Run duration.
2. THE Generator SHALL derive the target Run duration from a configurable Tunable that increases as
   the number of Biomes available to the generator increases, where the number of Biomes traversed
   by a Run is the chosen Route_Length (see Requirement 55).
3. WHEN more Biomes become available to the generator, THE Generator SHALL lengthen the generated
   Dungeon (more Rooms along the route) so the target Run duration grows accordingly.

---

## System I — Reachability & Validity

### Requirement 30: Gated Generation with the Logic Rule

**User Story:** As a player, I want every dungeon to be completable, so that no seed is a dead end.

#### Acceptance Criteria

1. THE Generator SHALL choose a gate plan for the route and, for each Gate, place a source of the
   Gate's required item or key in a Room reachable before that Gate without needing the gated item.
2. THE Generator SHALL NOT place a gate-opening item in a Room that is only reachable after the Gate
   it opens.
3. THE Generator SHALL place Pedestal items from the shuffled unattuned pool subject to criteria 1
   and 2.
4. WHEN starting a Dungeon, THE Reachability check SHALL verify the exit Room is reachable from the
   start Room using the Attuned_Set plus items placed before each Gate.
5. IF the Reachability check fails, THEN THE Generator SHALL re-roll the Dungeon from the Seed and
   SHALL NOT hand an uncompletable Dungeon to the Player.

---

## System J — Seeding

### Requirement 31: Single Seeded RNG

**User Story:** As a player, I want seeds that reproduce a whole dungeon, so that runs are shareable
and deterministic.

#### Acceptance Criteria

1. THE Generator SHALL thread a single seeded random number generator through Dungeon layout, loot
   placement, and enemy placement.
2. WHEN two Dungeons are generated with the same Seed and the same Attuned_Set, THE Generator SHALL
   produce an identical Dungeon — identical Door_Graph structure, Room layouts, loot placement, and
   enemy placement — strictly and deterministically, so that the same Seed and the same inputs always
   reproduce the same Dungeon.
3. THE Game SHALL display the current Seed and allow it to be read for sharing.

---

## System K — Town / Vigil & Economy

### Requirement 32: Vigil as Run Boundary

**User Story:** As a player, I want every run to begin and end in Vigil, so that the town is my
constant home between dungeons.

> **Start-hub supersession (System AA, Requirement 73):** The run-start / level-select role of Vigil
> is superseded by the Dark_Room start hub — each new Run now starts in the Dark_Room (loadout +
> Level_Select) rather than at Vigil's The_Board. The Run-boundary and return-on-end behavior below
> otherwise holds, with the start hub now the Dark_Room; a Run still ends by Clear or death and
> retains Persistent_State.

#### Acceptance Criteria

1. WHEN a Run ends by Clear or by death, THE Game SHALL return the Player_Character to Vigil with
   that visit's purchases reset and the Attuned_Set intact.
2. THE Game SHALL have Vigil contain the enterable buildings The_Last_Call (bar), The_Warm_Machine
   (restaurant), The Forge, The Apothecary, The_Chapel, The_Board, and The Pawnbroker as a global,
   persistent fact that holds regardless of the Player_Character's current location, so that Vigil
   contains those buildings whether or not the Player_Character is in Vigil.
3. WHEN the Player chooses a Dungeon at The_Board and enters it, THE Game SHALL begin a new Run.

### Requirement 33: The Bar — One Drink per Visit

**User Story:** As a player, I want a cheap drink that gives a short buff and sometimes a rumor, so
that I can learn what is coming.

#### Acceptance Criteria

1. WHILE in The_Last_Call, THE Game SHALL allow the Player to buy at most one drink per town visit.
2. WHEN the Player buys a drink, THE Game SHALL apply that drink's short, run-scoped Buff.
3. WHERE a drink defines a Rumor, WHEN the Player buys that drink, THE Game SHALL present a Rumor
   about the next Dungeon.
4. THE Game SHALL draw Rumor text from the next Dungeon's real generation (a hazard, a Gate, or the
   Boss's tell) and SHALL make the Rumor truthful but partial.

### Requirement 34: The Restaurant — One Meal per Visit

**User Story:** As a player, I want a meal that heals me fully and buffs the whole run, so that I can
prepare to survive.

#### Acceptance Criteria

1. WHILE in The_Warm_Machine, THE Game SHALL allow the Player to buy at most one meal per town visit.
2. WHEN the Player buys a meal, THE Game SHALL fully restore the Player_Character's health and apply
   that meal's run-long Buff.
3. IF a second drink Buff is active OR a second meal Buff is active, THEN THE Game SHALL treat that
   condition as invalid, so that a second drink Buff or a second meal Buff being active is itself a
   violation regardless of the state of the first drink Buff or first meal Buff.

### Requirement 35: Town Buffs Are Run-Scoped

**User Story:** As a player, I want town buffs to last only for the run I bought them for, so that
town purchases stay meaningful every run.

#### Acceptance Criteria

1. THE Game SHALL apply town Buffs only within the Run they were bought for.
2. THE Game SHALL NOT Attune any town Buff.

### Requirement 36: Sparks Economy

**User Story:** As a player, I want a currency I earn in dungeons and spend in town, so that risk in
the dungeon funds preparation.

#### Acceptance Criteria

1. WHEN an Enemy or Boss is defeated, THE Game SHALL drop Sparks scaled by the Dungeon's Rank and the
   Room's Depth, with the Dungeon's Rank greater than 0 whenever Sparks are dropped, so that Sparks
   are dropped only with a positive Rank scaling factor and never with a zero or unset Rank.
2. THE Game SHALL scale town prices with the next Dungeon's Rank by the factor (1 + Rank × 0.05).
3. WHEN a Run ends in a Clear, THE Game SHALL bank that Run's collected Sparks into Persistent_State.
4. WHEN a Run ends in death, THE Game SHALL lose that Run's unbanked Sparks.
5. THE Game SHALL allow the Pawnbroker to convert unclaimed loot into Sparks WHEN unclaimed loot is
   present AND SHALL NOT allow the Pawnbroker to convert unclaimed loot into Sparks WHEN no unclaimed
   loot is present, so that the conversion is available exactly when unclaimed loot exists.
6. IF the Player cannot afford an option, THEN THE Game SHALL display its price and dim the purchase
   option.

### Requirement 37: The Board and the Chapel

**User Story:** As a player, I want to choose my next dungeon and review my permanent unlocks, so
that I can plan a run.

#### Acceptance Criteria

1. THE_Board SHALL display the next Dungeon's Rank and exactly one hint.
2. WHEN the Player selects a Dungeon at The_Board, THE Game SHALL set that Dungeon as the next Run's
   Dungeon.
3. THE_Chapel SHALL display the current Attuned_Set.

---

## System L — NPCs & Ruined Vigil

### Requirement 38: Simulacra Populate the Town

**User Story:** As a player, I want a town of warm, uncanny simulacra, so that Vigil feels alive and
unsettling without ever being explained.

#### Acceptance Criteria

1. THE Game SHALL populate Vigil mostly with Simulacra that loop, glitch, freeze, reboot, and cite
   memories that never happened.
2. THE Game SHALL glitch Simulacra mechanically (small loops, dropped frames, repeated lines).
3. THE Game SHALL NOT present any confirmation or denial of whether a given NPC is real.
4. THE Game SHALL permit Simulacra to appear within any Biome, including wild Overworld areas and
   Dungeons.
5. THE Game SHALL concentrate Simulacra density at its highest value in and immediately around Vigil.
6. WHERE a location lies farther from Vigil into wild Overworld areas or into a Dungeon, THE Game
   SHALL place progressively fewer Simulacra as a continuous, gradual gradient that decreases
   smoothly with distance from Vigil, rather than dropping sharply at zone or biome boundaries.

### Requirement 39: Rare Human NPCs Recruited from Dungeons

**User Story:** As a player, I want to find real people in dungeons and bring them home, so that the
town can gain genuine inhabitants worth protecting.

#### Acceptance Criteria

1. THE Game SHALL make Human_NPCs encounterable within any Biome, including wild Overworld areas and
   Dungeons, as a rare occurrence.
2. THE Game SHALL concentrate Human_NPC density at its highest value near Vigil, which alone
   satisfies the density requirement, as an obligation independent of and separate from Human_NPC
   placement; and as a distinct placement obligation THE Game SHALL place progressively fewer
   Human_NPCs as distance from Vigil into wild Overworld areas or into a Dungeon increases.
3. WHEN the Player leads a Human_NPC back to Vigil, THE Game SHALL grant that Human_NPC a persistent
   town role as Persistent_State.
4. THE Game SHALL glitch Human_NPCs emotionally (panic, mistimed jokes, tears) rather than
   mechanically, as a tell that is never proof.

### Requirement 40: The Ruined Vigil Mirror Dungeon

**User Story:** As a player, I want a mirror of my town gone to rot, so that the game's central
question — which town is real — stays open.

#### Acceptance Criteria

1. THE Game SHALL provide a Ruined_Vigil Dungeon variant laid out to mirror Vigil street-for-street,
   populated by zombified versions of the same NPCs.
2. THE Game SHALL build the Ruined_Vigil's enemies by reusing the Hollow Crypts undead roster,
   reskinned to Vigil's characters.
3. THE Game SHALL NOT resolve whether the Ruined_Vigil is Vigil's past, its future, or the originals
   the Simulacra were copied from.

---

## System M — Health & Persistence

### Requirement 41: Health Container with Evolving Icon

**User Story:** As a player, I want a Zelda-style health meter whose icon evolves as I progress, so
that my growth is visible at a glance.

#### Acceptance Criteria

1. THE Health_System SHALL measure maximum and current health in Health_Containers, where one
   Health_Container equals 8 Damage_Units.
2. THE Health_System SHALL render each Health_Container with an evolving icon that is a leaf early in
   progression, a yellow star in mid progression, and a rainbow star at end-game progression.
3. WHEN the Player_Character's progression crosses a defined icon threshold, THE Health_System SHALL
   change the Health_Container icon to the next form.
4. WHEN the Player_Character's progression crosses a defined icon threshold WHILE current health is 0,
   THE Health_System SHALL update only the Health_Container icon appearance and SHALL leave current
   health unchanged at 0, performing no refill or adjustment of current health.

### Requirement 42: Persistent Maximum Health

**User Story:** As a player, I want maximum-health upgrades to persist across runs like my abilities,
so that surviving a clear permanently strengthens me.

#### Acceptance Criteria

1. WHEN a Run ends in a Clear, THE Game SHALL persist the Player_Character's maximum-health
   (Health_Container count) upgrades acquired that Run into Persistent_State.
2. WHEN a new Run begins, THE Game SHALL set the Player_Character's maximum health from the persisted
   Health_Container count.
3. THE Game SHALL treat maximum-health upgrades as persistent-on-clear and SHALL NOT reset them per
   Run, notwithstanding the general PASSIVE_Item reset rule.
4. WHEN a Run ends in death, THE Game SHALL retain the previously persisted maximum-health count.

---

## System N — Run & Death

### Requirement 43: Run Lifecycle

**User Story:** As a player, I want a clear run arc from town to dungeon and back, so that the
moment-to-moment structure is repeatable.

#### Acceptance Criteria

1. WHEN the Player enters the chosen Dungeon from Vigil, THE Game SHALL begin a Run and grant the
   Player_Character the Attuned_Set and persisted maximum health as its starting state.
2. WHEN the Player_Character reaches the exit Room alive, defeats the Boss, and claims its loot, THE
   Game SHALL end the Run as a Clear.
3. WHEN a Run ends, THE Game SHALL return the Player_Character to Vigil so a subsequent Run can begin
   without restarting the Game.

### Requirement 44: Death Is Final for the Run

**User Story:** As a player, I want death to cost me the run but not my permanent progress, so that
risk is real but progress is not erased.

#### Acceptance Criteria

1. WHEN the Player_Character's health reaches 0, THE Game SHALL end the Run as a death and return the
   Player_Character to Vigil for a new Run.
2. WHEN a Run ends in death, THE Game SHALL discard all Run-Scoped_State, including run-scoped items,
   PASSIVE_Items, CONSUMABLE_Items, keys, town Buffs, and unbanked Sparks.
3. WHEN a Run ends in death, THE Game SHALL retain all Persistent_State, including the Attuned_Set,
   persisted maximum health, banked Sparks, Boss_Ladder position, and recruited Human_NPC roles.
4. THE Game SHALL NOT provide any save-based recovery of a Run from death.

---

## System O — Save / Resume

### Requirement 45: Resumable In-Progress Run

**User Story:** As a player, I want to stop mid-run and continue the same world later, so that I can
play across sessions without abandoning a dungeon.

#### Acceptance Criteria

1. THE Save_System SHALL maintain at most one Resumable_Save representing a single in-progress Run.
2. WHEN the Player saves an in-progress Run, THE Save_System SHALL record the Run's Seed, Dungeon
   state, Player_Character position and Run-Scoped_State so the Player can return to the same Run and
   Dungeon later.
3. WHEN the Player resumes, THE Save_System SHALL restore the saved in-progress Run exactly as it was
   saved.
4. WHEN the Player starts a new game, THE Save_System SHALL discard the existing Resumable_Save.
5. WHEN a Run ends by Clear or death, THE Save_System SHALL clear the Resumable_Save so it cannot be
   used to recover a finished Run.

---

## System P — UI / HUD

### Requirement 46: Run HUD

**User Story:** As a player, I want to see my health, equipped item, seed, and depth, so that I can
read my state at a glance.

#### Acceptance Criteria

1. WHILE in a Dungeon, THE Game SHALL display the Player_Character's current and maximum
   Health_Containers using the current evolving icon form.
2. WHILE in a Dungeon, THE Game SHALL display the Equipped_Item, the current Seed, and the current
   Depth.
3. WHILE a Boss is active, THE Game SHALL display the Boss's HP bar.

### Requirement 47: Pausing Menus

**User Story:** As a player, I want menus to pause the world like LTTP, so that there is no real-time
inventory pressure.

#### Acceptance Criteria

1. WHEN the Player opens the inventory sub-screen, THE Game SHALL pause all world simulation until
   the sub-screen is closed.
2. WHEN the Player opens the Map view, THE Game SHALL pause world simulation until the Map view is
   closed.

---

## System Q — Tunables

### Requirement 48: Feel Numbers as Configurable Tunables

**User Story:** As a developer, I want every feel number held as configurable data with confidence
flags, so that we can tune by playtest instead of editing code.

#### Acceptance Criteria

1. THE Game SHALL store the following feel values as named Tunables rather than hardcoded constants:
   tile size (32 px), base canvas (640 × 448 px, 20 × 14 tiles), walk speed (~1.5–2.0 px/frame), dash speed
   (~2× walk, reused as the dash/run speed), spin-charge duration (~2.0 s), spin damage multiplier
   (×2), sword-tier multipliers (×1 / ×2 / ×3 / ×4), mail reduction factors (0% / 50% / 75%),
   Damage_Unit (8 = one Health_Container), i-frame duration (~0.5–1.0 s), dodge-dash distance (or
   duration), dodge i-frame duration (~0.3–0.5 s), tap-vs-hold hold-threshold duration (~0.15–0.25 s),
   hit-stun duration, knockback magnitude, sword reach (~1 tile), swing-active duration, Weak_Window
   duration (~1.5 s), Boss HP formula (12 + Rank × 2), Boss speed formula (48 + Rank × 0.8), the
   special / out-of-ladder Boss table keyed by negative Rank value (`[verify]`, reserved for special
   or scripted cases per Requirement 26, with HP/speed/phase defined per entry rather than by the
   Rank 1–100 formulas), bomb
   blast radius, bomb knockback magnitude, authentic-diagonal toggle, target Run duration, Boss
   attack delay window minimum (`[verify]`), Boss attack delay window maximum (`[verify]`), Boss
   feint probability per Rank (`[approx]`), Boss damage-per-hit scaling with Rank (`[verify]`), Boss
   target hits-to-kill at full health per Rank (`[verify]`), Boss phase-new-move count per phase
   transition (`[approx]`), the rarity-weighted enemy Death_Drop table keyed by Enemy rarity and
   Depth (`[verify]`), per-Chevron-color rarity/drop weights for all eight colors (`[approx]`), the maximum unlockable
   Route_Length (first-iteration value 7, `[approx]`, architected to support higher values up to the
   Biome_Library size per Requirement 55), the tutorial / short first-Dungeon maximum Room count
   (first-iteration value ~5–8 Rooms, `[approx]`, per Requirement 56.7), the minimum NPC count per Biome (`[approx]`), the minimum
   secret count per Biome (`[approx]`), the per-Biome biome-only item count (`[verify]`, per
   Requirement 56), the per-Biome_Variant rarity/selection weights governing which unlocked variant
   the Generator rolls for a Biome instance (`[approx]`, per Requirement 58), the plain-vs-variant
   chance/weighting governing how often a Biome instance is plain versus carrying a variant
   (`[approx]`, per Requirement 58), the per-Semantic_Object-type Tile_Library references and
   Prefab_Chunk set references (`[verify]`, per Requirement 59), the per-Semantic_Object assembly
   size/shape/layout ranges driving the Assembly_Rules (`[approx]`, per Requirement 59), the
   Unlock_Rule condition-type weights governing which condition types the Generator composes
   (`[approx]`, per Requirement 60), the maximum condition count per Unlock_Rule (`[approx]`, per
   Requirement 60), the unlock-rule generation/validation retry limit (`[approx]`, per
   Requirement 60.5), the Tier window size relative to Base_Level (first-iteration value ±5, a
   configurable range, `[approx]`, per Requirement 61), the per-distance Tier rarity/ladder curve
   weights governing how probability falls off with distance from Base_Level (`[approx]`, per
   Requirement 61), the Cursed_Item uncurse cost and location (TBD / `[verify]`, a deferred decision
   per Requirement 62), the per-Gear_Slot (Helmet, Body/Clothes, Shoes) base defense/stat-modifier
   values (`[approx]`, per Requirement 63), the per-Armor_Type (Tactical vs Armor) defense/modifier
   emphasis governing how Tactical leans toward mobility/utility and Armor leans toward defense/damage
   reduction (`[approx]`, per Requirement 63), the Worn_Gear defense stacking/composition rule
   governing how gear defense combines with the mail/tunic reduction of Requirement 10 (`[verify]`,
   per Requirement 63), and —
   WHERE an EXP/leveling system applies — EXP drop amount/weight (`[verify]`, conditional; no
   EXP/leveling system is otherwise specified in this document).
2. THE Game SHALL record a confidence flag of `exact`, `[approx]`, or `[verify]` for each Tunable,
   matching the reference, and SHALL flag the i-frame duration and the dodge i-frame duration
   `[approx]` and marked tune-first.
3. THE Game SHALL allow each Tunable to be changed in data without changing the systems that read it.
4. THE Game SHALL store the following presentation-layer size/scale values as named config
   constants, each flagged `exact` (these are LOCKED exact values, not `[approx]`), rather than as
   bare literals, consistent with the Graphics & Presentation Layer requirements of System Z
   (Requirements 64–72): `TILE_PX` (32), `PLAYER_W` (32), `PLAYER_H` (48), `VIEW_W` (640),
   `VIEW_H` (448), `VIEW_TILES_W` (20), `VIEW_TILES_H` (14), `ROOM_MAX_TILES_W` (80),
   `ROOM_MAX_TILES_H` (56), `ROOM_MAX_W` (2560), `ROOM_MAX_H` (1792), `SCALE_PRIMARY` (3),
   `SCALE_FALLBACK` (2), `DISPLAY_W` (1920), `DISPLAY_H` (1344), `FALLBACK_DISPLAY_W` (1280),
   `FALLBACK_DISPLAY_H` (896), `PLAYER_RENDER_W` (96), `PLAYER_RENDER_H` (144), `SHEET_MAX_PX`
   (2048), `UI_SMALL` (16), `UI_LARGE` (32), and `FONT_CELL` (16).
5. THE Game SHALL reference every presentation-layer size or scale factor by its named config
   constant from criterion 4 and SHALL NOT embed any such size or scale factor as a bare numeric
   literal in the systems that read it.

---

## System R — Out of Scope

### Requirement 49: Explicit Exclusions

**User Story:** As a stakeholder, I want the non-goals stated plainly, so that scope stays controlled
and legal risk is avoided.

#### Acceptance Criteria

1. THE Game SHALL NOT reproduce the original *A Link to the Past*'s fixed overworld, fixed story, or
   fixed item-gate progression; it is a procedural roguelike built around Attunement instead.
2. THE Game SHALL NOT distribute any Nintendo assets; all art and audio SHALL be original
   placeholders.
3. THE Game SHALL NOT include the previously framed Black Room hub, figure-eight overworld, or
   discovery-expands-the-generator meta model; those are replaced by Vigil, the dungeon-centric Run
   model, and Attunement.

---

## System T — Title / Start Screen

### Requirement 50: Title / Start Screen

**User Story:** As a player, I want a title screen when the game launches, so that I can start a new
run, continue a saved run, or exit from a clear menu.

> **Start-hub supersession (System AA, Requirement 73):** Where criteria 2 and 5 below say "begin a
> new Run from Vigil," the new Run now begins in the Dark_Room start hub (loadout + Level_Select) per
> Requirement 73. Persistent_State retention is unchanged; only the start hub differs.

#### Acceptance Criteria

1. WHEN the Game launches, THE Game SHALL present a Title Screen displaying the game title and a menu
   offering "Start New Run", "Continue Saved Run", and "Exit".
2. WHEN the Player selects "Start New Run", THE Game SHALL discard any existing Resumable_Save and
   begin a new Run from Vigil, while retaining all Persistent_State: the Attuned_Set, persisted
   maximum health, banked Sparks, Boss_Ladder position, and recruited Human_NPC roles.
3. WHERE a Resumable_Save exists, THE Title Screen SHALL present "Continue Saved Run" as selectable;
   WHERE no Resumable_Save exists, THE Title Screen SHALL hide or disable the "Continue Saved Run"
   option.
4. WHEN the Player selects "Continue Saved Run" AND a Resumable_Save exists, THE Game SHALL restore
   and resume that saved in-progress Run.
5. IF the Player selects "Continue Saved Run" AND the Resumable_Save is missing or corrupt, THEN THE
   Game SHALL present an error indication and THEN automatically begin a new Run from Vigil, while
   retaining all Persistent_State (the Attuned_Set, persisted maximum health, banked Sparks,
   Boss_Ladder position, and recruited Human_NPC roles) as in a new-run start per criterion 2.
6. WHEN the Player selects "Exit", THE Game SHALL quit the application.

---

## System G — Bosses (continued)

### Requirement 51: Souls-Style Boss Difficulty

**User Story:** As a player, I want Bosses that demand mastery and are learned through death, so that
each Boss is a genuine run-ender whose timing I earn the right to beat rather than brute-force.

#### Acceptance Criteria

1. WHEN a Boss begins an attack, THE Game SHALL resolve that attack's strike after a variable delay
   following its Telegraph, bounded by the Boss attack delay window minimum and maximum Tunables, so
   that a Telegraph does not resolve into a strike at a single fixed, predictable beat, while the
   Telegraph itself remains readable per Requirement 24.1.
2. WHERE a Boss attack is defined as a feint, WHEN the Boss plays that attack's Telegraph, THE Game
   SHALL either withhold the strike entirely or delay the strike on the first commit so the feint
   deals no damage on that first commit, with the feinting subset governed by the Boss feint
   probability per Rank Tunable, so that a Player_Character who dodges too early is punished.
3. WHEN a Boss attack strikes an overlapping Player_Character that is not in I_Frames, THE Game SHALL
   deal heavy damage scaled by the Boss damage-per-hit scaling with Rank and the Boss target
   hits-to-kill at full health per Rank Tunables, such that a small configurable number of unavoided
   strikes defeats a full-health Player_Character, without hardcoding an exact kill count.
4. WHEN the Player performs a dodge-dash during a Boss attack's actual strike, THE Game SHALL apply
   the dodge-dash I_Frames of Requirement 12.2 so the strike passes through without dealing damage;
   IF the dodge-dash I_Frames elapse before the delayed strike lands, THEN THE Game SHALL leave the
   Player_Character vulnerable to that strike, with the dodge i-frame duration remaining the Tunable
   defined in Requirement 48.
5. WHILE a Boss or the Player_Character is in the recovery of an attack or dodge, THE Game SHALL NOT
   allow that recovery to be cancelled into another action, so that spacing and patience are
   required and the Weak_Window of Requirement 24.4 remains the primary punish opportunity.
6. WHEN a Boss crosses a phase threshold defined in Requirement 24.3 and Requirement 26.5, THE Game
   SHALL introduce at least one new attack pattern or new delayed or feint variant for the later
   phase, governed by the Boss phase-new-move count per phase transition Tunable, rather than only
   raising HP or speed, and SHALL present a readable phase-transition moment; and WHILE the Boss
   remains in the later phase, THE Game SHALL keep that updated phase behavior in effect, so that the
   phase behavior stays consistent with the Boss's current phase throughout the phase and not only at
   the moment of the threshold crossing.
7. THE Game SHALL scale the delayed and feint intensity and the damage-per-hit of a Boss upward with
   that Boss's Rank along the Boss_Ladder.
8. WHEN the Player_Character's recorded Clears count is 0 AND the Boss is Gloamwing, THE Game SHALL
   use slow, honest, forgiving attack timing with no feints and reduced damage, so that a new Player
   learns the Telegraph then dodge-dash then Weak_Window punish loop before Souls-level timing
   applies at higher Ranks.
9. THE Game SHALL NOT automatically reduce any Boss's attack timing difficulty, feint frequency, or
   damage after repeated Player_Character deaths.
10. WHEN a Boss attack strikes a Player_Character and reduces health to 0, THE Game SHALL end the Run
    as a death per Requirement 44, discarding Run-Scoped_State and retaining Persistent_State, so a
    Boss death is a full run-ender.
11. THE Game SHALL ensure every Boss attack obeys telegraph-first fairness per Requirement 24.1 and
    SHALL NOT allow a Boss to deal first-contact damage from off-screen per Requirement 20.2, so that
    Souls-level difficulty remains tight-but-fair and never unreadable.

---

## System U — Drops, Chevrons & Economy

### Requirement 52: Enemy Death Drops

**User Story:** As a player, I want enemies to drop useful things when they die, so that combat
feeds my run with ammo, keys, weapons, health, and tokens.

#### Acceptance Criteria

1. WHEN an Enemy is defeated, THE Game SHALL have a chance to spawn one or more Death_Drops at the
   Enemy's position, with the drop chance and drop quality scaling by the Enemy's rarity, such that
   common Enemies yield fewer and lower-quality Death_Drops and rarer or elite Enemies and Bosses
   yield more and higher-quality Death_Drops.
2. THE Game SHALL draw each Death_Drop from a drop pool that includes consumable ammo-and-key types —
   bombs, arrows, bullets, keys, and Notes — and SHALL sometimes include weapons and sometimes
   include health pickups.
3. WHERE the Game includes an EXP/leveling system, THE Game SHALL also include EXP pickups in the
   Death_Drop pool. (No EXP/leveling system is otherwise specified in this document; such a system
   would require its own requirement, so the EXP Death_Drop is a conditional hook only.)
4. THE Game SHALL express the Death_Drop pool as a configurable, data-driven rarity-weighted drop
   table (a Tunable per Requirement 48) whose weights scale by Enemy rarity and by Room Depth,
   consistent with the Depth-based scaling of Requirement 28.
5. WHEN a Dungeon is generated and played from a given Seed with a given Attuned_Set, THE Game SHALL
   produce identical Death_Drop outcomes, consistent with the single seeded RNG of Requirement 31
   (same Seed produces the same drops).
6. WHEN a Death_Drop, a Chevron, or a Sparks pickup spawns or is collected, THE Game SHALL present
   the defined pickup visual effects — multi-colored clouds with purple and sparkles, and green
   leaves — as spawn and collect feedback. (These effects are cosmetic VFX tied to pickups; the
   detailed overlay/graphics treatment belongs to the design, but the feedback behavior is required
   here.)
7. WHEN the Player_Character overlaps a Death_Drop, THE Game SHALL collect that Death_Drop and add it
   to the appropriate pool: ammo to its ammo count, keys to the key count, health to current health,
   weapons to the Inventory per the existing item rules of Requirement 17, and — WHERE an EXP/leveling
   system applies — EXP to the EXP total.
8. WHEN a Run ends in death, THE Game SHALL treat collected run-scoped Death_Drops (consumables,
   ammo, bullets, keys, Notes) as Run-Scoped_State and discard them per Requirement 44, unless a
   given drop type is otherwise defined as Persistent_State.

### Requirement 53: Chevron Tokens

**User Story:** As a player, I want to collect colored chevron tokens I can trade and use to open
doors or change the environment, so that exploration and combat yield a flexible token economy
distinct from money.

#### Acceptance Criteria

1. THE Game SHALL spawn Chevrons as upward-pointing, chevron-shaped tokens that drop from defeated
   Enemies on a rarity-weighted basis, consistent with the Death_Drop rules of Requirement 52, and
   MAY also spawn Chevrons from the environment.
2. THE Game SHALL define exactly eight Chevron colors: gold, silver, black, blue, rainbow, brown,
   pink, and the ever-rare shiny light purple (seven standard colors plus one ultra-rare special
   color).
3. THE Game SHALL scale Chevron spawn rarity by color using data-driven per-color weights (Tunables
   per Requirement 48), with the shiny light purple Chevron as the ever-rarest color.
4. THE Player SHALL be able to spend Chevrons to trade with vendors or NPCs, to open certain doors,
   and to alter the environment (environmental interactions or puzzles); these are the Chevron's
   defined functions, kept distinct from Sparks money.
5. WHEN a Run ends by Clear or death, THE Game SHALL retain the Player's shiny light purple, rainbow,
   and black Chevrons as Persistent_State.
6. WHEN a Run ends by Clear or death, THE Game SHALL discard the Player's gold, silver, blue, brown,
   and pink Chevrons as Run-Scoped_State, consistent with the loss of unbanked Sparks and other
   run-scoped resources per Requirement 44.
7. WHEN the Player_Character overlaps a Chevron, THE Game SHALL add that Chevron to the Player's
   balance for its color and SHALL present the pickup VFX defined in Requirement 52.6.

### Requirement 54: Dual Economy — Sparks and Chevrons

**User Story:** As a player, I want money and tokens to be two separate systems, so that shopping and
trading stay distinct and each resource has a clear purpose.

#### Acceptance Criteria

1. THE Game SHALL treat Sparks as the primary spendable money, spent at Vigil's shops (Forge,
   Apothecary, The_Last_Call, The_Warm_Machine, and the Pawnbroker), banked on a Clear and lost if
   unbanked on death, per Requirement 36.
2. THE Game SHALL treat Chevrons as a token economy separate from Sparks, spendable to trade, to open
   certain doors, and to alter the environment, per Requirement 53, and SHALL NOT treat Chevrons as
   shop money.
3. THE Game SHALL retain the three ultra-rare Chevron colors (shiny light purple, rainbow, black) as
   Persistent_State and SHALL discard the five run-scoped Chevron colors (gold, silver, blue, brown,
   pink) as Run-Scoped_State, consistent with the death-handling of Requirement 44 and the save
   handling of Requirement 45.
4. THE Game SHALL account for Sparks balances and per-color Chevron balances as independent totals,
   such that spending or losing one SHALL NOT change the other.

---

## System V — Route Progression & Biome Content

### Requirement 55: Route-Length Progression

**User Story:** As a player, I want to unlock progressively longer Biome Routes by clearing them, so
that the world grows in scope as I prove myself.

#### Acceptance Criteria

1. THE Game SHALL model each Run as traversing a Route: an ordered sequence of Biomes in sequence
   that leads to exactly one end Dungeon, where the Route_Length is the number of Biomes in that
   Route.
2. THE Game SHALL place exactly one end Dungeon at the end of a Route, containing exactly one Boss
   selected from the Boss_Ladder per Requirement 26, so a Route of N Biomes is N Biomes in sequence
   leading to one end Dungeon rather than one Dungeon per Biome.
3. WHEN the Player starts the Game for the first time, THE Game SHALL make only a Route_Length of 1
   available, so the first available Route is a single Biome leading to the first Dungeon.
4. WHEN the Player clears the currently highest unlocked Route_Length, THE Game SHALL unlock the next
   Route_Length by one (a cleared Route_Length of N unlocks Route_Length N+1), up to the maximum
   unlockable Route_Length Tunable.
5. THE Game SHALL retain the highest unlocked Route_Length as Persistent_State that survives
   Player_Character defeat and persists across Runs, saved alongside the other meta-progression state
   of Requirement 44.3.
6. WHILE the Player is at The_Board, THE Game SHALL allow the Player to choose any unlocked
   Route_Length for the next Run, so that once a longer Route_Length is unlocked the Player MAY still
   choose a shorter unlocked Route_Length.
7. THE Game SHALL treat the Route_Length choice at The_Board as a selection distinct from, and
   composed with, the Dungeon and Rank selection of Requirement 37, so that choosing a Route_Length
   and choosing the next Dungeon are separate parts of the same Board decision for the next Run.
8. THE Game SHALL express the maximum unlockable Route_Length as a configurable Tunable (see
   Requirement 48) whose first-iteration value is 7, and SHALL architect the Route system to support
   Route_Lengths beyond 7 up to the number of Biomes in the Biome_Library, so the value 7 is the
   first-iteration target rather than a fixed architectural limit.
9. WHEN the Player chooses a Route_Length of N for a Run, THE Generator SHALL build a Route that
   traverses N Biomes in sequence, so the chosen Route_Length determines the Biome count and thereby
   the Run length, consistent with the Run-length scaling of Requirement 29.

### Requirement 56: Per-Biome Required Content

**User Story:** As a player, I want each Biome to have its own NPCs, secrets, exclusive items, and a
puzzle, so that every Biome is worth exploring and some progression is reachable only through
specific Biomes.

#### Acceptance Criteria

1. THE Game SHALL define each Biome with Biome_Content comprising multiple NPCs, multiple secrets,
   one or more biome-only Items (Items, keys, or power-ups obtainable only within that Biome), and at
   least one Biome_Puzzle.
2. THE Game SHALL treat biome-only Items as obtainable only within their defining Biome, reinforcing
   the biome-weighted item sourcing of Requirement 17 and the item taxonomy of Requirement 13.
3. IF a biome-only Item is required to complete a Route, THEN THE Generator SHALL constrain
   generation upfront so a valid placement for that Item always exists, and SHALL reject and
   regenerate any layout in which no valid placement for that required biome-only Item exists, so the
   Route remains completable under the Reachability rule of Requirement 30 and a required biome-only
   Item never produces an unsolvable Route, consistent with the re-roll rule of Requirement 30.5.
4. THE Game SHALL retain the full Biome_Library even when only a subset of its Biomes has been
   authored with complete Biome_Content, so that unauthored Biomes exist as defined structure while
   authored Biomes carry their NPCs, secrets, biome-only Items, puzzle, and resources.
5. THE Game SHALL gain Biome_Content for additional Biomes incrementally, so that a Biome can be
   added to the authored set over the course of development without the Biome_Library being reduced.
6. THE Game SHALL read each Biome's Biome_Content (NPC count, secret count, biome-only item set, and
   Biome_Puzzle) from data, so that a Biome can be fully authored by adding its data and resources
   without changing the central generation algorithm, consistent with the data-driven approach of
   Requirement 19 and Requirement 13.
7. WHERE the build is the first iteration (the tutorial / proof-of-concept build), THE Game SHALL
   fully build and test exactly one authored Biome plus one short first Dungeon as a playable
   end-to-end Route_Length of 1, SHALL constrain that first Dungeon's Room count to at or below the
   tutorial / short first-Dungeon maximum Room count Tunable (see Requirement 48), and SHALL keep the
   remaining Biomes of the Biome_Library present as defined structure to be authored later.
8. WHERE the build is the first iteration (the tutorial / proof-of-concept build), THE Game SHALL
   make that build a complete playable vertical slice of the core loop that exercises, end-to-end,
   departing Vigil, traversing the single-Biome Route_Length of 1, descending the short first
   Dungeon, defeating the tutorial
   Boss Gloamwing under the gentle first-Clear timing of Requirement 51.8, collecting Death_Drops
   and pickups per Requirement 52, Clearing the Dungeon with Attunement per Requirement 14, and
   returning to Vigil per the Run-boundary model of Requirement 32.
9. THE Biome_Library SHALL include the catalogued base Biomes Graveyard, Noir City (a 16-bit noir
   city with a distinct high-contrast noir palette and art treatment, authored through the
   data-driven art and palette approach of Requirement 19), and Temple as defined Biome_Library
   entries, and SHALL produce their ruined and corrupted versions (Ruined Graveyard, Corrupted Noir
   City, and Ruined Temple / Corrupted Temple) as the ruined/corrupted Biome_Variant of
   Requirement 58 applied to those base Biomes rather than as separate Biome_Library entries. These
   three base Biomes SHALL be catalogued now as defined structure per criteria 4 and 5, with their
   Biome_Content (NPCs, secrets, biome-only Items, and Biome_Puzzle) and any route-order or unlock
   placement authored later per Requirement 55 and Requirement 60, and SHALL NOT change the
   first-iteration scope of criteria 7 and 8 (still the single tutorial Biome).
10. THE Biome_Library SHALL include a GRASSLANDS base Biome as a data-driven Biome_Library entry
    authored like the other catalogued base Biomes of criterion 9, and THE Game SHALL use GRASSLANDS
    as the single authored Biome of the first iteration / tutorial proof-of-concept per criterion 7 —
    the one Route_Length-of-1 Biome leading to the short first Dungeon and the tutorial Boss Gloamwing
    (Requirement 26.2 and Requirement 51.8). WHERE the build is the first iteration, THE Game SHALL
    build the GRASSLANDS instance as a plain Biome carrying no Biome_Variant, consistent with
    Requirement 58.10, and SHALL author its Biome_Content (NPCs, secrets, biome-only Items, and
    Biome_Puzzle) per criterion 1 for the proof-of-concept.
11. THE Game SHALL define the first-iteration GRASSLANDS tutorial Enemy roster as exactly three
    Enemies that each cover a distinct Archetype to teach the core loop: a PATROL fodder Enemy (a
    field critter that walks a fixed path), a CHASE Enemy (a hound that pursues the Player_Character
    within aggro range), and a CHARGER Enemy (a horned boar that winds up with a readable Telegraph
    and then dashes). THE CHARGER Enemy SHALL present a readable Telegraph before its dash, consistent
    with the telegraph-first fairness of Requirement 20. THE Game SHALL hold each roster Enemy's name
    and stats as data in the Bestiary, consistent with the data-driven Bestiary of Requirement 19,
    while this criterion fixes the roster composition (one PATROL, one CHASE, one CHARGER) as the
    authored first-iteration GRASSLANDS roster.

### Requirement 57: Biome Puzzle Placement and Solvability

**User Story:** As a player, I want each Biome's puzzle to sit within that Biome and always be
solvable with what I can already reach, so that puzzles add exploration without ever soft-locking a
Route.

#### Acceptance Criteria

1. THE Generator SHALL place each Biome's Biome_Puzzle within that Biome's region of the Route.
2. WHERE a Biome_Puzzle requires an ability or item to solve, THE Generator SHALL require only an
   ability or item that is obtainable before that Biome_Puzzle within the same Run, so the
   Biome_Puzzle is solvable when the Player_Character reaches it.
3. THE Generator SHALL NOT place a Biome_Puzzle whose required ability or item is reachable only
   after the Biome_Puzzle, consistent with the gated-generation and Reachability rules of
   Requirement 30, so a Biome_Puzzle never soft-locks a Route.

### Requirement 58: Biome Variants

**User Story:** As a player, I want biomes to appear in discovered variant forms that reshape their
difficulty, loot, puzzle, NPCs, and story, so that revisiting a Biome stays fresh and discovering a
new variant feels like meta-progression.

#### Acceptance Criteria

1. THE Game SHALL define Biome_Variants as a data-driven, open set of modifiers (for example
   Corrupted/Infected, Negative, and Rainbow, as examples among a larger set), so that additional
   Biome_Variants can be added as data without changing the central generation algorithm, consistent
   with the data-driven Biome approach of Requirement 19, the item taxonomy of Requirement 13, and
   the Biome_Content of Requirement 56.
2. THE Game SHALL treat each Biome_Variant as a modifier layered on top of a base Biome, so that a
   Biome instance's underlying Biome identity and place remain while the variant reshapes that
   instance.
3. THE Game SHALL make every Biome instance either plain, carrying no Biome_Variant, or carrying
   exactly one Biome_Variant, and SHALL NOT apply more than one Biome_Variant to a single Biome
   instance, so that Biome_Variants do not stack.
4. WHERE a Biome instance carries a Biome_Variant, THE Game SHALL apply that variant's changes to
   that instance's difficulty, possible pickups (Death_Drops, Items, and biome-only Items), the
   Biome_Puzzle, the NPCs, and the story/flavor, overriding or augmenting the Biome_Content of
   Requirement 56 for that instance while the base Biome's identity and place remain unchanged.
5. WHEN the Generator builds a Biome instance for a Route, THE Generator SHALL decide deterministically
   from the Seed whether that instance is plain or carries a Biome_Variant, and which Biome_Variant,
   folding the variant choice into the deterministic generation inputs so that the same Seed with the
   same inputs produces the same variant assignment, consistent with the single-seeded determinism of
   Requirement 31 and the gated-generation inputs of Requirement 30.
6. WHEN the Generator selects a Biome_Variant for a Biome instance, THE Generator SHALL weight the
   choice by the per-Biome_Variant rarity/selection weights and the plain-vs-variant weighting, both
   defined as Tunables in Requirement 48.
7. THE Game SHALL retain the set of unlocked Biome_Variants as Persistent_State that survives
   Player_Character defeat and persists across Runs, saved alongside the other meta-progression state
   of Requirement 44.3 and consistent with the Route_Length unlock model of Requirement 55.
8. THE Generator SHALL draw a Biome instance's Biome_Variant only from the set of unlocked
   Biome_Variants, so that a Biome_Variant that has not been discovered does not appear in a Route.
9. WHILE no Biome_Variant has been unlocked, THE Generator SHALL build every Biome instance as a
   plain Biome, so that early Runs see plain Biomes only until Biome_Variants are discovered.
10. WHERE the build is the first iteration (the tutorial / proof-of-concept build), THE Game SHALL
    use the plain, no-variant Biome and SHALL NOT require any Biome_Variant, consistent with the
    first-iteration scope of Requirement 56.7 and Requirement 56.8.
11. WHEN a Biome instance carries a Biome_Variant, THE Generator SHALL ensure that the variant's
    changes to pickups, the Biome_Puzzle, and difficulty still satisfy the Reachability rule of
    Requirement 30 and the Biome_Puzzle solvability rule of Requirement 57, so that a Biome_Variant
    never produces an uncompletable Route.
---

## System W — Tile-Based Generation & Generated Unlock Rules

### Requirement 59: Tile-Based "Decide-Then-Assemble" Generation

**User Story:** As a player, I want generated places built from premade tiles so worlds look
hand-crafted yet endlessly varied, so that every run feels like a real, different place.

#### Acceptance Criteria

1. WHEN the Generator builds a location, THE Generator SHALL first decide which Semantic_Object it
   wants at that location (for example a house, a bridge, a shrine, a river, a landmark, or a
   settlement) and then assemble that Semantic_Object from the pieces scoped to that object type, so
   generation proceeds in two levels — decide, then assemble.
2. WHEN the Generator assembles a Semantic_Object, THE Generator SHALL draw the object's pieces from
   the Tile_Library tagged/scoped for that Semantic_Object type, so that when the Generator wants a
   house it draws from the house Tile_Library.
3. THE Game SHALL define each Semantic_Object type's Tile_Library and its tiles/pieces as
   data/assets, so that new Semantic_Object types and new tiles are added as data without changing
   the central generation algorithm, consistent with the data-driven approach of Requirement 19,
   Requirement 13, and Requirement 56.
4. THE Game SHALL provide, for each part/slot of a Semantic_Object type (for example a house's wall,
   roof, door, and window slots), many interchangeable tile options within that object's
   Tile_Library, so that the same Semantic_Object type looks different each time and variation scales
   with Tile_Library size.
5. WHEN the Generator assembles a Semantic_Object, THE Generator SHALL vary that object's structure —
   its size, shape, and layout — using the object's seeded Assembly_Rules, so that the same
   Semantic_Object type is generated at different sizes, shapes, and layouts across locations.
6. WHERE a Semantic_Object is a complex structure, THE Generator SHALL build it from Prefab_Chunks,
   from per-slot tile assembly drawn from its Tile_Library, or from both combined in a hybrid, and
   SHALL place and stitch each Prefab_Chunk to its neighbors.
7. THE Generator SHALL build terrain, paths, and filler from per-tile assembly with autotiling,
   distinct from the Prefab_Chunk assembly used for complex Semantic_Objects.
8. THE Generator SHALL draw every tile/piece selection and every Assembly_Rule choice from the single
   seeded RNG in the fixed generation draw order, so that the same Seed reproduces the same assembled
   Semantic_Objects, consistent with the single-seeded determinism of Requirement 31.
9. WHEN the Generator places an assembled Semantic_Object, THE Generator SHALL ensure the object and
   its placement still satisfy the Reachability rule of Requirement 30 and the Biome_Puzzle
   solvability rule of Requirement 57, so that a generated Semantic_Object (for example a house or a
   bridge) never blocks a required path or makes a Route uncompletable.
10. IF an assembled Semantic_Object or its placement would violate the Reachability rule of
    Requirement 30, THEN THE Generator SHALL re-roll or re-place that Semantic_Object from the Seed
    and SHALL NOT hand an uncompletable Route to the Player, consistent with the re-roll rule of
    Requirement 30.5.

### Requirement 60: Procedurally Generated Unlock Rules

**User Story:** As a player, I want the conditions for unlocking new biomes, puzzles, NPCs, and
enemies to themselves be generated, so that discovery stays fresh and unpredictable across
playthroughs.

#### Acceptance Criteria

1. THE Generator SHALL procedurally generate the Unlock_Rules — the conditions — for unlocking
   additional Biomes, Biome_Puzzles, Human_NPCs, and Enemies, generating the unlock conditions
   themselves rather than only the unlocked content.
2. THE Generator SHALL produce the same Unlock_Rule for the same Seed and the same inputs
   unconditionally, so that generated unlock conditions are deterministic, reproducible, and
   shareable for any given Seed and inputs regardless of whether Unlock_Rule generation has yet
   occurred for that Seed and those inputs, consistent with the single-seeded determinism of
   Requirement 31.
3. WHEN the Generator composes an Unlock_Rule, THE Generator SHALL draw its condition types from an
   open, data-driven condition-type set — for example defeat a specific Boss (Boss_Ladder,
   Requirement 26), solve a specific Biome_Puzzle (Requirement 57), find a specific biome-only Item
   in a specific Biome (Requirement 56), collect N Chevrons (Requirement 53) or N Sparks
   (Requirement 36), clear a Route of a given Route_Length (Requirement 55), discover a specific
   secret, or recruit a specific Human_NPC (Requirement 56 and Requirement 39) — so that new
   condition types are added as data without changing the Generator.
4. WHEN the Generator generates an Unlock_Rule, THE Generator SHALL require only content that is
   reachable and obtainable, and SHALL NOT generate an Unlock_Rule whose condition can be met only by
   first possessing the content that Unlock_Rule unlocks, so that an Unlock_Rule never creates a
   soft-lock or a circular dependency, consistent with the Reachability rule of Requirement 30 and
   the Biome_Puzzle solvability rule of Requirement 57.
5. WHEN the Generator generates an Unlock_Rule, THE Generator SHALL validate that Unlock_Rule for
   satisfiability and acyclicity, and IF a generated Unlock_Rule would be unsatisfiable or circular,
   THEN THE Generator SHALL regenerate or repair that Unlock_Rule from the Seed within the unlock-rule
   generation/validation retry limit Tunable, mirroring the generation-validity re-roll approach of
   Requirement 30.5.
6. WHEN an Unlock_Rule's condition is met, THE Game SHALL unlock the corresponding content and retain
   that unlocked result as Persistent_State that survives Player_Character defeat and persists across
   Runs, consistent with the persistent-unlock model of Requirement 55, Requirement 58, and the
   meta-progression state of Requirement 44.3, so that generated Unlock_Rules recur for the same Seed
   while the unlocked result persists across Runs.
7. WHERE the build is the first iteration (the tutorial / proof-of-concept build), THE Game SHALL
   keep generated Unlock_Rules minimal and simple, consistent with the single plain Biome and short
   first Dungeon of Requirement 56.7 and Requirement 56.8 and the plain, no-variant Biome of
   Requirement 58.10, so that generated unlock complexity does not burden the tutorial.

---

## System X — Tier Scaling & Cursed Items

### Requirement 61: Level-Anchored Tier Scaling

**User Story:** As a player, I want the power of what I find and fight to scale with the level I'm
in, with occasional rare high and low rolls, so that each area feels appropriately challenging and
rewarding with exciting outliers.

#### Acceptance Criteria

1. THE Generator SHALL assign each generated level or area (a level, a Dungeon region, or a Biome
   instance) a Base_Level, an integer that anchors that area's expected Tier.
2. WHEN the Generator rolls a Tier for seeded random content within an area, THE Generator SHALL draw
   that Tier from the window [Base_Level − 5, Base_Level + 5] relative to the area's Base_Level — up
   to 5 above and up to 5 below the Base_Level.
3. WHEN the Generator rolls a Tier within an area, THE Generator SHALL weight the probability of each
   candidate Tier so that the probability decreases as the Tier's distance from the Base_Level
   increases, such that tiers at or near the Base_Level are the most common and the extremes
   (Base_Level − 5 and Base_Level + 5) are the rarest.
4. THE Game SHALL express the per-distance Tier rarity weighting as a data-driven ladder/rarity curve
   Tunable (see Requirement 48), so that the common-near-base and rare-far-from-base distribution is
   configured in data rather than hardcoded.
5. THE Game SHALL provide level-anchored Tier scaling as a reusable mechanic that the item drop
   system (Death_Drops, Requirement 52), Pedestal and Boss loot (Requirement 17), and other seeded
   random generators (for example enemies and pickups) MAY use to roll a Tier anchored to the area's
   Base_Level.
6. WHEN two areas are generated with the same Seed and the same Attuned_Set, THE Generator SHALL draw
   Tier rolls from the single seeded RNG in the fixed generation order, so that the same Seed
   reproduces the same Tiers, consistent with the single seeded RNG of Requirement 31; the Tier
   window and the rarity curve SHALL be folded into that deterministic generation.

> **Example (illustrative, not hardcoded):** A Base_Level 0 area rolls Tiers from −5 to +5, with +5
> and −5 the rarest; a Base_Level 3 area rolls Tiers from −2 to +8 by the same relative window and
> rarity curve.

### Requirement 62: Cursed Items

**User Story:** As a player, I want rare cursed items that are powerful or strange but carry a
penalty, with a costly way to cleanse them, so that negative-tier finds are a meaningful risk and
reward.

#### Acceptance Criteria

1. WHEN a generated Item's resulting absolute Tier is negative (below 0), regardless of the area's
   Base_Level, THE Game SHALL treat that Item as a Cursed_Item.
2. WHILE an area's Base_Level is low enough that the window [Base_Level − 5, Base_Level + 5] includes
   Tiers below 0, THE Generator SHALL allow that window to produce negative resulting Tiers, forming
   the cursed band for that area, consistent with the Tier window of Requirement 61; and THE
   Generator SHALL keep negative, cursed Tiers rare unconditionally, independent of whether an area's
   level window includes Tiers below 0.
3. THE Game SHALL make negative, cursed Tiers rare and special, consistent with the rarity-by-
   distance curve of Requirement 61 and the reserved "negative is special" treatment of Boss Rank in
   Requirement 26.
4. WHILE a Cursed_Item is held or equipped by the Player_Character, THE Game SHALL apply that
   Cursed_Item's defined negative effect to the Player_Character, where the specific penalty is
   data-driven per item.
5. THE Game SHALL provide a way to uncurse (cleanse) a Cursed_Item that imposes a significant cost
   on the Player_Character (a great tradeoff).
6. THE Game SHALL treat the exact uncurse mechanism — the specific cost and the location or method at
   which uncursing is performed — as a deferred decision (TBD / `[verify]`) to be defined in a later
   requirement or design pass, and SHALL NOT fix that specific cost or location in this requirement
   (see Requirement 48).
7. WHEN the Generator rolls a Tier for an Item from a given Seed, THE Game SHALL determine whether
   that Item is a Cursed_Item deterministically from the resulting Tier, consistent with the item
   taxonomy of Requirement 13 and the single seeded RNG of Requirement 31, so that the same Seed
   reproduces the same cursed outcomes.

---

## System Y — Inventory Screen & Equipment

### Requirement 63: Inventory Screen and Worn-Gear Equipment Slots

**User Story:** As a player, I want an inventory screen that shows my worn gear, consumables,
potions, ammo, and active item, and lets me equip helmet, body, shoes, and an armor style, so that I
can read what everything does and build a defensive loadout alongside my single active item.

#### Acceptance Criteria

1. WHEN the Player opens the Inventory/Pause input per Requirement 1 and Requirement 2, THE Game
   SHALL present the Inventory_Screen and SHALL pause the world while the Inventory_Screen is open,
   consistent with the pausing-menus behavior of Requirement 47.
2. THE Game SHALL provide the Player_Character with three Worn_Gear Gear_Slots — a Helmet slot, a
   Body/Clothes slot, and a Shoes/Footwear slot — each holding at most one gear Item.
3. THE Game SHALL provide an Armor_Type selection of exactly one of Tactical or Armor that sets the
   Player_Character's body/defense style, where Tactical emphasizes mobility/utility modifiers and
   Armor emphasizes defense (damage reduction), with the specific modifier/defense emphasis held as
   data-driven Tunables and per-item data (see Requirement 48).
4. THE Game SHALL keep the Worn_Gear Gear_Slots and Armor_Type separate from the single active
   Equipped_Item bound to the Item (Y) button of Requirement 2, such that equipping, unequipping, or
   changing Worn_Gear SHALL NOT change the Equipped_Item and SHALL NOT violate the one-active-item
   rule of Requirement 2.
5. WHILE a Worn_Gear Item or the chosen Armor_Type is equipped, THE Game SHALL apply that gear's
   defense (damage reduction) and/or stat modifiers to the Player_Character, where the specific
   values are data-driven per item and per Armor_Type.
6. THE Game SHALL assign each Worn_Gear Item a Tier anchored to the area's Base_Level per
   Requirement 61, such that a higher or lower Tier scales that gear Item's modifiers along the
   data-driven Tier ladder.
7. WHEN a Worn_Gear Item's resulting absolute Tier is negative, THE Game SHALL treat that gear Item
   as a Cursed_Item per Requirement 62, applying its data-driven penalty while equipped and allowing
   it to be uncursed at the great tradeoff whose exact cost and location are a deferred decision
   (TBD / `[verify]`) per Requirement 62.
8. WHEN the Player_Character takes damage, THE Game SHALL have the equipped Worn_Gear's defense
   contribute to the Player_Character's damage reduction, composing with the mail/tunic reduction of
   Requirement 10, where the specific stacking/composition rule is data-driven (see Requirement 48).
9. THE Game SHALL treat Worn_Gear as Run-Scoped_State that is PASSIVE_Item-like per the item taxonomy
   of Requirement 13, such that Worn_Gear does not Attune and is discarded when the Run ends per
   Requirement 44, consistent with the mail/shield PASSIVE_Item handling of Requirement 10 and
   Requirement 13 and without changing the maximum-health persistence exception of Requirement 42.
10. THE Inventory_Screen SHALL display the three Worn_Gear Gear_Slots (Helmet, Body/Clothes, Shoes)
    and the current Armor_Type (Tactical or Armor), each showing the equipped Item and that Item's
    Tier and modifiers.
11. THE Inventory_Screen SHALL display the Player_Character's CONSUMABLE_Items and potions, each with
    its modifier and/or healing values, so that the Player can read what each consumable or potion
    does.
12. THE Inventory_Screen SHALL display the AMMO counts for arrows, bombs, and bullets, where bullets
    are the ammo type defined in Requirement 52.
13. THE Inventory_Screen SHALL display the current active Equipped_Item (the Y-button item of
    Requirement 2).
14. WHEN the Player selects a Worn_Gear Item for a Gear_Slot whose slot type matches that Item's gear
    type in the Inventory_Screen, THE Game SHALL equip that Item into the matching Gear_Slot,
    unequip any Item previously in that Gear_Slot, and apply the newly equipped Item's modifiers.
15. IF the Player selects a Worn_Gear Item for a Gear_Slot whose slot type does not match that Item's
    gear type, THEN THE Game SHALL reject the equip, SHALL NOT equip that Item into that Gear_Slot,
    and SHALL present visible feedback to the Player indicating the mismatched equip was rejected,
    rather than silently ignoring the selection.

---

## System Z — Graphics & Presentation Layer (REQ-GFX / REQ-RES / REQ-CAM / REQ-ROOM / REQ-SPR / REQ-TILE / REQ-ART-REF / REQ-ART-PIPE / REQ-UI)

This system is an additional, ID-stamped presentation-layer specification. Its requirements carry
stable `REQ-` identifiers in their own scheme (`REQ-GFX-`, `REQ-RES-`, `REQ-CAM-`, `REQ-ROOM-`,
`REQ-SPR-`, `REQ-TILE-`, `REQ-ART-REF-`, `REQ-ART-PIPE-`, `REQ-UI-`) in addition to the document's
sequential `Requirement N` integer headings (continuing from 64). The acceptance-criteria IDs within
each requirement are prefixed with that requirement's `REQ-` ID so the presentation layer can be
traced by its own scheme while the document still validates under the integer-heading format.

Every size and scale factor in this system is stated as a **named config constant**, never a bare
literal; each constant's LOCKED literal value is noted next to its name for reference and is listed
in full in the "System Z Config Constants (LOCKED)" subsection below. These values are LOCKED and
authoritative. Where they differ from earlier requirements (notably the Room model of
Requirement 27), the values here supersede, as called out in the relevant requirement.

### System Z Config Constants (LOCKED)

The following named config constants are LOCKED exact values (not `[approx]`). All System Z
requirements reference these constants by name; no System Z requirement embeds any of these as a
bare literal. These are also recorded as `exact`-flagged Tunables in Requirement 48 (criteria 4–5).

- **TILE_PX** = 32 — tile size in pixels.
- **PLAYER_W** = 32 — player sprite cell width in pixels.
- **PLAYER_H** = 48 — player sprite cell height in pixels.
- **VIEW_W** = 640 — view width in pixels.
- **VIEW_H** = 448 — view height in pixels.
- **VIEW_TILES_W** = 20 — view width in tiles (VIEW_W / TILE_PX).
- **VIEW_TILES_H** = 14 — view height in tiles (VIEW_H / TILE_PX).
- **ROOM_MAX_TILES_W** = 80 — maximum room width in tiles.
- **ROOM_MAX_TILES_H** = 56 — maximum room height in tiles.
- **ROOM_MAX_W** = 2560 — maximum room width in pixels (ROOM_MAX_TILES_W × TILE_PX).
- **ROOM_MAX_H** = 1792 — maximum room height in pixels (ROOM_MAX_TILES_H × TILE_PX).
- **SCALE_PRIMARY** = 3 — primary integer scale factor.
- **SCALE_FALLBACK** = 2 — fallback integer scale factor.
- **DISPLAY_W** = 1920 — primary display target width (VIEW_W × SCALE_PRIMARY).
- **DISPLAY_H** = 1344 — primary display target height (VIEW_H × SCALE_PRIMARY).
- **FALLBACK_DISPLAY_W** = 1280 — fallback display target width (VIEW_W × SCALE_FALLBACK).
- **FALLBACK_DISPLAY_H** = 896 — fallback display target height (VIEW_H × SCALE_FALLBACK).
- **PLAYER_RENDER_W** = 96 — player rendered width at SCALE_PRIMARY (PLAYER_W × SCALE_PRIMARY).
- **PLAYER_RENDER_H** = 144 — player rendered height at SCALE_PRIMARY (PLAYER_H × SCALE_PRIMARY).
- **SHEET_MAX_PX** = 2048 — maximum sprite-sheet dimension in pixels.
- **UI_SMALL** = 16 — small UI icon size in pixels (UI_SMALL × UI_SMALL).
- **UI_LARGE** = 32 — large UI icon size in pixels (UI_LARGE × UI_LARGE).
- **FONT_CELL** = 16 — pixel-font cell size in pixels (FONT_CELL × FONT_CELL grid).

### Requirement 64: Pixel-Grid Honesty (REQ-GFX-001)

**User Story:** As a player, I want LTTP-honest pixel art, so that the game reads with clean, crisp,
strong-silhouette sprites and never looks blurred or warped.

#### Acceptance Criteria

1. REQ-GFX-001-1: THE Game SHALL sample all textures with nearest-neighbour filtering
   (`default_texture_filter` = Nearest / value 0), so that no bilinear smoothing is applied.
2. REQ-GFX-001-2: THE Game SHALL scale rendered output by integer scale factors only and SHALL NOT
   apply any fractional scale factor.
3. REQ-GFX-001-3: THE Game SHALL render sprites without runtime rotation and without runtime
   scaling, and SHALL represent any apparent rotation or scaling with authored animation frames
   instead.
4. REQ-GFX-001-4: THE Game SHALL author sprites to present strong, readable silhouettes at
   TILE_PX resolution.
5. REQ-GFX-001-5: THE Game SHALL keep the pixel grid honest at all times — nearest-neighbour
   sampling, integer scaling, and no runtime rotation or scaling.
6. REQ-GFX-001-6 (v1 effects scope): THE Game SHALL include, as in-scope v1 effects, dynamic 2D
   lighting via a global `CanvasModulate` and `PointLight2D` lights, and particles via
   `CPUParticles2D`.
7. REQ-GFX-001-7 (deferred effects): THE Game SHALL defer and SHALL NOT build in v1 the following
   effects: normal maps, HD-2D, and 3D planes.

### Requirement 65: Resolution and Integer Scaling (REQ-RES-001)

**User Story:** As a player, I want a fixed low-resolution view scaled by whole numbers, so that the
image fills my screen crisply with no blur.

#### Acceptance Criteria

1. REQ-RES-001-1: THE Game SHALL render the view at exactly VIEW_W × VIEW_H pixels (640 × 448),
   equal to VIEW_TILES_W × VIEW_TILES_H tiles (20 × 14) at TILE_PX (32).
2. REQ-RES-001-2: THE Game SHALL configure Godot stretch mode = `canvas_items`, aspect = `keep`,
   scale mode = `integer`, and `default_texture_filter` = Nearest (0).
3. REQ-RES-001-3: THE Game SHALL target SCALE_PRIMARY (×3), rendering to DISPLAY_W × DISPLAY_H
   (1920 × 1344).
4. REQ-RES-001-4: IF the hardware cannot sustain SCALE_PRIMARY (×3), THEN THE Game SHALL fall back
   to SCALE_FALLBACK (×2), rendering to FALLBACK_DISPLAY_W × FALLBACK_DISPLAY_H (1280 × 896).
5. REQ-RES-001-5: THE Game SHALL NOT drop below integer scaling under any resolution condition.
6. REQ-RES-001-6: WHILE rendering at SCALE_PRIMARY (×3), THE Game SHALL render the Player_Character
   at exactly PLAYER_RENDER_W × PLAYER_RENDER_H (96 × 144), equal to PLAYER_W × SCALE_PRIMARY by
   PLAYER_H × SCALE_PRIMARY, and SHALL fill DISPLAY_W × DISPLAY_H (1920 × 1344) with no fractional
   blur.
7. REQ-RES-001-7: WHERE the display aspect ratio differs from the view aspect ratio, THE Game SHALL
   present letterbox or pillarbox bars only as needed to preserve integer scaling, and SHALL NOT
   stretch the view to remove the bars.
8. REQ-RES-001-8 (acceptance): THE Game SHALL present a view that is exactly VIEW_W × VIEW_H
   (640 × 448, = 20 × 14 tiles) and that at SCALE_PRIMARY (×3) lands clean — Player_Character at
   PLAYER_RENDER_W × PLAYER_RENDER_H (96 × 144) and the view filling DISPLAY_W × DISPLAY_H
   (1920 × 1344) — with no fractional blur.

### Requirement 66: Pixel-Snapped Scrolling Camera (REQ-CAM-001)

**User Story:** As a player, I want the camera to follow me smoothly within a room without ever
showing a half-pixel, so that scrolling looks as crisp as the sprites.

#### Acceptance Criteria

1. REQ-CAM-001-1: THE Game SHALL follow the Player_Character with a camera that uses a dead-zone, so
   that small Player_Character movements inside the dead-zone do not scroll the view.
2. REQ-CAM-001-2: THE Game SHALL clamp the camera to the bounds of the active room so that the
   camera never shows outside the room.
3. REQ-CAM-001-3: THE Game SHALL snap the camera position to the pixel grid (PixelSnap enabled) so
   that scroll never lands on a half-pixel.
4. REQ-CAM-001-4: THE Game SHALL NOT apply camera smoothing that breaks the pixel grid.
5. REQ-CAM-001-5: WHERE a room equals the view (VIEW_TILES_W × VIEW_TILES_H = 20 × 14), THE Game
   SHALL hold the camera static with no scroll.
6. REQ-CAM-001-6: WHERE a room is larger than the view, THE Game SHALL scroll the camera within the
   room bounds as the Player_Character moves.
7. REQ-CAM-001-7 (acceptance): WHEN the Player_Character traverses a room larger than the view, THE
   Game SHALL scroll the view smoothly with a pixel-snapped camera and SHALL never show a
   half-pixel.

### Requirement 67: Big Rooms on the Grid (REQ-ROOM-001)

**User Story:** As a player, I want rooms that can be bigger than one screen and scroll, so that the
dungeon has large, non-empty spaces instead of only single-screen boxes.

> **Supersession note:** This requirement SUPERSEDES the fixed-room-size assumption of
> Requirement 27 that a Room is exactly VIEW_TILES_W × VIEW_TILES_H (20 × 14 tiles / 640 × 448 px)
> and therefore equal to the view. Under System Z the VIEW is VIEW_TILES_W × VIEW_TILES_H
> (20 × 14, VIEW_W × VIEW_H = 640 × 448) but a ROOM MAY be larger — up to ROOM_MAX_TILES_W ×
> ROOM_MAX_TILES_H (80 × 56, ROOM_MAX_W × ROOM_MAX_H = 2560 × 1792 px) — and the camera scrolls within
> it (see Requirement 66): a baseline room equals the view and does not scroll, while a big room
> scrolls. Requirement 27 has been reconciled to this model (room ≠ view) in its own criteria 1 and 5 and
> its Room-model note; this requirement remains authoritative for Room sizing and camera scroll.

#### Acceptance Criteria

1. REQ-ROOM-001-1: THE Generator SHALL generate rooms aligned to the TILE_PX (32 px) grid.
2. REQ-ROOM-001-2: THE Generator SHALL size each room within the range from the view
   (VIEW_TILES_W × VIEW_TILES_H = 20 × 14) up to ROOM_MAX_TILES_W × ROOM_MAX_TILES_H (80 × 56),
   equal in pixels to the range VIEW_W × VIEW_H (640 × 448) up to ROOM_MAX_W × ROOM_MAX_H
   (2560 × 1792).
3. REQ-ROOM-001-3: THE Generator SHALL connect rooms with a Door_Graph (see Requirement 27) and
   SHALL ensure a run is completable, so that the Reachability check of Requirement 30 passes before
   play begins.
4. REQ-ROOM-001-4: WHERE a room is larger than the view, THE Generator SHALL scale enemy and decor
   density with room area so that larger rooms contain proportionally more enemies and decor and do
   not feel empty.
5. REQ-ROOM-001-5: WHERE a room equals the view (VIEW_TILES_W × VIEW_TILES_H = 20 × 14), THE Game
   SHALL present that room with no camera scroll, consistent with Requirement 66.
6. REQ-ROOM-001-6 (acceptance): THE Generator SHALL produce rooms whose dimensions fall within the
   range VIEW_TILES_W × VIEW_TILES_H (20 × 14) through ROOM_MAX_TILES_W × ROOM_MAX_TILES_H (80 × 56)
   on the TILE_PX grid, with a baseline room equal to the view and big rooms scrolling, and SHALL
   supersede the room-equals-view assumption of Requirement 27.

### Requirement 68: Sprite Sizes and Player Clip Set (REQ-SPR-001)

**User Story:** As a player, I want consistently sized sprites and a complete player animation set,
so that characters read clearly and the player moves with full LTTP-style coverage.

#### Acceptance Criteria

1. REQ-SPR-001-1: THE Game SHALL render the Player_Character cell at exactly PLAYER_W × PLAYER_H
   (16 × 24).
2. REQ-SPR-001-2: THE Game SHALL author each Enemy sprite at one of the ENEMY_TIERS sizes —
   16 × 16, 24 × 24, 32 × 32, or 48 × 48 pixels.
3. REQ-SPR-001-3: THE Game SHALL author each Boss sprite at one of the BOSS_TIERS sizes —
   64 × 64, 96 × 96, or 128 × 128 pixels or larger.
4. REQ-SPR-001-4: THE Game SHALL author UI icons at UI_SMALL × UI_SMALL (8 × 8) or UI_LARGE ×
   UI_LARGE (16 × 16) pixels.
5. REQ-SPR-001-5: THE Game SHALL render the pixel font on a FONT_CELL × FONT_CELL (8 × 8) grid.
6. REQ-SPR-001-6: THE Game SHALL provide the Player_Character clip set with LOCKED frame counts —
   idle (2), walk (6), attack (3), charge (2), spin (4), hurt (1), dash (4), lift/carry (2 + 2),
   swim (4), death (4), and push/pull (2) — authored in 4 directions each.
7. REQ-SPR-001-7: THE Game SHALL author the Player_Character outfit as a white shirt, brown shorts,
   and bare feet.
8. REQ-SPR-001-8 (acceptance): THE Game SHALL present a Player_Character cell that is exactly
   PLAYER_W × PLAYER_H (16 × 24), and SHALL present each staged asset at dimensions exactly equal to
   its declared tier (ENEMY_TIERS, BOSS_TIERS, or UI size).

### Requirement 69: Per-Biome Tilesets (REQ-TILE-001)

**User Story:** As a player, I want each biome to have its own tileset with autotiling, doors,
hazards, decorations, and lights, so that each biome looks distinct and assembles cleanly.

#### Acceptance Criteria

1. REQ-TILE-001-1: THE Game SHALL provide one TILE_PX × TILE_PX (32 × 16) tileset per biome for the
   seven core biomes of Requirement 21.
2. REQ-TILE-001-2: THE Game SHALL implement each biome tileset as a Godot `TileSet` with terrains
   configured for autotiling.
3. REQ-TILE-001-3: THE Game SHALL include in each biome tileset the pieces for doors, animated
   hazards, decorations, and lights.
4. REQ-TILE-001-4: THE Game SHALL define each tileset as data, consistent with the data-driven biome
   approach of Requirement 19 and Requirement 56.
5. REQ-TILE-001-5: WHERE the Biome_Library catalogues biomes beyond the core seven (for example
   Grasslands, Graveyard, Noir City, and Temple per Requirement 56.9 and Requirement 56.10), THE
   Game SHALL provide each such biome its own TILE_PX × TILE_PX (32 × 16) tileset as that biome is
   authored.

### Requirement 70: Reference Study — Originality and Non-Shipping (REQ-ART-REF-001)

**User Story:** As a developer, I want external reference used only for study and never shipped, so
that our art stays original and no ripped source material enters the game.

#### Acceptance Criteria

1. REQ-ART-REF-001-1: THE Game SHALL treat the 71 LTTP movement PNGs, `size_ref.png`, and
   `lttp_link_ref_x3.png` (from the Solarus LTTP project), located under
   `work/asset-packs/reference/lttp/movement/`, as STUDY-ONLY reference material.
2. REQ-ART-REF-001-2: THE Game SHALL treat the reference material as laid out on a 24 × 32 cell grid
   while the game grid is PLAYER_W × PLAYER_H (16 × 24), so that any use is a nearest-neighbour
   integer DOWNSAMPLE to PLAYER_W × PLAYER_H (16 × 24) followed by a HAND-CLEAN pass.
3. REQ-ART-REF-001-3: THE Game SHALL use the reference material for study of MOTION, PROPORTIONS,
   and FRAME COUNTS only, because the reference material is Nintendo-ripped.
4. REQ-ART-REF-001-4: THE Game SHALL NOT include any reference file in `res://` and SHALL NOT include
   any reference file in the export.
5. REQ-ART-REF-001-5: THE Game SHALL keep every reference file only under `work/` (outside `res://`),
   so that reference files are never shipped and never traced-and-shipped.
6. REQ-ART-REF-001-6: THE Game SHALL treat the reference material as locking animation coverage and
   frame counts only, and SHALL NOT derive new Player_Character abilities from the reference
   material.
7. REQ-ART-REF-001-7 (acceptance): THE Game SHALL contain no reference file inside `res://`, and the
   reference material SHALL be used only for motion, proportion, and frame-count study.

### Requirement 71: Art Pipeline and Originality (REQ-ART-PIPE-001)

**User Story:** As a developer, I want a defined asset pipeline that enforces originality and strips
brand metadata, so that every shipped asset is clean, original, and correctly sized.

#### Acceptance Criteria

1. REQ-ART-PIPE-001-1: THE Game SHALL accept asset packs at their native sizes — character cells at
   32 × 32 and tile atlases at 40 × 40.
2. REQ-ART-PIPE-001-2: THE Game SHALL process each asset through the pipeline: slice, then
   integer-resample to the game grid (PLAYER_W × PLAYER_H = 16 × 24 for characters, TILE_PX × TILE_PX
   = 16 × 16 for tiles), then hand-edit for originality, then scrub metadata.
3. REQ-ART-PIPE-001-3: THE Game SHALL ensure every prepared or staged asset carries no source or
   brand name in its filename and no source or brand name in its PNG metadata.
4. REQ-ART-PIPE-001-4: THE Game SHALL NOT resell pack files and SHALL NOT train AI on pack files.
5. REQ-ART-PIPE-001-5: WHERE an AI generator is used, THE Game SHALL use it for look, palette, and
   concept only, and SHALL lock the palette, pixelate to the exact grid, remove anti-aliasing, and
   hand-clean the result.
6. REQ-ART-PIPE-001-6: THE Game SHALL NOT ship AI-generator output raw at TILE_PX (32 px)
   resolution.
7. REQ-ART-PIPE-001-7: THE Game SHALL export PNG sprite sheets, optionally accompanied by JSON
   metadata.
8. REQ-ART-PIPE-001-8: THE Game SHALL import character assets as `AnimatedSprite2D` with
   `SpriteFrames`, and SHALL import tile assets as `TileSet` terrains.
9. REQ-ART-PIPE-001-9: THE Game SHALL keep each exported sprite sheet's maximum dimension at or below
   SHEET_MAX_PX (2048), so that sheets are at most 2048 px on their largest side.
10. REQ-ART-PIPE-001-10 (acceptance): THE Game SHALL ensure every staged asset has zero brand strings
    in its filename and metadata and has dimensions exactly equal to its declared tier.

### Requirement 72: UI / HUD Presentation on the Pixel Grid (REQ-UI-001)

**User Story:** As a player, I want the HUD and menus drawn crisply in screen space over the view, so
that UI stays readable and pixel-honest regardless of camera scroll.

#### Acceptance Criteria

1. REQ-UI-001-1: THE Game SHALL render UI icons at UI_SMALL × UI_SMALL (8 × 8) or UI_LARGE ×
   UI_LARGE (16 × 16) and UI text on the FONT_CELL × FONT_CELL (8 × 8) pixel-font grid.
2. REQ-UI-001-2: THE Game SHALL render the HUD and menus in screen space over the VIEW_W × VIEW_H
   (640 × 448) view at integer scale, so that UI rendering is unaffected by camera scroll.
3. REQ-UI-001-3: THE Game SHALL keep UI/HUD presentation consistent with the HUD and
   inventory-screen content requirements (Requirement 46, Requirement 47, and Requirement 63),
   specifying how the UI renders on the pixel grid rather than re-specifying HUD or menu contents.


---

## System AA — Dark Room Start Hub

> **Supersession note:** This system makes the **Dark_Room** the run-start hub and SUPERSEDES the
> run-start / level-select role of **Vigil** in Requirement 32 and the "begin a new Run from Vigil"
> wording of Requirement 50.2 and Requirement 50.5. Each new Run now starts in the Dark_Room (loadout
> + level select) rather than at Vigil's The_Board. The Run-boundary, return-on-end, and
> Persistent_State retention behavior of Requirements 32, 43, 44, and 50 is otherwise unchanged: a
> Run still ends by Clear or death and returns the Player_Character to the start hub, now the
> Dark_Room. Requirements 32 and 50 are not rewritten here; this system supersedes their start-hub
> and level-select role.

### Requirement 73: Dark Room Start Hub with Loadout and Level Select

**User Story:** As a player, I want to begin each run in a dark room with a TV screen where I pick my
starting weapon and the biome/level I drop into, so that every run starts with a deliberate choice of
loadout and destination.

#### Acceptance Criteria

1. WHEN a new Run begins, THE Game SHALL place the Player_Character in the Dark_Room as the run-start
   hub instead of Vigil, superseding the Vigil run-start role of Requirement 32.
2. THE Dark_Room SHALL contain a TV_Screen that the Player_Character interacts with (via the
   Context_Action of Requirement 11) to open the Level_Select for choosing the starting Biome/level
   of the Run.
3. THE Game SHALL offer at the Dark_Room a Starting_Loadout choice of exactly one of three options:
   the Sword (the bare sword ATTACK_Item of Requirement 13.3), the Pistol (a firearm ATTACK_Item per
   Requirement 75), or Nothing (no starting weapon), and SHALL apply the chosen option as the
   Player_Character's starting Equipped_Item for the Run (or no Equipped_Item when Nothing is chosen),
   consistent with the one-active-item rule of Requirement 2.
4. WHEN the Player chooses Nothing, THE Game SHALL start the Run with no Equipped_Item and SHALL leave
   the Player_Character able to acquire weapons during the Run per Requirement 14 and Requirement 17.
5. THE Level_Select SHALL offer only Biomes/levels that are currently unlocked per the Route-length
   and unlock progression of Requirement 55 and Requirement 60, and SHALL begin the Run at the chosen
   starting Biome/level when confirmed.
6. WHEN the Player confirms the Starting_Loadout and the Level_Select choice at the TV_Screen, THE
   Game SHALL begin the Run at the chosen Biome/level with the chosen loadout, consistent with the
   Run-begin behavior of Requirement 43.
7. THE Game SHALL make the Starting_Loadout and Level_Select choices available only at run start in
   the Dark_Room (one choice set per Run start), distinct from the in-dungeon Choice_Rooms of
   Requirement 74.
8. WHEN a Run ends by Clear (a successful Run) and the Player_Character returns to the start hub, THE
   Game SHALL present a Post_Run_Choice offering exactly one reward from a data-driven set that
   includes a new weapon, a Biome/level unlock, or a perk (held as data-driven options per
   Requirement 48 and Requirement 60), and SHALL apply the chosen reward to Persistent_State so it
   carries forward, consistent with the meta-progression retention of Requirement 44.
9. WHERE a Run ends by death rather than Clear, THE Game SHALL NOT present the Post_Run_Choice of
   criterion 8, consistent with death being final for the Run per Requirement 44.
10. WHERE the build is the first iteration (the tutorial / proof-of-concept build), THE Game SHALL
    include the Dark_Room as the run-start hub and SHALL display the Starting_Loadout as all three
    options (Sword, Pistol, Nothing), with Sword and Nothing selectable and the Pistol shown as a
    Locked_Option (dimmed/transparent and not selectable), and SHALL offer a Level_Select presenting
    the single authored GRASSLANDS Biome of Requirement 56.10, and SHALL present the Post_Run_Choice
    on a successful first Clear.
11. WHERE a Starting_Loadout option is a Locked_Option (such as the first-iteration Pistol of
    criterion 10), THE Game SHALL render that option dimmed/transparent using the same not-yet-
    available presentation as other locked/unaffordable options, SHALL NOT apply that option as the
    Starting_Loadout when the Player attempts to select it, and SHALL present a short ""available
    later"" message indicating the option is unlocked later, rather than silently ignoring the
    selection, consistent with the mismatched-equip feedback principle of Requirement 63.15.

---

## System BB — In-Game Choice Rooms

### Requirement 74: Choice Rooms

**User Story:** As a player, I want to occasionally enter a room that offers several items where I can
take only one, so that I make meaningful risk/reward loadout decisions during a run.

#### Acceptance Criteria

1. THE Generator SHALL be able to place a Choice_Room within a Dungeon as a data-driven Room type,
   weighted by Depth and biome per the generation model of Requirement 28 and Requirement 59.
2. WHEN the Player_Character enters a Choice_Room, THE Game SHALL present a Choice_Offer of N Items on
   offer (N a Tunable per Requirement 48), drawn from a data-driven pool weighted by Depth and biome
   and excluding Items already in the Attuned_Set, consistent with the loot sourcing of
   Requirement 17.
3. WHEN the Player selects one Item from the Choice_Offer, THE Game SHALL grant that Item to the
   current Run per Requirement 17.4 AND SHALL remove the remaining offered Items so that exactly one
   Item is taken from each Choice_Offer.
4. THE Game SHALL make each Choice_Room's Choice_Offer a one-time choice: once an Item is taken, THE
   Game SHALL NOT allow re-selecting from that Choice_Offer for the remainder of the Run.
5. THE Generator SHALL treat a Choice_Room and its Choice_Offer as deterministic from the Seed,
   producing the same offered Items for the same Seed and inputs, consistent with the single-seeded
   determinism of Requirement 31.
6. THE Generator SHALL ensure a Choice_Room never holds an Item required to satisfy Reachability
   (Requirement 30) behind the one-of-N choice, so that taking any single offered Item never makes a
   Route uncompletable.

---

## System CC — Firearms

### Requirement 75: Firearms as Bullet-Consuming Attack Items

**User Story:** As a player, I want modern firearms — pistol, machine gun, assault rifle, sniper
rifle, and grenade launcher — so that ranged gunplay sits alongside the sword and other tools.

#### Acceptance Criteria

1. THE Game SHALL define the Pistol, Machine_Gun, Assault_Rifle, Sniper_Rifle, and Grenade_Launcher
   as ATTACK_Items in the data-driven item catalogue of Requirement 13, each keyed by item id with
   its name, kind, verb, ammo type, tier, attune flag, and description.
2. THE Game SHALL equip a Firearm as the single active Equipped_Item bound to the Item (Y) button of
   Requirement 2, consistent with the one-active-item rule, so that a Firearm occupies the active
   slot like any other ATTACK_Item.
3. WHEN the Player fires the Pistol, Machine_Gun, Assault_Rifle, or Sniper_Rifle, THE Game SHALL
   consume Bullets (the bullet AMMO type of Requirement 52) and SHALL NOT fire WHILE Bullets are
   insufficient, leaving the ammo unchanged, consistent with the ammo-cost gating of Requirement 14.3.
4. WHEN the Player fires the Grenade_Launcher, THE Game SHALL consume Grenade ammo and SHALL launch a
   projectile that detonates with blast damage and Knockback per the bomb/explosive model of
   Requirement 16, where Grenade ammo is a data-driven AMMO type (Bombs or a dedicated Grenade AMMO
   type, selected as a Tunable per Requirement 48).
5. THE Game SHALL define each Firearm's fire rate, bullet damage, bullet speed, spread/accuracy,
   range, and per-shot ammo cost as data-driven Tunables per item (see Requirement 48), such that the
   Machine_Gun emphasizes high fire rate, the Sniper_Rifle emphasizes long range and high per-shot
   damage, the Assault_Rifle sits between them, and the Pistol is a reliable baseline.
6. THE Game SHALL fire Firearm projectiles through the existing Projectile system consistent with
   Sword_Beam and ranged-enemy projectiles, honoring telegraph-first fairness only for Enemies
   (Requirement 20) and not restricting Player_Character fire.
7. THE Game SHALL treat Firearms as ATTACK_Items that Attune on Clear per Requirement 18 unless an
   individual Firearm's data marks it otherwise, consistent with the attunement rules of
   Requirement 14 and Requirement 18.
8. WHERE a Firearm's absolute Tier is negative per Requirement 61, THE Game SHALL treat that Firearm
   as a Cursed_Item per Requirement 62, applying its data-driven penalty.

---

## System DD — Themed Armor Sets

### Requirement 76: Knight and Cyberpunk Armor Styles

**User Story:** As a player, I want armor in a medieval knight style and a cyberpunk/future style, so
that my defensive loadout has distinct looks that map to how I want to play.

#### Acceptance Criteria

1. THE Game SHALL provide Worn_Gear Items (Helmet, Body/Clothes, Shoes per Requirement 63.2) in two
   themed styles: a Knight style (medieval plate/mail look) and a Cyberpunk style (future/cyber look),
   held as data-driven gear Items in the catalogue of Requirement 13.
2. THE Game SHALL map the Knight style to the Armor Armor_Type (defense emphasis) and the Cyberpunk
   style to the Tactical Armor_Type (mobility/utility emphasis) of Requirement 63.3, so that the two
   themed styles reuse the existing Tactical/Armor axis rather than adding a new one.
3. WHILE Knight-style Worn_Gear is equipped under the Armor Armor_Type, THE Game SHALL apply its
   defense (damage reduction) emphasis per Requirement 63.3 and Requirement 63.5, with the specific
   values data-driven per item.
4. WHILE Cyberpunk-style Worn_Gear is equipped under the Tactical Armor_Type, THE Game SHALL apply its
   mobility/utility modifier emphasis per Requirement 63.3 and Requirement 63.5, with the specific
   values data-driven per item.
5. THE Game SHALL fit each themed gear Item into its matching Helmet, Body/Clothes, or Shoes Gear_Slot
   per Requirement 63.2 and the slot-type matching of Requirement 63.14 and Requirement 63.15, so that
   mixing styles across slots is allowed and no new slot is introduced.
6. THE Game SHALL Tier each themed gear Item anchored to the area Base_Level per Requirement 61 and
   SHALL treat a negative-Tier themed gear Item as a Cursed_Item per Requirement 62 and
   Requirement 63.7, consistent with all other Worn_Gear.
7. THE Game SHALL treat themed Worn_Gear as Run-Scoped_State that does not Attune and is discarded
   when the Run ends per Requirement 63.9 and Requirement 44, unchanged by its theme.
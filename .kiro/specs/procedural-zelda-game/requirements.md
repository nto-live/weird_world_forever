# Requirements Document

## Introduction

This document defines the requirements for a top-down, *A Link to the Past*-style action-adventure
**roguelike** built in **Godot 4 (GDScript)**. The requirements describe behavior and are
engine-agnostic, but acknowledge Godot 4 / GDScript as the implementation platform.

The game is framed around two places. The first is **Vigil**, the last warm town — a melancholy
hub of half-dead neon and androids remembering things that may never have happened. The second is a
**Dungeon**: a single seeded, procedurally generated descent of screen-sized rooms that the player
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
- **Clear**: A Run outcome in which the Player_Character reaches the Dungeon's exit alive, defeats
  the Boss, and claims its guaranteed loot. A Clear triggers Attunement, banks Sparks, and advances
  the Boss_Ladder.
- **Run-Scoped_State**: State belonging only to the current Run and discarded when the Run ends,
  including found ATTACK/UTILITY items not yet Attuned, PASSIVE items, CONSUMABLE items, keys, town
  Buffs, and unbanked Sparks.
- **Persistent_State**: State retained across Runs and surviving defeat (meta-progression): the
  Attuned set, persistent maximum-health upgrades, banked Sparks, the Boss_Ladder position (Clears
  count), and recruited human NPC roles.

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
- **CONSUMABLE_Item**: A run-scoped spendable (for example potions, fairies, arrows, bomb ammo).
  Does not Attune.
- **Attunement**: The meta-progression rule by which ATTACK/UTILITY items carried to a Clear become
  permanent and are granted at the start of future Runs.
- **Attuned_Item**: An ATTACK or UTILITY item that has been Attuned and is part of Persistent_State.
- **Attuned_Set**: The collection of all Attuned_Items.
- **Pedestal**: The primary in-Dungeon item source; a Room feature that may hold one unattuned item,
  weighted by biome and depth.
- **Inventory**: The subsystem holding the current Run's items plus a reference to the Attuned_Set.

### Enemies and bosses

- **Enemy**: A hostile, computer-controlled entity that can damage the Player_Character.
- **Archetype**: One of nine AI behaviors — PATROL, CHASE, CHARGER, TURRET, LOBBER, JUMPER, SWARM,
  PHASE, SUMMONER.
- **Bestiary**: The data-driven catalogue of Enemy definitions, biome rosters, and boss data.
- **Biome**: A themed region vocabulary (Hollow Crypts, Silkfall Warrens, Thornwild, Emberdeep,
  Glacier Barrow, Sunken Ruins, The Arcanum), each with its own enemies, hazards, and boss, and each
  asking a different question.
- **Telegraph**: A readable wind-up (flash, recoil, glow, crouch) preceding any harmful Enemy or
  Boss action.
- **Corrupted_Elite**: A rare Techno-Priest or Laser Warthog that leaks into any biome at Depth ≥ 5.
- **Boss**: A distinguished Enemy in a Dungeon's exit Room, with HP phases, a Weak_Window, and
  guaranteed loot.
- **Weak_Window**: A brief post-big-attack state (~1.5 s) during which the Boss takes double damage.
- **Boss_Ladder**: The ordered list of 100 bosses; the Nth cleared Dungeon fights boss N+1.
- **Rank**: A Boss's position (1–100) on the Boss_Ladder, driving HP/speed/phase scaling and prices.
- **Gloamwing**: The tutorial dragon; always the first Boss the Player ever fights.

### Dungeon, generation, seeding

- **Room**: One screen-sized sub-area of a Dungeon: a 16 × 14-tile grid (256 × 224 px) with door
  cells, connected to adjacent Rooms by a door graph.
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

### Town, economy, people

- **Sparks**: The currency, written "⚡," dropped by Enemies and Bosses; banked on a Clear, lost on
  death if unbanked.
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
2. THE Game SHALL resolve Player_Character collision against a 16 × 16 px tile grid using a
   collision bounds smaller than the Player_Character's sprite so corners can be slipped past.
3. WHEN the Player_Character pushes against a wall adjacent to a one-tile doorway, THE Game SHALL
   nudge the Player_Character into alignment with the tile edge so the doorway can be entered cleanly
   (edge alignment).
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
   damage and SHALL lock the Player_Character's facing for the duration of the spin.
3. IF the Spin_Attack is not unlocked WHEN the Player holds and releases the Attack input, THEN THE
   Game SHALL perform a normal swing on tap and SHALL NOT perform a Spin_Attack.
4. THE Game SHALL define the spin-charge duration and spin damage multiplier as Tunables.

### Requirement 7: Sword Beams at Full Health

**User Story:** As a player, I want sword beams at full health with a strong enough sword, so that
staying topped up is rewarded.

#### Acceptance Criteria

1. WHEN the Player swings the sword WHILE the Player_Character is at full health AND holds the Master
   Sword or a higher tier, THE Game SHALL fire a Sword_Beam projectile along the facing direction
   dealing normal sword damage.
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
5. WHILE dodge-dashing or running, WHEN the Player_Character contacts an Enemy, a pot, a breakable
   block, or a cracked wall, THE Game SHALL damage the Enemy or break the object.
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
3. THE Game SHALL start a brand-new Player_Character with only the bare sword swing and no other
   attack or utility verb unlocked.

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
   Knockback to the Player_Character.
3. WHEN a bomb detonates adjacent to a cracked dungeon wall, THE Game SHALL open that cracked wall
   (cracked-wall Gate).
4. THE Game SHALL define bomb blast radius and bomb knockback magnitude as Tunables.

### Requirement 17: Pedestals and Boss Loot as Item Sources

**User Story:** As a player, I want to find items on pedestals and from bosses, so that each dungeon
can grow my toolkit.

#### Acceptance Criteria

1. THE Generator SHALL give each non-start Room a chance to hold exactly one Pedestal item, weighted
   by the Room's biome and Depth, such that deeper and rarer biomes draw from a better pool.
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
4. THE Spawner SHALL place the Boss, with its fixed escort, only in the Dungeon's exit Room.
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
3. WHEN the Player_Character has recorded N Clears, THE Game SHALL select the Boss at Rank N+1 on the
   Boss_Ladder for the next Dungeon.
4. THE Boss_Ladder SHALL define 100 Bosses in a fixed escalating order.
5. THE Game SHALL compute each Boss's HP as 12 + Rank × 2 and base speed as 48 + Rank × 0.8 px/s, and
   SHALL increase the Boss's phase count at Ranks 20, 60, and 85, using these formulas as Tunables.
6. THE Game SHALL render every Boss's HP, speed, and phase scaling as monotonically non-decreasing
   with Rank.

---

## System H — Dungeon Generation

### Requirement 27: Screen-Sized Rooms on a Door Graph

**User Story:** As a player, I want a dungeon built from screen-sized rooms linked by doors, so that
each run is a distinct, coherent descent.

#### Acceptance Criteria

1. THE Generator SHALL build each Room as a 16 × 14-tile grid (256 × 224 px) with defined door cells.
2. THE Generator SHALL connect Rooms into a Door_Graph where Rooms are nodes and doors are edges,
   tagging a start Room and a far exit Room.
3. WHEN the Player_Character crosses a Room edge through a door, THE Game SHALL transition to the
   adjacent Room with a locked-screen scroll transition.
4. THE Generator SHALL place locked doors with matching keys and the boss/exit room as part of the
   Door_Graph.

### Requirement 28: Depth-Based Difficulty Scaling

**User Story:** As a player, I want deeper rooms to get harder through new combinations, so that
descent feels like escalation rather than only bigger numbers.

#### Acceptance Criteria

1. THE Generator SHALL scale enemy density and encounter composition by Room Depth, adding new
   archetype combinations at greater Depth rather than only increasing HP.
2. THE Generator SHALL weight Pedestal loot quality upward with Depth and biome rarity.

### Requirement 29: Run Length Scaling with Biome Count

**User Story:** As a player, I want the first world to take 15–25 minutes and runs to grow as more
biomes unlock, so that session length scales with content.

#### Acceptance Criteria

1. THE Generator SHALL size the first available world so a representative Clear targets a
   15–25 minute Run duration.
2. THE Generator SHALL derive the target Run duration from a configurable Tunable that increases as
   the number of Biomes available to the generator increases.
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
   produce identical Door_Graph structure, Room layouts, loot placement, and enemy placement.
3. THE Game SHALL display the current Seed and allow it to be read for sharing.

---

## System K — Town / Vigil & Economy

### Requirement 32: Vigil as Run Boundary

**User Story:** As a player, I want every run to begin and end in Vigil, so that the town is my
constant home between dungeons.

#### Acceptance Criteria

1. WHEN a Run ends by Clear or by death, THE Game SHALL return the Player_Character to Vigil with
   that visit's purchases reset and the Attuned_Set intact.
2. THE Game SHALL present Vigil containing the enterable buildings The_Last_Call (bar),
   The_Warm_Machine (restaurant), The Forge, The Apothecary, The_Chapel, The_Board, and The
   Pawnbroker.
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
3. THE Game SHALL NOT allow a second drink Buff or a second meal Buff to be active at the same time.

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
   Room's Depth.
2. THE Game SHALL scale town prices with the next Dungeon's Rank by the factor (1 + Rank × 0.05).
3. WHEN a Run ends in a Clear, THE Game SHALL bank that Run's collected Sparks into Persistent_State.
4. WHEN a Run ends in death, THE Game SHALL lose that Run's unbanked Sparks.
5. THE Game SHALL allow the Pawnbroker to convert unclaimed loot into Sparks.
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
   SHALL place progressively fewer Simulacra as distance from Vigil increases.

### Requirement 39: Rare Human NPCs Recruited from Dungeons

**User Story:** As a player, I want to find real people in dungeons and bring them home, so that the
town can gain genuine inhabitants worth protecting.

#### Acceptance Criteria

1. THE Game SHALL make Human_NPCs encounterable within any Biome, including wild Overworld areas and
   Dungeons, as a rare occurrence.
2. THE Game SHALL concentrate Human_NPC density at its highest value near Vigil and SHALL place
   progressively fewer Human_NPCs as distance from Vigil into wild Overworld areas or into a Dungeon
   increases.
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
   tile size (16 px), screen size (256 × 224 px), walk speed (~1.5–2.0 px/frame), dash speed
   (~2× walk, reused as the dash/run speed), spin-charge duration (~2.0 s), spin damage multiplier
   (×2), sword-tier multipliers (×1 / ×2 / ×3 / ×4), mail reduction factors (0% / 50% / 75%),
   Damage_Unit (8 = one Health_Container), i-frame duration (~0.5–1.0 s), dodge-dash distance (or
   duration), dodge i-frame duration (~0.3–0.5 s), tap-vs-hold hold-threshold duration (~0.15–0.25 s),
   hit-stun duration, knockback magnitude, sword reach (~1 tile), swing-active duration, Weak_Window
   duration (~1.5 s), Boss HP formula (12 + Rank × 2), Boss speed formula (48 + Rank × 0.8), bomb
   blast radius, bomb knockback magnitude, authentic-diagonal toggle, and target Run duration.
2. THE Game SHALL record a confidence flag of `exact`, `[approx]`, or `[verify]` for each Tunable,
   matching the reference, and SHALL flag the i-frame duration and the dodge i-frame duration
   `[approx]` and marked tune-first.
3. THE Game SHALL allow each Tunable to be changed in data without changing the systems that read it.

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
   Game SHALL return to the Title Screen without starting a Run and SHALL leave existing state
   unchanged.
6. WHEN the Player selects "Exit", THE Game SHALL quit the application.

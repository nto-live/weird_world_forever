# Items, Power-ups & the Attunement Loop

Companion to `00-LTTP-controls-and-feel.md` and `01-bestiary.md`. Same contract: data-driven
(`godot/scripts/Items.gd`), seeded, and honest about what's proven vs. designed.

## The two rulings that define this system

1. **Every attack beyond the starting swing is an unlock.** You begin with a bare sword and a swing.
   The **Spin Attack, sword beams, bow, boomerang, bombs, hookshot, hammer, rods, canes, and the
   techno spells** are all items you find. Power *is* progression.
2. **You keep your unlocks only if you solve the dungeon.** Items work for the run you found them in.
   Reach the end of the dungeon **alive** and they become **Attuned** — permanent, available at the
   start of every future run. Die, and everything you were carrying that run is gone.

That single rule turns LTTP's item chain into a roguelite: each cleared dungeon permanently widens
your toolkit, and the early runs are *deliberately* poor.

---

## The loop

```
start run (with everything Attuned so far)
   → explore a biome route (Crypts → … → Arcanum)
   → find Attack / Utility items on pedestals
   → a completed run ATTUNES the attack & utility items you carried
   → next run starts stronger
   → die → lose this run's finds, keep prior Attunements
```

The tension: do you play safe and bank an easy clear, or dive deep where the good unlocks live?

---

## Taxonomy

| Kind | Persists on clear? | Examples | Purpose |
|---|---|---|---|
| **ATTACK** | ✅ yes (attunes) | Bow, Bombs, Hookshot, Fire Rod, Laser Gauntlet | New ways to hurt things |
| **UTILITY** | ✅ yes (attunes) | Pegasus Boots, Flippers, Glove, Cape | New ways to *move / open the world* |
| **PASSIVE** | ❌ no (run-scoped) | Sword tiers, Shield, Mail, Heart Container | Power within a run only |
| **CONSUMABLE** | ❌ no | Potions, Fairies, Arrows, Bomb ammo | Spend for a moment of safety |

Attacks and utilities are *verbs*; passives are *numbers*. Verbs persist and compound; numbers reset
so a run never becomes a victory lap.

---

## ATTACK UNLOCKS (the centerpiece)

Each grants a distinct verb, an input, and usually a cost (magic or ammo). `mp` is in magic units.

| Item | Verb | Input | Cost | Feel / notes |
|---|---|---|---|---|
| *(start)* **Fighter's Sword** | **Swing** | attack tap | — | The baseline. Short arc, ~1 tile. |
| **Knights' Crest** | **Spin Attack** | hold attack ~2 s | — | Unlocks the charge. 360°, ×2 damage. |
| **Master Sword** | **Sword Beam** | swing at full health | — | Fires a beam; also the ×2 sword tier. |
| **Bow & Arrows** | **Arrow** | item button | 1 arrow | Fast, straight; hits turrets at range. |
| **Boomerang** | **Boomerang** | item button | — | Stuns; hits again on the return; grabs items. |
| **Bombs** | **Bomb** | item button | 1 bomb | Timed blast; opens **cracked walls** (gate). |
| **Hookshot** | **Grapple** | item button | — | Crosses **gaps** (gate); stuns; pulls loot. |
| **Magic Hammer** | **Smash** | item button | — | Overhead; breaks **pegs**; staggers armored foes. |
| **Fire Rod** | **Fire** | item button | 8 MP | Ranged burst; burns **webs**/grass (gate). |
| **Ice Rod** | **Ice** | item button | 8 MP | Freezes enemies; freezes **water** to cross (gate). |
| **Cane of Somaria** | **Block** | item button | 8 MP | Spawns a pushable block (puzzles, weight gates). |
| **Cane of Byrna** | **Barrier** | item button | 16 MP | Spinning damage shield while active. |
| **Laser Gauntlet** | **Laser** | item button | 8 MP | Charged piercing laser — the Arcanum answer to the rods. |
| **Arcane Bolt** | **Bolt** | item button | 6 MP | Homing magic bolt; curves toward the nearest foe. |
| **Servitor Charm** | **Command** | item button | 12 MP | Summons a temporary Servitor that fights for you. |

The last three are the **techno tier** — you only find them in **The Arcanum**, and they're a large
part of why clearing that biome is worth the risk.

## UTILITY UNLOCKS

| Item | Verb | Gate it opens |
|---|---|---|
| **Pegasus Boots** | **Dash** | Smash pots/cracked blocks; cross slow tiles fast |
| **Zora's Flippers** | **Swim** | Cross **deep water** |
| **Power Glove → Titan's Mitt** | **Lift** | Light rocks → **heavy boulders** (weight gates) |
| **Magic Cape** | **Vanish** | Pass invisible barriers; i-frames while drained |
| **Magic Mirror** | **Warp** | Return to the dungeon entrance (escape hatch) |
| **Moon Pearl** | *(unlocked form)* | Prevents form-lock in the dark world |

## PASSIVE UPGRADES (run-scoped)

| Item | Effect |
|---|---|
| **Sword tier** (Master / Tempered / Golden) | damage ×2 / ×3 / ×4 |
| **Shield** (Fighter's / Red / Mirror) | block tiers; Mirror blocks beams |
| **Mail** (Green / Blue / Red) | damage taken 100 / 50 / 25 % |
| **Heart Container** | +1 max heart |
| **Magic upgrade** | bigger magic meter |
| **Bottle** | carry one potion/fairy; auto-refill on empty |

## CONSUMABLES

Potions (red = heal, green = magic, blue = both), **Fairies** (auto-revive in a bottle), Arrows, Bomb
ammo, Magic refills. Drifting pedestal drops and enemy drops.

---

## Where items come from

- **Pedestals:** the primary source. Each non-start room has a chance to hold one, weighted by biome
  and depth. Deeper + rarer biome = better pool.
- **Boss reward:** the exit boss always drops one **guaranteed** ATTACK or UTILITY item — the reward
  for a clear.
- **Gates and keys:** some items double as **keys** (Bombs → cracked walls, Flippers → water,
  Hookshot → gaps). The dungeon generator places *at least one item that opens each gate before it* —
  the classic "logic" rule, enforced by `Reachability`.

## Gated generation (the logic rule)

The generator must guarantee a completable dungeon:

1. Pick a **gate plan** for the route (e.g., `cracked → water → gap`).
2. For each gate, place a source of the required item **before** the gate (and reachable without it).
3. Place pedestals with a shuffled item pool, but never place a gate item *after* its gate.
4. Only the **unattuned** pool is placed — you never re-find what you already Attuned.
5. Run `Reachability.completable(rooms, start, exit, attuned ∪ {found so far})` before handing the
   dungeon to the player. Fail → re-roll from the seed.

## Attunement — the exact rules

- **Trigger:** reach the dungeon's end **alive** (defeat the boss / take the exit). Death = no
  attunement, and you lose this run's finds.
- **What attunes:** the **ATTACK and UTILITY** items you were carrying. **PASSIVE** and **CONSUMABLE**
  do not.
- **Effect:** attuned items are granted at the start of every future run (`Game.start_run` seeds the
  inventory from `Meta.load_attuned()`), and are removed from the pedestal pool.
- **Anti-trivialization levers (put these in the design):**
  - Attunement is *earned per item per completed run* — you must carry it to the end.
  - Strong items are depth-gated, so early attunements are small.
  - Optional **Ascension**: each completed dungeon raises a difficulty modifier for veterans.
  - Passives never persist, so raw stats always come from *this* run.

## Code contract (see `gotod/scripts/`)

- `Items.gd` — the data: `id → {name, kind, verb, mp, gate, biome, tier, attune, desc}`.
- `Inventory.gd` — this run's items + the Attuned set; `has(id)`, `attack_unlocked(verb)`,
  `attunables()` (the list to persist on a clear).
- `Meta.gd` — persistence: `load_attuned()`, `attune(ids)` → saves to `user://meta.json`.
- `Game.gd` — holds the inventory; `acquire(id)`; `complete_run()` attunes and saves; `has(id)`.
- `Player.gd` — **gates the Spin Attack behind `attack_unlocked("spin")`**; sword beam behind the
  Master Sword; item button casts the equipped verb.
- `Main.gd` — drops pedestals, hands out the boss reward, calls `complete_run()` on a clear.
- `Reachability.gd` — `completable(rooms, start, exit, have_ids)` respects gates.

## Sources / inspiration

- LTTP item list & tiers (Zelda Dungeon): https://www.zeldadungeon.net/wiki/A_Link_to_the_Past_Items
- LTTP sword tiers / mail reduction / cape (GameFAQs WWalker walkthrough):
  https://gamefaqs.gamespot.com/snes/588436-the-legend-of-zelda-a-link-to-the-past/faqs/12595
- Magic costs per item (GameFAQs assassin17 monster/attack stats):
  https://gamefaqs.gamespot.com/snes/588436-the-legend-of-zelda-a-link-to-the-past/faqs/39556

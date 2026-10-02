# Bosses

Companion to `00` (feel), `01` (bestiary), `02` (items). Bosses use the same contract as every other
enemy — **contact damage, telegraphed tells, knockback, i-frames** — but with **phases**, a
**weak window**, and a **guaranteed loot drop**.

## Boss framework (what makes a boss a boss)

1. **Telegraph first, always.** No boss action lands without a readable wind-up (rear-back, glow,
   stomp-crouch). The dragon is the *tutorial*: it teaches "watch the tell, punish the recovery."
2. **Pattern cycle, not randomness.** A boss runs a repeating cycle of named patterns, so fights are
   learnable — the roguelike variance lives in the *room* and your loadout, not in an unreadable boss.
3. **Phases by HP.** Crossing a HP threshold swaps the pattern set and (usually) speeds it up.
4. **A weak window.** Most patterns end in a **recovery** state; after the big ones the boss is
   **winded** and takes **double damage** for ~1.5 s. This is the reward for surviving the tell.
5. **Arena, not just a body.** Bosses eventually want hazards/terrain (see Frostmaw). Wave 1 is a
   plain arena; the rest are designed, not built.
6. **Guaranteed loot.** A boss always drops **ATTACK/UTILITY** items you don't already have — and
   taking them is required to *count the dungeon solved* (and attune).

## Patterns (implemented in `Boss.gd`)

| Pattern | Reads as | Counter |
|---|---|---|
| **breath** | 1.2 s rear-back → a sweeping cone of fire | Strafe out of the cone, then hit it while **winded** |
| **volley** | Lobs a series of arcing fireballs at you | Keep moving; don't hide behind cover |
| **stomp** | Crouch → radial shockwave ring | Jump/step through the gaps |
| **ring** | Wide radial burst | Same — mind the spacing |
| **charge** | Winds up → dashes in a straight line | Sidestep, punish the wall-bonk |
| **laser** | Aiming glow → piercing beam | Break line of sight |
| **summon** | Channel → raises minions | Kill minions or burst the boss |

---

## Boss 1 — **Gloamwing, the First Wyrm** *(THE DRAGON — the tutorial boss)*

**Role:** the first boss the player ever fights. He must be **basic**. Every mechanic he uses is one
the player has already met in a lesser enemy (a charge, a spread, a ring) — only bigger and slower.
He is the *language lesson*.

- **Body:** a stout wyrm coiled in the middle of the arena. Slow, heavy, readable. Big silhouette.
- **HP:** 12 base hits (≈ 6 with spins). **Damage:** a full heart (8) per hit — respect the tail.
- **Arena:** one plain room. No hazards. (Tutorial!)
- **Aggro:** always.

**Phase 1 (100 %–50 %)** — slow and honest:
- **Fire Breath** *(breath)* — rears back ~1.2 s, then sweeps a **cone of fire** in front. After it,
  he's **winded** for 1.5 s (double damage) — *this is the lesson: punish the recovery.*
- **Tail Stomp** *(stomp)* — crouches, then a **radial shockwave ring** of 6. Step through the gaps.

**Phase 2 (≤ 50 %)** — adds reach, same vocabulary:
- **Fireball Volley** *(volley)* — lobs 4 arcing fireballs; forces movement.
- **Wyrm Charge** *(charge)* — winds up, dashes across the room; bonks the wall and is open.
- Breath and stomp are **faster** (speed 48 → 72).

**Tells:** glow in the throat before breath; a deep crouch before stomp; a scrape-back before charge.
**Weak window:** after *breath* only (the big commitment), ~1.5 s.
**Loot (guaranteed):** **Bombs** + **Fire Rod** — the first real tools, and thematically "you beat a
dragon, you get fire."

**Why basic:** no adds, no invuln gimmick, no arena reshuffle. Pure tell → dodge → punish. The Grave
Sovereign (Crypts) is the *next* boss and he raises an army — escalation you'll *feel* because the
dragon taught you clean.

---

## The biome bosses (later clears)

Each is harder than the dragon in a *different* way. Data in `Bestiary.BOSS_EXTRAS`.

| Boss | Biome | Phases / gimmick | Loot |
|---|---|---|---|
| **Gloamwing, the First Wyrm** | *(first clear, any)* | breath → stomp → volley/charge | Bombs, Fire Rod |
| **The Grave Sovereign** | Crypts | `summon` + `stomp` → `summon` + `ring`; **shielded while channeling** | Knights' Crest, Boomerang |
| **The Weaver Queen** | Warrens | `volley` + `summon` → +`ring`; anchored, webs the floor | Hookshot, Boomerang |
| **Root-Mother** | Thornwild | `volley` + `summon` → +`ring`; seed-bombs bloom into swarms | Bow |
| **The Forge Tyrant** | Emberdeep | `stomp` + `charge` → +`ring`; hammer shockwaves | Magic Hammer, Fire Rod |
| **Frostmaw** | Glacier | `breath` + `volley` → +`ring`/`charge`; frost **turns the floor to ice** | Ice Rod |
| **The Tidebound** | Sunken | `summon` + `volley` → +`ring`; **floods the arena in stages** | Flippers, Hookshot |
| **The Ordinator** | Arcanum | `laser` + `summon` → +`ring`; **shield via 3 pylons**, Laser Warthog guard | Laser Gauntlet, Arcane Bolt |

**The first boss is always the dragon** (`Meta.clears() == 0`). **One boss per dungeon** — each
dungeon's exit room holds exactly one. The ladder advances one rung per *cleared* dungeon, so
dungeon #2 is the Rust-Bound Squire, #3 the Weeping Lamplighter, and so on down `04-boss-roster-100`
through all 100. You never fight two bosses in one dungeon.

## Boss loot rules

- Always **1–2 ATTACK/UTILITY items you don't already own** (never a duplicate of an Attuned item).
- The drop sits in the arena; **you must pick it up** — `Main` counts the dungeon solved only when
  the boss is dead **and** its loot is claimed.
- Claiming (and clearing) **Attunes** the loot, per `02`.

## Debug

A **debug key (F1)** unlocks every item for the current run (`Game.debug_unlock_all()`), so you can
playtest the late-game verbs — Bow, Hookshot, Laser Gauntlet — without earning them first. It does
**not** Attune anything; it's a sandbox, not a cheat that persists.

## Code

- `Bestiary.FIRST_BOSS` — the dragon.
- `Bestiary.BOSS_EXTRAS` — per-boss `phases` + `loot`, merged onto the boss dict at spawn.
- `Boss.gd` (extends `Enemy`) — phase machine + the pattern implementations above.
- `Spawner.gd` — bosses spawn as `Boss` in the exit room; the first clear is always the dragon.
- `Main.gd` — connects each enemy's `died` signal; boss death drops loot; draws the boss HP bar.
- `Meta.gd` — tracks `clears`, so "first boss = dragon" is a fact of the save.

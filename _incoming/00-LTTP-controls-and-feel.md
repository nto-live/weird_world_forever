# Reference: How *The Legend of Zelda: A Link to the Past* (SNES, 1991) Controls and Feels

**Purpose of this document.** This is a factual, source-backed reference on how the original
*A Link to the Past* (LTTP) handles player control, movement, combat and interaction. It is written
to be dropped into **Kiro** as context so that Kiro can generate a `requirements.md` (spec-driven)
for a **LTTP-style roguelike built in Godot 4**.

It is deliberately split into:
1. **Verified facts** about the original game (what we copy or deliberately break).
2. **Feel numbers / tunables** (some are exact, some are approximations to be tuned — each is marked).
3. **Roguelike deltas** (what changes when the fixed overworld becomes a procedural run).
4. **A ready-to-paste Kiro prompt.**

Source links are at the bottom. Anything I could not verify is marked **[approx]** or **[verify]**.

---

## 0. At a glance (one screen)

| Thing | LTTP |
|---|---|
| Genre | Top-down (3/4 overhead) real-time action-adventure |
| Movement | 8-directional; you may move diagonally |
| Attack | Melee sword (B); charged spin attack; sword beams at full health |
| Interaction | One context button (A) does almost everything non-combat |
| Item use | One equipped item on a dedicated button (Y) |
| Damage model | Hearts; invincibility ("i-frame") flash after each hit; knockback on hit |
| Camera | Overworld scrolls freely; dungeons are room-locked screens with scroll transitions |
| Pausing | Inventory/map **pause the action** (not real-time menus) |
| Death | Respawn at last save point; the world does **not** reset (unlike a roguelike) |

---

## 1. Control scheme (SNES original)

From the official instruction booklet and IGN's control table. Only **six inputs** matter; the design
lesson is *few buttons, many contexts*.

| Action | SNES | What it does |
|---|---|---|
| **Move** | D-Pad | Move Link in **8 directions** (two directions at once = diagonal). Also navigates every menu. |
| **Sword / Attack** | **B** | Swing sword. **Hold ~2 s → release = Spin Attack.** Confirms choices on menus/game-over. |
| **Action / Interact** | **A** | The universal button: pick up, throw, pull, talk, read signs, open chests, swim (with Flippers), **dash (with Pegasus Boots, hold it)**. |
| **Use equipped item** | **Y** | Fires the single item currently selected in the inventory window. |
| **Map** | **X** | Overworld map / dungeon map. Press again → zoomed-out view; press again (or B) → close. **L** toggles close-up vs full map. |
| **Inventory / Sub-screen** | **Start** | Opens the item + equipment menu. **Pauses the game.** |
| **Pause / Save menu** | **Select** | Save / sleep (GBA). |

Notes that matter for a clone:
- **The action button is overloaded on purpose.** Context (what Link is standing next to + what he is
  holding) decides whether A lifts, throws, pulls, talks, reads, swims, or dashes. There is *no*
  separate "use" button for world objects.
- **Only one item can be "equipped" at a time** on Y. Switching is deliberate and happens in a paused
  menu. That single-item economy is a core part of LTTP's tension.
- **Menus pause the world.** There is no real-time inventory.

---

## 2. Movement model

- **8-directional, free (not grid-locked) movement.** Link's position is continuous pixels; he is
  *not* snapped to a tile grid while walking. **[verified — the game moved beyond the original's
  4-direction-only movement; diagonal movement is explicitly cited as new to LTTP.]**
- **Diagonal movement is faster than cardinal movement** in the original: each axis advances at the
  walking rate, so a diagonal covers ~1.41× the ground per frame. This is a well-documented quirk
  that speedrunners exploit. **[approx / verify against the disassembly] — decision point: keep it
  (authentic, speeds up traversal) or normalize diagonal to the same magnitude (fairer).**
- **Collision is tile-based (16×16 px tiles)** even though movement is free. Link's collision box is
  smaller than his sprite so he can slip past corners.
- **Snapping / alignment:** pushing against a wall or block nudges Link to align with the tile edge —
  essential for entering 1-tile doorways cleanly. A good clone needs this "edge alignment" or doors
  feel awful.
- **Speed values:** the game drives speed from a setting byte (`$7E005E`, indexed into a speed table)
  with a modifier at `$7E0057`; normal-walk is setting `0x00`. Exact px/frame figures are best
  measured from the disassembly. **[verify]** Recommended *starting* values for a Godot clone,
  tuned to feel, with a 16 px tile:
  - Walk ≈ **1.5–2.0 px/frame** → cross a tile in ~8–11 frames. **[approx]**
  - Dash (Pegasus) ≈ **2× walk**. **[approx]**
  - Stairs / water / ice have their own speed settings — special surfaces are a *setting*, not a
    physics hack.
- **Facing:** Link faces one of **4 cardinal directions** for sprite/attack purposes even while moving
  diagonally (the last-pressed axis wins). Attack direction follows facing.

### Room / camera structure
- **Screen = 256 × 224 px = 16 × 14 tiles.** **[verified — SNES standard; most devs used 256×224.]**
- **Dungeons are room-based:** each room occupies one screen; the camera is locked to the room and
  does a push/scroll transition when Link crosses an edge.
- **Overworld scrolls smoothly** as one big connected map (with its own "screens" for enemy/event
  bookkeeping).
- **Room transitions are hard cuts with a scroll**, and doors/edges define the traversal graph.

---

## 3. Combat model

### Sword
- **Swing (tap B):** a short melee arc in front of Link. Reach is roughly **1 tile** beyond his body.
- **Spin Attack (hold B ≈ 2 s, release):** a 360° attack hitting the surrounding tiles; it does
  **about double** a normal swing. While charging, Link **holds the sword up / shield turned to the
  side** (he is not blocking normally), but he **can still walk** — so charging is a commitment to
  defense. **[verified — manual/guides: "hold for two seconds … doubles damage".]**
  - The spin attack also **locks Link's facing** during the spin; it is the main answer to enemies
    that circle or bounce away (Vultures, Stalfos).
- **Sword beams:** at **full health** with the **Master Sword or better**, a swing also fires a
  projectile doing **normal** damage. **[verified]**
- **Sword tiers (damage multipliers):** Fighter's (×1) → Master (×2) → Tempered (×3) → Golden (×4).
  **[verified]**

### Damage model (hearts)
- Health is tracked in **hearts**; internally the damage tables use **8 units = 1 full heart**.
  **[verified — the standard "default bump damage" is 8 green / 4 blue / 2 red, i.e. one heart /
  half / quarter.]**
- **Tunic modifiers:** Green = full damage, **Blue Mail = 50 % reduction**, **Red Mail = 75 %
  reduction**. **[verified]**
- **Enemies deal "bump damage":** every enemy is assigned one of ~10 bump-damage classes; walking
  into (or being walked into by) an enemy hurts Link. So *contact itself* is the basic threat, not
  only enemy attacks. **[verified]**
- **Knockback:** taking a damaging hit knocks Link back and briefly removes his control (hit-stun).
  Sword/hammer hits against certain shielded enemies cause a hardcoded *damageless* knockback.
  **[verified]**
- **Invincibility frames (i-frames):** immediately after taking a hit, Link **flashes/blinks and is
  briefly invulnerable**; further hits pass through. Caveat worth copying: at least one damage source
  (fire faerie MP damage) **ignores i-frames** — i-frames are per-damage-type, not global.
  **[verified]**
  - Duration **[approx ~0.5–1.0 s]** — this is *the single most important feel variable* to tune.
- **Shield:** automatically blocks projectiles/attacks **from the direction Link faces**. Tiers:
  Fighter's → Red → **Mirror** (Mirror adds blocking of things like lasers). Blocking is passive —
  there is no block button. **[verified]**

### The "joust" pattern
Guides describe LTTP swordplay as **jousting**: shuffle in, swing, retreat, repeat. It falls out of
four systems combined: short sword reach, contact damage, knockback, and i-frames. A clone that
misses any one of those will *not* feel like LTTP even if the art matches.

---

## 4. Interaction verbs (the A-button set)

| Verb | Trigger | Notes |
|---|---|---|
| Talk / read | A near NPC or sign | Opens dialogue; movement locked during text |
| Open chest | A at a chest | Suspends play for the "item get" fanfare |
| Lift | A at a pot/rock/bush | Small objects by default; big ones need **Power Glove → Titan's Mitt** |
| Throw | A while carrying | Object becomes a projectile that damages enemies; breaks on impact |
| Pull | Stand adjacent, press *away* | Pulls pull-able blocks/levers |
| Push block | Walk into it | Some blocks push exactly **one tile** per push |
| Dash | **Hold A** (with Pegasus Boots) | Runs in the facing direction, sword out; **cannot turn** mid-dash (press another dir to stop); damages enemies on contact; smashes pots/blocks/cracked walls |
| Jump off ledge | Walk off | Overworld ledges auto-hop |
| Swim | A with Zora's Flippers | — |

Design takeaway: **everything non-combat is one button resolved by context.** For a roguelike this
is gold — it keeps the HUD and input map tiny.

---

## 5. Items (the classic LTTP "key ring" to mine for a run's item pool)

**Progression / ability items** (each unlocks a *verb* or a *door type*):
Lamp, Bow, Boomerang, Hookshot, Bombs, Magic Hammer, Fire Rod, Ice Rod, Cane of Somaria, Cane of
Byrna, Magic Cape, Magic Mirror, Book of Mudora, Zora's Flippers, Moon Pearl, Power Glove → Titan's
Mitt, Pegasus Boots, Flute.

**Consumables / supplementary:** Bottles (empty → fairies, potions, etc.), Magic Powder, Mushroom.

**Equipment tiers:** Sword (×1/2/3/4), Shield (Fighter/Red/Mirror), Tunic (Green/Blue/Red).

**Resource:** **Magic Meter (MP)** drains on rod/cape/etc. use.

For a roguelike, this list is your **item-pool skeleton** — separate *verbs* (Hookshot, Bombs,
Flippers — they change what a room can ask of you) from *stat sticks* (sword/tunic tiers) from
*consumables*.

---

## 6. Feel / tunables summary (build these as data, not constants)

| Variable | LTTP value | Confidence |
|---|---|---|
| Tile size | 16 × 16 px | exact |
| Screen | 256 × 224 px (16 × 14 tiles) | exact |
| Move directions | 8 (diagonal allowed) | exact |
| Walk speed | ≈1.5–2.0 px/frame | approx — tune |
| Dash speed | ≈2× walk | approx |
| Sword reach | ≈1 tile past body | approx |
| Sword swing duration | short (~a few frames of active hitbox) | approx — tune |
| Spin charge time | ~2.0 s hold | exact (2 s) |
| Spin damage | ×2 a swing | exact (approx) |
| Swords | ×1 / ×2 / ×3 / ×4 | exact |
| Tunic reduction | 0 % / 50 % / 75 % | exact |
| Damage unit | 8 = 1 heart | exact |
| I-frame duration | ~0.5–1.0 s | approx — **tune first** |
| Knockback | present, brief control loss | exact (magnitude approx) |
| Shield blocking | passive, facing-based | exact |

**Golden rule:** the *combination* of short reach + contact damage + knockback + i-frames + screen
lock defines the feel. Copy the systems, then tune the numbers.

---

## 7. Roguelike deltas — what changes and what must be designed

LTTP is **not** a roguelike: no procedural generation, no permadeath, no run structure, fixed item
progression gates. To keep the *feel* while making it a roguelike, these are the real design
questions Kiro needs to turn into requirements:

1. **Run structure.** One run = one seeded dungeon (or overworld-of-rooms)? Depth/branching? How
   long is a run (target minutes)? Roguelikes need a *session length* target the original never had.
2. **Procedural rooms on a 16 px grid.** Rooms are screen-sized (16 × 14 tiles) or larger. A tile
   layer + a door/anchor model is required. Rooms must be *generated*, then validated (reachable
   doors, no soft-locks) — this is LTTP's "reachability solver" problem wearing a roguelike hat.
3. **Door/room graph.** Generation produces a graph (rooms = nodes, doors = edges). Doors need
   rules (locked vs open, keys, one-way drops, boss/treasure/exit rooms).
4. **Item pool within a run.** Replace fixed progression gates with *gated generation*: an item
   pool is shuffled and placed so the run is always completable (the classic "logic" problem).
   Decide whether gates exist per-run or all items are open from the start.
5. **Permadeath + meta-progression.** Does anything carry between runs (unlocks, unlocks-by-
   achievement)? This is the roguelike variable LTTP has zero opinion on — it's a pure choice.
6. **Enemy design for random rooms.** Enemy AI must work in unknown layouts (patrol vs chase vs
   turret). Contact damage + knockback + i-frames still apply. Beware off-screen/unfair hits that
   hand-authored LTTP rooms were tuned to avoid.
7. **Difficulty curve.** Depth-based scaling of enemy density/damage vs the original's flat world.
8. **RNG + seeds.** A single seeded RNG fed into generation *and* item placement; the seed is shown
   and shareable (the original's "same seed = same world" idea, but for whole dungeons).
9. **Pausing/scoping.** Keep the LTTP rule: **menus pause the world.** For a roguelike, decide what
   pauses (inventory yes; is there a mid-run save at all? Typically no).
10. **Death feedback.** LTTP respawns at a save point preserving progress; a roguelike resets the
    run. Decide the death/respawn UX explicitly.

### Godot 4 implementation sketch (for the design doc)
- `CharacterBody2D` for the player; movement via `velocity` with `move_and_slide()`, **8-direction
  input vector normalized** (or not — see diagonal-speed note), `CollisionShape2D` smaller than the
  sprite.
- **Input map:** `move_up/down/left/right`, `attack` (B), `action` (A), `item` (Y), `map` (X),
  `inventory` (Start). Keep it to these six.
- **State machine** for player: `idle / walk / attack / charge / spin / hurt / lift / dash / swim`.
  `hurt` owns knockback + i-frames; `charge` owns the 2 s timer → `spin`.
- **Hitboxes/hurtboxes** as `Area2D` toggled per state (sword active only during the swing frames;
  hurtbox removed during i-frames — see the standard Godot i-frame recipe in the sources).
- **Room generation:** build a tile map from a generator, place doors from a graph, run a
  reachability check before handing the room to the player.
- **Seeded RNG:** one `RandomNumberGenerator` with an explicit `seed`, threaded through generation,
  loot and enemy placement; display the seed in the HUD.

---

## 8. Ready-to-paste Kiro prompt

> Use the attached reference document **"How A Link to the Past controls and feels"** as the
> authoritative description of the target game feel. We are building a **top-down, LTTP-style
> roguelike in Godot 4 (GDScript)**.
>
> Produce a **`requirements.md`** in Kiro's spec format:
> - **Scope:** a single playable run — procedurally generated dungeon/rooms on a 16 px tile grid,
>   LTTP-style 8-directional movement, one-button interaction, melee sword combat with a charged
>   spin attack, an item pool placed so a run is always completable, depth-based difficulty, seeded
>   RNG with a shareable seed, and permadeath.
> - **Out of scope (state explicitly):** the original's fixed overworld, fixed story, and fixed
>   item-gate progression; mid-run saves.
> - **For every requirement**, write a user story plus **EARS acceptance criteria** (When … the
>   system shall …, etc.).
> - **Encode the feel numbers from the reference as tunable config values**, not hardcoded
>   constants, and mark the ones the reference flags as **[approx] / [verify]**.
> - **Call out the open decisions** from §7 (run length, meta-progression, gate model, pause scope,
>   death/respawn UX) as questions for me to answer before you write the design.
> - Feed straight into the follow-on **`design.md`** and **`tasks.md`** once requirements are
>   approved.

---

## 9. Sources

- Official SNES instruction booklet transcription (buttons: A=action, B=sword, Y=items, X=map):
  http://www.world-of-nintendo.com/manuals/super_nes/legend_of_zelda_alttp.shtml
- IGN — A Link to the Past "Basics" (control table across SNES/Switch/GBA/Wii; spin attack; beams):
  https://www.ign.com/wikis/the-legend-of-zelda-a-link-to-the-past/Basics
- Wikipedia — *The Legend of Zelda: A Link to the Past* (diagonal movement is new vs. the original):
  https://en.wikipedia.org/wiki/The_Legend_of_Zelda:_A_Link_to_the_Past
- Neocities LTTP controls (diagonal via two directions; lift/throw/pull; dash rules):
  https://alinktothepast.neocities.org/walkthrough/controls
- Neoseeker Zelda Wiki — LTTP controls (hold ~2 s for spin attack; beams at full health):
  https://zelda.neoseeker.com/wiki/A_Link_to_the_Past_Controls
- Zelda Wiki — Spin Attack (2 s charge; two-spin variant; magic cost):
  https://zeldawiki.wiki/wiki/Spin_Attack
- GameFAQs — assassin17 "Monster/Attack Stats" (bump-damage classes; tunic tables; damage classes
  for swing/spin/Pegasus charge; hardcoded knockback; i-frames vs MP damage):
  https://gamefaqs.gamespot.com/snes/588436-the-legend-of-zelda-a-link-to-the-past/faqs/39556
- GameFAQs — WWalker walkthrough (sword tiers ×2/×3/×4; tunic 50 %/75 %; spin ×2):
  https://gamefaqs.gamespot.com/snes/588436-the-legend-of-zelda-a-link-to-the-past/faqs/12595
- LiveSplit.LinkToThePast RAM map (movement speed setting `$7E005E`, modifier `$7E0057`):
  https://github.com/mabako/LiveSplit.LinkToThePast/blob/master/notes/RAM_Map.txt
- Ars Technica — LTTP reverse-engineered PC port (≈80k lines of C; Spannerisms / Snesrev) — the
  best future source for exact frame values:
  https://arstechnica.com/gaming/2023/02/link-to-the-past-reverse-engineered-pc-port-improves-all-the-right-things
- RetroMechanics — "Hit Stun i-frames" (LTTP listed as a canonical user; Godot Timer/Tween/collision
  recipe for i-frames):
  https://retromechanics.com/mechanics/hit-stun-iframes.html
- NESDev forum — 256×224 standard resolution / 8:7 pixel aspect for SNES-era tiles:
  https://forums.nesdev.org/viewtopic.php?t=12336

*Prepared 2026-10-02. Anything marked [approx] or [verify] should be confirmed against the
disassembly (or by playtest) before it becomes a hard requirement.*

# The Bestiary — enemies, archetypes, biomes

Design companion to `00-LTTP-controls-and-feel.md`. Enemies here reuse LTTP's combat contract:
**everything deals contact damage, everything has a telegraphed tell, everything respects knockback
and i-frames.** The roster is data-driven (`godot/scripts/Bestiary.gd`), spawned by
`Spawner.gd` from the run seed.

## Design pillars

1. **The tell is the game.** Every attacker flashes, recoils, or winds up before it hurts you. LTTP's
   fairness is that you can *read* it; a random room shouldn't be able to ambush you off-screen.
2. **Biome = vocabulary.** Each biome has 4–6 enemies that ask a *different question*. Crypts ask
   "can you handle slow attrition?", Warrens ask "can you fight on webbed ground?", The Arcanum asks
   "can you dodge a laser?"
3. **Tech is a place, not a spray.** Techno-priests and laser warthogs live in **The Arcanum**. One or
   two "leak" outward at high depth as elites — they stay special because they're rare.
4. **Zombies where they make sense.** Undead appear in Crypts (classic), Glacier Barrow (frozen
   thralls), Sunken Ruins (the drowned), and The Arcanum (servitors raised by priests). **Not** in
   the living forest.
5. **Depth escalates, not stats alone.** Deeper rooms add *new combinations* (a Turret behind a
   Swarm, a Summoner with a Charger escort), not just +HP.

## Archetype vocabulary (the AI behaviors)

| Archetype | Behaviour | Player answer |
|---|---|---|
| **PATROL** | Walks a fixed/bouncing path, contact damage | Read the path, cut through |
| **CHASE** | Pursues once you enter its aggro radius | Back off or spin-attack |
| **CHARGER** | Winds up (flash/recoil) → dashes in a straight line | Step aside, punish the wall-bonk |
| **TURRET** | Stationary, fires projectiles on a timer | Break line of sight, close the gap |
| **LOBBER** | Fires arcing shots over obstacles | Keep moving, don't hide behind cover |
| **JUMPER** | Hops toward you in bursts | Time the space between hops |
| **SWARM** | Weak, fast, arrives in numbers | Spin attack, corridor choke |
| **PHASE** | Blinks in/out, briefly invulnerable | Hit only in the solid window |
| **SUMMONER** | Raises minions / shields itself | Kill it *first*, or drown |

---

## Biome 1 — **Hollow Crypts** *(undead, cold torchlight, bones)*
*Question: can you handle slow attrition and things that refuse to stay dead?*

| Enemy | Arch | Role | Gimmick |
|---|---|---|---|
| **Rotting Shambler** | PATROL | Fodder zombie | Slow; **Bloater** variant erupts in a poison puff on death |
| **Crypt Ghoul** | CHASE | Rusher | Lunges when adjacent; fast for undead |
| **Bone Rattler** | JUMPER | Skeleton | Hops at you; **throws a rib** on landing |
| **Grave Warden** | CHARGER | Armored | Wind-up then shield-charge; frontal attacks bounce |
| **Choir Wraith** | PHASE | Harasser | Blinks around, drains a half-heart per touch |

**Boss — The Grave Sovereign:** SUMMONER. Kneels for ~2 s channeling, then slams the floor and
raises 3–4 Shamblers. Only damageable in the "standing" window between raises. Escort: two Wardens.

## Biome 2 — **Silkfall Warrens** *(spiders, webs, hanging silk)*
*Question: can you fight when the floor fights back?*

| Enemy | Arch | Role | Gimmick |
|---|---|---|---|
| **Web Skitterer** | SWARM | Fodder | Fast, fragile, 3–6 at a time |
| **Silk Spitter** | TURRET | Controller | Spits web globs → **slows you for ~2 s** |
| **Duskweaver** | CHASE | Hunter | Leaves a **web trail** behind it |
| **Trapdoor Lurker** | CHARGER | Ambusher | Disguised as floor tile; bursts and lunges |
| **Broodmother** | SUMMONER | Spawner | Lays egg sacs that hatch Skitterers |

**Hazard:** web tiles slow movement (biome-wide). Boomerang/fire clears them.
**Boss — The Weaver Queen:** TURRET boss. Anchored to the ceiling; cycles
web-spray → egg-drop → **descend-and-slash** when its silk is cut.

## Biome 3 — **Thornwild** *(living forest — no undead here)*
*Question: can you read a telegraph at speed?*

| Enemy | Arch | Role | Gimmick |
|---|---|---|---|
| **Horned Boar** | CHARGER | Bruiser | Long, obvious charge telegraph; breaks pots/grass on the way |
| **Spriggan** | PATROL | Ambusher | Disguised as a bush; uproots when you pass |
| **Wisp Swarm** | SWARM | Zoner | Orbs of light; drift toward you slowly |
| **Bark Treant** | LOBBER | Anchor | Roots in place, lobs acorns over cover |
| **Dire Wolf** | CHASE | Pack hunter | Spawns in 2–3; circles before committing |

**Boss — Root-Mother:** LOBBER/SWARM boss. Hurls seed-bombs that bloom into Wisp Swarms you must
clear before the next volley.

## Biome 4 — **Emberdeep** *(volcanic, fire, obsidian)*
*Question: can you manage a floor that burns?*

| Enemy | Arch | Role | Gimmick |
|---|---|---|---|
| **Cinder Imp** | JUMPER | Fodder | Hops, leaves a small fire patch |
| **Magma Hound** | CHASE | Rusher | Leaves a **burning trail**; weak to ice |
| **Ember Bat** | SWARM | Swarmer | Fast, erratic, dive-bombs |
| **Obsidian Golem** | CHARGER | Tank | Huge hit, slow wind-up; **splits when killed by fire** |
| **Lava Slime** | PATROL | Attrition | **Splits into two smaller slimes** when struck |

**Hazard:** lava tiles (instant chip damage). **Boss — The Forge Tyrant:** CHARGER boss with a
hammer; slams create shockwave rings; cooling vents open to damage it.

## Biome 5 — **Glacier Barrow** *(frost, frozen dead)*
*Question: can you fight something that's already dead and frozen?*

| Enemy | Arch | Role | Gimmick |
|---|---|---|---|
| **Frozen Thrall** | PATROL | **Zombie (frozen)** | Slow, tanky; **shatters on death** into ice shards |
| **Rime Skitterer** | SWARM | Icy spiders | Slows you on contact |
| **Ice Basilisk** | TURRET | Zoner | Gaze beam → **freezes you for ~1 s** (not damage — control) |
| **Snow Wraith** | PHASE | Harasser | Blinks through snowdrifts |
| **Yeti** | CHARGER | Bruiser | Grabs and throws you if it connects |

**Hazard:** ice tiles (slippery — no friction). **Boss — Frostmaw:** PHASE boss; breathes a cone of
frost that **turns floor tiles to ice**, reshaping the arena each volley.

## Biome 6 — **Sunken Ruins** *(drowned halls, shallow water)*
*Question: can you fight while the water drags you down?*

| Enemy | Arch | Role | Gimmick |
|---|---|---|---|
| **Drowned Servant** | PATROL | **Zombie (drowned)** | Wades toward you; pulls you in on contact |
| **Barbed Eel** | CHARGER | Lurker | Bursts from water; fast, erratic lunge |
| **Jelly Drift** | SWARM | Floater | Drifts; **zaps in a small ring** periodically |
| **Undertow Crab** | PATROL | Anchor | Heavy pincer; blocks hallways |
| **Siren Wisp** | SUMMONER | Controller | Calls Drowned Servants from off-screen |

**Hazard:** deep-water tiles (you need Zora's Flippers to cross; without them it's a wall).
**Boss — The Tidebound:** SUMMONER boss; floods the arena in stages, each stage raising more drowned.

## Biome 7 — **The Arcanum** *(techno-sanctum — techno-priests & laser warthogs)*
*Question: can you dodge a laser and kill the thing keeping everyone alive?*

| Enemy | Arch | Role | Gimmick |
|---|---|---|---|
| **Techno-Priest** | SUMMONER | Anchor elite | Hovers, channels a **shield** (invulnerable while channeling); raises **Servitors** (tech-zombies) and buffs nearby machines |
| **Laser Warthog** | CHARGER | Signature | Winds up, **charges in a straight line trailing a laser beam**; the beam persists ~1 s after it stops |
| **Arcane Sentinel** | TURRET | Zoner | Eyeball drone; fires a **telegraphed aiming laser** before the shot |
| **Clockwork Golem** | PATROL | Tank | Mechanical zombie-analogue; **cranks back to life once** after death |
| **Mana Elemental** | PHASE | Harasser | Pure magic; only vulnerable between blinks |
| **Cyber Specter** | CHASE | Rusher | Phases through walls, then solidifies to strike |
| **Rave Punk** | SWARM | Fodder | Neon glowstick maniac; dances in erratic arcs toward you |
| **Bassline Bruiser** | CHARGER | Zoner | Winds up then **drops a radial "bass" shockwave ring** of shots |
| **Strobe DJ** | TURRET | Controller | Stationary deck; **strobe beam** + **summons Rave Punks** off the crowd |
| **Mosh Pit King** | CHARGER | Elite | Heavy; body-checks, then drops a **10-shot mosh ring** |

**Raver techno punks (the crew).** A themed sub-faction of The Arcanum: neon drones, glowsticks, bass,
and strobe. They fight like a warehouse party — the **Rave Punks** swarm and weave, the
**Bassline Bruiser** punctuates with a radial "drop" every few seconds, and the **Strobe DJ** holds a
corner, flashing a beam while **summoning more punks** from the crowd. The **Mosh Pit King** is the
elite: a crowd-crush that ends in a ten-shot ring. Answer them like any swarm — spin-attack the pile,
kill the DJ *first* so the crowd stops growing, and don't stand still through a drop.
*(Cosmetic: Strobe DJs flash-tint; a "blind" status that dims the screen is designed, not built.)*

**Boss — The Ordinator:** SUMMONER/CHARGER boss. Channels a shield from a raised dais while two
**Laser Warthogs** patrol. Break the three power pylons around the arena to drop the shield; the
Warthogs get faster each phase.

**The "leak" rule:** at **depth ≥ 5**, a rare **Techno-Priest** or **Laser Warthog** may appear in
any biome as a *corrupted elite* — this is how the techno threat spreads, and why it stays scary.

---

## Global / anywhere

| Enemy | Arch | Notes |
|---|---|---|
| **Cave Keese** | SWARM | The LTTP bat: erratic, everywhere, low damage |
| **Rat King** | SWARM | Dungeon vermin; flees when alone, swarms in numbers |
| **Mad Hermit** | CHASE (ranged) | *Rare spawn, any biome.* A shotgun-toting recluse who's been down here too long — shuffles after you, then **lets off both barrels in a 5-shot spread**. Human, so he counts as an enemy of the dungeon like anything else. Telegraph: a loud *click-clack* and a 0.4 s pause before each volley. |

## Conventions (code contract)

- **HP** is measured in *sword hits at base damage* (Fighter's = 1). Spin = 2. So `hp` of 3 = three
  plain swings, or two with one spin.
- **dmg** is in the game's damage units — **8 units = 1 heart** (LTTP's own table). `dmg: 2` = a
  quarter-heart bump.
- **speed** in px/s, tuned around the player's `WALK_SPEED` (96).
- Every enemy sets: `arch`, `hp`, `dmg`, `speed`, `color`, optional `ranged` block, `aggro` radius,
  `tags` (e.g. `["undead"]`, `["machine"]`, `["boss"]`), and `elite_at_depth`.
- **Weaknesses** are tags, not hardcoded: ice kills Obsidian Golem, fire pops Lava Slime, bombs crack
  Warden shields.

## Spawn rules (how the generator uses this)

1. Every room gets a **biome** from the depth track (Crypts → Warrens → Thornwild → Emberdeep →
   Glacier → Sunken → Arcanum), so the run has a *route* through the world, not a shuffle.
2. `Spawner.pick(room, seed)` draws 0–N enemies weighted by archetype, biasing:
   - **SWARM/CHASE** in wide rooms, **TURRET/LOBBER** in rooms with cover, **CHARGER** in corridors.
   - **Exactly one SUMMONER max per room**, and never in the first room of a run.
3. **Boss room** = the exit room, one boss + fixed escort.
4. Re-roll via the run seed — same seed, same bestiary.

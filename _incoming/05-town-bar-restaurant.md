# Vigil, the Last Town — hub, NPCs, the Bar, the Restaurant, and the Ruined Vigil

**Context for Kiro:** this specifies the **between-run town hub** for the top-down, A-Link-to-the-Past
style roguelike. The town is where the player rests, spends **Sparks**, learns **rumors**, and
prepares for the next dungeon. The town already has a **bar**; this document **adds a restaurant**
beside it. Build to the project's spec workflow (user stories + **EARS** acceptance criteria,
feel numbers as config).

---

## 1. Purpose of the town

A run begins in Vigil and ends in Vigil — whether you cleared the dungeon or died in it. Between
runs the player:

- spends **Sparks** on buffs, consumables and upgrades;
- buys **buffs** at the **bar** (short, cheap, informative) and at the **restaurant** (long, warm,
  restorative);
- picks the next dungeon from **the Board**;
- locks in unlocks at the **Chapel of Small Mercies** (Attunement, per `02`).

The town should feel like the *only* warm place left — melancholy, but not hostile. It is the game's
breathing room.

## 2. Town map (buildings)

| Building | Purpose | State |
|---|---|---|
| **The Last Call** | The bar — drinks + rumors | existing |
| **The Warm Machine** | The restaurant — meals, healing, run-long buffs | **NEW (this doc)** |
| The Forge | weapon / armour upgrades (sword tiers, mail) | existing |
| The Apothecary | potions, fairies, arrows, bombs | existing |
| The Chapel of Small Mercies | Attunement shrine — lock in unlocks | existing |
| The Board | choose the next dungeon (shows its rank + a hint) | existing |
| The Pawnbroker | sell loot you didn't claim | existing |

## 3. The Bar — "The Last Call" *(existing)*

A dim room with one neon sign half-dead in the window. **Marrow**, the barkeep, is a decommissioned
android pouring drinks it can no longer taste, and it remembers everyone who used to drink here.

**Drinks** are cheap and instant. Each grants a **short buff (this run, a few rooms)** and, often, a
**Rumor**. One drink per visit.

| Drink | Sparks | Effect (short) | Flavor |
|---|---|---|---|
| Rusted Stout | 5 | +1 temporary heart | *Tastes like a memory of rain.* |
| Static Sour | 8 | +20 % move speed for 5 rooms | *The fizz is a frequency nobody broadcasts on anymore.* |
| The Long Pour | 12 | Reveals a **Rumor** about the next dungeon | *Marrow talks when it pours. It always has.* |
| Numb | 10 | Longer i-frames for 5 rooms | *You won't feel the next few, dear.* |
| Ghost-Pepper Shine | 14 | Your fire attacks burn hotter (bigger cone) | *Burns twice: going down, and coming back up.* |

**Rumors** (bar only): the bartender hints at the next dungeon — a hazard ("frost floor; watch your
step"), a gate you'll need, or the boss's tell ("it's winded after it breathes — that's your moment").
Rumors are **partial and true**; they never spoil the whole dungeon.

## 4. The Restaurant — "The Warm Machine" *(NEW)*

Right next door, warmer, louder. **Ash** runs it — a cook working from a recipe book belonging to
people who are no longer around. She feeds you like it matters, because to her it does.

**Meals** cost more, take a moment (you sit and eat — a short cutscene), and grant a **run-long
buff**, plus a **full heal**. One meal per visit.

| Dish | Sparks | Effect (run-long) | Flavor |
|---|---|---|---|
| The Last Supper | 25 | **Full heal** + +1 max heart this run | *She sets an extra place. She always does.* |
| Widow's Broth | 18 | **Regenerate** one heart every 10 rooms | *Simmered for people who kept waiting at the door.* |
| Hearth Plate | 22 | −25 % damage taken this run (stacks with Mail) | *Home, if home were a plate.* |
| Don't Ask What It Is | 30 | One **random big buff** (+speed, +damage, +luck…) | *Best meal in Vigil. Do not ask.* |
| Bitter Greens | 12 | +25 % Sparks from this run | *Grows in the ash. So did everyone here.* |
| Something Sweet | 20 | Restores and **doubles** your magic meter this run | *Dessert is a small mercy. Take it.* |

**How it differs from the bar (this is the point):**

| | Bar (The Last Call) | Restaurant (The Warm Machine) |
|---|---|---|
| Cost | cheap | pricier |
| Duration | short (few rooms) | the **whole run** |
| Heals? | no | **yes (full + regen)** |
| Value | **information** (rumors) | **sustain** (health + long buffs) |
| Ritual | *drink to learn* | *eat to prepare* |

Only **one drink and one meal per town visit**. You cannot stack two of the same kind — one food buff,
one drink buff. The player's town ritual becomes: *drink to hear what's coming, eat to survive it.*

## 5. Economy

- **Sparks (⚡)** are dropped by enemies and bosses; drop size scales with **dungeon rank** and depth.
- Base prices above scale with rank (×`1 + rank×0.05`).
- The Pawnbroker converts unclaimed loot to Sparks; the Forge/Apothecary spend them.
- Dying still returns you to Vigil — but you lost the **Sparks you hadn't banked** this run (banking
  happens on a clear). *(Decision point: exact banking rule — see open questions.)*

## 6. Tie to the Attunement loop (per `02`)

- Clearing a dungeon **banks** your Sparks and **Attunes** your carried ATTACK/UTILITY items.
- The restaurant's run-long buffs are **not** Attuned — they're bought fresh each visit.
- This keeps town purchases meaningful forever, while unlocks remain the long-term progression.

## 7. Kiro requirements (draft — expand with user stories + EARS)

- **REQ-TOWN-001** — WHEN a run ends (clear *or* death) THE SYSTEM SHALL return the player to Vigil
  with all purchases reset for that visit and the attuned set intact.
- **REQ-TOWN-002** — The town SHALL contain the bar **The Last Call** and the restaurant
  **The Warm Machine**, both enterable.
- **REQ-TOWN-003** — WHILE in the bar, the player SHALL be able to buy at most **one drink**, which
  grants a short buff and (for some drinks) a Rumor.
- **REQ-TOWN-004** — WHILE in the restaurant, the player SHALL be able to buy at most **one meal**,
  which fully heals and grants a **run-long** buff.
- **REQ-TOWN-005** — The system SHALL NOT allow a second food buff or a second drink buff to be active
  at once.
- **REQ-TOWN-006** — Rumor text SHALL be drawn from the next dungeon's real generation (hazard / gate /
  boss tell) and be truthful but partial.
- **REQ-TOWN-007** — Prices SHALL scale with the rank of the player's **next** dungeon.
- **REQ-TOWN-008** — IF the player cannot afford an item THEN the system SHALL show the price and
  dim the purchase option.
- **REQ-TOWN-009** — The Board SHALL show the next dungeon's rank and one hint; the Chapel SHALL
  display the current Attuned set.
- **REQ-TOWN-010** — Town buffs SHALL persist only within the run they were bought for; they shall
  not be Attuned.
- **REQ-NPC-001** — The town SHALL be populated mostly by **simulacra** — broken computer
  representations of people — that loop, glitch, freeze, and cite memories that never happened. The
  game SHALL never fully confirm or deny whether any given NPC is real.
- **REQ-NPC-002** — **Real humans** SHALL be encounterable out in the dungeons/adventures. Leading one
  back to Vigil SHALL grant them a **persistent town role** (a new shopkeeper, patron, or friend).
- **REQ-NPC-003** — Simulacra SHALL glitch *mechanically* (tiny loops, dropped frames, repeated
  lines); real humans SHALL glitch *emotionally* (panic, wrong jokes, tears) — the tell, but never
  proof.
- **REQ-RUIN-001** — A **Ruined Vigil** dungeon variant SHALL mirror the town map street-for-street,
  with **zombified versions of the same NPCs** (Zombie Marrow still pouring nothing; Zombie Ash's
  special is you).
- **REQ-RUIN-002** — The Ruined Vigil SHALL reuse the **Crypts** undead roster (Shambler/Ghoul/
  Warden/Bloater), reskinned to the town's characters and silhouette.
- **REQ-RUIN-003** — The game SHALL leave ambiguous whether the Ruined Vigil is the town's corrupted
  past, its future, or the originals the simulacra were copied from.

## 8. Code hooks

- `Town.gd` — the hub scene: buildings, entry points, the return-to-town flow.
- `Buff.gd` — a timed/run-scoped buff object (`stat`, `amount`, `duration_rooms` or `run_long`).
- `TownStock.gd` — data tables for **drinks** and **meals** (mirror `Items.gd`'s data-driven style).
- `Rumors.gd` — reads the *already generated* next dungeon and emits a truthful, partial hint.
- `Wallet.gd` (or fold into `Game.gd`) — Sparks balance, banking on clear.
- Integration: `Game.complete_run()` → bank Sparks → return to Vigil; `Game.damage_player()` reaching 0
  → return to Vigil (run's unbanked Sparks lost).

## 9. Mood / naming

Vigil is **sad fantasy fused with techno-future**, like everything in this world: neon half-dead,
andoids remembering, a cook feeding ghosts. The bar and the restaurant are the same warmth in two
languages — **a drink and a meal in the last warm room before the dark**. Keep the names: **The Last
Call**, **The Warm Machine**, keep **Marrow** (barkeep) and **Ash** (cook).

## 10. The people of Vigil — and what they really are

There are two kinds of "people" in this world, and the game never tells you which is which:

- **Simulacra (most of the town).** Broken computer representations of people who once were. They run
  routines, loop, repeat themselves, freeze mid-sentence, reboot, and cite memories that never
  happened — *"remember when we…"* of a thing that never was. They are kind, warm, familiar, and
  **almost** human, which is worse. They do not know they are not real. **Marrow** the barkeep is a
  simulacrum. Whether **Ash** is one is deliberately left open.
- **The real few (rare).** Actual surviving humans you meet **out in your adventures** — in dungeons,
  on ledges, at the edges of the dark. They improvise, get scared, change their minds, say things no
  script would write. You can **lead them back to Vigil**, where they take up a persistent role — a
  shopkeeper, a patron, a friend. Losing one hurts precisely because they were the only real thing.

**The tell, never the proof:** simulacra glitch *mechanically* (a frame drop, a looped line, a light
that flickers in time with their speech); real humans glitch *emotionally* (panic, a joke that lands
wrong, tears at the wrong moment). The player is always *suspicious*, never *certain*. Vigil is a
genuinely nice place — and that is exactly what makes the unease work.

## 11. The Ruined Vigil — the same town, and everyone is hungry

The mirror. **The same town, street for street** — the same bar, the same restaurant, the same
half-dead neon sign — except the warmth is gone and **everyone is a zombie that wants to eat your
brains**.

- Entered as a **dungeon variant**: a recurring mirror run (or a biome) laid out identically to
  Vigil.
- The NPCs are **the same characters, zombified**: *Zombie Marrow* still tends the bar, pouring
  nothing for no one; *Zombie Ash* still "cooks," and tonight's special is you.
- Because the town's people are **broken computer representations**, the haunting is baked in: are
  these the **corrupted originals** the simulacra were copied from — or the simulacra themselves,
  degraded past the point of pretending? **Leave it ambiguous.**
- Mechanically it reuses the **Crypts** undead (Shambler, Bloater, Ghoul, Bone Rattler, Grave Warden),
  dressed in the town's silhouette. A natural boss: the zombified **barkeep** or **cook**.
- This is the candle at the centre of the whole game: **the nice town and the ruined town are the
  same town.** Which one is real is the question.

## 12. Open questions for the design pass

1. Are town visits **free-form** (walk around, enter any building) or a **menu** between runs?
2. Does the restaurant's "sit and eat" cutscene pause for a beat, or is it instant?
3. Banking rule: are Sparks kept on death (safe) or lost (risky)? Pick one.
4. Can the bar and restaurant be upgraded over time (more dishes unlocked by clearing dungeons)?
5. Is there a **third** food-adjacent building planned (a night market, a soup kitchen) — or keep the
   town tight at bar + restaurant?

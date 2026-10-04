# Kiro Prompt — LTTP-style Roguelike (Godot 4)

**How to use:** open your repo in Kiro, attach `00-LTTP-controls-and-feel.md` as context, paste the
prompt below into the spec chat, and let Kiro produce `requirements.md`. Answer its open questions,
then have it generate `design.md` and `tasks.md`.

---

## Prompt (paste verbatim)

> You are helping me specify a game. Use the attached reference document
> **"How A Link to the Past (LTTP) controls and feels"** as the authoritative description of the
> target game feel. We are building a **top-down, LTTP-style roguelike in Godot 4 (GDScript)**.
>
> Produce a **`requirements.md`** in Kiro's spec-driven format.
>
> **In scope (one playable run):**
> - Procedurally generated dungeon: rooms on a **32 px tile grid**, screen-sized rooms
>   (16 × 14 tiles) connected by a generated door graph.
> - **8-directional movement** over the tile grid, with edge-snapping so 1-tile doorways feel clean.
> - **One-button context interaction** (LTTP's A button): lift/throw/pull/push, talk, open chests,
>   swim — resolved by what the player is next to / holding.
> - **Melee sword combat**: swing, **hold ~2 s → charged Spin Attack (≈×2 damage)**, sword beams at
>   full health (Master Sword+).
> - **Contact damage + knockback + invincibility frames + passive facing-based shield** — the four
>   systems that together make LTTP's "joust" combat read right. Do not omit any of them.
> - **Item pool placed by gated generation** so every generated run is completable (a reachability
>   check must pass before a run starts).
> - **Depth-based difficulty scaling**.
> - **Seeded RNG** with a visible, shareable seed; same seed ⇒ same dungeon, loot and enemies.
> - **Permadeath** (one life per run).
>
> **Out of scope — state this explicitly in the doc:**
> - The original's fixed overworld, fixed story, and fixed item-gate progression.
> - Mid-run saves.
> - Any distribution of Nintendo assets; all art/audio are original placeholders.
>
> **Requirements format:**
> - For every requirement, write a **user story** ("As a …, I want …, so that …") **plus EARS
>   acceptance criteria** ("WHEN … THE SYSTEM SHALL …", "IF … THEN …", "WHILE …", "WHERE …").
> - Group requirements by system: Input&Control, Movement, Combat, Interaction, Items, Generation,
>   Progression/Difficulty, Run&Death, RNG/Seeding, UI/HUD, Save/Meta.
> - Give each requirement a stable ID (e.g. `REQ-COMBAT-003`) so the design and tasks can reference it.
> - **Encode every "feel" number from the reference as a configurable value, not a hardcoded
>   constant**, and carry the reference's confidence flags through: exact values vs `[approx]` /
>   `[verify]`. List these under a `Tunables` section.
>
> **Before writing the design**, ask me to decide the following open questions (the reference §7):
> 1. Run length / scope (target minutes, number of rooms/depth).
> 2. Meta-progression: none, unlocks, or currency between runs?
> 3. Gating model: keys/per-run gates, or all items available from the start?
> 4. Pause scope: does the inventory pause the world (LTTP-style) — and is there any mid-run save?
> 5. Death/respawn UX and whether any state persists.
> 6. Diagonal movement: keep LTTP's diagonal-is-faster quirk, or normalize it?
>
> Once I answer, generate **`design.md`** (Godot 4 architecture: node types, autoloads, state
> machines, generation pipeline, seeded RNG threading) and then **`tasks.md`** (ordered,
> independently testable tasks). There is a starter scaffold under `godot/` in this repo — align the
> design and tasks with its structure, and list what to replace vs. keep.

---

## Open-questions quick-answer sheet (fill in, then reply to Kiro)

| # | Decision | My answer |
|---|---|---|
| 1 | Run length (minutes / depth) | |
| 2 | Meta-progression | |
| 3 | Gating model | |
| 4 | Pause scope / mid-run save | |
| 5 | Death & respawn UX | |
| 6 | Diagonal speed: authentic-fast vs normalized | |

## Notes

- Keep the six-input map (move, sword, action, item, map, inventory). Resist adding buttons — the
  LTTP feel partly comes from one context button.
- The "feel" is the *interaction* of short sword reach + contact damage + knockback + i-frames +
  screen lock. If you ship the systems but hand-wave the numbers, it won't feel like LTTP.
- Mark anything the reference flags `[approx]`/`[verify]` as *to be confirmed against the
  disassembly or by playtest* — do not silently promote it to a hard requirement.

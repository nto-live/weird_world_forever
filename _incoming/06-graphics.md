# Reference: Graphics & Art Direction

**Purpose of this document.** This is the art-direction reference for the LTTP-style procedural
roguelike built in **Godot 4 (GDScript)**. It is written to be dropped into **Kiro** as context so the
graphics system is designed as a first-class citizen alongside combat, generation, and economy. It
pins the visual style, the pixel canvas and scaling, sprite/tile sizes, the per-biome tileset and
palette plan, animation needs, VFX, lighting, UI, and the asset pipeline — and it captures the
locked decisions and the deferred ones.

It is deliberately split into:
1. **Art direction** — the style and the mood.
2. **Resolution / scale / sizes** — the locked pixel canvas and sprite dimensions.
3. **Player character.**
4. **Biome tilesets.**
5. **Enemies & bosses sprite needs.**
6. **VFX / lighting / UI.**
7. **Pipeline & tools.**
8. **Decisions** (what is locked, what is deferred).
9. **Deliverables.**
10. **What the code does** (placeholder generator + swap-in).
11. **AI-assisted art notes.**
12. **Provided sprite references.**

Anything not yet decided is marked **[verify]**; locked decisions are marked **LOCKED**.

---

## 1. Art direction

**Style: modern HD pixel art — "16-bit, but more advanced."**

The game keeps the honesty of real 16-bit pixel art and adds a modern rendering layer on top. It is
*not* faux-retro with fake scanlines slapped over high-res art, and it is *not* HD-2D (that is parked;
see Decisions). It is a true pixel grid, drawn clean, then lit and composited with contemporary 2D
techniques.

**Keep (16-bit honesty):**
- A real, visible pixel grid. Every sprite and tile is authored at native resolution.
- Integer world positions for rendering; nearest-neighbour sampling; **no runtime rotation or
  scaling of sprites** (rotation/scale is faked with authored frames, as the SNES did).
- Strong, readable silhouettes — a character or enemy must be identifiable as a black shape.
- 16×16 tiles.
- Deliberate, limited colour ramps per material so forms read as pixel art, not smeared gradients.

**Add (modern features):**
- Unlimited colours per sprite, with smooth ramps and **selective dithering** (dithering is a
  deliberate texture choice, not a palette-count workaround).
- **Dynamic 2D lighting** (Light2D / normal-less lit sprites, point and directional lights, shadows
  where cheap).
- **Particles** (GPUParticles2D / CPUParticles2D) for VFX, ambient motes, embers, frost.
- **Parallax** backgrounds for depth.
- **Animated tiles** (water, lava, machinery, flora).
- **Shader-driven water and fire** (scrolling UV, palette-cycling, displacement).
- **Selective bloom** — only emissive pixels (neon, lava, magic) bloom; the base art stays crisp.
- **Optional CRT filter** — a post toggle for players who want it; off by default.

**Mood: sad fantasy fused with techno-future.** Cold neon against warm decay. Every biome should read
as simultaneously *beautiful and grieving* — a dying world lit by machines that outlived their makers.
Warm, failing organic light (torch, hearth, rot-glow) sits against cold synthetic light (neon, holo,
coolant). The contrast is the whole look.

---

## 2. Resolution / scale / sizes

### Canvas — **LOCKED**

- **Base pixel canvas: 320×224** (20×14 tiles at 16 px). **LOCKED.**
- Tile size: **16×16**. **LOCKED.**
- A room is **20×14 tiles** as its logical generation grid.
- **Integer scaling only** — nearest filter, `canvas_items` stretch mode, **keep** aspect, `integer`
  scale mode. No fractional scaling, ever. **LOCKED.**
- Scale targets:
  - **1440p at ×6 = 1920×1344** (letter/pillar-boxed inside a 2560×1440 window). Primary target.
  - **×5 = 1600×1120** fallback for smaller displays.
- The camera is **free-scrolling** across the dungeon (see §camera below); the 320×224 canvas is the
  *viewport*, not a room-lock. Rooms are the generation/collision unit, not screen frames.

### Camera — **LOCKED (free-scroll)**

- A single `Camera2D` rig follows the Player smoothly across the whole dungeon.
- Position smoothing (lerp) with a configurable speed; optional soft look-ahead in the facing
  direction.
- Camera limits clamp to the stitched bounds of the contiguous explored/active region so the view
  never shows outside the generated space.
- **No hard room-to-room screen snaps.** Contiguous rooms are stitched into one continuous space;
  the player walks seamlessly between them while generation, collision, and reachability still work
  per-room under the hood.

### Sprite sizes

| Asset | Size (px) |
|---|---|
| Player | 16×24 |
| Enemies | 16 / 24 / 32 / 48 (by class) |
| Bosses | 64 / 96 / 128+ |
| UI icons | 8 / 16 |
| Font | 8×8 or 16×16 |

---

## 3. Player character

- Size **16×24**.
- Starter outfit (default design): **white shirt, brown shorts, barefoot** — a "sad-but-trying" look.
  Poor, under-equipped, stubborn. This is the *default* player; see §12 for provided NPC/enemy
  reference sprites.
- 4-directional sprite set.
- Animation sets (clips): **idle, walk, attack, charge, spin, hurt, dash, lift-carry, swim, death,
  push-pull** — all 4-direction where it matters.
- Equipment tiers (sword/mail/shield) should be expressible as palette or overlay swaps so upgrades
  read visually without a full re-draw.

---

## 4. Biome tilesets

Each of the 7 biomes gets a tileset with:
- **Floor**: 3–5 variants.
- **Wall**: 2–3 variants **plus a top face** (for the 3/4 overhead look).
- **Autotile**: corners/edges (Godot TileSet terrains).
- **Door / threshold** tiles.
- **Animated hazards** (per biome: lava, spikes, coolant, thorns, etc.).
- **Decorations**: 4–8 per biome.
- **Lights**: 2–4 emissive/light-source tiles per biome.
- **Transitions** between adjacent biome floors.
- **One signature prop** per biome (a memorable landmark object that sells the mood).

### Palettes (per biome)

| Biome | Palette | Notes |
|---|---|---|
| Hollow Crypts | desaturated blue-grey | cold stone, dead light |
| Silkfall Warrens | muted violet/brown | web, chitin, rot |
| Thornwild | warm green/ochre | overgrown, choking life |
| Emberdeep | black/orange, **strong bloom** | lava, forge-glow |
| Glacier Barrow | cyan/white, **low contrast** | keep **enemies warm-toned** so they pop against the ice |
| Sunken Ruins | teal/verdant | drowned tech, algae |
| The Arcanum | deep violet + cyan/magenta **neon** | synthetic, holographic, final |

---

## 5. Enemies & bosses sprite needs

### Enemies
- Sizes 16 / 24 / 32 / 48 by class.
- Animation sets: **idle, walk, attack, hurt, death**.
- **Chargers get a distinct telegraph frame** — this is gameplay-critical (fairness: every harmful
  action telegraphs first; ties to the charger wind-up property).
- **Raver punks** get a **dance/wobble idle loop**.
- Enemies are **data-driven**: one base sheet (one silhouette) can back several archetype variants via
  the bestiary. A creature family (e.g. a frog/toad) reuses one sheet across JUMPER / CHASE / LOBBER /
  SWARM behaviours with palette/behaviour differences.

### Bosses
- Sizes 64 / 96 / 128+.
- Animation sets: **idle, telegraph, 1–3 attacks, hurt, phase-transition, death**.
- Optional **name-card portrait** on introduction.

---

## 6. VFX / lighting / UI

### VFX list
Sword arc, spin ring, hit spark, per-biome **ichor** (blood/sap/coolant by biome), projectile trails,
bomb burst, magic, dust, splash, frost, laser impact.

### Lighting (per biome)
Torch (warm), lava red-orange (Emberdeep), frost cyan (Glacier), neon magenta/cyan (Arcanum). Lights
are dynamic 2D lights; emissive pixels feed selective bloom.

### UI
- **Hearts** with the **evolving health icon**: leaf → yellow star → rainbow star (progression tiers).
- Magic meter.
- Item box (equipped item).
- Map.
- Boss HP bar.
- Menus (paused), dialogue box.
- **One pixel font** (8×8 or 16×16).

---

## 7. Pipeline & tools

- **Authoring tools**: Aseprite / LibreSprite / **Pixelorama** (Godot-native, free).
- **Export**: PNG sprite sheets (+ optional JSON atlas).
- **Godot import**: nearest filter; `AnimatedSprite2D` + `SpriteFrames` for characters; `TileSet` with
  terrains for tilesets; wall collision shapes; hazard `Area2D`.
- **Folder layout:**

```
res://art/
  characters/              # player, human NPCs, simulacra
  enemies/<biome>/         # per-biome enemy sheets
  bosses/                  # boss sheets + name-card portraits
  tilesets/<biome>/        # floor/wall/door/hazard/deco/light/transition
  vfx/                     # sword arc, sparks, ichor, bursts, trails, frost, splash
  ui/                      # hearts/health icon, magic meter, item box, map, boss bar, font
```

---

## 8. Decisions

- **Canvas 320×224 (20×14 tiles @ 16 px): LOCKED.** Supersedes any earlier 256×224 / 16×14 assumption.
- **Integer scaling only, nearest, keep aspect, integer mode: LOCKED.** Targets 1440p ×6 = 1920×1344,
  ×5 = 1600×1120 fallback.
- **Free-scrolling camera everywhere: LOCKED.** Rooms are the generation/collision/reachability unit
  only (door graph, biome route, gates unchanged). No hard room-to-room snaps.
- **Graphics v1 feature set: dynamic 2D lighting + particles + shader water/fire + selective bloom +
  parallax backgrounds.**
- **Deferred / parked:** normal maps and HD-2D. Not in v1.
- **Style: modern HD pixel art ("16-bit but more advanced").**
- **Mood: sad fantasy + techno-future; cold neon vs warm decay.**

---

## 9. Deliverables

- Per-biome tilesets (7 biomes) with the full tile set listed in §4.
- Player sheet (16×24) with all clips in §3.
- Enemy sheets (data-driven, reusable creature families) with clips in §5; charger telegraph frame.
- Boss sheets (64/96/128+) with clips in §5; optional name-card portraits.
- VFX sheets (§6).
- UI set including the evolving health icon, magic meter, item box, map, boss HP bar, menus,
  dialogue, one pixel font.
- Lighting setup per biome.
- Palettes per biome (§4).

---

## 10. What the code does

### Placeholder pipeline (now)
Until hand-authored sheets land, the game uses an **upgraded procedural placeholder-art generator** so
placeholders already look genuinely pixel-arty rather than flat polygons:
- **3-tone shading ramps** (base + highlight + shadow) per material.
- **Outlines** on sprites and props for silhouette readability.
- **Dithered gradients** for ambient surfaces.
- **One signature prop per biome** generated procedurally.

### Swap-in architecture
- All art is referenced **as data** (asset-reference ids), not hardcoded in systems. A sprite,
  tileset, palette, or animation clip is named in a data table; the renderer resolves the id to a real
  resource if present, otherwise to the procedural placeholder.
- **Clean swap-in points**: dropping a final PNG sheet + atlas at the referenced path replaces the
  placeholder **without touching gameplay code**. Missing art degrades gracefully to the placeholder
  rather than crashing.

---

## 11. AI-assisted art notes

- AI image tools may be used to draft concepts and palettes, but every shipped sprite is cleaned up
  to the native pixel grid by hand (or in Aseprite/Pixelorama) — no smeared/anti-aliased output ships.
- Keep silhouettes strong and ramps limited even when starting from an AI draft.
- AI is a drafting aid for the placeholder-to-final path, not a runtime generator.

---

## 12. Provided sprite references

Three character sprites were supplied as references. **The image files are not yet stored in the
workspace**; place them under `res://art/` at the referenced paths when available.

1. **Green frog/toad-like humanoid in red shorts** — clear outline, ~2 shading steps, mid-size.
   - Role: an **enemy in the Sunken Ruins biome**.
   - Treat as a **frog/toad creature family** sharing one silhouette, reusable across the Sunken Ruins
     archetypes (**JUMPER / CHASE / LOBBER / SWARM**) via the data-driven bestiary — one base sheet
     backing several enemy variants.
   - Target: `res://art/enemies/sunken/frogfolk.png`.

2. **Stout, bare-chested muscular man** (orange/tan tone, torn trousers) — a **Vigil townsperson /
   human NPC**. Exact town role left open (the simulacrum-vs-human ambiguity is intentional).
   - Target: `res://art/characters/npc_stout.png`.

3. **Lean bearded man in a red/brown plaid flannel shirt and dark trousers** — another **Vigil
   townsperson / human NPC**. Role left open.
   - Target: `res://art/characters/npc_flannel.png`.

**Tells.** Human NPC sprites follow the **"emotional glitch"** tell (panic, mistimed jokes, tears);
simulacra follow the **"mechanical glitch"** tell (loops, dropped frames, repeated lines). These three
provided sprites seed the NPC/enemy art set.

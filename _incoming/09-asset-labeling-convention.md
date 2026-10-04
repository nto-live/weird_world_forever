# 09 — Asset labeling & consumption convention (VIGIL)

> **Status: PRECEDENT — set 2026-10-04.** The procedural building machine is not built yet; this
> document fixes the contract it will consume so art and machine stay decoupled. Written to be
> dropped into Kiro as context. Placeholder text = `06-graphics.md` / `08-poc-asset-list-v2.md`.
> **Consumed by `10-procedural-generation-design.md`** (the machine that reads this contract).
> Anything here supersedes ad-hoc naming in earlier notes.

**Scope:** how tile/sprite art is *named, labeled, and resolved* — i.e. the interface between the
asset pak and the procedural generator (`DungeonGenerator`, `Room`, `ObjectAssembler`) and the
planned `AssetResolver` (System S).

---

## 0. The one rule

**Labels are authored; they are never inferred at runtime.** Roles come from a human (or the pack's
own atlas docs) and live in a small, versioned data file. Heuristics / vision / clustering may only
*pre-sort a review sheet* — they are never ground truth.

Corollary: the machine must run with **zero authored art** (procedural placeholders), and art swaps in
later. The contract below is what makes that swap free of code changes.

---

## 1. Principles (best practice, in priority order)

1. **Placeholder-first.** The generator emits *semantic ids* (`biome`, `role`), never filenames. If a
   resource is missing, the placeholder generator draws it. Art is additive.
2. **Small typed contract, not a big label dump.** Per biome you author ~25–35 tiles: `floor` ×3–5,
   `wall` ×2–3 + `wall_top`, a **12-piece autotile terrain**, `door`, `hazard`, `deco` ×4–8, `light`.
   You do **not** label every sprite frame in a pack.
3. **Use the engine's own mechanisms.** Godot `TileSet` **terrain sets** do the floor↔wall autotiling
   (you label *one terrain*, not 40 edge/corner tiles). Godot **custom data layers** carry the `role`
   string for tiles that aren't terrain (door/hazard/deco/light).
4. **One atlas + one manifest per biome.** Ship a single packed PNG per biome and a JSON manifest;
   the resolver builds the `TileSet` from them. (Optional: also commit the `.tres`.)
5. **Stable, opaque ids.** Ids are `<biome>.<role>.<nn>`. Source/brand names never appear in any asset
   filename or metadata (standing rule) — provenance lives in the license ledger only.
6. **Deterministic & versioned.** No global RNG; selection is seeded. The manifest is committed and
   versioned like code.
7. **Provenance in a ledger, outside the assets.** `work/asset-packs/LICENSES.md`. Never in the tree.
8. **Distribute only the typed set.** Examples/reference stay out of the shipped `res://art/`.

---

## 2. The contract

### 2.1 Layout (`res://art/`)

```
res://art/
  tilesets/<biome>/
    atlas.png              # packed sheet (32x32 cells, 16 per row)
    manifest.json          # roles -> tiles + atlas coords + terrain membership  (the contract)
    <biome>.tres           # generated Godot TileSet (terrain set + role custom-data layer)
  characters/<id>.png      # sprite sheets (SpriteFrames), id = <kind>_<name>
  objects/<id>.png         # props / decor sprites
  ui/…
  vfx/…
```

### 2.2 `manifest.json` (per biome) — the thing the machine reads

```json
{
  "schema": "vigil.tileset.manifest/1",
  "biome": "grasslands",
  "cell": 32,
  "atlas": "atlas.png",
  "roles": {
    "floor":     ["grasslands.floor.00", "grasslands.floor.01"],
    "floor_var": ["grasslands.floor.10"],
    "wall":      ["grasslands.wall.00"],
    "wall_top":  ["grasslands.wall.20"],
    "door":      ["grasslands.door.00"],
    "hazard":    ["grasslands.hazard.00"],
    "deco":      ["grasslands.deco.00", "grasslands.deco.01"],
    "light":     ["grasslands.light.00"]
  },
  "terrain": { "floor": {"terrain_set": 0, "terrain": 0},
               "wall":  {"terrain_set": 0, "terrain": 1} },
  "tiles": { "<id>": {"x": 0, "y": 0, "role": "floor", "terrain": "floor"} }
}
```

### 2.3 Godot `TileSet` (what `AssetResolver` returns)

- **One `TileSetAtlasSource`** over `atlas.png`, `texture_region_size = 32×32`.
- **Terrain set 0** = `{floor, wall}`; the 12 autotile pieces carry the correct corner peering bits
  (authored visually in the Godot editor once — the machine only *uses* them).
- **Custom data layer `role`** (String) on every tile → the resolver can query `get_custom_data("role")`.
- Everything else (door, hazard, deco, light) is placed by explicit tile coords looked up via
  `manifest.roles[role]`; collision/hazard shapes are declared as Area2D/TileSet physics when authored.

### 2.4 Resolution order (System S, Property 36)

`AssetResolver.resolve_tileset(biome)`:
1. if `res://art/tilesets/<biome>/manifest.json` (+atlas) exists → build/loot the `TileSet` from it;
2. else → procedural placeholder `TileSet` for the biome palette.

`AssetResolver.pick(biome, role, rng)` → a tile coord from `manifest.roles[role]` (seeded, deterministic),
or the placeholder. **No system ever indexes an asset file by name.**

---

## 3. Role vocabulary (the label set)

| role | meaning |
|---|---|
| `floor` | walkable ground, tileable (3–5 variants) |
| `floor_var` | floor accent/variant (path, cracked, stained) |
| `wall` | solid wall body |
| `wall_top` | wall top face / cap |
| `wall_base` | wall base / skirt |
| `pit` | void / hole / drop |
| `water` | liquid surface (animated) |
| `hazard` | damaging tile (lava, spikes, coolant) |
| `door` | door / threshold / stairs |
| `deco` | ground decoration (bush, rock, flower) — non-blocking |
| `prop` | placed/interactable object (chest, pot, sign) |
| `light` | emissive / light-source tile |
| `sprite` | animated creature/character frame (not a tile) |
| `glyph` | font glyph / UI icon |

Extend this table only by editing this document. **Never invent ad-hoc role strings in code.**

---

## 4. Workflow (intake → shippable tilesets)

1. **Intake** a pack into `work/asset-packs/reference/<neutral-slug>/` (no brand names).
2. **Slice + normalize** to the game grid (`tools/slice_lttp_pak.py` is the reference impl).
3. **Scrub** names + PNG metadata (`tools/scrub_pak.py`) — standing rule.
4. **Pre-sort** with clustering (`tools/cluster_tiles.py`) → review montage (this is *only* a helper).
5. **Author** the role set for each biome → `manifest.json` + `roles.json` (human-confirmed).
6. **Generate** the `TileSet` (`.tres`) and register it for `AssetResolver`.
7. **Ledger** every true source + license in `LICENSES.md`.

Only step 5 is irreducibly human. Steps 2–4 and 6 are scripted (see `work/asset-packs/tools/`).

---

## 5. Open items

- Autotile corner peering bits for the 12-piece terrain sets are authored **in the Godot editor**
  (visual), then exported — not auto-derived.
- POC biomes needing authored sets: **darkroom, grasslands, dungeon** (7 biomes later).
- Enemies, VFX, and full UI remain gaps (see `08-poc-asset-list-v2.md`).

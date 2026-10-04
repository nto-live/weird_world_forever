# LTTP POC Pak — sliced example tiles for the VIGIL vertical slice

**What this is:** every LTTP-*inspired* example tileset from `reference/lttp-style/`, **cut on its grid
into individual tiles and normalized to the game's 32×32 grid**, grouped by where the
POC/tutorial (doc `08-poc-asset-list-v2.md`) would use them. **Examples only** — not final art.

- **3,882 tiles** kept (empty cells dropped, exact duplicates within a sheet collapsed).
- 16px sources are nearest-upscaled **×2 → 32px**; 32px sources are used as-is.
- **Scrubbed:** no source/brand names in filenames, no metadata in any PNG (all ancillary chunks
  stripped). Sheet *codes* are opaque (`grasslands_a`, `dungeon_b`, …); the code → true-source map is
  kept **outside** the pak, in `../LICENSES.md`.

## Layout

```
lttp-poc-pak/
  tiles32/
    grasslands/   1551   grass / trees / houses / castle, grass-biome, 32px grass
    dungeon/       599   cave/dungeon stone, brick, pits, doors, hazards
    darkroom/      252   interiors (floor/wall/furniture) -> start-hub "Dark Room"
    characters/    215   4-dir hero sheet, NPCs, living-log character
    objects/       319   chests, pots, barrels, signs, rocks, props
    bosses/        872   a full dragon sheet -> stand-in for Gloamwing
    ui/             74   bitmap font (+ glyphs)
  preview/             scaled-up catalogs (catalog_<group>.png, _pak_overview.png)
  index.json           piece manifest: neutral key, grid, cell, scale, pieces[] (no source paths)
```

**Sheet codes** (one per source atlas, opaque on purpose): `grasslands_a…f`, `dungeon_a…d`,
`darkroom_a`, `characters_a…c`, `objects_a`, `bosses_a`, `ui_a`. Mapping to true sources: `../LICENSES.md`.

## Mapping to the POC scope (doc 08)

| POC slot (doc 08) | Covered by | Notes |
|---|---|---|
| **B. Dark Room** (floor/wall, furniture) | `darkroom/` | TV / loadout-rack / exit-door = compose from `objects/`; no dedicated art yet |
| **C. Grasslands** floor/wall/deco/light | `grasslands/` | rich floor/deco coverage; **autotile set not pre-built** — pick 12 pieces and register a terrain |
| **D. Dungeon** floor/wall/door/hazard | `dungeon/` | doors, cracked walls, pits/spikes present |
| **E. Enemies** (critter/hound/boar) | `characters/` partial | no dedicated enemies yet — **gap** (need the charger telegraph frame) |
| **F. Boss — Gloamwing** | `bosses/` (dragon sheet) | big readymade dragon = instant Gloamwing stand-in |
| **A. Main character** (32×48, 4-dir) | `characters/` | hero sheet is 4-dir; good enough to animate a slice |
| **G. VFX** | — | **gap** (author new, or slice sparks from `objects/`) |
| **H. Items / pickups** | `objects/` partial | sword/bomb/key/coin style props exist; amulet/leaf-heart not yet |
| **I. UI** | `ui/` font only | **gap**: hearts-leaf, item box, boss bar, menus, title |

## Gaps to close before the slice looks "done"

1. **Enemies** — the three Grasslands enemies (field critter / meadow hound / thistle boar), incl. the
   charger **telegraph** frame. Author or buy.
2. **VFX** — sword arc, spin ring, hit spark, ichor, bomb burst, dust, pickup cloud/leaves.
3. **UI** — the evolving **leaf health icon**, item box, boss HP bar, inventory frame, level-select and
   loadout-prompt panels, title logo.
4. **Dark Room signature props** — TV screen (on/off glow), loadout rack (sword / dimmed pistol / empty),
   exit portal.
5. **Autotile terrain sets** — doc 08 locks a **12-piece** floor/wall terrain set per tileset; pick them
   from these sheets and register them as Godot `TileSet` terrains.

## Labels (DRAFT — do not ship)

Auto-generated scaffolding from the sliced pak (kept for the authored pass; see `../tools/label_tiles.py`,
`cluster_tiles.py`, `pak_sheets.py`):

- `roles.json`     — role vocabulary (the label set; mirrors doc 09 §3).
- `labels.json`    — **per-tile draft** role + confidence (heuristic; known-noisy) + pixel features.
- `manifest.json`  — `group -> role -> tiles` (the machine query surface).
- `atlas/<g>.png`+`.json` — packed atlas per group + frame coords/roles (the machine-ready form).
- `review/`        — numbered contact sheets + cluster montages for human confirmation.
- `cluster/<g>.json` — cluster id -> members.

> ⚠️ **These labels are a first pass, not ground truth.** Heuristic/vision labeling of dense atlases is
> unreliable (verified). Per **doc 09**, roles must be **authored** — the machine consumes a *small
> per-biome* `manifest.json`, not 3,882 inferred labels. Use `review/` to confirm/correct.

**Ground truth to use instead of inference:** some packs ship real Tiled terrain data
(e.g. the grass-biome pack's `grass_biome.tsx` → `Grass/Water/Forest/…` + per-tile corner bits).
Import those; see doc 10 §10.

## Rebuild

```
python work/asset-packs/tools/slice_lttp_pak.py     # re-slice (deterministic, writes neutral keys)
python work/asset-packs/tools/scrub_pak.py          # neutralize names + strip metadata if re-run
python work/asset-packs/tools/pak_previews.py       # regenerate catalogs
```

> These are **example/reference** tiles (16px upscaled ×2 where applicable). Fine as POC placeholders;
> replace with original art at the same 32px sizes for shipping (`AssetResolver` swap-in, per doc 08).

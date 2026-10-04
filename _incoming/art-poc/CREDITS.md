# Art POC — credits & licensing

Example/placeholder art for the **VIGIL** proof-of-concept. **Not final game art.** These are
freely-licensed, *A Link to the Past*-inspired tilesets used as visual references and stand-in tiles
while the procedural systems are built. **No Nintendo assets are used or distributed.**

The `lttp-poc-pak/` tiles are delivered **scrubbed** — no source/brand names in filenames or PNG
metadata. The true provenance is recorded here (and in the private ledger) because two of the source
sets are **CC-BY**, and publishing them **requires attribution**. This file is the attribution.

## Tilesets used (neutral slug → source)
Raw archive lives in the private workspace at `work/asset-packs/reference/lttp-style/`.

| Neutral slug | True source | License | Attribution |
|---|---|---|---|
| `lttp-set-a-16px-forest` | **ArMM1998** — "Zelda-like tilesets and sprites", OpenGameArt | **CC0** | none required (credit appreciated) |
| `lttp-set-b-16px-grass` | **"Overworld - Grass Biome"** (commissioned; released CC0), OpenGameArt | **CC0** | none required |
| `lttp-set-c-16px-dungeon` | **Michele "Buch" Bucelli** — "Top down dungeon tileset", OpenGameArt | **CC-BY 3.0** | **"Michele 'Buch' Bucelli"** (+ link to OGA profile) and **Abram Connelly** (sponsor) |
| `lttp-set-d-32px-overworld` | **Daniel Cook** (Lost Garden) tiles, resized by **Jetrel**; additions by **Bertram**, **Zabin**; tall grass by **Saphy** (The Mana World), OpenGameArt | **CC-BY 3.0** | **Daniel Cook / Jetrel / Bertram / Zabin / Saphy (TMW)** + link to the OGA submission |
| `lttp-set-e-32px-grass` | **CDmir** — "Grass Tiles [32x32]", OpenGameArt | **CC0** | none required |
| `lttp-set-f-32px-dungeon` | **stealthix** — "32x32 Dungeon Tileset", OpenGameArt | **CC0** | none required |

## Obligations
- **CC-BY sets (`-c`, `-d`):** attribution required **if shipped**. Add to the game's credits screen
  and a repo `CREDITS.txt` before any public build.
- **None of these may be resold/redistributed as art assets** on their own.
- These are **examples** — replace with original art at the same 32px sizes for a shipping build
  (`AssetResolver` swap-in; see `_incoming/09-asset-labeling-convention.md` and `10-…`).

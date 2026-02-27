# animalia_mcl_hunger

Compatibility mod for running [Animalia](https://content.luanti.org/packages/ElCeejo/animalia/) with VoxeLibre/MineClone-style hunger and item IDs.

## Why this exists

Animalia is written to work across multiple game ecosystems, but some interactions use classic Minetest item IDs by default (`bucket:bucket_empty`, `wool:*`, `animalia:saddle`, etc.).

This mod patches selected Animalia mob interactions so they behave naturally in VoxeLibre-style games:

- Sheep can be sheared with `mcl_tools:shears` and drop `mcl_wool:*`.
- Cows can be milked with `mcl_buckets:bucket_empty` and return `mcl_mobitems:milk_bucket` (or fallback).
- Horses can be saddled with `mcl_mobitems:saddle`.
- Animalia meats are marked edible in `mcl_hunger` games.

## Local assumptions

This repo is currently placed in:

- `mods/animalia_mcl_hunger`

and was cross-checked against local sources in:

- `mods/animalia`
- `games/mineclone2`

The behavior should also be relevant to modern VoxeLibre item naming, but this mod intentionally keeps fallbacks configurable (see Settings).

## Install

1. Place this mod in your world or global mods folder.
2. Ensure dependencies are available:
   - Required: `animalia`, `mcl_hunger`
   - Optional but typically present in VoxeLibre stacks: `mcl_tools`, `mcl_wool`, `mcl_buckets`, `mcl_mobitems`, `dye`
3. Enable the mod in your world.

## Settings

All settings are under the `animalia_mcl_hunger.*` namespace and are documented in `settingtypes.txt`.

Common ones:

- `animalia_mcl_hunger.enable_food` (default: `true`)
- `animalia_mcl_hunger.enable_shearing` (default: `true`)
- `animalia_mcl_hunger.enable_milking` (default: `true`)
- `animalia_mcl_hunger.enable_horse_saddle` (default: `true`)
- `animalia_mcl_hunger.sheep_regrow_seconds` (default: `600`)
- `animalia_mcl_hunger.milk_cooldown_seconds` (default: `300`)
- `animalia_mcl_hunger.shears_items` (CSV list)
- `animalia_mcl_hunger.empty_bucket_items` (CSV list)
- `animalia_mcl_hunger.milk_bucket_items` (CSV list)
- `animalia_mcl_hunger.horse_saddle_items` (CSV list)

The CSV list settings pick the first registered item ID at runtime, so you can tune compatibility without editing Lua files.

## Notes on upstream naming

- Luanti is the current name of the Minetest engine project: <https://www.luanti.org/>
- VoxeLibre package/source metadata:
  - Package page: <https://content.luanti.org/packages/VoxeLibre/voxelibre/>
  - Source repository: <https://git.minetest.land/VoxeLibre/voxelibre>

## Scope

This mod patches behavior at runtime by overriding `on_rightclick` handlers after mods load. It does **not** modify Animalia source files directly.

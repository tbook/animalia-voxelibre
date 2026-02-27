# animalia_mcl_hunger

Compatibility mod for running [Animalia](https://content.luanti.org/packages/ElCeejo/animalia/) with VoxeLibre/MineClone-style hunger and item IDs.

## Why this exists

Animalia is written to work across multiple game ecosystems, but some interactions use classic Minetest item IDs by default (`bucket:bucket_empty`, `wool:*`, `animalia:saddle`, etc.).

This mod patches selected Animalia mob interactions so they behave naturally in VoxeLibre-style games:

- Sheep can be sheared with `mcl_tools:shears` and drop `mcl_wool:*`.
- Sheep dyeing accepts both `dye:*` and `mcl_dye:*`.
- Cows can be milked with `mcl_buckets:bucket_empty` and return `mcl_mobitems:milk_bucket` (or fallback).
- Horses can be saddled with `mcl_mobitems:saddle`.
- Animalia meats are marked edible in `mcl_hunger` games.
- Duplicate Animalia utility/material items can be canonicalized to VoxeLibre IDs.
- Overlapping `mobs_mc:*` passive spawns can be suppressed while this mod is active.

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
   - Optional but typically present in VoxeLibre stacks: `mcl_tools`, `mcl_wool`, `mcl_buckets`, `mcl_mobitems`, `mcl_dye`, `dye`
3. Enable the mod in your world.

## Settings

All settings are under the `animalia_mcl_hunger.*` namespace and are documented in `settingtypes.txt`.

Common ones:

- `animalia_mcl_hunger.enable_food` (default: `true`)
- `animalia_mcl_hunger.enable_shearing` (default: `true`)
- `animalia_mcl_hunger.enable_milking` (default: `true`)
- `animalia_mcl_hunger.enable_horse_saddle` (default: `true`)
- `animalia_mcl_hunger.enable_item_dedupe` (default: `true`)
- `animalia_mcl_hunger.dedupe_meats` (default: `true`)
- `animalia_mcl_hunger.enable_spawn_suppression` (default: `true`)
- `animalia_mcl_hunger.enforce_spawn_suppression` (default: `true`)
- `animalia_mcl_hunger.sheep_regrow_seconds` (default: `600`, real-time seconds)
- `animalia_mcl_hunger.milk_cooldown_seconds` (default: `300`)
- `animalia_mcl_hunger.shears_items` (CSV list)
- `animalia_mcl_hunger.empty_bucket_items` (CSV list)
- `animalia_mcl_hunger.milk_bucket_items` (CSV list)
- `animalia_mcl_hunger.horse_saddle_items` (CSV list)
- `animalia_mcl_hunger.leather_items` (CSV list)
- `animalia_mcl_hunger.feather_items` (CSV list)
- `animalia_mcl_hunger.suppressed_mobs` (CSV list)
- `animalia_mcl_hunger.pig_food_items` (CSV list)
- `animalia_mcl_hunger.wolf_food_items` (CSV list)

The CSV list settings pick the first registered item ID at runtime, so you can tune compatibility without editing Lua files.

## Duplicate item policy

With `animalia_mcl_hunger.enable_item_dedupe = true`, this mod treats VoxeLibre items as canonical where available:

- `animalia:shears` -> `mcl_tools:shears`
- `animalia:saddle` -> `mcl_mobitems:saddle`
- `animalia:bucket_milk` -> `mcl_mobitems:milk_bucket`
- `animalia:leather` -> `mcl_mobitems:leather`
- `animalia:feather` -> `mcl_mobitems:feather`

It also clears crafting outputs for those Animalia IDs and rewrites registered mob drops to canonical IDs after mods load.

When dedupe is enabled, this mod also adds compatibility groups (`leather`, `feather`, `food_milk`) to the selected canonical VoxeLibre items so Animalia recipes and checks still work.

If `animalia_mcl_hunger.dedupe_meats = true`, these IDs are also canonicalized when available:

- `animalia:beef_raw` -> `mcl_mobitems:beef`
- `animalia:beef_cooked` -> `mcl_mobitems:cooked_beef`
- `animalia:mutton_raw` -> `mcl_mobitems:mutton`
- `animalia:mutton_cooked` -> `mcl_mobitems:cooked_mutton`
- `animalia:porkchop_raw` -> `mcl_mobitems:porkchop`
- `animalia:porkchop_cooked` -> `mcl_mobitems:cooked_porkchop`
- `animalia:poultry_raw` -> `mcl_mobitems:chicken`
- `animalia:poultry_cooked` -> `mcl_mobitems:cooked_chicken`

## Spawn suppression

With `animalia_mcl_hunger.enable_spawn_suppression = true`, this mod patches `mcl_mobs.spawn_setup` and skips configured `mobs_mc:*` spawn registrations.
With `animalia_mcl_hunger.enforce_spawn_suppression = true`, it also removes suppressed `mobs_mc:*` entities near players every few seconds as a load-order-safe fallback.

Default suppressed IDs:

- `mobs_mc:cow`
- `mobs_mc:sheep`
- `mobs_mc:pig`
- `mobs_mc:chicken`
- `mobs_mc:horse`

This affects new natural spawns while the mod is active. It does not retroactively remove already-existing mobs.

## Pig feeding

Animalia pigs are fed from their follow list. This mod appends common VoxeLibre pig foods by default:

- `mcl_farming:carrot_item`
- `mcl_farming:potato_item`
- `mcl_farming:beetroot_item`
- `mcl_farming:carrot_item_gold`

Animalia wolves are also extended to accept common VoxeLibre raw meats by default:

- `mcl_mobitems:beef`
- `mcl_mobitems:mutton`
- `mcl_mobitems:porkchop`
- `mcl_mobitems:chicken`
- `mcl_mobitems:bone`

## Notes on upstream naming

- Luanti is the current name of the Minetest engine project: <https://www.luanti.org/>
- VoxeLibre package/source metadata:
  - Package page: <https://content.luanti.org/packages/VoxeLibre/voxelibre/>
  - Source repository: <https://git.minetest.land/VoxeLibre/voxelibre>

## Scope

This mod patches behavior at runtime by overriding `on_rightclick` handlers after mods load. It does **not** modify Animalia source files directly.

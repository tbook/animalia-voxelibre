-- animalia_mcl_hunger/milking.lua
-- VoxeLibre compat: milk Animalia cows with an empty bucket.

local COW_ENTITY = "animalia:cow"

-- Cooldown (seconds) between milks per cow
local MILK_COOLDOWN = 300 -- 5 minutes; tweak to taste

-- Candidate item IDs (we'll auto-pick the first that exists)
local EMPTY_BUCKET_CANDIDATES = {
  "mcl_buckets:bucket_empty",
  "bucket:bucket_empty", -- fallback if some bucket mod provides it
}

local MILK_BUCKET_CANDIDATES = {
  "mcl_mobitems:milk_bucket",
  "mcl_milk:milk_bucket",
  "mcl_milk:milk",
}

local function first_registered(candidates)
  for _, name in ipairs(candidates) do
    if minetest.registered_items[name] then
      return name
    end
  end
  return nil
end

local EMPTY_BUCKET = first_registered(EMPTY_BUCKET_CANDIDATES)
local MILK_BUCKET  = first_registered(MILK_BUCKET_CANDIDATES)

local function give_item_or_drop(player, itemstack)
  local inv = player:get_inventory()
  if inv and inv:room_for_item("main", itemstack) then
    inv:add_item("main", itemstack)
  else
    minetest.add_item(player:get_pos(), itemstack)
  end
end

local function is_empty_bucket(stack)
  return stack and EMPTY_BUCKET and stack:get_name() == EMPTY_BUCKET
end

minetest.register_on_mods_loaded(function()
  if not minetest.registered_entities[COW_ENTITY] then
    minetest.log("warning", "[animalia_mcl_hunger] cow entity not found: " .. COW_ENTITY)
    return
  end

  if not EMPTY_BUCKET then
    minetest.log("warning", "[animalia_mcl_hunger] no empty bucket item found (tried mcl_buckets/bucket)")
    return
  end

  if not MILK_BUCKET then
    minetest.log("warning", "[animalia_mcl_hunger] no milk bucket item found (tried mcl_mobitems/mcl_milk)")
    return
  end

  local def = minetest.registered_entities[COW_ENTITY]
  local old_on_rightclick = def.on_rightclick

  -- Patch in-place; do NOT re-register animalia:cow
  def.on_rightclick = function(self, clicker)
    -- Preserve Animalia's existing interactions first (feeding, nametag, etc.)
    if animalia.feed and animalia.feed(self, clicker, false, true) then
      return
    end
    if animalia.set_nametag and animalia.set_nametag(self, clicker) then
      return
    end

    -- Only milk adults (Animalia uses growth_scale < 1 check in sheep)
    if self.growth_scale and self.growth_scale < 1 then
      return
    end

    local stack = clicker and clicker:get_wielded_item()
    if clicker and is_empty_bucket(stack) then
      local pname = clicker:get_player_name()
      local creative = minetest.is_creative_enabled(pname)

      -- Per-cow cooldown (persisted)
      local now = minetest.get_gametime()
      local next_ok = self:recall("milk_next_ok_at") or 0
      if now < next_ok then
        return
      end

      -- Consume empty bucket (unless creative) and give milk bucket
      if not creative then
        stack:take_item()
        clicker:set_wielded_item(stack)
      end

      give_item_or_drop(clicker, ItemStack(MILK_BUCKET))

      -- Set cooldown
      self:memorize("milk_next_ok_at", now + MILK_COOLDOWN)

      return
    end

    -- Fallback to original cow handler for anything else
    if old_on_rightclick then
      return old_on_rightclick(self, clicker)
    end
  end

  minetest.log("action",
    ("[animalia_mcl_hunger] Milking enabled for %s using %s -> %s (cooldown %ds)")
      :format(COW_ENTITY, EMPTY_BUCKET, MILK_BUCKET, MILK_COOLDOWN)
  )
end)
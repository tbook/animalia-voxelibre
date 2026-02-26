-- animalia_mcl_hunger/shearing.lua
-- Patch Animalia sheep to be shearable with VoxeLibre shears, without re-registering the entity.

local SHEEP_ENTITY = "animalia:sheep"

local SHEARS_ITEMS = {
  ["mcl_tools:shears"] = true,
  -- ["mcl_shears:shears"] = true,
}

local function pick_wool_item()
  local candidates = {
    "mcl_wool:white",
    "mcl_wool:wool_white",
    "mcl_wool:wool",
    "wool:white",
    "wool:wool_white",
  }
  for _, name in ipairs(candidates) do
    if minetest.registered_items[name] then
      return name
    end
  end
  return nil
end

local WOOL_ITEM = pick_wool_item()

local function is_shears(itemstack)
  return itemstack and SHEARS_ITEMS[itemstack:get_name()] == true
end

local function damage_shears(clicker, itemstack)
  -- adjust wear to taste; harmless if wear isn't used
  itemstack:add_wear(1000)
  clicker:set_wielded_item(itemstack)
end

minetest.register_on_mods_loaded(function()
  minetest.log("action", "[animalia_mcl_hunger] shearing patch loading")

  local def = minetest.registered_entities[SHEEP_ENTITY]
  if not def then
    minetest.log("warning", "[animalia_mcl_hunger] entity not found: " .. SHEEP_ENTITY)
    return
  end
  if not WOOL_ITEM then
    minetest.log("warning", "[animalia_mcl_hunger] no wool item found; adjust candidates")
    return
  end

  local old_on_rightclick = def.on_rightclick

  -- Override in-place (no re-register)
  def.on_rightclick = function(self, clicker)
    local itemstack = clicker and clicker:get_wielded_item()

    if clicker and is_shears(itemstack) then
      if self._sheared then
        return
      end
      self._sheared = true

      local pos = self.object:get_pos()
      local count = math.random(1, 3)
      minetest.add_item(pos, ItemStack(WOOL_ITEM .. " " .. count))

      damage_shears(clicker, itemstack)

      -- regrow after 10 minutes
      minetest.after(600, function()
        if self and self.object and self.object:get_luaentity() == self then
          self._sheared = nil
        end
      end)

      return
    end

    if old_on_rightclick then
      return old_on_rightclick(self, clicker)
    end
  end

  minetest.log("action", "[animalia_mcl_hunger] shearing enabled for " .. SHEEP_ENTITY ..
    " dropping " .. WOOL_ITEM)
end)
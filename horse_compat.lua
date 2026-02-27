-- animalia_mcl_hunger/horse_compat.lua
local HORSE = "animalia:horse"
local SETTINGS = animalia_mcl_hunger

if not SETTINGS.enable_horse_saddle then
  return
end

local function is_supported_saddle(name)
  for _, saddle_name in ipairs(SETTINGS.horse_saddle_items) do
    if name == saddle_name then
      return true
    end
  end
  return false
end

minetest.register_on_mods_loaded(function()
  local def = minetest.registered_entities[HORSE]
  if not def then return end
  local old = def.on_rightclick

  def.on_rightclick = function(self, clicker)
    -- Preserve Animalia feed/nametag etc by calling original unless we intercept
    local stack = clicker and clicker:get_wielded_item()
    local name = stack and stack:get_name() or ""

    -- Treat VoxeLibre saddle as Animalia saddle
    if is_supported_saddle(name) then
      local creative = minetest.is_creative_enabled(clicker:get_player_name())

      self:set_saddle(true)

      if not creative then
        stack:take_item()
        clicker:set_wielded_item(stack)
      end
      return
    end

    if old then
      return old(self, clicker)
    end
  end
end)

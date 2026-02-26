-- animalia_mcl_hunger/shearing.lua
-- VoxeLibre compat: make Animalia sheep shear/dye using mcl_wool and mcl_tools shears.

local random = math.random
local SHEEP_ENTITY = "animalia:sheep"

-- Copy of Animalia palette (needed for texture tint when dyeing)
local palette  = {
  black = {"Black", "#000000b0"},
  blue = {"Blue", "#015dbb70"},
  brown = {"Brown", "#663300a0"},
  cyan = {"Cyan", "#01ffd870"},
  dark_green = {"Dark Green", "#005b0770"},
  dark_grey = {"Dark Grey",  "#303030b0"},
  green = {"Green", "#61ff0170"},
  grey = {"Grey", "#5b5b5bb0"},
  magenta = {"Magenta", "#ff05bb70"},
  orange = {"Orange", "#ff840170"},
  pink = {"Pink", "#ff65b570"},
  red = {"Red", "#ff0000a0"},
  violet = {"Violet", "#2000c970"},
  white = {"White", "#ababab00"},
  yellow = {"Yellow", "#e3ff0070"},
}

-- Map Animalia dye names to VoxeLibre wool color item suffixes
local function mcl_wool_color(dye_color)
  local map = {
    black = "black",
    blue = "blue",
    brown = "brown",
    cyan = "cyan",
    green = "green",
    dark_green = "green",   -- best match
    red = "red",
    yellow = "yellow",
    white = "white",
    pink = "pink",
    orange = "orange",
    magenta = "magenta",
    violet = "purple",      -- best match
    grey = "light_gray",    -- best match (Minecraft has gray + light_gray)
    dark_grey = "gray",     -- best match
  }
  return map[dye_color] or "white"
end

local function mcl_wool_item(dye_color)
  return "mcl_wool:" .. mcl_wool_color(dye_color or "white")
end

local function is_shears(itemstack)
  if not itemstack then return false end
  local name = itemstack:get_name()
  return name == "mcl_tools:shears" or name == "animalia:shears"
end

minetest.register_on_mods_loaded(function()
  local def = minetest.registered_entities[SHEEP_ENTITY]
  if not def then
    minetest.log("warning", "[animalia_mcl_hunger] entity not found: " .. SHEEP_ENTITY)
    return
  end

  local old_on_rightclick = def.on_rightclick

  -- Override in-place (do NOT re-register animalia:sheep)
  def.on_rightclick = function(self, clicker)
    -- Preserve Animalia’s existing behaviors first
    if animalia.feed and animalia.feed(self, clicker, false, true) then
      return
    end
    if animalia.set_nametag and animalia.set_nametag(self, clicker) then
      return
    end

    if self.collected or (self.growth_scale and self.growth_scale < 1) then
      return
    end

    local tool = clicker:get_wielded_item()
    local tool_name = tool:get_name()
    local creative = minetest.is_creative_enabled(clicker:get_player_name())

    -- Shearing: accept VoxeLibre shears, drop mcl_wool, set "collected" + texture swap
    if is_shears(tool) then
      minetest.add_item(
        self.object:get_pos(),
        ItemStack(mcl_wool_item(self.dye_color) .. " " .. random(1, 3))
      )

      self.collected = self:memorize("collected", true)
      self.dye_color = self:memorize("dye_color", "white")

      self.object:set_properties({
        textures = {"animalia_sheep.png"},
      })

      if not creative then
        tool:add_wear(650)
        clicker:set_wielded_item(tool)
      end

      -- 🔁 Regrow after 10 minutes
      minetest.after(600, function()
        if self and self.object and self.object:get_luaentity() == self then
          self.collected = self:memorize("collected", false)

          local tex
          if self.dye_color and self.dye_color ~= "white" then
            tex = "animalia_sheep.png^(animalia_sheep_wool.png^[multiply:" ..
                  palette[self.dye_color][2] .. ")"
          else
            tex = "animalia_sheep.png^animalia_sheep_wool.png"
          end

          self.object:set_properties({
            textures = {tex}
          })
        end
      end)

      return
    end

    -- Dyeing: keep Animalia’s visuals, but make drops use mcl_wool instead of wool:
    if tool_name:match("^dye:") then
      local dye_color = tool_name:split(":")[2]
      if palette[dye_color] then
        self.dye_color = self:memorize("dye_color", dye_color)

        self.drops = {
          {name = "animalia:mutton_raw", chance = 1, min = 1, max = 4},
          {name = mcl_wool_item(dye_color), chance = 2, min = 1, max = 2},
        }

        -- Same texture tinting as Animalia
        self.object:set_properties({
          textures = {"animalia_sheep.png^(animalia_sheep_wool.png^[multiply:" .. palette[dye_color][2] .. ")"},
        })

        if not creative then
          tool:take_item()
          clicker:set_wielded_item(tool)
        end
      end
      return
    end

    -- Fallback to original Animalia handler for anything else (lasso/net/etc.)
    if old_on_rightclick then
      return old_on_rightclick(self, clicker)
    end
  end

  minetest.log("action", "[animalia_mcl_hunger] Patched Animalia sheep for VoxeLibre shears + mcl_wool")
end)
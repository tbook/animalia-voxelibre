local SETTINGS = animalia_mcl_hunger
local WOLF_ENTITY = "animalia:wolf"

local function append_unique(dst, values)
  local seen = {}
  for _, item in ipairs(dst) do
    seen[item] = true
  end
  for _, item in ipairs(values) do
    if (item:match("^group:") or minetest.registered_items[item]) and not seen[item] then
      dst[#dst + 1] = item
      seen[item] = true
    end
  end
end

minetest.register_on_mods_loaded(function()
  local def = minetest.registered_entities[WOLF_ENTITY]
  if not def then
    return
  end

  local follow = {}
  if type(def.follow) == "table" then
    for _, item in ipairs(def.follow) do
      follow[#follow + 1] = item
    end
  elseif type(def.follow) == "string" and def.follow ~= "" then
    follow[1] = def.follow
  end

  append_unique(follow, SETTINGS.wolf_food_items)
  def.follow = follow

  minetest.log("action",
    ("[animalia_mcl_hunger] wolf follow foods updated (%d items)"):format(#follow))
end)

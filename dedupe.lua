local SETTINGS = animalia_mcl_hunger

if not SETTINGS.enable_item_dedupe then
  return
end

local function first_registered(candidates)
  for _, name in ipairs(candidates) do
    if minetest.registered_items[name] then
      return name
    end
  end
  return nil
end

local function add_groups(itemname, extra_groups)
  local def = minetest.registered_items[itemname]
  if not def then
    return
  end
  local groups = table.copy(def.groups or {})
  local changed = false
  for group_name, value in pairs(extra_groups) do
    if groups[group_name] ~= value then
      groups[group_name] = value
      changed = true
    end
  end
  if changed then
    minetest.override_item(itemname, {groups = groups})
  end
end

local function apply_drop_rewrites(alias_map)
  for _, def in pairs(minetest.registered_entities) do
    if type(def.drops) == "table" then
      for _, drop in ipairs(def.drops) do
        if drop.name and alias_map[drop.name] then
          drop.name = alias_map[drop.name]
        end
      end
    end
  end
end

minetest.register_on_mods_loaded(function()
  local alias_map = {}

  local shears = first_registered(SETTINGS.shears_items)
  if shears and shears ~= "animalia:shears" then
    alias_map["animalia:shears"] = shears
  end

  local saddle = first_registered(SETTINGS.horse_saddle_items)
  if saddle and saddle ~= "animalia:saddle" then
    alias_map["animalia:saddle"] = saddle
  end

  local milk_bucket = first_registered(SETTINGS.milk_bucket_items)
  if milk_bucket and milk_bucket ~= "animalia:bucket_milk" then
    alias_map["animalia:bucket_milk"] = milk_bucket
  end

  local leather = first_registered(SETTINGS.leather_items)
  if leather and leather ~= "animalia:leather" then
    alias_map["animalia:leather"] = leather
    add_groups(leather, {leather = 1})
  end

  local feather = first_registered(SETTINGS.feather_items)
  if feather and feather ~= "animalia:feather" then
    alias_map["animalia:feather"] = feather
    add_groups(feather, {feather = 1})
  end

  if milk_bucket then
    add_groups(milk_bucket, {food_milk = 1})
  end

  if SETTINGS.dedupe_meats then
    local meat_map = {
      ["animalia:beef_raw"] = "mcl_mobitems:beef",
      ["animalia:beef_cooked"] = "mcl_mobitems:cooked_beef",
      ["animalia:mutton_raw"] = "mcl_mobitems:mutton",
      ["animalia:mutton_cooked"] = "mcl_mobitems:cooked_mutton",
      ["animalia:porkchop_raw"] = "mcl_mobitems:porkchop",
      ["animalia:porkchop_cooked"] = "mcl_mobitems:cooked_porkchop",
      ["animalia:poultry_raw"] = "mcl_mobitems:chicken",
      ["animalia:poultry_cooked"] = "mcl_mobitems:cooked_chicken",
    }
    for old_name, new_name in pairs(meat_map) do
      if minetest.registered_items[old_name] and minetest.registered_items[new_name] then
        alias_map[old_name] = new_name
      end
    end
  end

  for old_name, new_name in pairs(alias_map) do
    minetest.register_alias_force(old_name, new_name)
    minetest.clear_craft({output = old_name})
    minetest.clear_craft({output = old_name .. " 1"})
    minetest.log("action",
      ("[animalia_mcl_hunger] dedupe: %s -> %s"):format(old_name, new_name))
  end

  apply_drop_rewrites(alias_map)
end)

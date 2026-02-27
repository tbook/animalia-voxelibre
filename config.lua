local MODNAME = minetest.get_current_modname()
local PREFIX = MODNAME .. "."

local function setting(name)
  return minetest.settings:get(PREFIX .. name)
end

local function get_bool(name, default)
  local raw = setting(name)
  if raw == nil then
    return default
  end
  return minetest.is_yes(raw)
end

local function get_int(name, default, min_value)
  local value = tonumber(setting(name))
  if not value then
    value = default
  end
  value = math.floor(value)
  if min_value and value < min_value then
    value = min_value
  end
  return value
end

local function get_csv(name, default_list)
  local raw = setting(name)
  if not raw or raw == "" then
    return default_list
  end
  local list = {}
  for part in raw:gmatch("[^,]+") do
    local item = part:gsub("^%s+", ""):gsub("%s+$", "")
    if item ~= "" then
      list[#list + 1] = item
    end
  end
  if #list == 0 then
    return default_list
  end
  return list
end

animalia_mcl_hunger = {
  settings_prefix = PREFIX,
  enable_food = get_bool("enable_food", true),
  enable_shearing = get_bool("enable_shearing", true),
  enable_milking = get_bool("enable_milking", true),
  enable_horse_saddle = get_bool("enable_horse_saddle", true),
  enable_item_dedupe = get_bool("enable_item_dedupe", true),
  dedupe_meats = get_bool("dedupe_meats", true),
  sheep_regrow_seconds = get_int("sheep_regrow_seconds", 600, 0),
  milk_cooldown_seconds = get_int("milk_cooldown_seconds", 300, 0),
  shears_items = get_csv("shears_items", {
    "mcl_tools:shears",
    "animalia:shears",
  }),
  empty_bucket_items = get_csv("empty_bucket_items", {
    "mcl_buckets:bucket_empty",
    "bucket:bucket_empty",
  }),
  milk_bucket_items = get_csv("milk_bucket_items", {
    "mcl_mobitems:milk_bucket",
    "mcl_milk:milk_bucket",
    "mcl_milk:milk",
    "animalia:bucket_milk",
  }),
  horse_saddle_items = get_csv("horse_saddle_items", {
    "mcl_mobitems:saddle",
  }),
  leather_items = get_csv("leather_items", {
    "mcl_mobitems:leather",
    "animalia:leather",
  }),
  feather_items = get_csv("feather_items", {
    "mcl_mobitems:feather",
    "animalia:feather",
  }),
}

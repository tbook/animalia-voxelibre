if not animalia_mcl_hunger.enable_food then
  return
end

local function make_food(name, hunger)
  local def = minetest.registered_items[name]
  if not def then
    minetest.log("warning", "[animalia_mcl_hunger] missing item: " .. name)
    return
  end

  local groups = table.copy(def.groups or {})
  groups.food = groups.food or 2
  groups.eatable = hunger                 -- important in MCL-style games
  groups.can_eat_when_full = groups.can_eat_when_full or 1

  -- wrapper around do_item_eat
  local eat = minetest.item_eat(hunger)

  minetest.override_item(name, {
    on_use = function(itemstack, user, pointed_thing)
      return eat(itemstack, user, pointed_thing)
    end,
    -- optional: allow eating when pointing at nodes too
    on_place = function(itemstack, user, pointed_thing)
      return eat(itemstack, user, pointed_thing)
    end,
    groups = groups,
  })
end

local foods = {
  ["animalia:beef_cooked"] = 8,
  ["animalia:beef_raw"] = 1,
  ["animalia:mutton_cooked"] = 6,
  ["animalia:mutton_raw"] = 1,
  ["animalia:rat_cooked"] = 4,
  ["animalia:rat_raw"] = 1,
  ["animalia:porkchop_cooked"] = 8,
  ["animalia:porkchop_raw"] = 1,
  ["animalia:poultry_cooked"] = 3,
  ["animalia:poultry_raw"] = 1,
  ["animalia:venison_cooked"] = 8,
  ["animalia:venison_raw"] = 1,
  ["animalia:chicken_egg_fried"] = 4,
  ["animalia:song_bird_egg_fried"] = 4,
  ["animalia:turkey_egg_fried"] = 4,
}

for name, hunger in pairs(foods) do
  make_food(name, hunger)
end

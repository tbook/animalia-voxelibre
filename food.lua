local function make_food(name, hunger)
  local def = minetest.registered_items[name]
  if not def then
    minetest.log("warning", "[animalia_mcl] missing item: " .. name)
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
      return eat(itemstack, user, pointed_thing)   -- must return the new stack :contentReference[oaicite:0]{index=0}
    end,
    -- optional: allow eating when pointing at nodes too
    on_place = function(itemstack, user, pointed_thing)
      return eat(itemstack, user, pointed_thing)
    end,
    groups = groups,
  })
end

make_food("animalia:beef_cooked", 8)
make_food("animalia:beef_raw", 1)
make_food("animalia:porkchop_cooked", 8)
make_food("animalia:porkchop_raw", 1)
make_food("animalia:mutton_cooked", 6)
make_food("animalia:mutton_raw", 1)
make_food("animalia:venison_cooked", 8)
make_food("animalia:venison_raw", 1)
make_food("animalia:poultry_cooked", 3)
make_food("animalia:poultry_raw", 1)
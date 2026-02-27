local SETTINGS = animalia_mcl_hunger

if not SETTINGS.enable_spawn_suppression then
  return
end

local suppressed = {}
for _, mob_name in ipairs(SETTINGS.suppressed_mobs) do
  suppressed[mob_name] = true
end

local function remove_suppressed_near(pos, radius)
  local objects = minetest.get_objects_inside_radius(pos, radius)
  for _, obj in ipairs(objects) do
    local ent = obj:get_luaentity()
    if ent and suppressed[ent.name] then
      obj:remove()
    end
  end
end

if mcl_mobs and type(mcl_mobs.spawn_setup) == "function" then
  if not mcl_mobs._animalia_mcl_hunger_spawn_patch then
    local old_spawn_setup = mcl_mobs.spawn_setup
    mcl_mobs.spawn_setup = function(self, def)
      local name = def and def.name
      if name and suppressed[name] then
        minetest.log("action",
          ("[animalia_mcl_hunger] suppressed mcl spawn setup for %s"):format(name))
        return
      end
      return old_spawn_setup(self, def)
    end
    mcl_mobs._animalia_mcl_hunger_spawn_patch = true
  end
else
  minetest.log("warning",
    "[animalia_mcl_hunger] mcl_mobs.spawn_setup not available; using cleanup fallback only")
end

if SETTINGS.enforce_spawn_suppression then
  local timer = 0
  minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < 5 then
      return
    end
    timer = 0
    for _, player in ipairs(minetest.get_connected_players()) do
      local pos = player:get_pos()
      if pos then
        remove_suppressed_near(pos, 64)
      end
    end
  end)
end

local S = core.get_translator(core.get_current_modname())

local fill_time = 864.0 -- 14.4 minutes
local max_water = 100   -- 100 water levels (buckets)
                        -- 24 hours to fill

local function update_water_level(pos, change)
  local meta = core.get_meta(pos)
  local current = meta:get_int("water") or 0
  local water = current + change

  if water < 0 then
    return nil
  end

  water = math.min(water, max_water)

  local timer = core.get_node_timer(pos)

  if water >= max_water then
    timer:stop()
  else
    if not timer:is_started() then
      timer:start(fill_time)
    end
  end

  meta:set_int("water", water)
  meta:set_string("infotext", "Well water: (" .. water .. ")")

  return true
end


local function player_take_water(pos, node, clicker, itemstack, pointed_thing)
  if not pos then return end

  if (clicker and clicker:is_player()) and itemstack then
    if itemstack:get_name() ~= "bucket:bucket_empty" then
      return
    end

    if not update_water_level(pos, -1) then
      core.chat_send_player(clicker:get_player_name(), S("Well is dry"))
      return
    end

    if itemstack:get_count() > 1 then
      itemstack:take_item(1)

      local full_bucket = ItemStack("bucket:bucket_water")
      local inv = clicker:get_inventory()

      if inv:room_for_item("main", full_bucket) then
        inv:add_item("main", full_bucket)
      else
        local pos = clicker:get_pos()
        pos.y = math.floor(pos.y + 0.5)
        core.add_item(pos, full_bucket)
      end
    else
      itemstack:replace("bucket:bucket_water")
    end

    return itemstack
  end
end


core.register_node("irrigation:well", {
  description = "Irrigation Well",
  drawtype = "mesh",
  mesh = "irrigation_well.obj",
  paramtype = "light",
  groups = {cracky = 1},
  tiles = {
    core.registered_nodes["default:water_source"].tiles[1],
    "default_wood.png",
    "default_stone.png",
    "default_cobble.png"
  },
  collision_box = {type="fixed", fixed={-0.6,-0.5,-0.6,0.6,1.0,0.6}},
  selection_box = {type="fixed", fixed={-0.6,-0.5,-0.6,0.6,1.0,0.6}},

  on_timer = function(pos)
    update_water_level(pos, 1)
  end,

  on_construct = function(pos)
    update_water_level(pos, 0)
  end,

  on_rightclick = player_take_water,
})


core.register_craft({
  output = "irrigation:well",
  recipe = {
    {"group:wood",     "group:wood",  "group:wood"},
    {"default:stone",  "",            "default:stone"},
    {"default:cobble", "",            "default:cobble"}
  }
})

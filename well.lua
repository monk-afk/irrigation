local S = minetest.get_translator("irrigation")

local fill_time = 864.0 -- 14.4 minutes
local max_water = 100   -- 100 water levels (buckets)
                        -- 24 hours to fill

local function well_set_water(pos, node, clicker, itemstack, pointed_thing)
  if not pos then return end
  local meta = minetest.get_meta(pos)
  local water_level = (meta:get_int("water") or 0)

  if (clicker and clicker:is_player()) and itemstack then

    local wield_item = clicker:get_wielded_item():get_name()

    if wield_item ~= "bucket:bucket_empty" then
      return
    end
    local name = clicker:get_player_name()

    if water_level < 1 then
      minetest.chat_send_player(name, S("Well is dry"))
      return
    end

    local giving_back = "bucket:bucket_water 1"
    local item_count = clicker:get_wielded_item():get_count()
    if item_count > 1 then

      local inv = clicker:get_inventory()
      if inv:room_for_item("main", {name = giving_back}) then
        inv:add_item("main", giving_back)
      else
        local pos = clicker:get_pos()
        pos.y = math.floor(pos.y + 0.5)
        minetest.add_item(pos, giving_back)
      end

      giving_back = "bucket:bucket_empty "..tostring(item_count-1)
    end

    water_level = water_level - 1
    meta:set_int("water", water_level)
    meta:set_string("infotext", "Well water: ("..water_level..")")

    if not minetest.get_node_timer(pos):is_started() then
      minetest.get_node_timer(pos):start(fill_time)
    end

    return ItemStack(giving_back)
  else
    water_level = water_level + 1
    meta:set_int("water", water_level)
    meta:set_string("infotext", "Well water: ("..water_level..")")
    
    if water_level < max_water then
      minetest.get_node_timer(pos):start(fill_time)
      return
    else
      minetest.get_node_timer(pos):stop()
      return
    end
  end
end


minetest.register_node("irrigation:well", {
  description = "Irrigation Well",
  drawtype = "mesh",
  mesh = "irrigation_well.obj",
  paramtype = "light",
  groups = {cracky = 1},
  tiles = {
    minetest.registered_nodes["default:water_source"].tiles[1],
    "default_wood.png",
    "default_stone.png",
    "default_cobble.png"
  },
  collision_box = {type="fixed", fixed={-0.6,-0.5,-0.6,0.6,1.0,0.6}},
  selection_box = {type="fixed", fixed={-0.6,-0.5,-0.6,0.6,1.0,0.6}},
  
  on_timer = function(pos)
    well_set_water(pos)
  end,
  
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    meta:set_int("water", 0)
    meta:set_string("infotext", "Well water: (0)")
    minetest.get_node_timer(pos):start(fill_time)
  end,

  on_rightclick = well_set_water,
})


minetest.register_craft({
  output = "irrigation:well",
  recipe = {
    {"group:wood",     "group:wood",  "group:wood"},
    {"default:stone",  "",            "default:stone"},
    {"default:cobble", "",            "default:cobble"}
  }
})
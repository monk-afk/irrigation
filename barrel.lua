local S = minetest.get_translator("irrigation")

local drain_time = 3600.0

local function water_level(i)
  return {
    {0,  0, 0,  16, 16, 1},
    {0,  0, 15, 16, 16, 1},
    {0,  0, 0,  1,  16, 16},
    {15, 0, 0,  1,  16, 16},
    {0,  0, 0,  16, i,  16}
  }
end

local set_nodebox = function(size, boxes)
  local fixed = {}
  for _, box in ipairs(boxes) do
    local x, y, z, w, h, l = unpack(box)
    fixed[#fixed + 1] = {
      (x / size) - 0.5,
      (y / size) - 0.5,
      (z / size) - 0.5,
      ((x + w) / size) - 0.5,
      ((y + h) / size) - 0.5,
      ((z + l) / size) - 0.5
    }
  end
  return {type = "fixed", fixed = fixed}
end

local function barrel_set_water(pos, node, clicker, itemstack, pointed_thing)
  if not pos then return end
  local meta = minetest.get_meta(pos)
  local water_level = (meta:get_int("water") or 0)
  local barrel_type = "irrigation:water_barrel"

  if (clicker and clicker:is_player()) and itemstack then
    local inv = clicker:get_inventory()
    local wield_item = clicker:get_wielded_item():get_name()
    if wield_item == "bucket:bucket_water" or wield_item == "bucket:bucket_river_water" then
      water_level = water_level + 1
      if water_level <= 3 then
        if minetest.get_node_timer(pos):is_started() then
          minetest.get_node_timer(pos):stop()
        end
        minetest.set_node(pos, {name = barrel_type.."_holding_"..water_level})
        minetest.get_node_timer(pos):start(drain_time)
        itemstack:replace("bucket:bucket_empty")
      end
    end
    return itemstack
  else
    water_level = water_level - 1
    if water_level > 0 then
      barrel_type = barrel_type.."_holding_"..water_level
      minetest.set_node(pos, {name = barrel_type})
      minetest.get_node_timer(pos):start(drain_time)
      return
    else
      minetest.set_node(pos, {name = barrel_type})
      minetest.get_node_timer(pos):stop()
      return
    end
  end
end

minetest.register_node("irrigation:water_barrel", {
  drawtype = "nodebox",
  paramtype = "light",
  backface_culling = true,
  short_description = S("Water Barrel"),
  description = "Supplies water to soil up to 4 hours",
  groups = {choppy = 3},
  tiles = {"irrigation_barrel_top.png", "irrigation_barrel_bottom.png", "irrigation_barrel_sides.png"},
  collision_box = set_nodebox(16, water_level(1)),
  node_box = set_nodebox(16, water_level(1)),

  on_rightclick = barrel_set_water,
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("infotext", "Water Barrel (empty)")
    if minetest.get_node_timer(pos):is_started() then
      minetest.get_node_timer(pos):stop()
    end
  end,
})

for i = 1,3 do
  local node_def = {
    drawtype = "nodebox",
    paramtype = "light",
    backface_culling = true,
    description = S("Water Barrel"),
    groups = {choppy = 3, water = 1, not_in_creative_inventory = 1},
    tiles = {"irrigation_barrel_top_water.png", "irrigation_barrel_bottom.png", "irrigation_barrel_sides.png"},
    drop = "irrigation:water_barrel",
    
    collision_box = set_nodebox(16, water_level(1)),
    node_box = set_nodebox(16, water_level(i * 5)),

    on_rightclick = barrel_set_water,
    on_construct =  function(pos)
      local meta = minetest.get_meta(pos)
      meta:set_int("water", i)
      meta:set_string("infotext", "Water Barrel ("..i..")")
    end,
    on_timer = barrel_set_water,
    
    on_destruct = function(pos)
      minetest.get_node_timer(pos):stop()
    end,
  }
  minetest.register_node("irrigation:water_barrel_holding_"..i, node_def)
end


minetest.register_craft({
  output = "irrigation:water_barrel",
  recipe = {
    {"group:wood",        "",		    		"group:wood"},
    {"default:iron_lump", "",   				"default:iron_lump"},
    {"group:wood",        "group:wood",	"group:wood"}
  }
})
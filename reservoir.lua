local S = minetest.get_translator("irrigation")

local drain_time = 3600.0  -- drain time per water_level

local floor = math.floor
local function level_percent(water_level)
  return floor((water_level / 63) * 100)
end

local meta = minetest.get_meta

local function place_reservoir(pos, reservoir_type, water_level, start_drain)
  minetest.set_node(pos, {name = reservoir_type, param2 = water_level})
  local meta = meta(pos)
  meta:set_int("water", water_level)
  meta:set_string("infotext", "Water Reservoir ("..level_percent((water_level or 0)).."%)")

  if start_drain then
    minetest.get_node_timer(pos):start(drain_time)
  else
    minetest.get_node_timer(pos):stop()
  end
end

local function reservoir_set_water(pos, node, clicker, itemstack, pointed_thing)
  if not pos then return end
  local water_level = (meta(pos):get_int("water") or 0)
  local reservoir_type = "irrigation:water_reservoir"

  if (clicker and clicker:is_player()) and itemstack then
    local inv = clicker:get_inventory()
    local wield_item = clicker:get_wielded_item():get_name()

    if wield_item == "bucket:bucket_water" or wield_item == "bucket:bucket_river_water" then
      water_level = math.min(water_level + 16, 63)  -- 4 water buckets to fill reservoir
    
      if water_level <= 63 then
        if minetest.get_node_timer(pos):is_started() then
          minetest.get_node_timer(pos):stop()
        end

        place_reservoir(pos, reservoir_type.."_holding", water_level, true)
        itemstack:replace("bucket:bucket_empty")
      end
    end
    return itemstack

  else
    -- Eight water levels, 60 minutes per level, 8 hours of water on a full tank
    water_level = water_level - 8

    if water_level > 0 then
      place_reservoir(pos, reservoir_type.."_holding", water_level, true)
      return
    else
      water_level = 0
      place_reservoir(pos, reservoir_type, water_level, false)
      return
    end
  end
end


minetest.register_node("irrigation:water_reservoir_holding", {
  drawtype = "glasslike_framed",
  paramtype2 = "glasslikeliquidlevel",
  backface_culling = false,
  short_description = S("Water Reservoir"),
  description = S("Waters soil for up to 8 hours"),
  groups = {cracky = 3, water = 1, not_in_creative_inventory = 1},
  tiles = {"irrigation_reservoir.png"},
  drop = "irrigation:water_reservoir",
  use_texture_alpha = "blend",
  special_tiles = {minetest.registered_nodes["default:water_source"].tiles[1]},
  on_rightclick = reservoir_set_water,
  on_timer = reservoir_set_water,
  on_destruct = function(pos)
    minetest.get_node_timer(pos):stop()
  end,
})

minetest.register_node("irrigation:water_reservoir", {
  drawtype = "glasslike_framed",
  paramtype2 = "glasslikeliquidlevel",
  backface_culling = false,
  short_description = S("Water Reservoir"),
  description = S("Waters soil for up to 8 hours"),
  groups = {cracky = 3},
  tiles = {"irrigation_reservoir.png"},
  drop = "irrigation:water_reservoir",
  use_texture_alpha = "blend",
  on_rightclick = reservoir_set_water,
})

minetest.register_craft({
	output = "irrigation:water_reservoir",
	recipe = {
		{"group:glass", 			"",			      	"group:glass"},
		{"default:iron_lump",	"",		      		"default:iron_lump"},
		{"group:glass",	  		"group:glass",	"group:glass"}
	}
})